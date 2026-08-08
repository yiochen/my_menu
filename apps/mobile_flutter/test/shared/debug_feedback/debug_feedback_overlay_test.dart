import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_controller.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_overlay.dart';
import 'package:mymenu/shared/debug_feedback/feedback_target.dart';

void main() {
  testWidgets('selects an explicit meaningful target and saves a comment', (
    WidgetTester tester,
  ) async {
    final DebugFeedbackController controller = DebugFeedbackController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_FeedbackTestApp(controller: controller));
    controller.startCollecting();
    await tester.pump();

    await tester.tapAt(
      tester.getCenter(
        find.byKey(const ValueKey<String>('feedback_test_action')),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('debug_feedback_composer')),
      findsOneWidget,
    );
    expect(find.text('Continue action'), findsOneWidget);
    expect(find.textContaining('Padding'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey<String>('debug_feedback_comment')),
      'Make this action less prominent.',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('debug_feedback_save_comment')),
    );
    await tester.pump();

    expect(controller.entries, hasLength(1));
    expect(controller.entries.single.target.id, 'detail.continue');
    expect(
      controller.entries.single.target.sourceLocation,
      contains('debug_feedback_overlay_test.dart'),
    );
    expect(
      controller.entries.single.target.widgetPath,
      isNot(contains('Padding')),
    );
    expect(controller.entries.single.target.widgetPath.last, 'FilledButton');
    expect(
      controller.entries.single.comment,
      'Make this action less prominent.',
    );
    expect(
      find.byKey(const ValueKey<String>('debug_feedback_composer')),
      findsNothing,
    );
  });

  testWidgets('does not expose structural widgets as target choices', (
    WidgetTester tester,
  ) async {
    final DebugFeedbackController controller = DebugFeedbackController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_FeedbackTestApp(controller: controller));
    controller.startCollecting();
    await tester.pump();
    await tester.tapAt(
      tester.getCenter(
        find.byKey(const ValueKey<String>('feedback_test_action')),
      ),
    );
    await tester.pump();

    expect(find.textContaining(' meaningful targets'), findsOneWidget);
    expect(find.textContaining('Padding'), findsNothing);
    expect(find.textContaining('SizedBox'), findsNothing);
    expect(find.textContaining('Column'), findsNothing);
  });
}

class _FeedbackTestApp extends StatelessWidget {
  const _FeedbackTestApp({required this.controller});

  final DebugFeedbackController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DebugFeedbackOverlay(
        controller: controller,
        child: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: FeedbackTarget(
                id: 'detail.continue',
                label: 'Continue action',
                child: FilledButton(
                  key: ValueKey<String>('feedback_test_action'),
                  onPressed: _noOp,
                  child: Text('Continue'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _noOp() {}
