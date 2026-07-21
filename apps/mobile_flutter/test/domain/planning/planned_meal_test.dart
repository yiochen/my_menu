import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';

void main() {
  group('PlannedMeal', () {
    const PlannedMeal meal = PlannedMeal(
      id: 'plan_1',
      dayKey: '2026-06-15',
      dishId: 'dish_linguine',
      label: 'Dinner',
    );

    test('stores all constructor fields', () {
      expect(meal.id, 'plan_1');
      expect(meal.dayKey, '2026-06-15');
      expect(meal.dishId, 'dish_linguine');
      expect(meal.label, 'Dinner');
    });

    test('label defaults to null', () {
      const PlannedMeal noLabel = PlannedMeal(
        id: 'plan_2',
        dayKey: '2026-06-16',
        dishId: 'dish_pho',
      );

      expect(noLabel.label, isNull);
    });

    test('copyWith overrides specified fields', () {
      final PlannedMeal copy = meal.copyWith(
        dayKey: '2026-06-20',
        dishId: 'dish_katsu',
      );

      expect(copy.id, meal.id);
      expect(copy.dayKey, '2026-06-20');
      expect(copy.dishId, 'dish_katsu');
      expect(copy.label, meal.label);
    });

    test('copyWith can set label to null', () {
      final PlannedMeal copy = meal.copyWith(label: null);

      expect(copy.label, isNull);
    });

    test('copyWith preserves label when not provided', () {
      final PlannedMeal copy = meal.copyWith(dayKey: '2026-07-01');

      expect(copy.label, 'Dinner');
    });

    test('copyWith can override id', () {
      final PlannedMeal copy = meal.copyWith(id: 'plan_99');

      expect(copy.id, 'plan_99');
      expect(copy.dayKey, meal.dayKey);
    });
  });
}
