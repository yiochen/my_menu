import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_history_content.dart';
import 'package:mymenu/features/menu/menu_exit_transition.dart';
import 'package:mymenu/features/menu/menu_grid_card.dart';
import 'package:mymenu/features/menu/menu_screen.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

void main() {
  testWidgets('exit snapshot survives until a dilated animation completes', (
    WidgetTester tester,
  ) async {
    timeDilation = 5;
    addTearDown(() => timeDilation = 1);
    var removing = false;
    var visible = true;
    late StateSetter rebuild;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            rebuild = setState;
            return visible
                ? MenuExitTransition(
                    removing: removing,
                    duration: const Duration(milliseconds: 420),
                    onExitCompleted: () {
                      rebuild(() => visible = false);
                    },
                    child: const SizedBox(
                      key: ValueKey<String>('dilated_exit_snapshot'),
                      width: 100,
                      height: 100,
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
    );

    rebuild(() => removing = true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.byKey(const ValueKey<String>('dilated_exit_snapshot')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 1200));
    expect(
      find.byKey(const ValueKey<String>('dilated_exit_snapshot')),
      findsNothing,
    );
    timeDilation = 1;
    await tester.pump();
  });

  testWidgets('menu actually orders dishes newest first', (
    WidgetTester tester,
  ) async {
    final Dish oldDish = seededDishes.first.copyWith(
      title: 'Older dish',
      createdAt: DateTime.utc(2026, 7),
    );
    final Dish newDish = seededDishes.last.copyWith(
      title: 'Newest dish',
      createdAt: DateTime.utc(2026, 7, 27),
    );
    final MyMenuState state = MyMenuState.forTesting(
      dishes: <Dish>[oldDish, newDish],
    );
    addTearDown(state.dispose);

    await _pumpMenu(tester, state);

    final List<MenuGridCard> cards =
        tester.widgetList<MenuGridCard>(find.byType(MenuGridCard)).toList();
    expect(cards.map((MenuGridCard card) => card.dish.title), <String>[
      'Newest dish',
      'Older dish',
    ]);
  });

  testWidgets('active capture appears as a tappable processing dish', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.utc(2026, 7, 27, 12);
    final CaptureItem capture = CaptureItem(
      id: 'capture_1',
      batchId: 'batch_1',
      kind: CaptureItemKind.photo,
      status: CaptureItemStatus.uploading,
      createdAt: now,
    );
    final MyMenuState state = MyMenuState.forTesting(
      dishes: <Dish>[seededDishes.first],
      captureBatches: <CaptureBatch>[
        CaptureBatch(
          id: 'batch_1',
          status: CaptureBatchStatus.uploading,
          createdAt: now,
          updatedAt: now,
          items: <CaptureItem>[capture],
        ),
      ],
      captureItems: <CaptureItem>[capture],
    );
    addTearDown(state.dispose);

    await _pumpMenu(tester, state);

    final Finder placeholder =
        find.byKey(const ValueKey<String>('processing_dish_batch_1'));
    expect(placeholder, findsOneWidget);
    expect(find.text('Organizing photo'), findsOneWidget);
    expect(find.text('Tap for processing status'), findsOneWidget);

    await tester.tap(placeholder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Recent Captures'), findsOneWidget);
    expect(find.text('Uploading'), findsOneWidget);
  });

  testWidgets('history renders real occasion dates, photos, and grouping', (
    WidgetTester tester,
  ) async {
    final Dish dish = seededDishes.first.copyWith(
      madeCount: 2,
      sourcePhotos: <SourcePhoto>[
        SourcePhoto(
          id: 'photo_1',
          url: 'https://example.com/1.jpg',
          capturedLabel: 'Jul 27',
          cookingOccasionId: 'occasion_new',
          capturedAt: DateTime.utc(2026, 7, 27, 12),
        ),
        SourcePhoto(
          id: 'photo_2',
          url: 'https://example.com/2.jpg',
          capturedLabel: 'Jul 27',
          cookingOccasionId: 'occasion_new',
          capturedAt: DateTime.utc(2026, 7, 27, 12, 1),
        ),
        SourcePhoto(
          id: 'photo_3',
          url: 'https://example.com/3.jpg',
          capturedLabel: 'Jul 20',
          cookingOccasionId: 'occasion_old',
          capturedAt: DateTime.utc(2026, 7, 20, 18),
          note: 'Use less salt next time.',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.data,
        home: Scaffold(
          body: SingleChildScrollView(child: DishHistoryContent(dish: dish)),
        ),
      ),
    );

    final BuildContext historyContext =
        tester.element(find.byType(DishHistoryContent));
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(historyContext);
    expect(find.text('2 times made'), findsOneWidget);
    expect(find.text('3 source photos across 2 cooking occasions'),
        findsOneWidget);
    expect(
      find.text(localizations.formatMediumDate(DateTime.utc(2026, 7, 27, 12))),
      findsOneWidget,
    );
    expect(
      find.text(localizations.formatMediumDate(DateTime.utc(2026, 7, 20, 18))),
      findsOneWidget,
    );
    expect(find.text('Cook #2'), findsOneWidget);
    expect(find.text('Cook #1'), findsOneWidget);
    expect(find.text('Use less salt next time.'), findsOneWidget);
    expect(find.text('July 18, 2026'), findsNothing);
  });

  testWidgets('idea dish history is empty without deleting the dish', (
    WidgetTester tester,
  ) async {
    final Dish idea = seededDishes.first.copyWith(
      madeCount: 0,
      sourcePhotos: const <SourcePhoto>[],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.data,
        home: Scaffold(body: DishHistoryContent(dish: idea)),
      ),
    );

    expect(find.text('No cooking history yet'), findsOneWidget);
    expect(find.textContaining('Ideas can live in your Menu'), findsOneWidget);
  });

  testWidgets('long press replaces the sticky header with multi-select', (
    WidgetTester tester,
  ) async {
    final Dish idea = seededDishes.first.copyWith(
      id: 'idea',
      title: 'Dinner idea',
      madeCount: 0,
      sourcePhotos: const <SourcePhoto>[],
    );
    final Dish cooked = seededDishes.last.copyWith(
      id: 'cooked',
      title: 'Cooked dish',
    );
    final MyMenuState state = MyMenuState.forTesting(
      dishes: <Dish>[idea, cooked],
    );
    addTearDown(state.dispose);
    await _pumpMenu(tester, state);

    expect(
      find.byKey(const ValueKey<String>('menu_compact_search_header')),
      findsOneWidget,
    );
    expect(find.text('Select'), findsNothing);

    await tester.longPress(
      find.byKey(const ValueKey<String>('menu_dish_idea')),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey<String>('menu_selection_header')),
      findsOneWidget,
    );
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('menu_dish_cooked')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('2 selected'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('menu_delete_action_bar')),
      findsOneWidget,
    );
  });

  testWidgets('Select all includes processing placeholders', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.utc(2026, 7, 28);
    final CaptureItem capture = CaptureItem(
      id: 'capture_processing',
      batchId: 'batch_processing',
      kind: CaptureItemKind.photo,
      status: CaptureItemStatus.uploading,
      createdAt: now,
    );
    final MyMenuState state = MyMenuState.forTesting(
      dishes: <Dish>[seededDishes.first, seededDishes.last],
      captureBatches: <CaptureBatch>[
        CaptureBatch(
          id: 'batch_processing',
          status: CaptureBatchStatus.uploading,
          createdAt: now,
          updatedAt: now,
          items: <CaptureItem>[capture],
        ),
      ],
      captureItems: <CaptureItem>[capture],
    );
    addTearDown(state.dispose);
    await _pumpMenu(tester, state);

    await tester.longPress(
      find.byKey(ValueKey<String>('menu_dish_${seededDishes.first.id}')),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const ValueKey<String>('menu_select_all')));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('3 selected'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>('processing_dish_batch_processing'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('long press selects and removes a processing placeholder', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final DateTime now = DateTime.utc(2026, 7, 28);
    final CaptureItem capture = CaptureItem(
      id: 'capture_to_remove',
      batchId: 'batch_to_remove',
      kind: CaptureItemKind.photo,
      status: CaptureItemStatus.uploading,
      createdAt: now,
    );
    final MyMenuState state = MyMenuState.forTesting(
      captureBatches: <CaptureBatch>[
        CaptureBatch(
          id: 'batch_to_remove',
          status: CaptureBatchStatus.uploading,
          createdAt: now,
          updatedAt: now,
          items: <CaptureItem>[capture],
        ),
      ],
      captureItems: <CaptureItem>[capture],
    );
    addTearDown(state.dispose);
    await _pumpMenu(tester, state);

    await tester.longPress(
      find.byKey(const ValueKey<String>('processing_dish_batch_to_remove')),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('1 selected'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('menu_delete_selected')),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Remove this pending upload?'), findsOneWidget);

    final Finder confirm =
        find.byKey(const ValueKey<String>('menu_confirm_delete'));
    tester.widget<FilledButton>(confirm).onPressed!();
    await tester.pump(const Duration(milliseconds: 100));

    expect(state.captureBatches, isEmpty);
    expect(state.pendingCaptureBatchDeletionCount, 1);

    // The card stays unchanged while the confirmation sheet closes.
    expect(
      find.byKey(const ValueKey<String>('processing_dish_batch_to_remove')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FadeTransition>(
            find
                .descendant(
                  of: find
                      .ancestor(
                        of: find.byKey(
                          const ValueKey<String>(
                            'processing_dish_batch_to_remove',
                          ),
                        ),
                        matching: find.byType(MenuExitTransition),
                      )
                      .first,
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value,
      1,
    );

    await tester.pump(const Duration(milliseconds: 180));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 210));
    final FadeTransition paintedFade = tester.widget<FadeTransition>(
      find
          .descendant(
            of: find
                .ancestor(
                  of: find.byKey(
                    const ValueKey<String>(
                      'processing_dish_batch_to_remove',
                    ),
                  ),
                  matching: find.byType(MenuExitTransition),
                )
                .first,
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(paintedFade.opacity.value, inExclusiveRange(0, 1));

    await tester.pump(const Duration(milliseconds: 210));

    expect(state.captureBatches, isEmpty);
    expect(find.text('Pending upload removed'), findsOneWidget);
    expect(state.pendingCaptureBatchDeletionCount, 1);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    expect(state.pendingCaptureBatchDeletionCount, 0);
  });

  testWidgets('dismissing Undo commits a pending upload deletion', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final DateTime now = DateTime.utc(2026, 7, 28);
    final CaptureItem capture = CaptureItem(
      id: 'capture_dismiss',
      batchId: 'batch_dismiss',
      kind: CaptureItemKind.photo,
      status: CaptureItemStatus.uploading,
      createdAt: now,
    );
    final MyMenuState state = MyMenuState.forTesting(
      captureBatches: <CaptureBatch>[
        CaptureBatch(
          id: 'batch_dismiss',
          status: CaptureBatchStatus.uploading,
          createdAt: now,
          updatedAt: now,
          items: <CaptureItem>[capture],
        ),
      ],
      captureItems: <CaptureItem>[capture],
    );
    addTearDown(state.dispose);
    await _pumpMenu(tester, state);

    await tester.longPress(
      find.byKey(const ValueKey<String>('processing_dish_batch_dismiss')),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(
      find.byKey(const ValueKey<String>('menu_delete_selected')),
    );
    await tester.pump(const Duration(milliseconds: 250));
    tester
        .widget<FilledButton>(
          find.byKey(const ValueKey<String>('menu_confirm_delete')),
        )
        .onPressed!();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    expect(state.pendingCaptureBatchDeletionCount, 1);

    final BuildContext menuContext = tester.element(find.byType(MenuScreen));
    ScaffoldMessenger.of(menuContext).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
    expect(state.pendingCaptureBatchDeletionCount, 0);
  });

  testWidgets('completed processing cards do not select their new dishes', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final DateTime now = DateTime.utc(2026, 7, 28);
    final Dish existing = seededDishes.first;
    final CaptureItem capture = CaptureItem(
      id: 'capture_finishing',
      batchId: 'batch_finishing',
      kind: CaptureItemKind.photo,
      status: CaptureItemStatus.classifying,
      createdAt: now,
    );
    final MyMenuState state = MyMenuState.forTesting(
      dishes: seededDishes,
      captureBatches: <CaptureBatch>[
        CaptureBatch(
          id: 'batch_finishing',
          status: CaptureBatchStatus.processing,
          createdAt: now,
          updatedAt: now,
          items: <CaptureItem>[capture],
        ),
      ],
      captureItems: <CaptureItem>[capture],
    );
    addTearDown(state.dispose);
    await _pumpMenu(tester, state);

    await tester.longPress(
      find.byKey(ValueKey<String>('menu_dish_${existing.id}')),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(
      find.byKey(const ValueKey<String>('processing_dish_batch_finishing')),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('2 selected'), findsOneWidget);

    await state.deleteCaptureBatch('batch_finishing');
    state.addIdea('newly organized dish');
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
    final MenuGridCard newCard = tester.widget<MenuGridCard>(
      find.ancestor(
        of: find.text('Newly Organized Dish'),
        matching: find.byType(MenuGridCard),
      ),
    );
    expect(newCard.selected, isFalse);
    expect(newCard.selectionMode, isTrue);
  });

  testWidgets('regular dish paints an intermediate exit frame', (
    WidgetTester tester,
  ) async {
    final Dish dish = seededDishes.first.copyWith(id: 'animated_dish');
    final MyMenuState state = MyMenuState.forTesting(dishes: <Dish>[dish]);
    addTearDown(state.dispose);
    await _pumpMenu(tester, state);

    await tester.longPress(
      find.byKey(const ValueKey<String>('menu_dish_animated_dish')),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(
      find.byKey(const ValueKey<String>('menu_delete_selected')),
    );
    await tester.pump(const Duration(milliseconds: 250));
    tester
        .widget<FilledButton>(
          find.byKey(const ValueKey<String>('menu_confirm_delete')),
        )
        .onPressed!();

    await tester.pump(const Duration(milliseconds: 280));
    await tester.pump(const Duration(milliseconds: 210));

    final FadeTransition paintedFade = tester.widget<FadeTransition>(
      find
          .descendant(
            of: find
                .ancestor(
                  of: find.byKey(
                    const ValueKey<String>('menu_dish_animated_dish'),
                  ),
                  matching: find.byType(MenuExitTransition),
                )
                .first,
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(paintedFade.opacity.value, inExclusiveRange(0, 1));
    expect(state.dishes, isEmpty);

    await tester.pump(const Duration(milliseconds: 220));
    tester.widget<SnackBarAction>(find.byType(SnackBarAction)).onPressed();
    await tester.pump();
    await tester.pumpAndSettle();
  });

  testWidgets('delete confirmation explains scope and Undo restores dishes', (
    WidgetTester tester,
  ) async {
    final Dish idea = seededDishes.first.copyWith(
      id: 'idea_to_delete',
      title: 'Dinner idea',
      madeCount: 0,
      sourcePhotos: const <SourcePhoto>[],
    );
    final MyMenuState state = MyMenuState.forTesting(dishes: <Dish>[idea]);
    addTearDown(state.dispose);
    await _pumpMenu(tester, state);

    await tester.longPress(
      find.byKey(const ValueKey<String>('menu_dish_idea_to_delete')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('menu_delete_selected')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete this dish?'), findsOneWidget);
    expect(find.textContaining('Cooking history, notes'), findsOneWidget);
    expect(find.textContaining('phone’s library'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey<String>('menu_keep_dishes')),
          )
          .width,
      closeTo(
        tester
            .getSize(
              find.byKey(const ValueKey<String>('menu_confirm_delete')),
            )
            .width,
        0.1,
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('menu_confirm_delete')),
    );
    await tester.pumpAndSettle();

    expect(state.dishes, isEmpty);
    expect(find.text('Dish deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(state.dishes.single.id, 'idea_to_delete');
    expect(
      find.byKey(const ValueKey<String>('menu_dish_idea_to_delete')),
      findsOneWidget,
    );
  });

  testWidgets('Keep dishes closes confirmation without changing selection', (
    WidgetTester tester,
  ) async {
    final Dish idea = seededDishes.first.copyWith(
      id: 'idea_to_keep',
      title: 'Keep this idea',
      madeCount: 0,
      sourcePhotos: const <SourcePhoto>[],
    );
    final MyMenuState state = MyMenuState.forTesting(dishes: <Dish>[idea]);
    addTearDown(state.dispose);
    await _pumpMenu(tester, state);

    await tester.longPress(
      find.byKey(const ValueKey<String>('menu_dish_idea_to_keep')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('menu_delete_selected')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('menu_keep_dishes')));
    await tester.pumpAndSettle();

    expect(state.dishes.single.id, 'idea_to_keep');
    expect(
      find.byKey(const ValueKey<String>('menu_delete_dialog')),
      findsNothing,
    );
    expect(find.text('1 selected'), findsOneWidget);
  });

  testWidgets('deletion commits after the Undo window closes', (
    WidgetTester tester,
  ) async {
    final Dish cooked = seededDishes.first.copyWith(id: 'finished_to_delete');
    final MyMenuState state = MyMenuState.forTesting(dishes: <Dish>[cooked]);
    addTearDown(state.dispose);
    await _pumpMenu(tester, state);

    await tester.longPress(
      find.byKey(const ValueKey<String>('menu_dish_finished_to_delete')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('menu_delete_selected')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('menu_confirm_delete')),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    await tester.pump();

    expect(state.dishes, isEmpty);
    expect(
      find.byKey(const ValueKey<String>('menu_dish_finished_to_delete')),
      findsNothing,
    );
  });
}

Future<void> _pumpMenu(WidgetTester tester, MyMenuState state) async {
  await tester.pumpWidget(
    MyMenuScope(
      notifier: state,
      child: MaterialApp(
        theme: AppTheme.data,
        home: Scaffold(
          body: MenuScreen(query: '', onQueryChanged: (_) {}),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}
