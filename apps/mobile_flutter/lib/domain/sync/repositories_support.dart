part of 'repositories.dart';

Map<String, Object?> _payloadObject(String payloadJson) {
  final Object? decoded = jsonDecode(payloadJson);
  if (decoded is Map<String, dynamic>) {
    return Map<String, Object?>.from(decoded);
  }
  return const <String, Object?>{};
}

String _requiredPayloadString(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is String) {
    return value;
  }
  throw StateError('Missing payload string: $key');
}

int? _payloadInt(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  return value is int ? value : null;
}

void _logSync(String message, [Object? error, StackTrace? stackTrace]) {
  developer.log(
    message,
    name: 'mymenu.sync',
    error: error,
    stackTrace: stackTrace,
  );
  debugPrint('mymenu.sync: $message${error == null ? '' : ' error=$error'}');
  if (stackTrace != null) {
    debugPrintStack(label: 'mymenu.sync stack', stackTrace: stackTrace);
  }
}
