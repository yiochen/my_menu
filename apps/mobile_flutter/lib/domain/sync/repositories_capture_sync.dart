part of 'repositories.dart';

extension SyncRepositoryCaptures on SyncRepository {
  Future<List<Dish>> processPendingCaptures() async {
    final List<db.CaptureBatchRow> batches =
        await (_database.select(_database.captureBatches)
              ..where(
                (db.$CaptureBatchesTable table) =>
                    table.status.equals(CaptureBatchStatus.pendingUpload.name) |
                    table.status.equals(CaptureBatchStatus.uploading.name) |
                    table.status.equals(CaptureBatchStatus.readyForAi.name) |
                    table.status.equals(CaptureBatchStatus.failed.name),
              )
              ..orderBy(<OrderingTerm Function(db.$CaptureBatchesTable)>[
                (db.$CaptureBatchesTable table) =>
                    OrderingTerm.asc(table.createdAt),
              ]))
            .get();
    _logSync('processPendingCaptureBatches count=${batches.length}');
    for (final db.CaptureBatchRow batch in batches) {
      await _processPhotoBatch(batch);
    }
    return const <Dish>[];
  }

  Future<void> _processPhotoBatch(db.CaptureBatchRow batch) async {
    final ProcessingOutboxRepository outbox =
        ProcessingOutboxRepository(_database);
    final ProcessingOutboxRequest? request = await outbox.requestForSubject(
      kind: ProcessingRequestKind.captureGrouping,
      subjectId: batch.id,
    );
    if (request == null || !await outbox.claimForUpload(request.id)) {
      return;
    }
    final List<db.CaptureItemRow> initialItems = await _itemsForBatch(batch.id);
    final List<db.CaptureItemRow> photoItems = initialItems
        .where(
          (db.CaptureItemRow item) =>
              item.kind == capture_domain.CaptureItemKind.photo.name &&
              item.status != capture_domain.CaptureItemStatus.discarded.name,
        )
        .toList(growable: false);
    if (photoItems.isEmpty) {
      if (initialItems.length == 1 &&
          initialItems.single.kind ==
              capture_domain.CaptureItemKind.idea.name) {
        await _finalizeCaptureBatch(batch, initialItems.single);
        await outbox.markSubmitted(request.id);
      }
      return;
    }

    try {
      await _apiClient
          .upsertCaptureBatch(
            batchId: batch.id,
            itemCount: photoItems.length,
            createdAt: batch.createdAt,
          )
          .timeout(_controlRequestTimeout);
      await _markBatchStatus(batch.id, CaptureBatchStatus.uploading);
    } on Object catch (error, stackTrace) {
      _logSync('batch upsert failed id=${batch.id}', error, stackTrace);
      await _markBatchStatus(
        batch.id,
        _isConnectivityError(error)
            ? CaptureBatchStatus.pendingUpload
            : CaptureBatchStatus.failed,
        failureReason: _isConnectivityError(error)
            ? captureWaitingForConnectionReason
            : error.toString(),
      );
      return;
    }

    await _uploadPendingPhotos(batch, photoItems);
    final List<db.CaptureItemRow> activePhotos =
        (await _itemsForBatch(batch.id))
            .where(
              (db.CaptureItemRow item) =>
                  item.kind == capture_domain.CaptureItemKind.photo.name &&
                  item.status !=
                      capture_domain.CaptureItemStatus.discarded.name,
            )
            .toList(growable: false);
    final bool allUploaded = activePhotos.isNotEmpty &&
        activePhotos.every(
          (db.CaptureItemRow item) => item.remoteMediaRef != null,
        );
    if (!allUploaded) {
      if (activePhotos.any(
        (db.CaptureItemRow item) =>
            item.remoteMediaRef == null &&
            item.status == capture_domain.CaptureItemStatus.pendingUpload.name,
      )) {
        await _markBatchStatus(
          batch.id,
          CaptureBatchStatus.pendingUpload,
          failureReason: captureWaitingForConnectionReason,
        );
      }
      return;
    }

    try {
      await _markBatchStatus(batch.id, CaptureBatchStatus.readyForAi);
      await _finalizeCaptureBatch(batch, activePhotos.first);
      await outbox.markSubmitted(request.id);
    } on Object catch (error, stackTrace) {
      _logSync('batch finalize failed id=${batch.id}', error, stackTrace);
      if (!_isConnectivityError(error)) {
        await outbox.markFailed(request.id);
        await _markBatchStatus(
          batch.id,
          CaptureBatchStatus.failed,
          failureReason: error.toString(),
        );
      }
    }
  }

  Future<void> _uploadPendingPhotos(
    db.CaptureBatchRow batch,
    List<db.CaptureItemRow> photoItems,
  ) async {
    for (final db.CaptureItemRow item in photoItems) {
      if (item.remoteMediaRef != null) {
        continue;
      }
      if (item.status == capture_domain.CaptureItemStatus.failed.name &&
          !_isInterruptedSignedUpload(item.failureReason)) {
        continue;
      }
      final String? localMediaRef = item.localMediaRef;
      if (localMediaRef == null) {
        await _markCaptureFailed(item.id, 'Missing local photo.');
        continue;
      }
      await _markCaptureStatus(
        item.id,
        capture_domain.CaptureItemStatus.uploading,
      );
      try {
        final String remoteMediaRef =
            await _apiClient.uploadCaptureMediaWithMetadata(
          captureId: item.id,
          batchId: batch.id,
          ordinal: item.ordinal,
          localMediaRef: localMediaRef,
          capturedAt: item.capturedAt ?? item.createdAt,
          capturedLocalDate: item.capturedLocalDate,
          captureDateSource: item.captureDateSource ?? 'unknown',
        );
        await _markCaptureStatus(
          item.id,
          capture_domain.CaptureItemStatus.uploaded,
          remoteMediaRef: remoteMediaRef,
        );
      } on Object catch (error, stackTrace) {
        _logSync('capture upload failed id=${item.id}', error, stackTrace);
        if (_isConnectivityError(error)) {
          await _markCaptureStatus(
            item.id,
            capture_domain.CaptureItemStatus.pendingUpload,
          );
        } else {
          await _markCaptureFailed(item.id, error.toString());
        }
      }
    }
  }

  Future<void> _finalizeCaptureBatch(
    db.CaptureBatchRow batch,
    db.CaptureItemRow representative,
  ) async {
    final db.AiJobRow? job = await (_database.select(_database.aiJobs)
          ..where(
            (db.AiJobs table) =>
                table.subjectId.equals(batch.id) &
                table.jobType.equals(AiJobType.batchGrouping.apiValue),
          )
          ..orderBy(<OrderingTerm Function(db.$AiJobsTable)>[
            (db.$AiJobsTable table) => OrderingTerm.desc(table.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
    if (job == null) {
      throw StateError('Capture batch ${batch.id} has no grouping job.');
    }

    final ApiAiJob remote = await _apiClient
        .finalizeCaptureBatch(
          batchId: batch.id,
          kind: representative.kind,
          ideaText: representative.ideaText,
          capturedAt: representative.capturedAt ?? representative.createdAt,
          capturedLocalDate: representative.capturedLocalDate,
          captureDateSource: representative.captureDateSource ?? 'unknown',
          jobId: job.id,
          idempotencyKey: job.idempotencyKey,
          inputHash: job.inputHash,
          inputVersion: job.inputVersion,
          maxAttempts: job.maxAttempts,
        )
        .timeout(_controlRequestTimeout);
    await _upsertAiJob(remote, localJobId: job.id);
    await _markBatchStatus(batch.id, CaptureBatchStatus.processing);
    await (_database.update(_database.captureItems)
          ..where(
            (db.CaptureItems table) => table.batchId.equals(batch.id),
          ))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(
          capture_domain.CaptureItemStatus.classifying.name,
        ),
      ),
    );
  }

  Future<List<db.CaptureItemRow>> _itemsForBatch(String batchId) {
    return (_database.select(_database.captureItems)
          ..where(
            (db.CaptureItems table) => table.batchId.equals(batchId),
          )
          ..orderBy(<OrderingTerm Function(db.$CaptureItemsTable)>[
            (db.$CaptureItemsTable table) => OrderingTerm.asc(table.ordinal),
          ]))
        .get();
  }

  Future<void> _markCaptureStatus(
    String captureId,
    capture_domain.CaptureItemStatus status, {
    String? remoteMediaRef,
  }) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(captureId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(status.name),
        remoteMediaRef: remoteMediaRef == null
            ? const Value<String?>.absent()
            : Value<String?>(remoteMediaRef),
        failureReason: const Value<String?>(null),
      ),
    );
  }

  Future<void> _markCaptureFailed(
    String captureId, [
    String? failureReason,
  ]) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(captureId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(capture_domain.CaptureItemStatus.failed.name),
        failureReason: Value<String?>(failureReason),
      ),
    );
  }

  Future<void> _markBatchStatus(
    String batchId,
    CaptureBatchStatus status, {
    String? failureReason,
  }) async {
    await (_database.update(_database.captureBatches)
          ..where((db.$CaptureBatchesTable table) => table.id.equals(batchId)))
        .write(
      db.CaptureBatchesCompanion(
        status: Value<String>(status.name),
        updatedAt: Value<DateTime>(DateTime.now()),
        failureReason: Value<String?>(failureReason),
      ),
    );
  }

  bool _isConnectivityError(Object error) {
    if (error is SocketException || error is TimeoutException) {
      return true;
    }
    final String message = error.toString().toLowerCase();
    return message.contains('socket') ||
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('timed out') ||
        message.contains('failed host lookup');
  }

  bool _isInterruptedSignedUpload(String? failureReason) {
    final String normalized = failureReason?.toLowerCase() ?? '';
    return normalized.contains('resource already exists') ||
        normalized.contains('duplicate');
  }
}
