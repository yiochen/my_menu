part of 'my_menu_api_client.dart';

String _contentTypeForPath(String path) {
  final String lower = path.toLowerCase();
  if (lower.endsWith('.png')) {
    return 'image/png';
  }
  if (lower.endsWith('.heic')) {
    return 'image/heic';
  }
  if (lower.endsWith('.heif')) {
    return 'image/heif';
  }
  return 'image/jpeg';
}

Future<List<ApiCaptureBatch>> _getCaptureBatches(
  SupabaseMyMenuApiClient client,
  List<String> ids,
) async {
  if (ids.isEmpty) {
    return const <ApiCaptureBatch>[];
  }
  await client._ensureSession();
  final Object? response = await client._client.rpc<Object?>(
    'api_get_capture_batches',
    params: <String, Object?>{'p_ids': ids},
  );
  if (response is! List<dynamic>) {
    throw StateError('Capture batch RPC returned non-list JSON.');
  }
  return response.map((dynamic value) {
    if (value is! Map<dynamic, dynamic>) {
      throw StateError('Capture batch RPC returned an invalid row.');
    }
    final Map<String, Object?> row = value.map(
      (dynamic key, dynamic item) => MapEntry<String, Object?>(
        key.toString(),
        item as Object?,
      ),
    );
    return ApiCaptureBatch(
      id: apiStringValue(row, 'batch_id'),
      status: apiStringValue(row, 'status'),
      itemCount: apiIntValue(row, 'item_count'),
      uploadedItemCount: apiIntValue(row, 'uploaded_item_count'),
    );
  }).toList(growable: false);
}

Future<Map<String, Object?>> _invokeSupabaseJson(
  SupabaseMyMenuApiClient client,
  String functionName,
  Map<String, Object?> body,
) async {
  _logApi('invoke $functionName start');
  final FunctionResponse response;
  try {
    response = await client._client.functions.invoke(
      functionName,
      body: body,
    );
  } on Object catch (error, stackTrace) {
    _logApi('invoke $functionName threw', error, stackTrace);
    rethrow;
  }
  _logApi('invoke $functionName status=${response.status}');
  if (response.status < 200 || response.status >= 300) {
    throw StateError(
      'Supabase function failed: ${response.status} ${response.data}',
    );
  }
  final Object? data = response.data;
  if (data is Map<String, dynamic>) {
    return Map<String, Object?>.from(data);
  }
  if (data is Map<String, Object?>) {
    return data;
  }
  throw StateError('Supabase function returned non-object JSON.');
}
