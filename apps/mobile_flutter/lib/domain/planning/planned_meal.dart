class PlannedMeal {
  const PlannedMeal({
    required this.dayKey,
    required this.label,
    this.dishId,
  });

  final String dayKey;
  final String label;
  final String? dishId;

  PlannedMeal copyWith({
    String? dayKey,
    String? label,
    String? dishId,
  }) {
    return PlannedMeal(
      dayKey: dayKey ?? this.dayKey,
      label: label ?? this.label,
      dishId: dishId ?? this.dishId,
    );
  }
}
