part of 'processing_api_client.dart';

mixin SupabaseProcessingApi on ProcessingApiClient {
  SupabaseClient get _client;

  Future<void> _ensureSession();

  Future<Map<String, Object?>> _invokeJson(
    String functionName,
    Map<String, Object?> body,
  );

  @override
  Future<ApiProcessingAllowances> getProcessingAllowances() async {
    await _ensureSession();
    final Map<String, Object?> response = await _invokeJson(
      'processing-jobs',
      <String, Object?>{'action': 'allowances'},
    );
    return ApiProcessingAllowances(
      organizationRemaining: apiIntValue(response, 'organizationRemaining'),
      coverRemaining: apiIntValue(response, 'coverRemaining'),
    );
  }

  @override
  Future<ApiProcessingJob> createProcessingJob({
    required ApiProcessingContract contract,
    required String idempotencyKey,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) async {
    await _ensureSession();
    final Map<String, Object?> response = await _invokeJson(
      'processing-jobs',
      <String, Object?>{
        'action': 'create',
        'operation': contract.operation.apiValue,
        'idempotencyKey': idempotencyKey,
        'inputSchemaVersion': contract.inputSchemaVersion,
        'resultSchemaVersion': contract.resultSchemaVersion,
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
    required ApiProcessingInput input,
  }) async {
    await _ensureSession();
    return _processingJobFromResponse(
      await _invokeJson('processing-jobs', <String, Object?>{
        'action': 'submit',
        'jobId': jobId,
        'input': input.payload,
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
  Future<ApiProcessingResult> downloadProcessingResult({
    required String jobId,
  }) async {
    await _ensureSession();
    final Map<String, Object?> response = await _invokeJson(
      'processing-jobs',
      <String, Object?>{'action': 'result', 'jobId': jobId},
    );
    final Map<String, Object?> result = apiMapValue(response, 'result');
    final String schemaVersion = apiStringValue(result, 'schemaVersion');
    return switch (ApiProcessingOperation.fromApi(
      apiStringValue(result, 'operation'),
    )) {
      ApiProcessingOperation.captureGrouping => ApiCaptureGroupingResult(
          schemaVersion: schemaVersion,
          payload: result,
        ),
      ApiProcessingOperation.coverGeneration => ApiCoverGenerationResult(
          schemaVersion: schemaVersion,
          payload: result,
        ),
    };
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
      operation: ApiProcessingOperation.fromApi(
        apiStringValue(job, 'operation'),
      ),
      idempotencyKey: apiStringValue(job, 'idempotencyKey'),
      status: ApiProcessingJobStatus.fromApi(apiStringValue(job, 'status')),
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
