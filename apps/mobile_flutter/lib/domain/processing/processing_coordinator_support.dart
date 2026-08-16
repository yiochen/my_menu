part of 'processing_coordinator.dart';

List<String> _payloadStringList(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is List<dynamic>) {
    return value.whereType<String>().toList(growable: false);
  }
  throw StateError('Missing payload string list: $key');
}

void _logProcessing(String message, [Object? error, StackTrace? stackTrace]) {
  developer.log(
    message,
    name: 'mymenu.processing',
    error: error,
    stackTrace: stackTrace,
  );
  debugPrint(
      'mymenu.processing: $message${error == null ? '' : ' error=$error'}');
  if (stackTrace != null) {
    debugPrintStack(label: 'mymenu.processing stack', stackTrace: stackTrace);
  }
}
