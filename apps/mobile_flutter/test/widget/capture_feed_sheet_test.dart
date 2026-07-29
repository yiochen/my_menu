import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/ai/ai_job.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_feed_sheet.dart';

void main() {
  testWidgets('shows capture results first and completed AI card opens result',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final MyMenuState state = _state();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () => showCaptureFeedSheet(context, state),
                child: const Text('Open captures'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open captures'));
    await tester.pumpAndSettle();

    expect(find.text('Capture results'), findsOneWidget);
    expect(find.text('AI activity'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Capture results')).dy,
      lessThan(tester.getTopLeft(find.text('AI activity')).dy),
    );
    expect(find.text('Open result'), findsOneWidget);
    expect(find.text('Remove upload'), findsNothing);

    await tester.tap(find.text('Open result'));
    await tester.pumpAndSettle();

    expect(find.text('3 photos organized into 2 dishes'), findsOneWidget);
    expect(find.text('Correct grouping'), findsOneWidget);
  });

  testWidgets('pending capture batch can be removed from processing status',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final DateTime now = DateTime.utc(2026, 7, 28, 12);
    final List<CaptureItem> items = <CaptureItem>[
      CaptureItem(
        id: 'pending_a',
        batchId: 'pending_batch',
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.pendingUpload,
        createdAt: now,
      ),
      CaptureItem(
        id: 'pending_b',
        batchId: 'pending_batch',
        ordinal: 1,
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.uploading,
        createdAt: now,
      ),
    ];
    final MyMenuState state = MyMenuState.forTesting(
      captureItems: items,
      captureBatches: <CaptureBatch>[
        CaptureBatch(
          id: 'pending_batch',
          status: CaptureBatchStatus.uploading,
          createdAt: now,
          updatedAt: now,
          items: items,
        ),
      ],
    );
    addTearDown(state.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () => showCaptureFeedSheet(context, state),
                child: const Text('Open captures'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open captures'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove upload'));
    await tester.pumpAndSettle();

    expect(find.text('Remove pending upload?'), findsOneWidget);
    expect(find.textContaining('phone’s library'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('confirm_remove_capture_batch')),
    );
    await tester.pumpAndSettle();

    expect(state.captureBatches, isEmpty);
    expect(state.captureItems, isEmpty);
    expect(find.text('No captures yet.'), findsOneWidget);
  });
}

MyMenuState _state() {
  final DateTime now = DateTime.utc(2026, 7, 27, 12);
  final List<CaptureItem> items = <CaptureItem>[
    _capture('capture_a', 0, 'dish_a', now),
    _capture('capture_b', 1, 'dish_a', now),
    _capture('capture_c', 2, 'dish_b', now),
  ];
  return MyMenuState.forTesting(
    dishes: <Dish>[
      _dish('dish_a', 'Miso Salmon'),
      _dish('dish_b', 'Charred Corn Ramen'),
    ],
    captureItems: items,
    captureBatches: <CaptureBatch>[
      CaptureBatch(
        id: 'batch_1',
        status: CaptureBatchStatus.applied,
        createdAt: now,
        updatedAt: now,
        items: items,
      ),
    ],
    aiJobs: <AiJob>[
      AiJob(
        id: 'grouping_1',
        type: AiJobType.batchGrouping,
        subjectId: 'batch_1',
        status: AiJobStatus.succeeded,
        idempotencyKey: 'batch_grouping:batch_1:1',
        inputHash: 'hash',
        inputVersion: '1',
        attemptCount: 1,
        maxAttempts: 3,
        promptVersion: '1',
        modelVersion: 'gemini-flash-latest',
        schemaVersion: '1',
        createdAt: now,
        updatedAt: now,
      ),
    ],
  );
}

CaptureItem _capture(
  String id,
  int ordinal,
  String dishId,
  DateTime createdAt,
) {
  return CaptureItem(
    id: id,
    batchId: 'batch_1',
    ordinal: ordinal,
    kind: CaptureItemKind.photo,
    status: CaptureItemStatus.applied,
    createdAt: createdAt,
    appliedDishId: dishId,
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
