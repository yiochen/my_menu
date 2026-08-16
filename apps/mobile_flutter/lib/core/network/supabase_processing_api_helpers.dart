part of 'processing_api_client.dart';

void _logApi(String message, [Object? error, StackTrace? stackTrace]) {
  developer.log(
    message,
    name: 'mymenu.processing.api',
    error: error,
    stackTrace: stackTrace,
  );
  debugPrint(
    'mymenu.processing.api: $message${error == null ? '' : ' error=$error'}',
  );
}

Future<Map<String, Object?>> _invokeSupabaseJson(
  SupabaseProcessingApiClient client,
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
  } on Object {
    _logApi('invoke $functionName failed code=request_exception');
    rethrow;
  }
  _logApi('invoke $functionName status=${response.status}');
  if (response.status < 200 || response.status >= 300) {
    throw StateError('Processing service request failed: ${response.status}.');
  }
  final Object? data = response.data;
  if (data is Map<String, dynamic>) {
    return Map<String, Object?>.from(data);
  }
  if (data is Map<String, Object?>) return data;
  throw StateError('Supabase function returned non-object JSON.');
}
