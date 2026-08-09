import 'package:mymenu/shared/debug_feedback/debug_feedback_models.dart';

class DebugFeedbackPromptBuilder {
  const DebugFeedbackPromptBuilder({
    this.appRevision = const String.fromEnvironment('GIT_COMMIT'),
  });

  final String appRevision;

  String build(List<DebugFeedbackEntry> entries) {
    final StringBuffer output = StringBuffer()
      ..writeln('# UI feedback implementation task')
      ..writeln()
      ..writeln('Implement all UI feedback below in the current repository.')
      ..writeln()
      ..writeln('Before editing:')
      ..writeln('- Read the repository instructions, including AGENTS.md.')
      ..writeln(
          '- Inspect every referenced component and its surrounding screen.')
      ..writeln(
          '- Use target IDs, widget paths, visible text, and source locations '
          'to locate code whose line numbers have moved.')
      ..writeln()
      ..writeln('Implementation guidance:')
      ..writeln(
          '- Treat each comment as product intent, not necessarily a literal '
          'implementation prescription.')
      ..writeln('- Resolve related comments cohesively.')
      ..writeln(
          '- Preserve behavior unless feedback requests a behavior change.')
      ..writeln("- Reuse the project's theme, components, and conventions.")
      ..writeln('- Do not modify unrelated areas.')
      ..writeln()
      ..writeln('After implementation:')
      ..writeln('- Add or update proportionate tests.')
      ..writeln(
          "- Run the repository's documented analysis, structural checks, "
          'and relevant tests.')
      ..writeln(
          '- Summarize each resolved item and identify anything unresolved.');

    if (appRevision.trim().isNotEmpty) {
      output
        ..writeln()
        ..writeln('App revision: ${appRevision.trim()}');
    }

    for (int index = 0; index < entries.length; index += 1) {
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
      ..writeln()
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
