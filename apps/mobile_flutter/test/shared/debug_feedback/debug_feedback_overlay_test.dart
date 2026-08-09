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
    expect(
      find.byKey(const ValueKey<String>('debug_feedback_highlight')),
      findsOneWidget,
    );
    expect(controller.collecting, isFalse);
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
    expect(controller.collecting, isTrue);
  });

  testWidgets('retargets with a background tap and updates the highlight', (
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

    final Finder highlight =
        find.byKey(const ValueKey<String>('debug_feedback_highlight'));
    final CustomPainter initialPainter =
        tester.widget<CustomPaint>(highlight).painter!;
    await tester.enterText(
      find.byKey(const ValueKey<String>('debug_feedback_comment')),
      'Update the alternate action.',
    );
    await tester.pump();

    await tester.tapAt(
      tester.getCenter(
        find.byKey(const ValueKey<String>('feedback_test_alternate')),
      ),
    );
    await tester.pump();

    expect(find.text('Alternate action'), findsOneWidget);
    expect(find.text('Update the alternate action.'), findsOneWidget);
    final CustomPainter updatedPainter =
        tester.widget<CustomPaint>(highlight).painter!;
    expect(updatedPainter.shouldRepaint(initialPainter), isTrue);

    await tester.tap(
      find.byKey(const ValueKey<String>('debug_feedback_save_comment')),
    );
    await tester.pump();

    expect(controller.entries.single.target.id, 'detail.alternate');
    expect(controller.collecting, isTrue);
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

  testWidgets('deleted comment text stays deleted across a parent rebuild', (
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

    final Finder commentField =
        find.byKey(const ValueKey<String>('debug_feedback_comment'));
    await tester.enterText(commentField, 'Keep this old suffix');
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'Keep this',
        selection: TextSelection.collapsed(offset: 9),
      ),
    );
    await tester.pump();

    await tester.pumpWidget(_FeedbackTestApp(controller: controller));
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'Keep this replacement',
        selection: TextSelection.collapsed(offset: 21),
      ),
    );
    await tester.pump();

    expect(find.text('Keep this replacement'), findsOneWidget);
    expect(find.textContaining('old suffix'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('debug_feedback_save_comment')),
    );
    await tester.pump();

    expect(controller.entries.single.comment, 'Keep this replacement');
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
          body: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 120),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FeedbackTarget(
                    id: 'detail.continue',
                    label: 'Continue action',
                    child: FilledButton(
                      key: ValueKey<String>('feedback_test_action'),
                      onPressed: _noOp,
                      child: Text('Continue'),
                    ),
                  ),
                  SizedBox(height: 32),
                  FeedbackTarget(
                    id: 'detail.alternate',
                    label: 'Alternate action',
                    child: FilledButton(
                      key: ValueKey<String>('feedback_test_alternate'),
                      onPressed: _noOp,
                      child: Text('Alternate'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _noOp() {}
