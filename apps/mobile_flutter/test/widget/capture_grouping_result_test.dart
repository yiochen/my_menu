import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_correction.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_grouping_result.dart';

void main() {
  testWidgets('teaches multi-select and offers two drop destinations',
      (WidgetTester tester) async {
    await _pumpResult(tester, _groupedState());

    expect(find.text('3 photos organized into 2 dishes'), findsOneWidget);
    expect(
      find.text(
        'Every photo is shown under the dish where it was organized.',
      ),
      findsOneWidget,
    );
    expect(find.text('Miso Salmon'), findsOneWidget);
    expect(find.text('Charred Corn Ramen'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Miso Salmon, 2 source photos')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Charred Corn Ramen, 1 source photo')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('correct_capture_grouping')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey<String>('undo_capture_grouping')),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('correct_capture_grouping')),
    );
    await tester.pump();
    expect(find.text('Correct grouping'), findsOneWidget);
    expect(find.text('Select, then drag'), findsOneWidget);
    expect(
      find.text(
        'Tap photos to select one or more. Drag them onto another dish.',
      ),
      findsOneWidget,
    );

    final Finder selectablePhotos = find.bySemanticsLabel(
      'Select capture photo',
    );
    expect(selectablePhotos, findsAtLeastNWidgets(2));
    await tester.tap(selectablePhotos.at(0));
    await tester.tap(selectablePhotos.at(1));
    await tester.pump();

    expect(find.text('2 photos selected'), findsOneWidget);
    expect(
      find.text('2 selected · drag them together or tap a destination.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('make_new_dish_drop_zone')),
      120,
    );
    expect(find.text('Another dish in your Menu'), findsOneWidget);
    expect(find.text('Make a new dish'), findsOneWidget);
  });

  testWidgets('new dish interaction uses the reviewed title and Create CTA',
      (WidgetTester tester) async {
    await _pumpResult(tester, _groupedState());
    await tester.tap(
      find.byKey(const ValueKey<String>('correct_capture_grouping')),
    );
    await tester.pump();
    final Finder destination =
        find.byKey(const ValueKey<String>('make_new_dish_drop_zone'));
    await tester.scrollUntilVisible(destination, 120);
    await tester.tap(destination);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Make a new dish'),
      ),
      findsOneWidget,
    );
    expect(
        find.text('3 selected photos will start one history.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('new_capture_dish_name')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('create_capture_dish')),
      findsOneWidget,
    );
    expect(find.text('Create separate dish'), findsNothing);
  });

  testWidgets('searches only dishes outside the organized result',
      (WidgetTester tester) async {
    await _pumpResult(tester, _groupedState());
    await tester.tap(
      find.byKey(const ValueKey<String>('correct_capture_grouping')),
    );
    await tester.pump();
    final Finder destination =
        find.byKey(const ValueKey<String>('move_to_menu_drop_zone'));
    await tester.scrollUntilVisible(destination, 120);
    await tester.tap(destination);
    await tester.pumpAndSettle();

    expect(find.text('Move to another dish'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('capture_dish_search')),
      findsOneWidget,
    );
    expect(find.text('Crispy Tofu Salad'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('capture_destination_dish_c')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('capture_destination_dish_a')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('capture_destination_dish_b')),
      findsNothing,
    );
  });

  testWidgets('shows pending correction status and undo action',
      (WidgetTester tester) async {
    await _pumpResult(tester, _groupedState(withCorrection: true));

    await tester.scrollUntilVisible(find.text('Saved here · syncing'), 120);

    expect(find.text('Saved here · syncing'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('undo_capture_grouping')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey<String>('undo_capture_grouping')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('shows every unclassified photo with assign and delete actions',
      (WidgetTester tester) async {
    await _pumpResult(tester, _groupedState(withUnclassified: true));

    expect(
      find.byKey(const ValueKey<String>('unclassified_capture_section')),
      findsOneWidget,
    );
    expect(find.text('Unclassified photos'), findsOneWidget);
    expect(
      find.text('1 photo was left unclassified and shown below.'),
      findsOneWidget,
    );
    expect(
      find.text('No prepared dish was recognized.'),
      findsOneWidget,
    );

    final Finder assign = find.byKey(
      const ValueKey<String>('assign_unclassified_capture_rejected'),
    );
    await tester.scrollUntilVisible(assign, 120);
    await tester.tap(assign);
    await tester.pumpAndSettle();
    expect(find.text('Assign photo'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('assign_to_existing_dish')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('assign_to_new_dish')),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    final Finder delete = find.byKey(
      const ValueKey<String>('delete_unclassified_capture_rejected'),
    );
    await tester.scrollUntilVisible(delete, 120);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(find.text('Delete photo?'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('confirm_delete_unclassified')),
      findsOneWidget,
    );
  });
}

Future<void> _pumpResult(WidgetTester tester, MyMenuState state) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CaptureGroupingResultView(
          state: state,
          batchId: 'batch_1',
          onClose: () {},
        ),
      ),
    ),
  );
  await tester.pump();
}

MyMenuState _groupedState({
  bool withCorrection = false,
  bool withUnclassified = false,
}) {
  final DateTime now = DateTime.utc(2026, 7, 27);
  final List<CaptureItem> captures = <CaptureItem>[
    CaptureItem(
      id: 'capture_a',
      batchId: 'batch_1',
      kind: CaptureItemKind.photo,
      status: CaptureItemStatus.applied,
      createdAt: now,
      appliedDishId: 'dish_a',
    ),
    CaptureItem(
      id: 'capture_b',
      batchId: 'batch_1',
      ordinal: 1,
      kind: CaptureItemKind.photo,
      status: CaptureItemStatus.applied,
      createdAt: now,
      appliedDishId: 'dish_a',
    ),
    CaptureItem(
      id: 'capture_c',
      batchId: 'batch_1',
      ordinal: 2,
      kind: CaptureItemKind.photo,
      status: CaptureItemStatus.applied,
      createdAt: now,
      appliedDishId: 'dish_b',
    ),
    if (withUnclassified)
      CaptureItem(
        id: 'capture_rejected',
        batchId: 'batch_1',
        ordinal: 3,
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.discarded,
        createdAt: now,
        failureReason: 'No prepared dish was recognized.',
      ),
  ];
  return MyMenuState.forTesting(
    dishes: <Dish>[
      _dish('dish_a', 'Miso Salmon'),
      _dish('dish_b', 'Charred Corn Ramen'),
      _dish('dish_c', 'Crispy Tofu Salad'),
    ],
    captureBatches: <CaptureBatch>[
      CaptureBatch(
        id: 'batch_1',
        status: CaptureBatchStatus.applied,
        createdAt: now,
        updatedAt: now,
        items: captures,
      ),
    ],
    captureItems: captures,
    captureCorrections: withCorrection
        ? <CaptureCorrection>[
            CaptureCorrection(
              id: 'correction_1',
              batchId: 'batch_1',
              type: CaptureCorrectionType.move,
              captureIds: const <String>['capture_a'],
              previousDishIds: const <String, String>{
                'capture_a': 'dish_a',
              },
              targetDishId: 'dish_b',
              status: CaptureCorrectionStatus.pending,
              createdAt: now,
              updatedAt: now,
            ),
          ]
        : const <CaptureCorrection>[],
  );
}

Dish _dish(String id, String title) {
  return Dish(
    id: id,
    title: title,
    description: '',
    heroImageUrl: '',
    category: 'Captured',
    prepMinutes: 0,
    difficulty: 'Not set',
    madeCount: 1,
    lastMadeLabel: 'Today',
    ingredients: const <String>[],
    recipeSteps: const <String>[],
    notes: const <DishNote>[],
    sourcePhotos: const <SourcePhoto>[],
  );
}
