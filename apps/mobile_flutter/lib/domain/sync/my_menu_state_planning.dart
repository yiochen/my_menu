part of 'my_menu_state.dart';

extension MyMenuStatePlanning on MyMenuState {
  void addPlannedMeal(String dayKey, String dishId, {String? label}) {
    _plan = <PlannedMeal>[
      ..._plan,
      PlannedMeal(
        id: 'plan_${_plan.length + 1}',
        dayKey: dayKey,
        dishId: dishId,
        label: label,
      ),
    ];
    _notifyChanged();
  }

  void updatePlannedMeal(String planId, String dishId, {String? label}) {
    _plan = _plan.map((PlannedMeal meal) {
      return meal.id == planId
          ? meal.copyWith(dishId: dishId, label: label)
          : meal;
    }).toList(growable: false);
    _notifyChanged();
  }

  void removePlannedMeal(String planId) {
    _plan = _plan
        .where((PlannedMeal meal) => meal.id != planId)
        .toList(growable: false);
    _notifyChanged();
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

  void movePlannedMeal(
    String planId, {
    required String targetDayKey,
    required int targetIndex,
  }) {
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
    _plan = nextPlan;
    _notifyChanged();
  }
}
