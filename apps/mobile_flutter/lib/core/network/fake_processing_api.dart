part of 'my_menu_api_client.dart';

mixin FakeProcessingApi on MyMenuApiClient {
  final Map<String, _FakeProcessingRecord> _processingJobs =
      <String, _FakeProcessingRecord>{};
  bool _interruptProcessingUpload = false;
  int _processingJobCreationCount = 0;

  int get processingJobCreationCount => _processingJobCreationCount;

  void interruptNextProcessingUpload() {
    _interruptProcessingUpload = true;
  }

  bool hasPayloadForProcessingJob(String jobId) {
    final _FakeProcessingRecord? record = _processingJobs[jobId];
    return record?.input != null || record?.result != null;
  }

  @override
  Future<ApiProcessingJob> createProcessingJob({
    required String operation,
    required String idempotencyKey,
    required String inputSchemaVersion,
    required String resultSchemaVersion,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) async {
    final _FakeProcessingRecord? existing = _processingJobs.values
        .where(
          (_FakeProcessingRecord record) =>
              record.job.idempotencyKey == idempotencyKey,
        )
        .firstOrNull;
    if (existing != null) {
      return existing.job;
    }
    _processingJobCreationCount += 1;
    final String id = 'processing-job-$_processingJobCreationCount';
    final ApiProcessingJob job = ApiProcessingJob(
      id: id,
      operation: operation,
      idempotencyKey: idempotencyKey,
      status: 'created',
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 24)),
      inputSchemaVersion: inputSchemaVersion,
      resultSchemaVersion: resultSchemaVersion,
      uploadTargets: assets
          .map(
            (ApiProcessingAssetManifest asset) => ApiProcessingUploadTarget(
              assetId: asset.assetId,
              storagePath: 'processing/$id/${asset.assetId}',
              token: 'fake-upload-token',
              contentType: asset.contentType,
            ),
          )
          .toList(growable: false),
    );
    _processingJobs[id] = _FakeProcessingRecord(
      job: job,
      assetIds: assets
          .map((ApiProcessingAssetManifest asset) => asset.assetId)
          .toSet(),
    );
    return job;
  }

  @override
  Future<void> uploadProcessingAsset({
    required ApiProcessingUploadTarget target,
    required String localPath,
  }) async {
    if (_interruptProcessingUpload) {
      _interruptProcessingUpload = false;
      throw const SocketException('Processing upload interrupted');
    }
    final _FakeProcessingRecord record = _processingJobs.values.firstWhere(
      (_FakeProcessingRecord candidate) =>
          candidate.job.uploadTargets.any(
            (ApiProcessingUploadTarget candidateTarget) =>
                candidateTarget.storagePath == target.storagePath,
          ),
    );
    await File(localPath).readAsBytes();
    record.uploadedAssetIds.add(target.assetId);
  }

  @override
  Future<ApiProcessingJob> submitProcessingJob({
    required String jobId,
    required Map<String, Object?> input,
  }) async {
    final _FakeProcessingRecord record = _processingJobs[jobId]!;
    if (!record.uploadedAssetIds.containsAll(record.assetIds)) {
      throw StateError('Processing assets are not uploaded.');
    }
    final List<Object?> captures = input['captures']! as List<Object?>;
    record
      ..input = input
      ..result = <String, Object?>{
        'operation': 'capture_grouping',
        'schemaVersion': record.job.resultSchemaVersion,
        'groups': captures.map((Object? value) {
          final Map<String, Object?> capture =
              Map<String, Object?>.from(value! as Map<String, Object?>);
          return <String, Object?>{
            'captureIds': <String>[capture['id']! as String],
            'proposal': <String, Object?>{
              'type': 'new_dish',
              'title': 'Captured Dish',
              'description': 'Deterministic capture grouping proposal.',
            },
            'confidence': 1.0,
            'evidence': <String>['Deterministic local provider'],
            'uncertainty': <String>[],
          };
        }).toList(growable: false),
        'rejectedCaptures': <Object?>[],
        'provenance': <String, Object?>{
          'provider': 'fake',
          'model': 'fake-date-grouper-v2',
        },
      };
    return record.job = _copyProcessingJob(record.job, status: 'succeeded');
  }

  @override
  Future<ApiProcessingJob> getProcessingJob({required String jobId}) async {
    return _processingJobs[jobId]!.job;
  }

  @override
  Future<Map<String, Object?>> downloadProcessingResult({
    required String jobId,
  }) async {
    return Map<String, Object?>.from(_processingJobs[jobId]!.result!);
  }

  @override
  Future<void> acknowledgeProcessingJob({required String jobId}) async {
    final _FakeProcessingRecord record = _processingJobs[jobId]!;
    record
      ..input = null
      ..result = null
      ..uploadedAssetIds.clear()
      ..job = _copyProcessingJob(record.job, status: 'acknowledged');
  }

  @override
  Future<void> cancelProcessingJob({required String jobId}) async {
    final _FakeProcessingRecord record = _processingJobs[jobId]!;
    record
      ..input = null
      ..result = null
      ..uploadedAssetIds.clear()
      ..job = _copyProcessingJob(record.job, status: 'canceled');
  }

  ApiProcessingJob _copyProcessingJob(
    ApiProcessingJob job, {
    required String status,
  }) {
    return ApiProcessingJob(
      id: job.id,
      operation: job.operation,
      idempotencyKey: job.idempotencyKey,
      status: status,
      expiresAt: job.expiresAt,
      inputSchemaVersion: job.inputSchemaVersion,
      resultSchemaVersion: job.resultSchemaVersion,
      uploadTargets: job.uploadTargets,
    );
  }
}

class _FakeProcessingRecord {
  _FakeProcessingRecord({
    required this.job,
    required this.assetIds,
  });

  ApiProcessingJob job;
  final Set<String> assetIds;
  final Set<String> uploadedAssetIds = <String>{};
  Map<String, Object?>? input;
  Map<String, Object?>? result;
}
