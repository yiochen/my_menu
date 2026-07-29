part of 'repositories.dart';

class PlanRepository {
  PlanRepository(this._database);

  final db.AppDatabase _database;

  Future<void> seedIfNeeded() async {
    final List<db.PlannedMealRow> rows =
        await _database.select(_database.plannedMeals).get();
    if (rows.isNotEmpty) {
      return;
    }

    await _database.batch((Batch batch) {
      for (final planning_domain.PlannedMeal meal in buildSeededPlan()) {
        batch.insert(
          _database.plannedMeals,
          db.PlannedMealsCompanion.insert(
            id: meal.id,
            dayKey: meal.dayKey,
            dishId: meal.dishId,
            label: Value<String?>(meal.label),
          ),
        );
      }
    });
  }

  Future<List<planning_domain.PlannedMeal>> listMeals({
    required Set<String> validDishIds,
  }) async {
    final List<db.PlannedMealRow> rows =
        await _database.select(_database.plannedMeals).get();
    final List<String> orphanIds = rows
        .where((db.PlannedMealRow row) => !validDishIds.contains(row.dishId))
        .map((db.PlannedMealRow row) => row.id)
        .toList(growable: false);
    if (orphanIds.isNotEmpty) {
      await (_database.delete(_database.plannedMeals)
            ..where((db.PlannedMeals table) => table.id.isIn(orphanIds)))
          .go();
    }
    return rows
        .where((db.PlannedMealRow row) => validDishIds.contains(row.dishId))
        .map(
          (db.PlannedMealRow row) => planning_domain.PlannedMeal(
            id: row.id,
            dayKey: row.dayKey,
            dishId: row.dishId,
            label: row.label,
          ),
        )
        .toList(growable: false);
  }
}
