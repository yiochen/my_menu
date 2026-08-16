part of 'app_repositories.dart';

class PlanRepository {
  PlanRepository(this._database);

  final db.AppDatabase _database;

  Future<void> _seedIfEmpty() async {
    final List<db.PlannedMealRow> rows =
        await _database.select(_database.plannedMeals).get();
    if (rows.isNotEmpty) {
      return;
    }

    await _database.batch((Batch batch) {
      final List<planning_domain.PlannedMeal> meals = buildSeededPlan();
      for (int index = 0; index < meals.length; index += 1) {
        final planning_domain.PlannedMeal meal = meals[index];
        batch.insert(
          _database.plannedMeals,
          db.PlannedMealsCompanion.insert(
            id: meal.id,
            dayKey: meal.dayKey,
            dishId: meal.dishId,
            label: Value<String?>(meal.label),
            position: Value<int>(index),
          ),
        );
      }
    });
  }

  Future<void> replaceMeals(
    List<planning_domain.PlannedMeal> meals,
  ) async {
    await _database.transaction(() async {
      await _database.delete(_database.plannedMeals).go();
      await _database.batch((Batch batch) {
        for (int index = 0; index < meals.length; index += 1) {
          final planning_domain.PlannedMeal meal = meals[index];
          batch.insert(
            _database.plannedMeals,
            db.PlannedMealsCompanion.insert(
              id: meal.id,
              dayKey: meal.dayKey,
              dishId: meal.dishId,
              label: Value<String?>(meal.label),
              position: Value<int>(index),
            ),
          );
        }
      });
    });
  }

  Future<List<planning_domain.PlannedMeal>> listMeals({
    required Set<String> validDishIds,
  }) async {
    final List<db.PlannedMealRow> rows =
        await (_database.select(_database.plannedMeals)
              ..orderBy(<OrderingTerm Function(db.$PlannedMealsTable)>[
                (db.PlannedMeals table) => OrderingTerm.asc(table.position),
              ]))
            .get();
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
