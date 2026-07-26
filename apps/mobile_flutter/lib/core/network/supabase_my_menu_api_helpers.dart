part of 'my_menu_api_client.dart';

void _logApi(String message, [Object? error, StackTrace? stackTrace]) {
  developer.log(
    message,
    name: 'mymenu.api',
    error: error,
    stackTrace: stackTrace,
  );
  debugPrint('mymenu.api: $message${error == null ? '' : ' error=$error'}');
  if (stackTrace != null) {
    debugPrintStack(label: 'mymenu.api stack', stackTrace: stackTrace);
  }
}

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

Future<ApiAiJob> _singleAiJobRpc(
  SupabaseMyMenuApiClient client,
  String functionName,
  Map<String, Object?> params,
) async {
  final List<ApiAiJob> jobs = await _aiJobRpc(client, functionName, params);
  if (jobs.length != 1) {
    throw StateError('$functionName returned ${jobs.length} AI jobs.');
  }
  return jobs.single;
}

Future<List<ApiAiJob>> _getAiJobs(
  SupabaseMyMenuApiClient client,
  List<String> ids,
) {
  if (ids.isEmpty) {
    return Future<List<ApiAiJob>>.value(const <ApiAiJob>[]);
  }
  return _aiJobRpc(
    client,
    'api_get_ai_jobs',
    <String, Object?>{'p_ids': ids},
  );
}

Future<List<ApiAiJob>> _aiJobRpc(
  SupabaseMyMenuApiClient client,
  String functionName,
  Map<String, Object?> params,
) async {
  await client._ensureSession();
  final Object? response = await client._client.rpc<Object?>(
    functionName,
    params: params,
  );
  if (response is! List<dynamic>) {
    throw StateError('$functionName returned non-list JSON.');
  }
  return response.map((dynamic value) {
    if (value is! Map<dynamic, dynamic>) {
      throw StateError('$functionName returned an invalid row.');
    }
    final Map<String, Object?> row = value.map(
      (dynamic key, dynamic item) =>
          MapEntry<String, Object?>(key.toString(), item as Object?),
    );
    return apiAiJobFromJson(row);
  }).toList(growable: false);
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
