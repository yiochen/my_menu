import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_controller.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_models.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_prompt.dart';

void main() {
  const DebugFeedbackTargetSnapshot target = DebugFeedbackTargetSnapshot(
    id: 'detail.primary_action',
    label: 'Primary action',
    route: 'DetailScreen',
    widgetType: 'FilledButton',
    widgetPath: <String>['DetailScreen', 'ActionPanel', 'FilledButton'],
    visibleText: 'Continue',
    semantics: 'Continue, button',
    sourceLocation: 'lib/features/detail/action_panel.dart:42',
  );

  test('builds a generic self-contained agent prompt', () {
    final DebugFeedbackController controller = DebugFeedbackController(
      promptBuilder: const DebugFeedbackPromptBuilder(appRevision: 'abc123'),
    );
    addTearDown(controller.dispose);

    controller.add(
      target: target,
      comment: '  Make this action less prominent.  ',
      createdAt: DateTime.utc(2026, 8, 8),
    );

    final String prompt = controller.buildAgentPrompt();
    expect(prompt, contains('# UI feedback implementation task'));
    expect(prompt, contains('Read the repository instructions'));
    expect(prompt, contains('Target: detail.primary_action'));
    expect(prompt, contains('ActionPanel > FilledButton'));
    expect(prompt, contains('Visible text: Continue'));
    expect(prompt, contains('Make this action less prominent.'));
    expect(prompt, contains('App revision: abc123'));
    expect(prompt, isNot(contains('MyMenu')));
  });

  test('persists additions and clearing', () async {
    final List<List<DebugFeedbackEntry>> writes = <List<DebugFeedbackEntry>>[];
    final DebugFeedbackController controller = DebugFeedbackController(
      persistEntries: (List<DebugFeedbackEntry> entries) async {
        writes.add(entries);
      },
    );
    addTearDown(controller.dispose);

    controller.add(target: target, comment: 'Adjust spacing.');
    await Future<void>.delayed(Duration.zero);
    controller.clear();
    await Future<void>.delayed(Duration.zero);

    expect(writes, hasLength(2));
    expect(writes.first.single.comment, 'Adjust spacing.');
    expect(writes.last, isEmpty);
  });

  test('feedback entries round-trip through JSON', () {
    final DebugFeedbackEntry original = DebugFeedbackEntry(
      target: target,
      comment: 'Use the secondary style.',
      createdAt: DateTime.utc(2026, 8, 8, 12, 30),
    );

    final DebugFeedbackEntry restored = DebugFeedbackEntry.fromJson(
      original.toJson(),
    );

    expect(restored.target.id, original.target.id);
    expect(restored.target.widgetPath, original.target.widgetPath);
    expect(restored.comment, original.comment);
    expect(restored.createdAt, original.createdAt);
  });
}
