part of 'repositories.dart';

extension SyncRepositoryCovers on SyncRepository {
  Future<void> processPendingCovers() async {
    final ProcessingOutboxRepository outbox =
        ProcessingOutboxRepository(_database);
    final List<ProcessingOutboxRequest> requests = await outbox.listRequests()
      ..sort((ProcessingOutboxRequest left, ProcessingOutboxRequest right) {
        final bool leftManual =
            left.payload['origin'] == CoverOrigin.manual.name;
        final bool rightManual =
            right.payload['origin'] == CoverOrigin.manual.name;
        if (leftManual != rightManual) return leftManual ? -1 : 1;
        final String? leftBatch =
            left.payload['automaticCaptureBatchId'] as String?;
        final String? rightBatch =
            right.payload['automaticCaptureBatchId'] as String?;
        if (!leftManual && leftBatch != null && leftBatch == rightBatch) {
          final int leftOrdinal =
              left.payload['automaticCaptureOrdinal'] as int? ?? 1 << 30;
          final int rightOrdinal =
              right.payload['automaticCaptureOrdinal'] as int? ?? 1 << 30;
          final int byOrdinal = leftOrdinal.compareTo(rightOrdinal);
          if (byOrdinal != 0) return byOrdinal;
        }
        final int byCreatedAt = left.createdAt.compareTo(right.createdAt);
        return byCreatedAt != 0 ? byCreatedAt : left.id.compareTo(right.id);
      });
    bool automaticChainWaiting = false;
    for (final ProcessingOutboxRequest request in requests) {
      if (request.kind != ProcessingRequestKind.coverGeneration) {
        continue;
      }
      if (request.deliveryState == ProcessingDeliveryState.canceled) {
        await _cancelCoverJob(outbox, request);
        continue;
      }
      if (<ProcessingDeliveryState>{
        ProcessingDeliveryState.acknowledged,
        ProcessingDeliveryState.failed,
        ProcessingDeliveryState.expired,
      }.contains(request.deliveryState)) {
        continue;
      }
      final bool automatic =
          request.payload['origin'] == CoverOrigin.automatic.name;
      if (automatic && automaticChainWaiting) continue;
      await _resumeCoverGeneration(outbox, request);
      if (automatic) {
        final ProcessingOutboxRequest? current = await outbox.requestForSubject(
          kind: request.kind,
          subjectId: request.subjectId,
        );
        automaticChainWaiting = current != null &&
            <ProcessingDeliveryState>{
              ProcessingDeliveryState.pendingUpload,
              ProcessingDeliveryState.uploading,
              ProcessingDeliveryState.submitted,
            }.contains(current.deliveryState);
      }
    }
  }

  Future<void> _resumeCoverGeneration(
    ProcessingOutboxRepository outbox,
    ProcessingOutboxRequest initial,
  ) async {
    ProcessingOutboxRequest request = initial;
    try {
      if (request.deliveryState == ProcessingDeliveryState.pendingUpload ||
          request.deliveryState == ProcessingDeliveryState.uploading) {
        if (!await outbox.claimForUpload(request.id)) {
          return;
        }
        final Map<String, String> assets =
            await _coverProcessingAssets(request);
        final ApiProcessingJob job = await _apiClient
            .createProcessingJob(
              operation: request.kind.databaseValue,
              idempotencyKey: request.idempotencyKey,
              inputSchemaVersion: 'cover-generation-input-v1',
              resultSchemaVersion: 'cover-generation-result-v1',
              privacyNoticeVersion: request.privacyNoticeVersion!,
              assets: await _assetManifest(assets),
            )
            .timeout(_controlRequestTimeout);
        await outbox.recordServerJob(
          requestId: request.id,
          serverJobId: job.id,
          expiresAt: job.expiresAt,
        );
        request = (await outbox.requestForSubject(
          kind: request.kind,
          subjectId: request.subjectId,
        ))!;
        if (request.deliveryState == ProcessingDeliveryState.canceled) {
          await _cancelCoverJob(outbox, request);
          return;
        }
        if (!await _uploadCoverAssets(outbox, request, job, assets)) return;
        request = (await outbox.requestForSubject(
          kind: request.kind,
          subjectId: request.subjectId,
        ))!;
        if (request.deliveryState == ProcessingDeliveryState.canceled) {
          await _cancelCoverJob(outbox, request);
          return;
        }
        await _apiClient
            .submitProcessingJob(
              jobId: job.id,
              input: _coverProcessingInput(request),
            )
            .timeout(_controlRequestTimeout);
        await outbox.markSubmitted(request.id);
        request = (await outbox.requestForSubject(
          kind: request.kind,
          subjectId: request.subjectId,
        ))!;
      }

      if (request.deliveryState != ProcessingDeliveryState.submitted ||
          request.serverJobId == null) {
        return;
      }
      final ApiProcessingJob job = await _apiClient
          .getProcessingJob(jobId: request.serverJobId!)
          .timeout(_controlRequestTimeout);
      if (job.status == 'expired') {
        await outbox.markExpired(request.id);
        return;
      }
      if (job.status == 'failed') {
        await outbox.markFailed(
          request.id,
          failureCode: job.errorCode ?? 'cover_generation_failed',
        );
        return;
      }
      if (job.status == 'acknowledged' && request.resultPayload != null) {
        await outbox.markAcknowledged(request.id);
        return;
      }
      if (job.status != 'succeeded') {
        return;
      }
      final Map<String, Object?> result = await _apiClient
          .downloadProcessingResult(jobId: job.id)
          .timeout(_controlRequestTimeout);
      _validateCoverResult(request, result, job.resultSchemaVersion);
      final GeneratedCover? existing =
          await CoverRepository(_database).findById(request.id);
      if (existing == null) {
        if (!await _coverSourcesStillBelongToDish(request)) {
          await _apiClient.cancelProcessingJob(jobId: job.id);
          await outbox.markFailed(
            request.id,
            failureCode: 'source_set_changed',
          );
          return;
        }
        if (!await _automaticCoverSnapshotStillCurrent(request)) {
          await _apiClient.cancelProcessingJob(jobId: job.id);
          await outbox.markFailed(request.id, failureCode: 'cover_changed');
          return;
        }
        final String localPath = await _materializeGeneratedCover(
          request,
          result,
        );
        await _database.transaction(() async {
          await _storeDeliveredCover(request, result, localPath);
          await outbox.storeResult(
            requestId: request.id,
            result: result,
            schemaVersion: job.resultSchemaVersion,
          );
        });
      } else {
        await outbox.storeResult(
          requestId: request.id,
          result: result,
          schemaVersion: job.resultSchemaVersion,
        );
      }
      await _apiClient
          .acknowledgeProcessingJob(jobId: job.id)
          .timeout(_controlRequestTimeout);
      await outbox.markAcknowledged(request.id);
      if (request.payload['origin'] == CoverOrigin.automatic.name) {
        await outbox.markAdopted(request.id);
      }
      await _deleteProcessingAssets(request.id);
    } on Object catch (error) {
      if (_isConnectivityError(error)) {
        return;
      }
      await outbox.markFailed(
        request.id,
        failureCode: _processingErrorCode(error),
      );
      _logSync(
        'cover processing failed requestId=${request.id} '
        'code=${_processingErrorCode(error)}',
      );
    }
  }

  Future<Map<String, String>> _coverProcessingAssets(
    ProcessingOutboxRequest request,
  ) async {
    final List<String> sourceIds = _payloadStringList(
      request.payload,
      'sourceIds',
    );
    if (sourceIds.isEmpty) {
      return const <String, String>{};
    }
    final List<db.SourcePhotoRow> rows = await (_database.select(
      _database.sourcePhotos,
    )..where(
            (db.SourcePhotos table) =>
                table.id.isIn(sourceIds) &
                table.dishId.equals(request.subjectId),
          ))
        .get();
    if (rows.length != sourceIds.length) {
      throw const FormatException('The selected Source set changed.');
    }
    final Map<String, String> assets = <String, String>{};
    for (final String sourceId in sourceIds) {
      final db.SourcePhotoRow source =
          rows.firstWhere((db.SourcePhotoRow row) => row.id == sourceId);
      final ImageDerivativeSet previews = await _imageDerivativeStore.ensureSet(
        key: 'cover_source_${source.id}',
        sourcePath: source.url,
        existingProcessingRef: source.previewUrl,
        existingCardRef: source.thumbnailUrl,
        existingPlaceholderRef: source.placeholderUrl,
      );
      final String? path = previews.processingRef;
      if (path == null) {
        throw FileSystemException(
            'The selected Source is unavailable.', source.url);
      }
      assets[_coverAssetId(request.id, source.id)] = path;
    }
    return assets;
  }

  Future<bool> _uploadCoverAssets(
    ProcessingOutboxRepository outbox,
    ProcessingOutboxRequest request,
    ApiProcessingJob job,
    Map<String, String> assets,
  ) async {
    for (final ApiProcessingUploadTarget target in job.uploadTargets) {
      final ProcessingOutboxRequest? current = await outbox.requestForSubject(
        kind: request.kind,
        subjectId: request.subjectId,
      );
      if (current == null) return false;
      if (current.deliveryState == ProcessingDeliveryState.canceled) {
        await _cancelCoverJob(outbox, current);
        return false;
      }
      if (request.uploadedAssetIds.contains(target.assetId)) {
        continue;
      }
      final String? path = assets[target.assetId];
      if (path == null) {
        throw FileSystemException(
            'Cover processing asset unavailable.', target.assetId);
      }
      await _apiClient.uploadProcessingAsset(target: target, localPath: path);
      await outbox.markAssetUploaded(request.id, target.assetId);
    }
    return true;
  }

  Map<String, Object?> _coverProcessingInput(ProcessingOutboxRequest request) {
    final List<String> sourceIds = _payloadStringList(
      request.payload,
      'sourceIds',
    );
    return <String, Object?>{
      'dishTitle': request.payload['dishTitle'],
      'sources': sourceIds
          .map(
            (String id) => <String, Object?>{
              'id': id,
              'assetId': _coverAssetId(request.id, id),
            },
          )
          .toList(growable: false),
      'notes': request.payload['notes'],
      'treatment': request.payload['treatment'],
      'origin': request.payload['origin'],
      'contractVersion': request.payload['contractVersion'],
    };
  }

  String _coverAssetId(String requestId, String sourceId) {
    return const Uuid().v5(requestId, sourceId);
  }

  void _validateCoverResult(
    ProcessingOutboxRequest request,
    Map<String, Object?> result,
    String schemaVersion,
  ) {
    if (result['operation'] !=
            ProcessingRequestKind.coverGeneration.databaseValue ||
        result['schemaVersion'] != schemaVersion ||
        result['proposalId'] is! String ||
        result['output'] is! Map<String, Object?> ||
        result['validation'] is! Map<String, Object?>) {
      throw const FormatException('Invalid Cover result.');
    }
    final Map<String, Object?> validation =
        result['validation']! as Map<String, Object?>;
    final num confidence = validation['confidence'] as num? ?? 0;
    final bool automatic =
        request.payload['origin'] == CoverOrigin.automatic.name;
    if (validation['valid'] != true || (automatic && confidence < 0.9)) {
      throw const FormatException('Cover validation failed.');
    }
  }

  Future<bool> _coverSourcesStillBelongToDish(
    ProcessingOutboxRequest request,
  ) async {
    final List<String> sourceIds = _payloadStringList(
      request.payload,
      'sourceIds',
    );
    if (sourceIds.isEmpty) {
      return true;
    }
    final List<db.SourcePhotoRow> rows = await (_database.select(
      _database.sourcePhotos,
    )..where(
            (db.SourcePhotos table) =>
                table.id.isIn(sourceIds) &
                table.dishId.equals(request.subjectId),
          ))
        .get();
    return rows.length == sourceIds.length;
  }

  Future<bool> _automaticCoverSnapshotStillCurrent(
    ProcessingOutboxRequest request,
  ) async {
    if (request.payload['origin'] != CoverOrigin.automatic.name) {
      return true;
    }
    final Object? rawSnapshot = request.payload['coverSnapshot'];
    if (rawSnapshot is! Map<String, Object?>) {
      return false;
    }
    final db.DishRow? dish = await (_database.select(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(request.subjectId)))
        .getSingleOrNull();
    return dish != null &&
        dish.heroImageUrl == rawSnapshot['image'] &&
        dish.heroPreviewUrl == rawSnapshot['preview'] &&
        dish.heroThumbnailUrl == rawSnapshot['thumbnail'] &&
        dish.heroPlaceholderUrl == rawSnapshot['placeholder'];
  }
}
