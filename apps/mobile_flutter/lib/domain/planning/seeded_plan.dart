import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';

List<PlannedMeal> buildSeededPlan([DateTime? now]) {
  final DateTime sampleDay = now ?? DateTime(2026, 7, 22);
  final DateTime monday =
      sampleDay.subtract(Duration(days: sampleDay.weekday - 1));
  return <PlannedMeal>[
    PlannedMeal(
      id: 'plan_today_0',
      dayKey: dayKeyForDate(monday.add(const Duration(days: 2))),
      dishId: 'dish_salmon',
      label: 'Dinner',
    ),
    PlannedMeal(
      id: 'plan_today_1',
      dayKey: dayKeyForDate(monday.add(const Duration(days: 2))),
      dishId: 'dish_katsu',
      label: 'Dinner',
    ),
    PlannedMeal(
      id: 'plan_monday_0',
      dayKey: dayKeyForDate(monday),
      dishId: 'dish_linguine',
      label: 'Dinner',
    ),
    PlannedMeal(
      id: 'plan_friday_0',
      dayKey: dayKeyForDate(monday.add(const Duration(days: 4))),
      dishId: 'dish_pho',
      label: 'Dinner',
    ),
  ];
}
