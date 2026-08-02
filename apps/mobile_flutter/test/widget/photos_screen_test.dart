import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/photos/photo_gallery_tile.dart';
import 'package:mymenu/features/photos/photos_screen.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

void main() {
  testWidgets('gallery filters by assignment and communicates photo state',
      (WidgetTester tester) async {
    final MyMenuState state = _state();
    await tester.pumpWidget(_app(state));

    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Unorganized 2'), findsOneWidget);
    expect(find.text('Organized 1'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('photo_tile_unorganized')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('photo_tile_review')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('photo_tile_organized')),
        findsOneWidget);

    final semantics = tester.getSemantics(
      find.byKey(const ValueKey<String>('photo_tile_review')),
    );
    expect(semantics.label, contains('review'));

    await tester.tap(find.text('Unorganized 2'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('photo_tile_organized')),
        findsNothing);
    expect(find.byType(PhotoGalleryTile), findsNWidgets(2));
  });

  testWidgets('tapping a photo opens immediate manual organization actions',
      (WidgetTester tester) async {
    final MyMenuState state = _state();
    await tester.pumpWidget(_app(state));

    await tester.tap(
      find.byKey(const ValueKey<String>('photo_tile_unorganized')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add to a dish'), findsOneWidget);
    expect(find.text('Create a new dish'), findsOneWidget);
    expect(find.textContaining('ready whenever'), findsOneWidget);
  });

  testWidgets(
      'long press exposes multi-photo organize split and delete actions',
      (WidgetTester tester) async {
    final MyMenuState state = _state();
    await tester.pumpWidget(_app(state));

    await tester.longPress(
      find.byKey(const ValueKey<String>('photo_tile_unorganized')),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
    expect(find.byTooltip('Add selected photos to a dish'), findsOneWidget);
    expect(find.byTooltip('Split selected photos into a new dish'),
        findsOneWidget);
    expect(find.byTooltip('Delete selected photos'), findsOneWidget);
  });
}

Widget _app(MyMenuState state) {
  return MyMenuScope(
    notifier: state,
    child: MaterialApp(
      theme: AppTheme.data,
      home: PhotosScreen(onBack: () {}),
    ),
  );
}

MyMenuState _state() {
  final Dish dish = Dish(
    id: 'dish_1',
    title: 'Miso salmon',
    description: '',
    heroImageUrl: '',
    category: 'Dinner',
    prepMinutes: 0,
    difficulty: '',
    madeCount: 1,
    lastMadeLabel: 'Today',
    ingredients: const <String>[],
    recipeSteps: const <String>[],
    notes: const <DishNote>[],
    sourcePhotos: const <SourcePhoto>[],
  );
  final DateTime now = DateTime.now();
  return MyMenuState.forTesting(
    dishes: <Dish>[dish],
    captureItems: <CaptureItem>[
      CaptureItem(
        id: 'unorganized',
        batchId: 'batch_1',
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.localOnly,
        createdAt: now,
        localMediaRef: '',
        capturedLocalDate: _dateKey(now),
      ),
      CaptureItem(
        id: 'review',
        batchId: 'batch_2',
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.needsReview,
        createdAt: now.subtract(const Duration(minutes: 1)),
        localMediaRef: '',
        capturedLocalDate: _dateKey(now),
      ),
      CaptureItem(
        id: 'organized',
        batchId: 'batch_3',
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.applied,
        createdAt: now.subtract(const Duration(minutes: 2)),
        localMediaRef: '',
        capturedLocalDate: _dateKey(now),
        appliedDishId: dish.id,
      ),
    ],
    reviewItems: const <ReviewItem>[
      ReviewItem(
        id: 'review_1',
        captureId: 'review',
        summary: 'Could be miso salmon',
        suggestedDishIds: <String>['dish_1'],
        confidenceLabel: '61%',
      ),
    ],
  );
}

String _dateKey(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
