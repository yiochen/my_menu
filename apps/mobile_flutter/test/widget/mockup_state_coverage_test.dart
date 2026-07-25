import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/add_idea_sheet.dart';
import 'package:mymenu/features/capture/capture_outcome_sheet.dart';
import 'package:mymenu/features/improve_cover/improve_cover_dialog.dart';
import 'package:mymenu/features/review/review_sheet.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

void main() {
  group('mockup state coverage at 390×844 logical pixels', () {
    for (final ImproveCoverStep step in ImproveCoverStep.values) {
      testWidgets('renders improve-cover ${step.name}', (
        WidgetTester tester,
      ) async {
        final MyMenuState state = MyMenuState();
        await _pumpMockupViewport(
          tester,
          ImproveCoverFlow(
            state: state,
            dishId: 'dish_salmon',
            initialStep: step,
          ),
        );

        expect(tester.takeException(), isNull);
      });
    }

    for (final CaptureOutcomeStep step in CaptureOutcomeStep.values) {
      testWidgets('renders capture outcome ${step.name}', (
        WidgetTester tester,
      ) async {
        await _pumpMockupViewport(
          tester,
          CaptureOutcomeSheet(
            state: MyMenuState(),
            initialStep: step,
            organizedStep: CaptureOutcomeStep.matched,
          ),
          settle: step != CaptureOutcomeStep.saved,
        );

        expect(tester.takeException(), isNull);
        if (step == CaptureOutcomeStep.saved) {
          expect(find.text('Got it. You’re done.'), findsOneWidget);
          await tester.pump(const Duration(seconds: 1));
        }
      });
    }

    testWidgets('retains an idea note after validation', (
      WidgetTester tester,
    ) async {
      await _pumpMockupViewport(
        tester,
        const AddIdeaSheet(),
        settle: false,
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('idea_note_field')),
        'Use lime and scallions.',
      );
      await tester.tap(find.text('Save idea'));
      await tester.pump();

      expect(
        find.text('Add a dish name or a few words about the idea.'),
        findsOneWidget,
      );
      expect(find.text('Use lime and scallions.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders review decision and empty alternate search', (
      WidgetTester tester,
    ) async {
      await _pumpMockupViewport(tester, ReviewFlow(state: MyMenuState()));
      expect(find.text('Where should this go?'), findsOneWidget);

      await tester.tap(find.text('Choose a different dish'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a different dish'), findsOneWidget);
      expect(find.text('No matching dish'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpMockupViewport(
  WidgetTester tester,
  Widget child, {
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.data,
      home: Scaffold(body: child),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}
