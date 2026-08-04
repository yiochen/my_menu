import 'package:mymenu/core/network/my_menu_api_client.dart';

class NetworkGatedMyMenuApiClient extends MyMenuApiClient {
  NetworkGatedMyMenuApiClient(this._delegate, this._requireNetwork);

  final MyMenuApiClient _delegate;
  final void Function() _requireNetwork;

  Future<T> _online<T>(Future<T> Function() request) async {
    _requireNetwork();
    return request();
  }

  @override
  Future<ApiProcessingAllowances> getProcessingAllowances() {
    return _online(_delegate.getProcessingAllowances);
  }

  @override
  Future<ApiProcessingJob> createProcessingJob({
    required String operation,
    required String idempotencyKey,
    required String inputSchemaVersion,
    required String resultSchemaVersion,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) {
    return _online(
      () => _delegate.createProcessingJob(
        operation: operation,
        idempotencyKey: idempotencyKey,
        inputSchemaVersion: inputSchemaVersion,
        resultSchemaVersion: resultSchemaVersion,
        privacyNoticeVersion: privacyNoticeVersion,
        assets: assets,
      ),
    );
  }

  @override
  Future<void> uploadProcessingAsset({
    required ApiProcessingUploadTarget target,
    required String localPath,
  }) {
    return _online(
      () => _delegate.uploadProcessingAsset(
        target: target,
        localPath: localPath,
      ),
    );
  }

  @override
  Future<ApiProcessingJob> submitProcessingJob({
    required String jobId,
    required Map<String, Object?> input,
  }) {
    return _online(
      () => _delegate.submitProcessingJob(jobId: jobId, input: input),
    );
  }

  @override
  Future<ApiProcessingJob> getProcessingJob({required String jobId}) {
    return _online(() => _delegate.getProcessingJob(jobId: jobId));
  }

  @override
  Future<Map<String, Object?>> downloadProcessingResult({
    required String jobId,
  }) {
    return _online(() => _delegate.downloadProcessingResult(jobId: jobId));
  }

  @override
  Future<void> acknowledgeProcessingJob({required String jobId}) {
    return _online(() => _delegate.acknowledgeProcessingJob(jobId: jobId));
  }

  @override
  Future<void> cancelProcessingJob({required String jobId}) {
    return _online(() => _delegate.cancelProcessingJob(jobId: jobId));
  }

  @override
  Future<void> upsertCaptureBatch({
    required String batchId,
    required int itemCount,
    required DateTime createdAt,
  }) {
    return _online(
      () => _delegate.upsertCaptureBatch(
        batchId: batchId,
        itemCount: itemCount,
        createdAt: createdAt,
      ),
    );
  }

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
  }) {
    return _online(
      () => _delegate.uploadCaptureMedia(
        captureId: captureId,
        batchId: batchId,
        ordinal: ordinal,
        localMediaRef: localMediaRef,
      ),
    );
  }

  @override
  Future<String> uploadCaptureMediaWithMetadata({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
    required DateTime capturedAt,
    required String? capturedLocalDate,
    required String captureDateSource,
  }) {
    return _online(
      () => _delegate.uploadCaptureMediaWithMetadata(
        captureId: captureId,
        batchId: batchId,
        ordinal: ordinal,
        localMediaRef: localMediaRef,
        capturedAt: capturedAt,
        capturedLocalDate: capturedLocalDate,
        captureDateSource: captureDateSource,
      ),
    );
  }

  @override
  Future<ApiAiJob> finalizeCaptureBatch({
    required String batchId,
    required String kind,
    required String? ideaText,
    required DateTime capturedAt,
    required String? capturedLocalDate,
    required String captureDateSource,
    required String jobId,
    required String idempotencyKey,
    required String inputHash,
    required String inputVersion,
    required int maxAttempts,
  }) {
    return _online(
      () => _delegate.finalizeCaptureBatch(
        batchId: batchId,
        kind: kind,
        ideaText: ideaText,
        capturedAt: capturedAt,
        capturedLocalDate: capturedLocalDate,
        captureDateSource: captureDateSource,
        jobId: jobId,
        idempotencyKey: idempotencyKey,
        inputHash: inputHash,
        inputVersion: inputVersion,
        maxAttempts: maxAttempts,
      ),
    );
  }

  @override
  Future<List<ApiCaptureBatch>> getCaptureBatches(List<String> ids) {
    return _online(() => _delegate.getCaptureBatches(ids));
  }

  @override
  Future<void> deleteCapture({required String captureId}) {
    return _online(() => _delegate.deleteCapture(captureId: captureId));
  }

  @override
  Future<void> deleteCaptureBatch({required String batchId}) {
    return _online(() => _delegate.deleteCaptureBatch(batchId: batchId));
  }

  @override
  Future<void> correctCaptureGrouping({
    required String clientMutationId,
    required String batchId,
    required String actionType,
    required List<String> captureIds,
    required String targetDishId,
    String? newDishTitle,
  }) {
    return _online(
      () => _delegate.correctCaptureGrouping(
        clientMutationId: clientMutationId,
        batchId: batchId,
        actionType: actionType,
        captureIds: captureIds,
        targetDishId: targetDishId,
        newDishTitle: newDishTitle,
      ),
    );
  }

  @override
  Future<void> undoCaptureGrouping({
    required String clientMutationId,
    required String actionId,
  }) {
    return _online(
      () => _delegate.undoCaptureGrouping(
        clientMutationId: clientMutationId,
        actionId: actionId,
      ),
    );
  }

  @override
  Future<ApiAiJob> scheduleAiJob({
    required String jobId,
    required String jobType,
    required String subjectId,
    required String idempotencyKey,
    required String inputHash,
    required String inputVersion,
    required String promptVersion,
    required String modelVersion,
    required String schemaVersion,
    required int maxAttempts,
  }) {
    return _online(
      () => _delegate.scheduleAiJob(
        jobId: jobId,
        jobType: jobType,
        subjectId: subjectId,
        idempotencyKey: idempotencyKey,
        inputHash: inputHash,
        inputVersion: inputVersion,
        promptVersion: promptVersion,
        modelVersion: modelVersion,
        schemaVersion: schemaVersion,
        maxAttempts: maxAttempts,
      ),
    );
  }

  @override
  Future<List<ApiAiJob>> getAiJobs(List<String> ids) {
    return _online(() => _delegate.getAiJobs(ids));
  }

  @override
  Future<ApiAiJob> retryAiJob({required String jobId}) {
    return _online(() => _delegate.retryAiJob(jobId: jobId));
  }

  @override
  Future<ApiAiJob> cancelAiJob({required String jobId}) {
    return _online(() => _delegate.cancelAiJob(jobId: jobId));
  }

  @override
  Future<void> createDishNote({
    required String noteId,
    required String dishId,
    required String body,
    required int position,
  }) {
    return _online(
      () => _delegate.createDishNote(
        noteId: noteId,
        dishId: dishId,
        body: body,
        position: position,
      ),
    );
  }

  @override
  Future<void> updateDishNote({
    required String noteId,
    required String body,
    required int? position,
  }) {
    return _online(
      () => _delegate.updateDishNote(
        noteId: noteId,
        body: body,
        position: position,
      ),
    );
  }

  @override
  Future<void> deleteDishNote({required String noteId}) {
    return _online(() => _delegate.deleteDishNote(noteId: noteId));
  }

  @override
  Future<void> deleteDishes({required List<String> dishIds}) {
    return _online(() => _delegate.deleteDishes(dishIds: dishIds));
  }

  @override
  Future<void> updateDish({
    required String clientMutationId,
    required String dishId,
    required Map<String, Object?> patch,
  }) {
    return _online(
      () => _delegate.updateDish(
        clientMutationId: clientMutationId,
        dishId: dishId,
        patch: patch,
      ),
    );
  }

  @override
  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  }) {
    return _online(
      () => _delegate.pullSync(afterCursor: afterCursor, limit: limit),
    );
  }

  @override
  Future<List<ApiCapture>> getCaptures(List<String> ids) {
    return _online(() => _delegate.getCaptures(ids));
  }

  @override
  Future<List<ApiDish>> getDishes(List<String> ids) {
    return _online(() => _delegate.getDishes(ids));
  }

  @override
  Future<List<ApiReviewItem>> getReviewItems(List<String> ids) {
    return _online(() => _delegate.getReviewItems(ids));
  }
}
