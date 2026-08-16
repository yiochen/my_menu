import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
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
            photoCount: 1,
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

    testWidgets('saved capture shows its real offline state', (
      WidgetTester tester,
    ) async {
      final DateTime now = DateTime(2026, 7, 25);
      final List<CaptureItem> items = <CaptureItem>[
        CaptureItem(
          id: 'offline_0',
          batchId: 'offline_batch',
          kind: CaptureItemKind.photo,
          status: CaptureItemStatus.pendingUpload,
          createdAt: now,
          localMediaRef: '/tmp/zero.jpg',
        ),
        CaptureItem(
          id: 'offline_1',
          batchId: 'offline_batch',
          ordinal: 1,
          kind: CaptureItemKind.photo,
          status: CaptureItemStatus.pendingUpload,
          createdAt: now,
          localMediaRef: '/tmp/one.jpg',
        ),
      ];
      final CaptureBatch batch = CaptureBatch(
        id: 'offline_batch',
        status: CaptureBatchStatus.pendingUpload,
        createdAt: now,
        updatedAt: now,
        items: items,
        failureReason: captureWaitingForConnectionReason,
      );
      final MyMenuState state = MyMenuState.forTesting(
        captureBatches: <CaptureBatch>[batch],
        captureItems: items,
      );

      await _pumpMockupViewport(
        tester,
        CaptureOutcomeSheet(
          state: state,
          initialStep: CaptureOutcomeStep.saved,
          organizedStep: CaptureOutcomeStep.matched,
          photoCount: 2,
          batchId: batch.id,
        ),
      );

      expect(find.text('Captured—even offline'), findsOneWidget);
      expect(find.text('2 photos safe on this device'), findsOneWidget);
      expect(
          find.textContaining('retry happens automatically'), findsOneWidget);
    });

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
