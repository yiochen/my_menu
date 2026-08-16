part of 'my_menu_state.dart';

extension MyMenuStatePlanning on MyMenuState {
  List<PlannedMeal> get _validPlannedMeals {
    final Set<String> dishIds = dishes.map((Dish dish) => dish.id).toSet();
    return List<PlannedMeal>.unmodifiable(
      _plan.where((PlannedMeal meal) => dishIds.contains(meal.dishId)),
    );
  }

  Future<void> addPlannedMeal(
    String dayKey,
    String dishId, {
    String? label,
  }) async {
    final List<PlannedMeal> nextPlan = <PlannedMeal>[
      ..._plan,
      PlannedMeal(
        id: const Uuid().v4(),
        dayKey: dayKey,
        dishId: dishId,
        label: label,
      ),
    ];
    await _replacePlan(nextPlan);
  }

  Future<void> replacePlannedDishesForDay(
    String dayKey,
    Iterable<String> dishIds, {
    String label = 'Dinner',
  }) async {
    final Set<String> validDishIds = dishes.map((Dish dish) => dish.id).toSet();
    final List<String> selectedDishIds =
        dishIds.where(validDishIds.contains).toSet().toList(growable: false);
    final List<PlannedMeal> existingForDay =
        _plan.where((PlannedMeal meal) => meal.dayKey == dayKey).toList();
    final Map<String, PlannedMeal> existingByDishId = <String, PlannedMeal>{
      for (final PlannedMeal meal in existingForDay) meal.dishId: meal,
    };
    final List<PlannedMeal> replacements = selectedDishIds.map((String dishId) {
      return existingByDishId[dishId] ??
          PlannedMeal(
            id: const Uuid().v4(),
            dayKey: dayKey,
            dishId: dishId,
            label: label,
          );
    }).toList(growable: false);
    final int firstDayIndex =
        _plan.indexWhere((PlannedMeal meal) => meal.dayKey == dayKey);
    final List<PlannedMeal> nextPlan = _plan
        .where((PlannedMeal meal) => meal.dayKey != dayKey)
        .toList(growable: true);
    nextPlan.insertAll(
      firstDayIndex == -1 ? nextPlan.length : firstDayIndex,
      replacements,
    );
    await _replacePlan(nextPlan);
  }

  Future<void> savePlannedMeal({
    required String dayKey,
    required String dishId,
    String? planId,
    String? label,
  }) async {
    if (planId == null) {
      await addPlannedMeal(dayKey, dishId, label: label);
      return;
    }
    final List<PlannedMeal> nextPlan = _plan.map((PlannedMeal meal) {
      return meal.id == planId
          ? meal.copyWith(dayKey: dayKey, dishId: dishId, label: label)
          : meal;
    }).toList(growable: false);
    await _replacePlan(nextPlan);
  }

  Future<void> removePlannedMeal(String planId) async {
    final List<PlannedMeal> nextPlan = _plan
        .where((PlannedMeal meal) => meal.id != planId)
        .toList(growable: false);
    await _replacePlan(nextPlan);
  }

  void addNextPlanDay() {
    _extraPlanDays = (_extraPlanDays ?? 0) + 1;
    _notifyChanged();
  }

  void ensurePlanDateVisible(DateTime date, {DateTime? from}) {
    final List<DateTime> baseDates = remainingDaysInWeek(from);
    if (baseDates.isEmpty) {
      return;
    }

    final DateTime normalizedDate = startOfDay(date);
    final DateTime lastBaseDate = startOfDay(baseDates.last);
    if (!normalizedDate.isAfter(lastBaseDate)) {
      return;
    }

    final int extraPlanDays = normalizedDate.difference(lastBaseDate).inDays;
    final int nextExtraPlanDays = extraPlanDays > (_extraPlanDays ?? 0)
        ? extraPlanDays
        : (_extraPlanDays ?? 0);
    if (nextExtraPlanDays == (_extraPlanDays ?? 0)) {
      return;
    }

    _extraPlanDays = nextExtraPlanDays;
    _notifyChanged();
  }

  Future<void> movePlannedMeal(
    String planId, {
    required String targetDayKey,
    required int targetIndex,
  }) async {
    final int sourceIndex =
        _plan.indexWhere((PlannedMeal meal) => meal.id == planId);
    if (sourceIndex == -1) {
      return;
    }

    final PlannedMeal movingMeal = _plan[sourceIndex];
    final PlannedMeal updatedMeal = movingMeal.dayKey == targetDayKey
        ? movingMeal
        : movingMeal.copyWith(dayKey: targetDayKey);

    final List<PlannedMeal> nextPlan = List<PlannedMeal>.of(_plan)
      ..removeAt(sourceIndex);

    int insertAt = _globalInsertIndexForDay(
      nextPlan,
      dayKey: targetDayKey,
      indexInDay: targetIndex,
    );
    if (insertAt < 0) {
      insertAt = 0;
    } else if (insertAt > nextPlan.length) {
      insertAt = nextPlan.length;
    }

    nextPlan.insert(insertAt, updatedMeal);
    await _replacePlan(nextPlan);
  }

  Future<void> _replacePlan(List<PlannedMeal> nextPlan) async {
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      await repositories.planRepository.replaceMeals(nextPlan);
      await _reloadFromRepositories();
      return;
    }
    _plan = nextPlan;
    _notifyChanged();
  }
}
