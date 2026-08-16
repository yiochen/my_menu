part of 'processing_coordinator.dart';

extension ProcessingCoordinatorCaptures on ProcessingCoordinator {
  Future<List<Dish>> processPendingCaptures() async {
    final ProcessingOutboxRepository outbox =
        ProcessingOutboxRepository(_database);
    final List<ProcessingOutboxRequest> requests = await outbox.listRequests();
    for (final ProcessingOutboxRequest request in requests) {
      if (request.kind != ProcessingRequestKind.captureGrouping) {
        continue;
      }
      if (request.deliveryState == ProcessingDeliveryState.acknowledged &&
          request.adoptionState != ProcessingAdoptionState.readyForAdoption) {
        continue;
      }
      if (request.deliveryState == ProcessingDeliveryState.canceled) {
        if (request.serverJobId != null) {
          try {
            await _processingApi
                .cancelProcessingJob(jobId: request.serverJobId!)
                .timeout(_controlRequestTimeout);
            await outbox.clearServerJob(request.id);
          } on Object catch (error) {
            if (_isProcessingJobNotFound(error)) {
              await outbox.clearServerJob(request.id);
              continue;
            }
            _logProcessing(
              'processing cancel unavailable requestId=${request.id} '
              'code=${_processingErrorCode(error)}',
            );
          }
        }
        await _deleteProcessingAssets(request.id);
        continue;
      }
      if (request.deliveryState == ProcessingDeliveryState.expired) {
        await _deleteProcessingAssets(request.id);
        continue;
      }
      if (request.deliveryState == ProcessingDeliveryState.acknowledged &&
          request.adoptionState == ProcessingAdoptionState.readyForAdoption) {
        await _adoptCaptureRoutingProposal(request);
        await _deleteProcessingAssets(request.id);
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
        final Map<String, String> processingAssets =
            await _prepareProcessingAssets(captures);
        final ApiProcessingJob job = await _processingApi
            .createProcessingJob(
              contract: ApiProcessingContract.captureGroupingV2,
              idempotencyKey: request.idempotencyKey,
              privacyNoticeVersion: request.privacyNoticeVersion!,
              assets: await _assetManifest(processingAssets),
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
        await _uploadProcessingAssets(
          outbox,
          request,
          job,
          processingAssets,
        );
        final Map<String, Object?> input =
            await _captureGroupingInput(captures);
        await outbox.recordSubmittedDishIds(
          request.id,
          (input['dishes']! as List<Object?>).map(
            (Object? value) =>
                (value! as Map<String, Object?>)['localId']! as String,
          ),
        );
        await _processingApi
            .submitProcessingJob(
              jobId: job.id,
              input: ApiCaptureGroupingInput(input),
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
        _logProcessing(
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
      final ApiProcessingJob job = await _processingApi
          .getProcessingJob(jobId: request.serverJobId!)
          .timeout(_controlRequestTimeout);
      if (job.status == ApiProcessingJobStatus.expired) {
        await outbox.markExpired(request.id);
        return;
      }
      if (job.status == ApiProcessingJobStatus.acknowledged &&
          request.resultPayload != null) {
        await outbox.markAcknowledged(request.id);
        final ProcessingOutboxRequest acknowledged =
            (await outbox.requestForSubject(
          kind: request.kind,
          subjectId: request.subjectId,
        ))!;
        await _adoptCaptureRoutingProposal(acknowledged);
        await _deleteProcessingAssets(request.id);
        return;
      }
      if (job.status == ApiProcessingJobStatus.failed) {
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
      if (job.status != ApiProcessingJobStatus.succeeded) {
        return;
      }
      final ApiProcessingResult downloaded = await _processingApi
          .downloadProcessingResult(jobId: job.id)
          .timeout(_controlRequestTimeout);
      if (downloaded is! ApiCaptureGroupingResult) {
        throw const FormatException('Unexpected processing result type.');
      }
      final Map<String, Object?> result = downloaded.payload;
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
      await _processingApi
          .acknowledgeProcessingJob(jobId: job.id)
          .timeout(_controlRequestTimeout);
      await outbox.markAcknowledged(request.id);
      final ProcessingOutboxRequest acknowledged =
          (await outbox.requestForSubject(
        kind: request.kind,
        subjectId: request.subjectId,
      ))!;
      await _adoptCaptureRoutingProposal(acknowledged);
      await _deleteProcessingAssets(request.id);
    } on Object catch (error) {
      if (_isProcessingJobNotFound(error)) {
        if (request.resultPayload != null) {
          await outbox.markAcknowledged(request.id);
        } else if (request.serverExpiresAt case final DateTime expiresAt
            when !DateTime.now().toUtc().isBefore(expiresAt.toUtc())) {
          await outbox.markExpired(request.id);
        }
        return;
      }
      _logProcessing(
        'processing result unavailable requestId=${request.id} '
        'code=${_processingErrorCode(error)}',
      );
    }
  }

  Future<List<db.CaptureItemRow>> _activeItemsForBatch(String batchId) {
    return _captureProcessingLocalStore.activeItemsForBatch(batchId);
  }

  Future<List<ApiProcessingAssetManifest>> _assetManifest(
    Map<String, String> processingAssets,
  ) async {
    final List<ApiProcessingAssetManifest> manifest =
        <ApiProcessingAssetManifest>[];
    for (final MapEntry<String, String> asset in processingAssets.entries) {
      manifest.add(
        ApiProcessingAssetManifest(
          assetId: asset.key,
          contentType: _processingContentType,
          byteSize: await File(asset.value).length(),
        ),
      );
    }
    return manifest;
  }

  Future<void> _uploadProcessingAssets(
    ProcessingOutboxRepository outbox,
    ProcessingOutboxRequest request,
    ApiProcessingJob job,
    Map<String, String> processingAssets,
  ) async {
    for (final ApiProcessingUploadTarget target in job.uploadTargets) {
      if (request.uploadedAssetIds.contains(target.assetId)) {
        continue;
      }
      final String? localPath = processingAssets[target.assetId];
      if (localPath == null) {
        throw FileSystemException(
          'Processing derivative is unavailable.',
          target.assetId,
        );
      }
      await _processingApi.uploadProcessingAsset(
        target: target,
        localPath: localPath,
      );
      await outbox.markAssetUploaded(request.id, target.assetId);
      await _markCaptureStatus(
        target.assetId,
        capture_domain.CaptureItemStatus.uploaded,
      );
    }
  }

  Future<void> _markCapturesClassifying(String batchId) async {
    await _captureProcessingLocalStore.markCapturesClassifying(batchId);
  }

  Future<void> _markCaptureStatus(
    String captureId,
    capture_domain.CaptureItemStatus status,
  ) async {
    await _captureProcessingLocalStore.markCaptureStatus(captureId, status);
  }

  Future<void> _markCapturesPending(String batchId) async {
    await _captureProcessingLocalStore.markCapturesPending(batchId);
  }

  Future<void> _markCapturesFailed(String batchId, String reason) async {
    await _captureProcessingLocalStore.markCapturesFailed(batchId, reason);
  }

  Future<void> _markBatchStatus(
    String batchId,
    CaptureBatchStatus status, {
    String? failureReason,
  }) async {
    await _captureProcessingLocalStore.markBatchStatus(
      batchId,
      status,
      failureReason: failureReason,
    );
  }
}
