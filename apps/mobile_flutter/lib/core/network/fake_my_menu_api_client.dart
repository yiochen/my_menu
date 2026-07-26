part of 'my_menu_api_client.dart';

class FakeMyMenuApiClient extends MyMenuApiClient {
  final Map<String, ApiAiJob> _aiJobs = <String, ApiAiJob>{};
  final Map<String, _FakeCaptureRecord> _captures =
      <String, _FakeCaptureRecord>{};
  final Map<String, ApiDish> _dishes = <String, ApiDish>{};
  final Map<String, int> _batchItemCounts = <String, int>{};
  final Map<String, String> _batchStatuses = <String, String>{};
  final List<ApiSyncEvent> _events = <ApiSyncEvent>[];
  int _cursor = 0;

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
  }) async {
    final ApiAiJob? existing = _aiJobs.values
        .where((ApiAiJob job) => job.idempotencyKey == idempotencyKey)
        .firstOrNull;
    if (existing != null) {
      return existing;
    }
    final DateTime now = DateTime.now();
    final ApiAiJob job = ApiAiJob(
      id: jobId,
      jobType: jobType,
      subjectId: subjectId,
      status: 'queued',
      idempotencyKey: idempotencyKey,
      inputHash: inputHash,
      inputVersion: inputVersion,
      attemptCount: 0,
      maxAttempts: maxAttempts,
      promptVersion: promptVersion,
      modelVersion: modelVersion,
      schemaVersion: schemaVersion,
      createdAt: now,
      updatedAt: now,
    );
    _aiJobs[job.id] = job;
    _emit('ai_job.queued', <String, String>{'aiJobId': job.id});
    return job;
  }

  @override
  Future<List<ApiAiJob>> getAiJobs(List<String> ids) async {
    return ids
        .map((String id) => _aiJobs[id])
        .whereType<ApiAiJob>()
        .toList(growable: false);
  }

  @override
  Future<ApiAiJob> retryAiJob({required String jobId}) async {
    final ApiAiJob existing = _aiJobs[jobId]!;
    final ApiAiJob retried = _copyAiJob(
      existing,
      status: 'queued',
      updatedAt: DateTime.now(),
    );
    _aiJobs[jobId] = retried;
    return retried;
  }

  @override
  Future<ApiAiJob> cancelAiJob({required String jobId}) async {
    final ApiAiJob existing = _aiJobs[jobId]!;
    final ApiAiJob canceled = _copyAiJob(
      existing,
      status: 'canceled',
      updatedAt: DateTime.now(),
    );
    _aiJobs[jobId] = canceled;
    return canceled;
  }

  @override
  Future<void> upsertCaptureBatch({
    required String batchId,
    required int itemCount,
    required DateTime createdAt,
  }) async {
    _batchItemCounts[batchId] = itemCount;
    _batchStatuses[batchId] = 'uploading';
  }

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
  }) {
    final DateTime now = DateTime.now();
    return uploadCaptureMediaWithMetadata(
      captureId: captureId,
      batchId: batchId,
      ordinal: ordinal,
      localMediaRef: localMediaRef,
      capturedAt: now,
      capturedLocalDate: null,
      captureDateSource: 'unknown',
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
  }) async {
    final String mediaRef = 'fake://captures/$captureId';
    _captures[captureId] = _FakeCaptureRecord(
      id: captureId,
      batchId: batchId,
      ordinal: ordinal,
      kind: 'photo',
      status: 'uploaded',
      capturedAt: capturedAt,
      capturedLocalDate: capturedLocalDate,
      captureDateSource: captureDateSource,
      mediaRef: mediaRef,
    );
    return mediaRef;
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
  }) async {
    if (kind == 'idea') {
      _batchItemCounts[batchId] = 1;
      _captures[batchId] = _FakeCaptureRecord(
        id: batchId,
        batchId: batchId,
        ordinal: 0,
        kind: 'idea',
        status: 'classifying',
        capturedAt: capturedAt,
        capturedLocalDate: capturedLocalDate,
        captureDateSource: captureDateSource,
        ideaText: ideaText,
      );
    }
    _batchStatuses[batchId] = 'processing';
    final ApiAiJob job = await scheduleAiJob(
      jobId: jobId,
      jobType: 'batch_grouping',
      subjectId: batchId,
      idempotencyKey: idempotencyKey,
      inputHash: inputHash,
      inputVersion: inputVersion,
      promptVersion: 'date-v1',
      modelVersion: 'fake-date-grouper',
      schemaVersion: '1',
      maxAttempts: maxAttempts,
    );
    return job;
  }

  @override
  Future<void> createDishNote({
    required String noteId,
    required String dishId,
    required String body,
    required int position,
  }) async {}

  @override
  Future<void> updateDishNote({
    required String noteId,
    required String body,
    required int? position,
  }) async {}

  @override
  Future<void> deleteDishNote({required String noteId}) async {}

  @override
  Future<void> updateDish({
    required String clientMutationId,
    required String dishId,
    required Map<String, Object?> patch,
  }) async {}

  @override
  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  }) async {
    _completeQueuedGroupingJobs();
    final List<ApiSyncEvent> events = _events
        .where((ApiSyncEvent event) => event.cursor > afterCursor)
        .take(limit)
        .toList(growable: false);
    return ApiSyncPull(
      cursor: events.isEmpty ? afterCursor : events.last.cursor,
      hasMore: _events.any(
        (ApiSyncEvent event) =>
            event.cursor > (events.isEmpty ? afterCursor : events.last.cursor),
      ),
      requiresBootstrap: false,
      events: events,
    );
  }

  @override
  Future<List<ApiCapture>> getCaptures(List<String> ids) async {
    return ids
        .map((String id) => _captures[id])
        .whereType<_FakeCaptureRecord>()
        .map((_FakeCaptureRecord item) => item.toApi())
        .toList(growable: false);
  }

  @override
  Future<List<ApiDish>> getDishes(List<String> ids) async {
    return ids
        .map((String id) => _dishes[id])
        .whereType<ApiDish>()
        .toList(growable: false);
  }

  @override
  Future<List<ApiReviewItem>> getReviewItems(List<String> ids) async {
    return const <ApiReviewItem>[];
  }

  @override
  Future<List<ApiCaptureBatch>> getCaptureBatches(List<String> ids) async {
    return ids
        .where(_batchItemCounts.containsKey)
        .map(
          (String id) => ApiCaptureBatch(
            id: id,
            status: _batchStatuses[id] ?? 'processing',
            itemCount: _batchItemCounts[id]!,
            uploadedItemCount: _captures.values
                .where((_FakeCaptureRecord item) => item.batchId == id)
                .length,
          ),
        )
        .toList(growable: false);
  }
}

ApiAiJob _copyAiJob(
  ApiAiJob job, {
  required String status,
  required DateTime updatedAt,
  Map<String, Object?>? normalizedError,
  Map<String, Object?>? normalizedResult,
  DateTime? completedAt,
}) {
  return ApiAiJob(
    id: job.id,
    jobType: job.jobType,
    subjectId: job.subjectId,
    status: status,
    idempotencyKey: job.idempotencyKey,
    inputHash: job.inputHash,
    inputVersion: job.inputVersion,
    attemptCount: job.attemptCount,
    maxAttempts: job.maxAttempts,
    promptVersion: job.promptVersion,
    modelVersion: job.modelVersion,
    schemaVersion: job.schemaVersion,
    createdAt: job.createdAt,
    updatedAt: updatedAt,
    nextRetryAt: job.nextRetryAt,
    normalizedResult: normalizedResult ?? job.normalizedResult,
    normalizedError: normalizedError,
    startedAt: job.startedAt,
    completedAt: completedAt ?? job.completedAt,
  );
}

class _FakeCaptureRecord {
  _FakeCaptureRecord({
    required this.id,
    required this.batchId,
    required this.ordinal,
    required this.kind,
    required this.status,
    required this.capturedAt,
    required this.capturedLocalDate,
    required this.captureDateSource,
    this.mediaRef,
    this.ideaText,
  });

  final String id;
  final String batchId;
  final int ordinal;
  final String kind;
  String status;
  final DateTime capturedAt;
  final String? capturedLocalDate;
  final String captureDateSource;
  final String? mediaRef;
  final String? ideaText;
  String? appliedDishId;

  ApiCapture toApi() {
    return ApiCapture(
      id: id,
      kind: kind,
      status: status,
      capturedAt: capturedAt,
      batchId: batchId,
      ordinal: ordinal,
      ideaText: ideaText,
      capturedLocalDate: capturedLocalDate,
      captureDateSource: captureDateSource,
      appliedDishId: appliedDishId,
      image: mediaRef == null
          ? null
          : ApiImage(
              id: 'fake-image-$id',
              kind: status == 'applied' ? 'source_photo' : 'capture_photo',
              mediaRef: mediaRef!,
            ),
    );
  }
}
