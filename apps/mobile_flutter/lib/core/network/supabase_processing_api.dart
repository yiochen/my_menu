part of 'my_menu_api_client.dart';

mixin SupabaseProcessingApi on MyMenuApiClient {
  SupabaseClient get _client;

  Future<void> _ensureSession();

  Future<Map<String, Object?>> _invokeJson(
    String functionName,
    Map<String, Object?> body,
  );

  @override
  Future<ApiProcessingJob> createProcessingJob({
    required String operation,
    required String idempotencyKey,
    required String inputSchemaVersion,
    required String resultSchemaVersion,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) async {
    await _ensureSession();
    final Map<String, Object?> response = await _invokeJson(
      'processing-jobs',
      <String, Object?>{
        'action': 'create',
        'operation': operation,
        'idempotencyKey': idempotencyKey,
        'inputSchemaVersion': inputSchemaVersion,
        'resultSchemaVersion': resultSchemaVersion,
        'privacyNoticeVersion': privacyNoticeVersion,
        'assets': assets
            .map((ApiProcessingAssetManifest asset) => asset.toJson())
            .toList(growable: false),
      },
    );
    return _processingJobFromResponse(response);
  }

  @override
  Future<void> uploadProcessingAsset({
    required ApiProcessingUploadTarget target,
    required String localPath,
  }) async {
    await _ensureSession();
    await _client.storage.from('processing-media').uploadBinaryToSignedUrl(
          target.storagePath,
          target.token,
          await File(localPath).readAsBytes(),
          FileOptions(contentType: target.contentType, upsert: true),
        );
  }

  @override
  Future<ApiProcessingJob> submitProcessingJob({
    required String jobId,
    required Map<String, Object?> input,
  }) async {
    await _ensureSession();
    return _processingJobFromResponse(
      await _invokeJson('processing-jobs', <String, Object?>{
        'action': 'submit',
        'jobId': jobId,
        'input': input,
      }),
    );
  }

  @override
  Future<ApiProcessingJob> getProcessingJob({required String jobId}) async {
    await _ensureSession();
    return _processingJobFromResponse(
      await _invokeJson('processing-jobs', <String, Object?>{
        'action': 'status',
        'jobId': jobId,
      }),
    );
  }

  @override
  Future<Map<String, Object?>> downloadProcessingResult({
    required String jobId,
  }) async {
    await _ensureSession();
    final Map<String, Object?> response = await _invokeJson(
      'processing-jobs',
      <String, Object?>{'action': 'result', 'jobId': jobId},
    );
    return apiMapValue(response, 'result');
  }

  @override
  Future<void> acknowledgeProcessingJob({required String jobId}) async {
    await _ensureSession();
    await _invokeJson('processing-jobs', <String, Object?>{
      'action': 'acknowledge',
      'jobId': jobId,
    });
  }

  @override
  Future<void> cancelProcessingJob({required String jobId}) async {
    await _ensureSession();
    await _invokeJson('processing-jobs', <String, Object?>{
      'action': 'cancel',
      'jobId': jobId,
    });
  }

  ApiProcessingJob _processingJobFromResponse(
    Map<String, Object?> response,
  ) {
    final Map<String, Object?> job = apiMapValue(response, 'job');
    final List<Object?> targetValues =
        response['uploadTargets'] is List<Object?>
            ? response['uploadTargets']! as List<Object?>
            : const <Object?>[];
    return ApiProcessingJob(
      id: apiStringValue(job, 'id'),
      operation: apiStringValue(job, 'operation'),
      idempotencyKey: apiStringValue(job, 'idempotencyKey'),
      status: apiStringValue(job, 'status'),
      expiresAt: DateTime.parse(apiStringValue(job, 'expiresAt')),
      inputSchemaVersion: apiStringValue(job, 'inputSchemaVersion'),
      resultSchemaVersion: apiStringValue(job, 'resultSchemaVersion'),
      errorCode: job['errorCode'] as String?,
      uploadTargets: targetValues.map((Object? value) {
        final Map<String, Object?> target =
            Map<String, Object?>.from(value! as Map<String, Object?>);
        return ApiProcessingUploadTarget(
          assetId: apiStringValue(target, 'assetId'),
          storagePath: apiStringValue(target, 'storagePath'),
          token: apiStringValue(target, 'token'),
          contentType: apiStringValue(target, 'contentType'),
        );
      }).toList(growable: false),
    );
  }
}
