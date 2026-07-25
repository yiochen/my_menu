import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';

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
  });
}
