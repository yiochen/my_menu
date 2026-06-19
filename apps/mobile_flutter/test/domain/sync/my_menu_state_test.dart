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
      final String dayKey = dayKeyForDate(state.remainingPlanDates().first);
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
