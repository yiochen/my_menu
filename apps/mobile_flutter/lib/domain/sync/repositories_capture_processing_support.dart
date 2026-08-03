part of 'repositories.dart';

List<String> _jsonStringList(String source) {
  final Object? value = jsonDecode(source);
  return value is List<Object?>
      ? value.whereType<String>().toList(growable: false)
      : const <String>[];
}

String _processingContentType(String path) {
  final String normalized = path.toLowerCase();
  if (normalized.endsWith('.png')) {
    return 'image/png';
  }
  if (normalized.endsWith('.heic')) {
    return 'image/heic';
  }
  if (normalized.endsWith('.heif')) {
    return 'image/heif';
  }
  return 'image/jpeg';
}

bool _isConnectivityError(Object error) {
  if (error is SocketException || error is TimeoutException) {
    return true;
  }
  final String message = error.toString().toLowerCase();
  return message.contains('socket') ||
      message.contains('network') ||
      message.contains('connection') ||
      message.contains('timed out') ||
      message.contains('failed host lookup');
}

String _processingErrorCode(Object error) {
  if (_isConnectivityError(error)) {
    return 'network_unavailable';
  }
  if (error is FileSystemException) {
    return 'local_asset_unavailable';
  }
  if (error is FormatException || error is TypeError) {
    return 'invalid_processing_response';
  }
  final String message = error.toString().toLowerCase();
  if (message.contains('free_allowance_exhausted')) {
    return 'free_allowance_exhausted';
  }
  return 'processing_failed';
}

String _processingFailureReason(String code) {
  return switch (code) {
    'local_asset_unavailable' => 'The local photo is unavailable.',
    'invalid_processing_response' => 'The processing result was invalid.',
    'free_allowance_exhausted' => 'The free processing allowance is used.',
    _ => 'Processing could not be completed.',
  };
}

bool _isProcessingJobNotFound(Object error) {
  final String message = error.toString().toLowerCase();
  return message.contains('processing_job_not_found') ||
      (message.contains('404') && message.contains('not_found'));
}
