part of 'my_menu_state.dart';

class DishDeletionTicket {
  const DishDeletionTicket({
    required this.id,
    required this.dishIds,
  });

  final String id;
  final List<String> dishIds;

  int get dishCount => dishIds.length;
}

class _PendingDishDeletion {
  const _PendingDishDeletion({
    required this.ticket,
    required this.dishes,
    required this.plannedMeals,
    required this.captureIds,
    required this.batchIds,
    required this.captureBatches,
    required this.captureItems,
    required this.captureCorrections,
    required this.aiJobs,
    required this.reviewItems,
  });

  final DishDeletionTicket ticket;
  final List<({int index, Dish dish})> dishes;
  final List<({int index, PlannedMeal meal})> plannedMeals;
  final Set<String> captureIds;
  final Set<String> batchIds;
  final List<CaptureBatch> captureBatches;
  final List<CaptureItem> captureItems;
  final List<CaptureCorrection> captureCorrections;
  final List<AiJob> aiJobs;
  final List<ReviewItem> reviewItems;
}

extension MyMenuDishDeletion on MyMenuState {
  DishDeletionTicket stageDishDeletion(Iterable<String> dishIds) {
    final Set<String> requested = dishIds.toSet();
    final List<({int index, Dish dish})> selected = _dishes
        .asMap()
        .entries
        .where(
            (MapEntry<int, Dish> entry) => requested.contains(entry.value.id))
        .map(
          (MapEntry<int, Dish> entry) => (index: entry.key, dish: entry.value),
        )
        .toList(growable: false);
    if (selected.isEmpty) {
      throw StateError('Select at least one dish to delete.');
    }

    final Set<String> selectedIds =
        selected.map((entry) => entry.dish.id).toSet();
    final Set<String> captureIds = _captureItems
        .where((CaptureItem item) => selectedIds.contains(item.appliedDishId))
        .map((CaptureItem item) => item.id)
        .toSet();
    final Set<String> batchIds = _captureItems
        .where((CaptureItem item) => captureIds.contains(item.id))
        .map((CaptureItem item) => item.batchId)
        .whereType<String>()
        .toSet();
    final List<({int index, PlannedMeal meal})> plannedMeals = _plan
        .asMap()
        .entries
        .where(
          (MapEntry<int, PlannedMeal> entry) =>
              selectedIds.contains(entry.value.dishId),
        )
        .map(
          (MapEntry<int, PlannedMeal> entry) =>
              (index: entry.key, meal: entry.value),
        )
        .toList(growable: false);
    final DishDeletionTicket ticket = DishDeletionTicket(
      id: 'dish_delete_${DateTime.now().microsecondsSinceEpoch}',
      dishIds: selected.map((entry) => entry.dish.id).toList(growable: false),
    );
    _pendingDishDeletions[ticket.id] = _PendingDishDeletion(
      ticket: ticket,
      dishes: selected,
      plannedMeals: plannedMeals,
      captureIds: captureIds,
      batchIds: batchIds,
      captureBatches: _captureBatches,
      captureItems: _captureItems,
      captureCorrections: _captureCorrections,
      aiJobs: _aiJobs,
      reviewItems: _reviewItems,
    );
    _dishes = _dishes
        .where((Dish dish) => !selectedIds.contains(dish.id))
        .toList(growable: false);
    _plan = _plan
        .where((PlannedMeal meal) => !selectedIds.contains(meal.dishId))
        .toList(growable: false);
    _captureItems = _captureItems
        .where((CaptureItem item) => !captureIds.contains(item.id))
        .toList(growable: false);
    _captureBatches = _captureBatches
        .map(
          (CaptureBatch batch) => CaptureBatch(
            id: batch.id,
            status: batch.status,
            createdAt: batch.createdAt,
            updatedAt: batch.updatedAt,
            items: batch.items
                .where((CaptureItem item) => !captureIds.contains(item.id))
                .toList(growable: false),
            failureReason: batch.failureReason,
          ),
        )
        .where((CaptureBatch batch) => batch.items.isNotEmpty)
        .toList(growable: false);
    _captureCorrections = _captureCorrections
        .where(
          (CaptureCorrection correction) =>
              !selectedIds.contains(correction.targetDishId) &&
              !selectedIds.contains(correction.createdDishId) &&
              !correction.captureIds.any(captureIds.contains) &&
              !correction.previousDishIds.values.any(selectedIds.contains),
        )
        .toList(growable: false);
    _aiJobs = _aiJobs
        .where(
          (AiJob job) =>
              !selectedIds.contains(job.subjectId) &&
              !batchIds.contains(job.subjectId),
        )
        .toList(growable: false);
    _reviewItems = _reviewItems
        .where((ReviewItem item) => !captureIds.contains(item.captureId))
        .map(
          (ReviewItem item) => item.copyWith(
            suggestedDishIds: item.suggestedDishIds
                .where((String id) => !selectedIds.contains(id))
                .toList(growable: false),
          ),
        )
        .where((ReviewItem item) => item.suggestedDishIds.isNotEmpty)
        .toList(growable: false);
    _notifyChanged();
    return ticket;
  }

  bool undoDishDeletion(DishDeletionTicket ticket) {
    final _PendingDishDeletion? pending =
        _pendingDishDeletions.remove(ticket.id);
    if (pending == null) {
      return false;
    }
    _restorePendingDishDeletion(pending);
    _notifyChanged();
    return true;
  }

  Future<void> commitDishDeletion(DishDeletionTicket ticket) async {
    final _PendingDishDeletion? pending =
        _pendingDishDeletions.remove(ticket.id);
    if (pending == null) {
      return;
    }
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return;
    }

    try {
      await repositories.dishRepository.deleteDishes(ticket.dishIds);
      await _reloadFromRepositories();
      await repositories.syncRepository.processPendingOperations();
    } on Object {
      _restorePendingDishDeletion(pending);
      _notifyChanged();
      rethrow;
    }
  }

  void _restorePendingDishDeletion(_PendingDishDeletion pending) {
    final List<Dish> restoredDishes = List<Dish>.of(_dishes);
    for (final ({int index, Dish dish}) item in pending.dishes.toList()
      ..sort((a, b) => a.index.compareTo(b.index))) {
      if (restoredDishes.any((Dish dish) => dish.id == item.dish.id)) {
        continue;
      }
      final int index = item.index > restoredDishes.length
          ? restoredDishes.length
          : item.index;
      restoredDishes.insert(
        index,
        item.dish,
      );
    }
    _dishes = restoredDishes;

    final List<PlannedMeal> restoredPlan = List<PlannedMeal>.of(_plan);
    for (final ({int index, PlannedMeal meal}) item
        in pending.plannedMeals.toList()
          ..sort((a, b) => a.index.compareTo(b.index))) {
      if (restoredPlan.any((PlannedMeal meal) => meal.id == item.meal.id)) {
        continue;
      }
      final int index =
          item.index > restoredPlan.length ? restoredPlan.length : item.index;
      restoredPlan.insert(
        index,
        item.meal,
      );
    }
    _plan = restoredPlan;
    _captureBatches = pending.captureBatches;
    _captureItems = pending.captureItems;
    _captureCorrections = pending.captureCorrections;
    _aiJobs = pending.aiJobs;
    _reviewItems = pending.reviewItems;
  }

  Set<String> get _pendingDishDeletionIds => _pendingDishDeletions.values
      .expand((_PendingDishDeletion pending) => pending.ticket.dishIds)
      .toSet();

  Set<String> get _pendingDishCaptureIds => _pendingDishDeletions.values
      .expand((_PendingDishDeletion pending) => pending.captureIds)
      .toSet();

  Set<String> get _pendingDishBatchIds => _pendingDishDeletions.values
      .expand((_PendingDishDeletion pending) => pending.batchIds)
      .toSet();
}
