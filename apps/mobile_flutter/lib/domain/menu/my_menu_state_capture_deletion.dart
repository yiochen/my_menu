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

class CaptureIngestDeletionTicket {
  const CaptureIngestDeletionTicket({
    required this.id,
    required this.ingestIds,
  });

  final String id;
  final List<String> ingestIds;

  int get ingestCount => ingestIds.length;
}

class _PendingCaptureIngestDeletion {
  const _PendingCaptureIngestDeletion({
    required this.ticket,
    required this.captureIds,
  });

  final CaptureIngestDeletionTicket ticket;
  final Set<String> captureIds;
}

extension MyMenuCaptureIngestDeletion on MyMenuState {
  @visibleForTesting
  int get pendingCaptureDeletionCount => _pendingCaptureDeletions.length;

  @visibleForTesting
  int get pendingCaptureIngestDeletionCount =>
      _pendingCaptureIngestDeletions.length;

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

  CaptureIngestDeletionTicket stageCaptureIngestDeletion(
    Iterable<String> ingestIds,
  ) {
    final Set<String> requested = ingestIds.toSet();
    final List<String> existing = _captureIngests
        .where((CaptureIngest ingest) => requested.contains(ingest.id))
        .map((CaptureIngest ingest) => ingest.id)
        .toList(growable: false);
    if (existing.isEmpty) {
      throw StateError('Select at least one pending upload to remove.');
    }
    final Set<String> captureIds = _captureItems
        .where((CaptureItem item) => existing.contains(item.ingestId))
        .map((CaptureItem item) => item.id)
        .toSet();
    final CaptureIngestDeletionTicket ticket = CaptureIngestDeletionTicket(
      id: 'ingest_delete_${DateTime.now().microsecondsSinceEpoch}',
      ingestIds: existing,
    );
    _pendingCaptureIngestDeletions[ticket.id] =
        _PendingCaptureIngestDeletion(ticket: ticket, captureIds: captureIds);
    _notifyChanged();
    return ticket;
  }

  bool undoCaptureIngestDeletion(CaptureIngestDeletionTicket ticket) {
    final bool removed =
        _pendingCaptureIngestDeletions.remove(ticket.id) != null;
    if (removed) {
      _notifyChanged();
    }
    return removed;
  }

  Future<void> commitCaptureIngestDeletion(
    CaptureIngestDeletionTicket ticket,
  ) async {
    final _PendingCaptureIngestDeletion? pending =
        _pendingCaptureIngestDeletions.remove(ticket.id);
    if (pending == null) {
      return;
    }
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      _captureIngests = _captureIngests
          .where(
            (CaptureIngest ingest) => !ticket.ingestIds.contains(ingest.id),
          )
          .toList(growable: false);
      _captureItems = _captureItems
          .where((CaptureItem item) => !pending.captureIds.contains(item.id))
          .toList(growable: false);
      _notifyChanged();
      return;
    }
    try {
      for (final String ingestId in ticket.ingestIds) {
        await repositories.captureRepository.deleteIngest(ingestId);
      }
      await _reloadFromRepositories();
    } on Object {
      _pendingCaptureIngestDeletions[ticket.id] = pending;
      _notifyChanged();
      rethrow;
    }
  }

  Set<String> get _pendingCaptureIngestIds =>
      _pendingCaptureIngestDeletions.values
          .expand(
            (_PendingCaptureIngestDeletion pending) => pending.ticket.ingestIds,
          )
          .toSet();

  Set<String> get _pendingCaptureIds => _pendingCaptureIngestDeletions.values
      .expand((_PendingCaptureIngestDeletion pending) => pending.captureIds)
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
    required CaptureIngest ingest,
    required List<CaptureItem> items,
    required List<Dish> dishes,
  }) {
    _captureIngests = <CaptureIngest>[
      ingest,
      ..._captureIngests.where((CaptureIngest value) => value.id != ingest.id),
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
