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
}
