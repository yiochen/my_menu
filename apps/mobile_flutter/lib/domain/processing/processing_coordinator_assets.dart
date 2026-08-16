part of 'processing_coordinator.dart';

List<String> _jsonStringList(String source) {
  final Object? value = jsonDecode(source);
  return value is List<Object?>
      ? value.whereType<String>().toList(growable: false)
      : const <String>[];
}

const String _processingContentType = 'image/jpeg';

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

extension ProcessingCoordinatorProcessingAssets on ProcessingCoordinator {
  Future<Map<String, String>> _prepareProcessingAssets(
    List<db.CaptureItemRow> captures,
  ) async {
    final Map<String, String> result = <String, String>{};
    for (final db.CaptureItemRow capture in captures) {
      if (capture.kind != capture_domain.CaptureItemKind.photo.name) {
        continue;
      }
      final String? sourcePath = capture.localMediaRef;
      if (sourcePath == null) {
        throw const FileSystemException('The local photo is unavailable.');
      }
      final ImageDerivativeSet previews = await _imageDerivativeStore.ensureSet(
        key: 'capture_${capture.id}',
        sourcePath: sourcePath,
        existingProcessingRef: capture.localPreviewRef,
        existingCardRef: capture.localThumbnailRef,
        existingPlaceholderRef: capture.localPlaceholderRef,
      );
      final String? previewPath = previews.processingRef;
      if (previewPath == null) {
        throw FileSystemException(
          'Could not create the reduced processing photo.',
          sourcePath,
        );
      }
      if (previewPath != capture.localPreviewRef ||
          previews.cardRef != capture.localThumbnailRef ||
          previews.placeholderRef != capture.localPlaceholderRef) {
        await _captureProcessingLocalStore.updatePreviewRefs(
          capture.id,
          previews,
        );
      }
      result[capture.id] = previewPath;
    }
    return result;
  }

  Future<void> _deleteProcessingAssets(String requestId) async {
    try {
      final Directory directory = await _processingDirectory(requestId);
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    } on Object {
      // Processing copies contain no unique data and are cleaned on retry.
    }
  }

  Future<Directory> _processingDirectory(String requestId) async {
    try {
      final Directory support = await getApplicationSupportDirectory();
      return Directory('${support.path}/processing/$requestId');
    } on Object {
      if (Platform.environment['FLUTTER_TEST'] != 'true') rethrow;
      return Directory(
        '${Directory.systemTemp.path}/mymenu-processing/$requestId',
      );
    }
  }
}
