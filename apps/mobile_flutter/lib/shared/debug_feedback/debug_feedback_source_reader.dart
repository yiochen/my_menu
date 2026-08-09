import 'package:flutter/widgets.dart';

class DebugFeedbackSourceReader {
  const DebugFeedbackSourceReader();

  String? read(Element element) {
    try {
      // Flutter only exposes tracked creation locations through this serializer.
      // ignore: invalid_use_of_visible_for_testing_member
      final InspectorSerializationDelegate delegate =
          InspectorSerializationDelegate(
        service: WidgetInspectorService.instance,
      );
      final Map<String, Object?> serialized =
          element.toDiagnosticsNode().toJsonMap(delegate);
      final Object? rawLocation = serialized['creationLocation'];
      if (rawLocation is! Map<String, Object?>) {
        return null;
      }
      final String? file = rawLocation['file'] as String?;
      final int? line = rawLocation['line'] as int?;
      if (file == null || line == null) {
        return null;
      }
      return '${_readableFile(file)}:$line';
    } on Object {
      return null;
    }
  }

  String _readableFile(String file) {
    final Uri? uri = Uri.tryParse(file);
    if (uri != null && uri.scheme == 'file') {
      return uri.toFilePath();
    }
    return file;
  }
}
