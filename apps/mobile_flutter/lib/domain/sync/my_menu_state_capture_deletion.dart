part of 'my_menu_state.dart';

class CaptureBatchDeletionTicket {
  const CaptureBatchDeletionTicket({
    required this.id,
    required this.batchIds,
  });

  final String id;
  final List<String> batchIds;

  int get batchCount => batchIds.length;
}

class _PendingCaptureBatchDeletion {
  const _PendingCaptureBatchDeletion({
    required this.ticket,
    required this.captureIds,
  });

  final CaptureBatchDeletionTicket ticket;
  final Set<String> captureIds;
}

extension MyMenuCaptureBatchDeletion on MyMenuState {
  @visibleForTesting
  int get pendingCaptureBatchDeletionCount =>
      _pendingCaptureBatchDeletions.length;

  CaptureBatchDeletionTicket stageCaptureBatchDeletion(
    Iterable<String> batchIds,
  ) {
    final Set<String> requested = batchIds.toSet();
    final List<String> existing = _captureBatches
        .where((CaptureBatch batch) => requested.contains(batch.id))
        .map((CaptureBatch batch) => batch.id)
        .toList(growable: false);
    if (existing.isEmpty) {
      throw StateError('Select at least one pending upload to remove.');
    }
    final Set<String> captureIds = _captureItems
        .where((CaptureItem item) => existing.contains(item.batchId))
        .map((CaptureItem item) => item.id)
        .toSet();
    final CaptureBatchDeletionTicket ticket = CaptureBatchDeletionTicket(
      id: 'batch_delete_${DateTime.now().microsecondsSinceEpoch}',
      batchIds: existing,
    );
    _pendingCaptureBatchDeletions[ticket.id] =
        _PendingCaptureBatchDeletion(ticket: ticket, captureIds: captureIds);
    _notifyChanged();
    return ticket;
  }

  bool undoCaptureBatchDeletion(CaptureBatchDeletionTicket ticket) {
    final bool removed =
        _pendingCaptureBatchDeletions.remove(ticket.id) != null;
    if (removed) {
      _notifyChanged();
    }
    return removed;
  }

  Future<void> commitCaptureBatchDeletion(
    CaptureBatchDeletionTicket ticket,
  ) async {
    final _PendingCaptureBatchDeletion? pending =
        _pendingCaptureBatchDeletions.remove(ticket.id);
    if (pending == null) {
      return;
    }
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      _captureBatches = _captureBatches
          .where((CaptureBatch batch) => !ticket.batchIds.contains(batch.id))
          .toList(growable: false);
      _captureItems = _captureItems
          .where((CaptureItem item) => !pending.captureIds.contains(item.id))
          .toList(growable: false);
      _notifyChanged();
      return;
    }
    try {
      for (final String batchId in ticket.batchIds) {
        await repositories.captureRepository.deleteBatch(batchId);
      }
      await _reloadFromRepositories();
    } on Object {
      _pendingCaptureBatchDeletions[ticket.id] = pending;
      _notifyChanged();
      rethrow;
    }
  }

  Set<String> get _pendingCaptureBatchIds =>
      _pendingCaptureBatchDeletions.values
          .expand(
            (_PendingCaptureBatchDeletion pending) => pending.ticket.batchIds,
          )
          .toSet();

  Set<String> get _pendingCaptureIds => _pendingCaptureBatchDeletions.values
      .expand((_PendingCaptureBatchDeletion pending) => pending.captureIds)
      .toSet();

  Set<String> get _pendingCaptureResultDishIds => _captureItems
      .where(
        (CaptureItem item) =>
            _pendingCaptureIds.contains(item.id) && item.appliedDishId != null,
      )
      .map((CaptureItem item) => item.appliedDishId!)
      .toSet();

  @visibleForTesting
  void applyCaptureCompletionForTesting({
    required CaptureBatch batch,
    required List<CaptureItem> items,
    required List<Dish> dishes,
  }) {
    _captureBatches = <CaptureBatch>[
      batch,
      ..._captureBatches.where((CaptureBatch value) => value.id != batch.id),
    ];
    final Set<String> itemIds =
        items.map((CaptureItem item) => item.id).toSet();
    _captureItems = <CaptureItem>[
      ...items,
      ..._captureItems.where((CaptureItem item) => !itemIds.contains(item.id)),
    ];
    _dishes = <Dish>[
      ...dishes,
      ..._dishes.where(
        (Dish dish) => !dishes.any((Dish incoming) => incoming.id == dish.id),
      ),
    ];
    _notifyChanged();
  }
}
