part of 'my_menu_api_client.dart';

mixin SupabaseCaptureApi on MyMenuApiClient {
  SupabaseClient get _client;

  Future<void> _ensureSession();

  Future<Map<String, Object?>> _invokeJson(
    String functionName,
    Map<String, Object?> body,
  );

  @override
  Future<void> upsertCaptureBatch({
    required String batchId,
    required int itemCount,
    required DateTime createdAt,
  }) async {
    await _ensureSession();
    await _client.rpc<Object?>(
      'api_upsert_capture_batch',
      params: <String, Object?>{
        'p_batch_id': batchId,
        'p_item_count': itemCount,
        'p_created_at': createdAt.toUtc().toIso8601String(),
      },
    );
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
    await _ensureSession();

    final Uint8List bytes = await File(localMediaRef).readAsBytes();
    final String contentType = _contentTypeForPath(localMediaRef);
    _logApi(
      'uploadCaptureMedia start captureId=$captureId '
      'contentType=$contentType bytes=${bytes.length}',
    );
    final Map<String, Object?> prepare = await _invokeJson(
      'prepare-photo-upload',
      <String, Object?>{
        'captureId': captureId,
        'batchId': batchId,
        'ordinal': ordinal,
        'contentType': contentType,
        'byteSize': bytes.length,
      },
    );

    final Map<String, Object?> upload = apiMapValue(prepare, 'upload');
    final String storagePath = apiStringValue(prepare, 'storagePath');
    final String token = apiStringValue(upload, 'token');

    _logApi('uploadCaptureMedia storage upload start captureId=$captureId');
    await _client.storage.from('menu-media').uploadBinaryToSignedUrl(
          storagePath,
          token,
          bytes,
          FileOptions(contentType: contentType, upsert: true),
        );
    _logApi('uploadCaptureMedia storage upload complete captureId=$captureId');

    final Map<String, Object?> created = await _invokeJson(
      'create-photo',
      <String, Object?>{
        'captureId': captureId,
        'batchId': batchId,
        'ordinal': ordinal,
        'storagePath': storagePath,
        'contentType': contentType,
        'byteSize': bytes.length,
        'capturedAt': capturedAt.toUtc().toIso8601String(),
        if (capturedLocalDate != null) 'capturedLocalDate': capturedLocalDate,
        'captureDateSource': captureDateSource,
      },
    );
    final Map<String, Object?> image = apiMapValue(created, 'image');
    final String mediaRef = apiStringValue(image, 'mediaRef');
    _logApi('uploadCaptureMedia complete captureId=$captureId');
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
    await _ensureSession();
    final Map<String, Object?> result = await _invokeJson(
      'finalize-capture-batch',
      <String, Object?>{
        'batchId': batchId,
        'kind': kind,
        if (ideaText != null) 'ideaText': ideaText,
        'capturedAt': capturedAt.toUtc().toIso8601String(),
        if (capturedLocalDate != null) 'capturedLocalDate': capturedLocalDate,
        'captureDateSource': captureDateSource,
        'job': <String, Object?>{
          'id': jobId,
          'idempotencyKey': idempotencyKey,
          'inputHash': inputHash,
          'inputVersion': inputVersion,
          'maxAttempts': maxAttempts,
        },
      },
    );
    return apiAiJobFromJson(apiMapValue(result, 'job'));
  }

  @override
  Future<List<ApiCaptureBatch>> getCaptureBatches(List<String> ids) {
    return _getCaptureBatches(this as SupabaseMyMenuApiClient, ids);
  }
}
