class PlannedMeal {
  const PlannedMeal({
    required this.id,
    required this.dayKey,
    required this.dishId,
    this.label,
  });

  final String id;
  final String dayKey;
  final String dishId;
  final String? label;

  PlannedMeal copyWith({
    String? id,
    String? dayKey,
    String? dishId,
    Object? label = _sentinel,
  }) {
    return PlannedMeal(
      id: id ?? this.id,
      dayKey: dayKey ?? this.dayKey,
      dishId: dishId ?? this.dishId,
      label: label == _sentinel ? this.label : label as String?,
    );
  }
}

const Object _sentinel = Object();
