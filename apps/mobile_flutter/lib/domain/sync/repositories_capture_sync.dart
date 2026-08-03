part of 'repositories.dart';

extension SyncRepositoryCaptures on SyncRepository {
  Future<List<Dish>> processPendingCaptures() async {
    final ProcessingOutboxRepository outbox =
        ProcessingOutboxRepository(_database);
    final List<ProcessingOutboxRequest> requests = await outbox.listRequests();
    for (final ProcessingOutboxRequest request in requests) {
      if (request.kind != ProcessingRequestKind.captureGrouping ||
          request.deliveryState == ProcessingDeliveryState.acknowledged) {
        continue;
      }
      if (request.deliveryState == ProcessingDeliveryState.canceled) {
        if (request.serverJobId != null) {
          try {
            await _apiClient
                .cancelProcessingJob(jobId: request.serverJobId!)
                .timeout(_controlRequestTimeout);
            await outbox.clearServerJob(request.id);
          } on Object catch (error) {
            _logSync(
              'processing cancel unavailable requestId=${request.id} '
              'code=${_processingErrorCode(error)}',
            );
          }
        }
        continue;
      }
      if (request.deliveryState == ProcessingDeliveryState.expired) {
        continue;
      }
      await _resumeCaptureGrouping(outbox, request);
    }
    return const <Dish>[];
  }

  Future<void> _resumeCaptureGrouping(
    ProcessingOutboxRepository outbox,
    ProcessingOutboxRequest initial,
  ) async {
    ProcessingOutboxRequest request = initial;
    if (request.deliveryState == ProcessingDeliveryState.pendingUpload ||
        request.deliveryState == ProcessingDeliveryState.uploading) {
      if (!await outbox.claimForUpload(request.id)) {
        return;
      }
      try {
        final List<db.CaptureItemRow> captures =
            await _activeItemsForBatch(request.subjectId);
        final ApiProcessingJob job = await _apiClient
            .createProcessingJob(
              operation: request.kind.databaseValue,
              idempotencyKey: request.idempotencyKey,
              inputSchemaVersion: 'capture-grouping-input-v1',
              resultSchemaVersion: 'capture-grouping-result-v1',
              privacyNoticeVersion: request.privacyNoticeVersion!,
              assets: await _assetManifest(captures),
            )
            .timeout(_controlRequestTimeout);
        await outbox.recordServerJob(
          requestId: request.id,
          serverJobId: job.id,
          expiresAt: job.expiresAt,
        );
        await _markBatchStatus(
          request.subjectId,
          CaptureBatchStatus.uploading,
        );
        request = (await outbox.requestForSubject(
          kind: request.kind,
          subjectId: request.subjectId,
        ))!;
        await _uploadProcessingAssets(outbox, request, job, captures);
        await _apiClient
            .submitProcessingJob(
              jobId: job.id,
              input: await _captureGroupingInput(captures),
            )
            .timeout(_controlRequestTimeout);
        await outbox.markSubmitted(request.id);
        await _markCapturesClassifying(request.subjectId);
        request = (await outbox.requestForSubject(
          kind: request.kind,
          subjectId: request.subjectId,
        ))!;
      } on Object catch (error) {
        final String code = _processingErrorCode(error);
        _logSync(
          'processing transition failed requestId=${request.id} code=$code',
        );
        if (_isConnectivityError(error)) {
          await _markBatchStatus(
            request.subjectId,
            CaptureBatchStatus.pendingUpload,
            failureReason: captureWaitingForConnectionReason,
          );
          await _markCapturesPending(request.subjectId);
        } else {
          final String reason = _processingFailureReason(code);
          await outbox.markFailed(request.id, failureCode: code);
          await _markBatchStatus(
            request.subjectId,
            CaptureBatchStatus.failed,
            failureReason: reason,
          );
          await _markCapturesFailed(request.subjectId, reason);
        }
        return;
      }
    }

    if (request.deliveryState != ProcessingDeliveryState.submitted ||
        request.serverJobId == null) {
      return;
    }
    try {
      final ApiProcessingJob job = await _apiClient
          .getProcessingJob(jobId: request.serverJobId!)
          .timeout(_controlRequestTimeout);
      if (job.status == 'expired') {
        await outbox.markExpired(request.id);
        return;
      }
      if (job.status == 'acknowledged' && request.resultPayload != null) {
        await outbox.markAcknowledged(request.id);
        return;
      }
      if (job.status == 'failed') {
        await outbox.markFailed(
          request.id,
          failureCode: job.errorCode ?? 'processing_failed',
        );
        await _markBatchStatus(
          request.subjectId,
          CaptureBatchStatus.failed,
          failureReason: job.errorCode ?? 'Processing failed.',
        );
        await _markCapturesFailed(
          request.subjectId,
          job.errorCode ?? 'Processing failed.',
        );
        return;
      }
      if (job.status != 'succeeded') {
        return;
      }
      final Map<String, Object?> result = await _apiClient
          .downloadProcessingResult(jobId: job.id)
          .timeout(_controlRequestTimeout);
      _validateCaptureGroupingResult(
        request,
        result,
        schemaVersion: job.resultSchemaVersion,
      );
      await outbox.storeResult(
        requestId: request.id,
        result: result,
        schemaVersion: job.resultSchemaVersion,
      );
      await _apiClient
          .acknowledgeProcessingJob(jobId: job.id)
          .timeout(_controlRequestTimeout);
      await outbox.markAcknowledged(request.id);
    } on Object catch (error) {
      _logSync(
        'processing result unavailable requestId=${request.id} '
        'code=${_processingErrorCode(error)}',
      );
    }
  }

  Future<List<db.CaptureItemRow>> _activeItemsForBatch(String batchId) {
    return (_database.select(_database.captureItems)
          ..where(
            (db.CaptureItems table) =>
                table.batchId.equals(batchId) &
                table.status
                    .equals(capture_domain.CaptureItemStatus.discarded.name)
                    .not(),
          )
          ..orderBy(<OrderingTerm Function(db.$CaptureItemsTable)>[
            (db.$CaptureItemsTable table) => OrderingTerm.asc(table.ordinal),
          ]))
        .get();
  }

  Future<List<ApiProcessingAssetManifest>> _assetManifest(
    List<db.CaptureItemRow> captures,
  ) async {
    final List<ApiProcessingAssetManifest> assets =
        <ApiProcessingAssetManifest>[];
    for (final db.CaptureItemRow capture in captures) {
      final String? path = capture.localMediaRef;
      if (capture.kind != capture_domain.CaptureItemKind.photo.name ||
          path == null) {
        continue;
      }
      assets.add(
        ApiProcessingAssetManifest(
          assetId: capture.id,
          contentType: _processingContentType(path),
          byteSize: await File(path).length(),
        ),
      );
    }
    return assets;
  }

  Future<void> _uploadProcessingAssets(
    ProcessingOutboxRepository outbox,
    ProcessingOutboxRequest request,
    ApiProcessingJob job,
    List<db.CaptureItemRow> captures,
  ) async {
    for (final ApiProcessingUploadTarget target in job.uploadTargets) {
      if (request.uploadedAssetIds.contains(target.assetId)) {
        continue;
      }
      final db.CaptureItemRow capture = captures.firstWhere(
        (db.CaptureItemRow item) => item.id == target.assetId,
      );
      await _apiClient.uploadProcessingAsset(
        target: target,
        localPath: capture.localMediaRef!,
      );
      await outbox.markAssetUploaded(request.id, target.assetId);
      await _markCaptureStatus(
        target.assetId,
        capture_domain.CaptureItemStatus.uploaded,
      );
    }
  }

  Future<Map<String, Object?>> _captureGroupingInput(
    List<db.CaptureItemRow> captures,
  ) async {
    final List<db.DishRow> dishes =
        await _database.select(_database.dishes).get();
    final List<db.DishNoteRow> notes =
        await _database.select(_database.dishNotes).get();
    return <String, Object?>{
      'captures': captures
          .map(
            (db.CaptureItemRow capture) => <String, Object?>{
              'id': capture.id,
              'kind': capture.kind,
              'ordinal': capture.ordinal,
              'capturedAt': capture.capturedAt?.toUtc().toIso8601String(),
              'capturedLocalDate': capture.capturedLocalDate,
              'ideaText': capture.ideaText,
              if (capture.kind == capture_domain.CaptureItemKind.photo.name)
                'assetId': capture.id,
            },
          )
          .toList(growable: false),
      'dishes': dishes
          .map(
            (db.DishRow dish) => <String, Object?>{
              'localId': dish.id,
              'title': dish.title,
              'description': dish.description,
              'ingredients': _jsonStringList(dish.ingredientsJson),
              'recipeSteps': _jsonStringList(dish.recipeStepsJson),
              'notes': notes
                  .where((db.DishNoteRow note) => note.dishId == dish.id)
                  .map((db.DishNoteRow note) => note.body)
                  .toList(growable: false),
            },
          )
          .toList(growable: false),
    };
  }

  void _validateCaptureGroupingResult(
    ProcessingOutboxRequest request,
    Map<String, Object?> result, {
    required String schemaVersion,
  }) {
    if (result['operation'] != request.kind.databaseValue ||
        result['schemaVersion'] != schemaVersion ||
        result['groups'] is! List<Object?> ||
        result['rejectedCaptures'] is! List<Object?>) {
      throw const FormatException('Invalid capture grouping proposal.');
    }
    final Set<String> expected =
        (request.payload['captureIds']! as List<Object?>)
            .whereType<String>()
            .toSet();
    final List<String> decisions = <String>[];
    for (final Object? value in result['groups']! as List<Object?>) {
      final Map<String, Object?> group =
          Map<String, Object?>.from(value! as Map<String, Object?>);
      decisions.addAll(
        (group['captureIds']! as List<Object?>).whereType<String>(),
      );
    }
    for (final Object? value in result['rejectedCaptures']! as List<Object?>) {
      final Map<String, Object?> rejected =
          Map<String, Object?>.from(value! as Map<String, Object?>);
      decisions.add(rejected['captureId']! as String);
    }
    if (decisions.length != decisions.toSet().length ||
        decisions.toSet().difference(expected).isNotEmpty ||
        expected.difference(decisions.toSet()).isNotEmpty) {
      throw const FormatException(
        'Capture grouping proposal must exactly partition the input.',
      );
    }
  }

  Future<void> _markCapturesClassifying(String batchId) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.batchId.equals(batchId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(
          capture_domain.CaptureItemStatus.classifying.name,
        ),
      ),
    );
    await (_database.update(_database.captureBatches)
          ..where((db.CaptureBatches table) => table.id.equals(batchId)))
        .write(
      db.CaptureBatchesCompanion(
        status: Value<String>(CaptureBatchStatus.processing.name),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> _markCaptureStatus(
    String captureId,
    capture_domain.CaptureItemStatus status,
  ) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(captureId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(status.name),
        failureReason: const Value<String?>(null),
      ),
    );
  }

  Future<void> _markCapturesPending(String batchId) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.batchId.equals(batchId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(
          capture_domain.CaptureItemStatus.pendingUpload.name,
        ),
        failureReason: const Value<String?>(null),
      ),
    );
  }

  Future<void> _markCapturesFailed(String batchId, String reason) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.batchId.equals(batchId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(capture_domain.CaptureItemStatus.failed.name),
        failureReason: Value<String?>(reason),
      ),
    );
  }

  Future<void> _markBatchStatus(
    String batchId,
    CaptureBatchStatus status, {
    String? failureReason,
  }) async {
    await (_database.update(_database.captureBatches)
          ..where((db.CaptureBatches table) => table.id.equals(batchId)))
        .write(
      db.CaptureBatchesCompanion(
        status: Value<String>(status.name),
        updatedAt: Value<DateTime>(DateTime.now()),
        failureReason: Value<String?>(failureReason),
      ),
    );
  }
}
