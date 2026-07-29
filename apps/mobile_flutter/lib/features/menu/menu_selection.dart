part of 'menu_screen.dart';

extension _MenuSelection on _MenuScreenState {
  void _handleDishTap(BuildContext context, Dish dish) {
    if (_isSelecting) {
      _toggleSelection(dish.id);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DishDetailScreen(dishId: dish.id),
      ),
    );
  }

  void _handleBatchTap(
    BuildContext context,
    MyMenuState state,
    CaptureBatch batch,
  ) {
    if (_isSelecting) {
      _toggleBatchSelection(batch.id);
      return;
    }
    unawaited(showCaptureFeedSheet(context, state));
  }

  void _startSelection(String dishId) {
    HapticFeedback.mediumImpact();
    _toggleSelection(dishId);
  }

  void _startBatchSelection(String batchId) {
    HapticFeedback.mediumImpact();
    _toggleBatchSelection(batchId);
  }

  void _toggleSelection(String dishId) {
    final bool wasSelecting = _isSelecting;
    _updateSelection(() {
      if (!_selectedDishIds.add(dishId)) {
        _selectedDishIds.remove(dishId);
      }
    });
    _notifySelectionModeChanged(wasSelecting);
  }

  void _toggleBatchSelection(String batchId) {
    final bool wasSelecting = _isSelecting;
    _updateSelection(() {
      if (!_selectedBatchIds.add(batchId)) {
        _selectedBatchIds.remove(batchId);
      }
    });
    _notifySelectionModeChanged(wasSelecting);
  }

  void _toggleSelectAll(
    List<Dish> dishes,
    List<CaptureBatch> processingBatches,
  ) {
    final Set<String> visibleIds = dishes.map((Dish dish) => dish.id).toSet();
    final Set<String> visibleBatchIds =
        processingBatches.map((CaptureBatch batch) => batch.id).toSet();
    final bool allSelected =
        (visibleIds.isNotEmpty || visibleBatchIds.isNotEmpty) &&
            visibleIds.every(_selectedDishIds.contains) &&
            visibleBatchIds.every(_selectedBatchIds.contains);
    final bool wasSelecting = _isSelecting;
    _updateSelection(() {
      if (allSelected) {
        _selectedDishIds.removeAll(visibleIds);
        _selectedBatchIds.removeAll(visibleBatchIds);
      } else {
        _selectedDishIds.addAll(visibleIds);
        _selectedBatchIds.addAll(visibleBatchIds);
      }
    });
    _notifySelectionModeChanged(wasSelecting);
  }

  void _clearSelection() {
    final bool wasSelecting = _isSelecting;
    _updateSelection(() {
      _selectedDishIds.clear();
      _selectedBatchIds.clear();
    });
    _notifySelectionModeChanged(wasSelecting);
  }

  void _notifySelectionModeChanged(bool wasSelecting) {
    final bool isSelecting = _isSelecting;
    if (wasSelecting != isSelecting) {
      widget.onSelectionModeChanged?.call(isSelecting);
    }
  }

  Future<void> _confirmDeleteSelected(MyMenuState state) async {
    final List<Dish> selected = state.dishes
        .where((Dish dish) => _selectedDishIds.contains(dish.id))
        .toList(growable: false);
    final List<CaptureBatch> selectedBatches = state.captureBatches
        .where((CaptureBatch batch) => _selectedBatchIds.contains(batch.id))
        .toList(growable: false);
    if (selected.isEmpty && selectedBatches.isEmpty ||
        !await showMenuDeleteDialog(
          context,
          selected,
          processingBatches: selectedBatches,
        ) ||
        !mounted) {
      return;
    }

    // Retain UI-only snapshots so the data can be marked deleted immediately
    // while the same cards remain available for their exit animation.
    _updateSelection(() {
      _exitingDishes.addEntries(
        selected.map((Dish dish) => MapEntry<String, Dish>(dish.id, dish)),
      );
      _exitingBatches.addEntries(
        selectedBatches.map(
          (CaptureBatch batch) =>
              MapEntry<String, CaptureBatch>(batch.id, batch),
        ),
      );
    });
    final DishDeletionTicket? ticket = selected.isEmpty
        ? null
        : state.stageDishDeletion(selected.map((Dish dish) => dish.id));
    final CaptureBatchDeletionTicket? batchTicket = selectedBatches.isEmpty
        ? null
        : state.stageCaptureBatchDeletion(
            selectedBatches.map((CaptureBatch batch) => batch.id),
          );
    _clearSelection();

    // showModalBottomSheet returns its result while its reverse transition is
    // still covering the menu. The snapshots remain fully visible underneath,
    // then animate once the sheet has cleared them.
    await Future<void>.delayed(
      _MenuScreenState._dilated(_MenuScreenState._deleteSheetExitDuration),
    );
    if (!mounted) {
      return;
    }
    _updateSelection(() {
      _removingDishIds.addAll(selected.map((Dish dish) => dish.id));
      _removingBatchIds.addAll(
        selectedBatches.map((CaptureBatch batch) => batch.id),
      );
    });
    final Duration offscreenExitFallback = _MenuScreenState._dilated(
      _MenuScreenState._cardExitDuration,
      bufferMilliseconds: 1000,
    );
    for (final Dish dish in selected) {
      _dishExitFallbacks[dish.id]?.cancel();
      _dishExitFallbacks[dish.id] = Timer(
        offscreenExitFallback,
        () => _finishDishExit(dish.id),
      );
    }
    for (final CaptureBatch batch in selectedBatches) {
      _batchExitFallbacks[batch.id]?.cancel();
      _batchExitFallbacks[batch.id] = Timer(
        offscreenExitFallback,
        () => _finishBatchExit(batch.id),
      );
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    var undone = false;
    Timer? undoTimer;
    final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller =
        messenger.showSnackBar(
      SnackBar(
        key: const ValueKey<String>('menu_delete_undo_snackbar'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 118),
        duration: const Duration(seconds: 5),
        content: Text(
          _deletionMessage(ticket, batchTicket),
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            undone = true;
            undoTimer?.cancel();
            if (ticket != null) {
              state.undoDishDeletion(ticket);
            }
            if (batchTicket != null) {
              state.undoCaptureBatchDeletion(batchTicket);
            }
          },
        ),
      ),
    );
    undoTimer = Timer(const Duration(seconds: 5), controller.close);
    final SnackBarClosedReason reason = await controller.closed;
    undoTimer.cancel();
    if (undone || reason == SnackBarClosedReason.action) {
      return;
    }
    try {
      if (ticket != null) {
        await state.commitDishDeletion(ticket);
      }
      if (batchTicket != null) {
        await state.commitCaptureBatchDeletion(batchTicket);
      }
    } on Object {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not delete dishes. They were restored.'),
        ),
      );
    }
  }

  String _deletionMessage(
    DishDeletionTicket? dishTicket,
    CaptureBatchDeletionTicket? batchTicket,
  ) {
    final int dishes = dishTicket?.dishCount ?? 0;
    final int uploads = batchTicket?.batchCount ?? 0;
    if (dishes == 0) {
      return uploads == 1
          ? 'Pending upload removed'
          : '$uploads pending uploads removed';
    }
    if (uploads == 0) {
      return dishes == 1 ? 'Dish deleted' : '$dishes dishes deleted';
    }
    return '${dishes + uploads} items removed';
  }
}
