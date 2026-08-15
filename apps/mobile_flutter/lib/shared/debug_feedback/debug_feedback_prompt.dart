import 'package:mymenu/shared/debug_feedback/debug_feedback_models.dart';

class DebugFeedbackPromptBuilder {
  const DebugFeedbackPromptBuilder();

  String build(List<DebugFeedbackEntry> entries) {
    final StringBuffer output = StringBuffer();
    for (int index = 0; index < entries.length; index += 1) {
      if (index > 0) {
        output.writeln();
      }
      _writeEntry(output, index + 1, entries[index]);
    }
    return output.toString().trimRight();
  }

  void _writeEntry(
    StringBuffer output,
    int number,
    DebugFeedbackEntry entry,
  ) {
    final DebugFeedbackTargetSnapshot target = entry.target;
    output
      ..writeln('## Feedback $number')
      ..writeln()
      ..writeln('Target: ${target.id ?? target.label}')
      ..writeln('Description: ${target.label}')
      ..writeln('Captured: ${entry.createdAt.toLocal().toIso8601String()}');
    _writeOptional(output, 'Screen/route', target.route);
    _writeOptional(output, 'Source', target.sourceLocation);
    output
      ..writeln('Widget: ${target.widgetType}')
      ..writeln('Widget path: ${target.widgetPath.join(' > ')}');
    _writeOptional(output, 'Visible text', target.visibleText);
    _writeOptional(output, 'Accessibility', target.semantics);
    output
      ..writeln()
      ..writeln('Comment:')
      ..writeln(entry.comment.trim());
  }

  void _writeOptional(StringBuffer output, String name, String? value) {
    if (value != null && value.trim().isNotEmpty) {
      output.writeln('$name: ${value.trim()}');
    }
  }
}
