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
