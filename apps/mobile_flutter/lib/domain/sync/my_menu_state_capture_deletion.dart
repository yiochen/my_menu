part of 'my_menu_state.dart';

class CaptureDeletionTicket {
  const CaptureDeletionTicket({
    required this.id,
    required this.captureIds,
    required this.undoWindow,
  });

  final String id;
  final List<String> captureIds;
  final Duration undoWindow;

  int get captureCount => captureIds.length;
}

class _PendingCaptureDeletion {
  const _PendingCaptureDeletion({required this.ticket});

  final CaptureDeletionTicket ticket;
}

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
  int get pendingCaptureDeletionCount => _pendingCaptureDeletions.length;

  @visibleForTesting
  int get pendingCaptureBatchDeletionCount =>
      _pendingCaptureBatchDeletions.length;

  CaptureDeletionTicket stageCaptureDeletion(
    Iterable<String> captureIds, {
    Duration undoWindow = const Duration(seconds: 4),
  }) {
    final Set<String> requested = captureIds.toSet();
    final List<String> existing = captureItems
        .where((CaptureItem item) => requested.contains(item.id))
        .map((CaptureItem item) => item.id)
        .toList(growable: false);
    if (existing.isEmpty) {
      throw StateError('Select at least one photo to delete.');
    }
    final CaptureDeletionTicket ticket = CaptureDeletionTicket(
      id: 'photo_delete_${DateTime.now().microsecondsSinceEpoch}',
      captureIds: existing,
      undoWindow: undoWindow,
    );
    _pendingCaptureDeletions[ticket.id] =
        _PendingCaptureDeletion(ticket: ticket);
    _notifyChanged();
    return ticket;
  }

  bool undoCaptureDeletion(CaptureDeletionTicket ticket) {
    final _PendingCaptureDeletion? pending =
        _pendingCaptureDeletions.remove(ticket.id);
    if (pending != null) {
      _notifyChanged();
    }
    return pending != null;
  }

  Future<void> commitCaptureDeletion(CaptureDeletionTicket ticket) async {
    final _PendingCaptureDeletion? pending =
        _pendingCaptureDeletions[ticket.id];
    if (pending == null) {
      return;
    }
    try {
      for (final String captureId in ticket.captureIds) {
        await deleteCapture(captureId);
      }
      _pendingCaptureDeletions.remove(ticket.id);
      _notifyChanged();
    } on Object {
      _pendingCaptureDeletions.remove(ticket.id);
      _notifyChanged();
      rethrow;
    }
  }

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

  Set<String> get _pendingIndividualCaptureIds =>
      _pendingCaptureDeletions.values
          .expand(
            (_PendingCaptureDeletion pending) => pending.ticket.captureIds,
          )
          .toSet();

  Set<String> get _hiddenCaptureIds => <String>{
        ..._pendingCaptureIds,
        ..._pendingIndividualCaptureIds,
      };

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
