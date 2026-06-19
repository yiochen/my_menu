import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';

List<PlannedMeal> buildSeededPlan([DateTime? now]) {
  final List<DateTime> dates = remainingDaysInWeek(now);
  final List<PlannedMeal> seeded = <PlannedMeal>[];

  if (dates.isNotEmpty) {
    seeded.addAll(<PlannedMeal>[
      PlannedMeal(
        id: 'plan_today_0',
        dayKey: dayKeyForDate(dates.first),
        dishId: 'dish_linguine',
        label: 'Dinner',
      ),
      PlannedMeal(
        id: 'plan_today_1',
        dayKey: dayKeyForDate(dates.first),
        dishId: 'dish_salmon',
        label: 'Lunch',
      ),
    ]);
  }

  if (dates.length > 1) {
    seeded.add(
      PlannedMeal(
        id: 'plan_next_0',
        dayKey: dayKeyForDate(dates[1]),
        dishId: 'dish_katsu',
        label: 'Dinner',
      ),
    );
  }

  if (dates.length > 3) {
    seeded.add(
      PlannedMeal(
        id: 'plan_later_0',
        dayKey: dayKeyForDate(dates[3]),
        dishId: 'dish_pho',
      ),
    );
  }

  return seeded;
}
