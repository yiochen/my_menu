import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';

void main() {
  group('MyMenuState', () {
    test('adds a dish idea to the front of the dish list', () {
      final MyMenuState state = MyMenuState();

      final int before = state.dishes.length;
      state.addIdea('crispy tofu bowls');

      expect(state.dishes.length, before + 1);
      expect(state.dishes.first.title, 'Crispy Tofu Bowls');
      expect(state.dishes.first.lastMadeLabel, 'Not cooked yet');
    });

    test('adds photo captures to the review queue', () {
      final MyMenuState state = MyMenuState()
        ..addPhotoCaptures(<String>[
          '/tmp/mymenu/capture_one.jpg',
          '/tmp/mymenu/capture_two.jpg',
        ]);

      final reviewItems = state.reviewItems;

      expect(reviewItems.first.imageRef, '/tmp/mymenu/capture_one.jpg');
      expect(
        reviewItems.first.summary,
        'Photo capture ready to organize.',
      );
      expect(reviewItems[1].imageRef, '/tmp/mymenu/capture_two.jpg');
    });

    test('ignores empty photo capture refs', () {
      final MyMenuState state = MyMenuState();
      final int initialReviewCount = state.reviewItems.length;

      state.addPhotoCaptures(const <String>['', '   ']);

      expect(state.reviewItems.length, initialReviewCount);
    });

    test('planning a dish adds it to the targeted day', () {
      final MyMenuState state = MyMenuState();
      final String dayKey = dayKeyForDate(state.remainingPlanDates().first);

      final int before = state.plannedMealsForDay(dayKey).length;
      state.addPlannedMeal(dayKey, 'dish_katsu', label: 'Dinner');

      final plannedMeals = state.plannedMealsForDay(dayKey);
      expect(plannedMeals.length, before + 1);
      expect(plannedMeals.last.dishId, 'dish_katsu');
      expect(plannedMeals.last.label, 'Dinner');
    });

    test('replaces all dishes for a day and preserves other days', () async {
      const String editedDay = '2026-08-11';
      const String otherDay = '2026-08-12';
      final MyMenuState state = MyMenuState.forTesting(
        dishes: <Dish>[seededDishes.first, seededDishes[1], seededDishes[2]],
        plan: const <PlannedMeal>[
          PlannedMeal(
            id: 'existing',
            dayKey: editedDay,
            dishId: 'dish_salmon',
            label: 'Lunch',
          ),
          PlannedMeal(
            id: 'other',
            dayKey: otherDay,
            dishId: 'dish_katsu',
          ),
        ],
      );
      addTearDown(state.dispose);

      await state.replacePlannedDishesForDay(
        editedDay,
        const <String>{'dish_salmon', 'dish_linguine'},
      );

      final List<PlannedMeal> edited = state.plannedMealsForDay(editedDay);
      expect(edited.map((PlannedMeal meal) => meal.dishId), <String>[
        'dish_salmon',
        'dish_linguine',
      ]);
      expect(edited.first.id, 'existing');
      expect(edited.first.label, 'Lunch');
      expect(state.plannedMealsForDay(otherDay).single.id, 'other');

      await state.replacePlannedDishesForDay(editedDay, const <String>{});
      expect(state.plannedMealsForDay(editedDay), isEmpty);
      expect(state.plannedMealsForDay(otherDay).single.id, 'other');
    });

    test('opening a newly created dish clears its new status', () async {
      final Dish newDish = seededDishes.first.copyWith(
        createdAt: DateTime.utc(2026, 8, 11),
      );
      final MyMenuState state = MyMenuState.forTesting(
        dishes: <Dish>[newDish],
      );
      addTearDown(state.dispose);

      expect(state.dishes.single.isNew, isTrue);

      final DateTime openedAt = DateTime.utc(2026, 8, 11, 8);
      await state.markDishOpened(newDish.id, openedAt: openedAt);

      expect(state.dishes.single.isNew, isFalse);
      expect(state.dishes.single.openedAt, openedAt);
    });

    test('adding a next day extends the plan timeline by one date', () {
      final MyMenuState state = MyMenuState();

      final int before = state.remainingPlanDates().length;
      state.addNextPlanDay();

      expect(state.remainingPlanDates().length, before + 1);
    });

    test('moving a planned meal reorders it within a day', () {
      final MyMenuState state = MyMenuState();
      final String dayKey = state.plan.first.dayKey;
      final List<PlannedMeal> meals = state.plannedMealsForDay(dayKey);

      state.movePlannedMeal(
        meals.first.id,
        targetDayKey: dayKey,
        targetIndex: meals.length,
      );

      final List<PlannedMeal> reorderedMeals = state.plannedMealsForDay(dayKey);
      expect(reorderedMeals.last.id, meals.first.id);
    });

    test('ensurePlanDateVisible extends visible days to a dropped date', () {
      final MyMenuState state = MyMenuState();
      final DateTime targetDate =
          state.remainingPlanDates().last.add(const Duration(days: 3));

      state.ensurePlanDateVisible(targetDate);

      expect(
        state.remainingPlanDates().last,
        targetDate,
      );
    });

    test('staged dish deletion removes plans and Undo restores both', () {
      final PlannedMeal planned = PlannedMeal(
        id: 'planned_idea',
        dayKey: '2026-07-28',
        dishId: seededDishes.first.id,
      );
      final MyMenuState state = MyMenuState.forTesting(
        dishes: <Dish>[seededDishes.first, seededDishes.last],
        plan: <PlannedMeal>[planned],
      );
      addTearDown(state.dispose);

      final DishDeletionTicket ticket =
          state.stageDishDeletion(<String>[seededDishes.first.id]);

      expect(
        state.dishes.map((Dish dish) => dish.id),
        isNot(contains(seededDishes.first.id)),
      );
      expect(state.plan, isEmpty);

      expect(state.undoDishDeletion(ticket), isTrue);
      expect(state.dishes.first.id, seededDishes.first.id);
      expect(state.plan.single.id, planned.id);
    });

    test('plan lists exclude references to missing dishes', () {
      const PlannedMeal orphan = PlannedMeal(
        id: 'orphaned_plan',
        dayKey: '2026-07-28',
        dishId: 'deleted_dish',
      );
      final MyMenuState state = MyMenuState.forTesting(
        dishes: <Dish>[seededDishes.first],
        plan: <PlannedMeal>[orphan],
      );
      addTearDown(state.dispose);

      expect(state.plan, isEmpty);
      expect(state.plannedMealsForDay(orphan.dayKey), isEmpty);
    });

    test('zero-history ideas remain valid until explicitly deleted', () async {
      final Dish idea = seededDishes.first.copyWith(
        id: 'zero_history_idea',
        madeCount: 0,
        sourcePhotos: const <SourcePhoto>[],
      );
      final MyMenuState state = MyMenuState.forTesting(dishes: <Dish>[idea]);
      addTearDown(state.dispose);

      expect(state.dishes.single.madeCount, 0);
      final DishDeletionTicket ticket =
          state.stageDishDeletion(<String>[idea.id]);
      await state.commitDishDeletion(ticket);

      expect(state.dishes, isEmpty);
    });

    test('staged photo deletion stays hidden and Undo restores it', () async {
      final DateTime now = DateTime.utc(2026, 8, 2);
      final CaptureItem photo = CaptureItem(
        id: 'photo_to_delete',
        batchId: 'photo_batch',
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.localOnly,
        createdAt: now,
        localMediaRef: '/tmp/photo_to_delete.jpg',
        capturedLocalDate: '2026-08-02',
      );
      final CaptureBatch batch = CaptureBatch(
        id: 'photo_batch',
        status: CaptureBatchStatus.local,
        createdAt: now,
        updatedAt: now,
        items: <CaptureItem>[photo],
      );
      final MyMenuState state = MyMenuState.forTesting(
        captureBatches: <CaptureBatch>[batch],
        captureItems: <CaptureItem>[photo],
      );
      addTearDown(state.dispose);

      final CaptureDeletionTicket ticket = state.stageCaptureDeletion(
        <String>[photo.id],
        undoWindow: const Duration(days: 1),
      );

      expect(state.photos, isEmpty);
      expect(state.captureItems, isEmpty);
      expect(state.captureBatches, isEmpty);
      expect(state.undoCaptureDeletion(ticket), isTrue);
      expect(state.photos.single.id, photo.id);
      expect(state.captureBatches.single.items.single.id, photo.id);

      final CaptureDeletionTicket committed = state.stageCaptureDeletion(
        <String>[photo.id],
        undoWindow: const Duration(days: 1),
      );
      await state.commitCaptureDeletion(committed);
      expect(state.photos, isEmpty);
      expect(state.pendingCaptureDeletionCount, 0);
    });

    test(
      'grouping completed during Undo stays hidden and is preserved by Undo',
      () {
        final DateTime now = DateTime.utc(2026, 7, 28);
        final CaptureItem pendingItem = CaptureItem(
          id: 'race_capture',
          batchId: 'race_batch',
          kind: CaptureItemKind.photo,
          status: CaptureItemStatus.classifying,
          createdAt: now,
        );
        final CaptureBatch pendingBatch = CaptureBatch(
          id: 'race_batch',
          status: CaptureBatchStatus.processing,
          createdAt: now,
          updatedAt: now,
          items: <CaptureItem>[pendingItem],
        );
        final MyMenuState state = MyMenuState.forTesting(
          dishes: seededDishes,
          captureBatches: <CaptureBatch>[pendingBatch],
          captureItems: <CaptureItem>[pendingItem],
        );
        addTearDown(state.dispose);

        final CaptureBatchDeletionTicket ticket =
            state.stageCaptureBatchDeletion(<String>[pendingBatch.id]);
        final Dish groupedDish = seededDishes.first.copyWith(
          id: 'server_grouped_dish',
          title: 'Server Grouped Dish',
        );
        final CaptureItem appliedItem = CaptureItem(
          id: pendingItem.id,
          batchId: pendingItem.batchId,
          kind: pendingItem.kind,
          status: CaptureItemStatus.applied,
          createdAt: pendingItem.createdAt,
          appliedDishId: groupedDish.id,
        );
        state.applyCaptureCompletionForTesting(
          batch: CaptureBatch(
            id: pendingBatch.id,
            status: CaptureBatchStatus.applied,
            createdAt: now,
            updatedAt: now.add(const Duration(seconds: 1)),
            items: <CaptureItem>[appliedItem],
          ),
          items: <CaptureItem>[appliedItem],
          dishes: <Dish>[groupedDish],
        );

        expect(
          state.dishes.map((Dish dish) => dish.id),
          isNot(contains(groupedDish.id)),
        );
        expect(state.captureBatches, isEmpty);

        expect(state.undoCaptureBatchDeletion(ticket), isTrue);
        expect(
          state.dishes.map((Dish dish) => dish.id),
          contains(groupedDish.id),
        );
        expect(state.captureBatches.single.status, CaptureBatchStatus.applied);
        expect(state.captureItems.single.appliedDishId, groupedDish.id);
      },
    );
  });
}
