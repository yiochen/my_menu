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

  void _startSelection(String dishId) {
    HapticFeedback.mediumImpact();
    _toggleSelection(dishId);
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

  void _toggleSelectAll(List<Dish> dishes) {
    final Set<String> visibleIds = dishes.map((Dish dish) => dish.id).toSet();
    final bool allSelected =
        visibleIds.isNotEmpty && visibleIds.every(_selectedDishIds.contains);
    final bool wasSelecting = _isSelecting;
    _updateSelection(() {
      if (allSelected) {
        _selectedDishIds.removeAll(visibleIds);
      } else {
        _selectedDishIds.addAll(visibleIds);
      }
    });
    _notifySelectionModeChanged(wasSelecting);
  }

  void _clearSelection() {
    final bool wasSelecting = _isSelecting;
    _updateSelection(_selectedDishIds.clear);
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
    if (selected.isEmpty ||
        !await showMenuDeleteDialog(context, selected) ||
        !mounted) {
      return;
    }

    _updateSelection(() {
      _exitingDishes.addEntries(
        selected.map((Dish dish) => MapEntry<String, Dish>(dish.id, dish)),
      );
    });
    final DishDeletionTicket ticket =
        state.stageDishDeletion(selected.map((Dish dish) => dish.id));
    _clearSelection();

    await Future<void>.delayed(
      _MenuScreenState._dilated(_MenuScreenState._deleteSheetExitDuration),
    );
    if (!mounted) {
      return;
    }
    _updateSelection(() {
      _removingDishIds.addAll(selected.map((Dish dish) => dish.id));
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

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    var undone = false;
    Timer? undoTimer;
    final controller = messenger.showSnackBar(
      SnackBar(
        key: const ValueKey<String>('menu_delete_undo_snackbar'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 118),
        duration: const Duration(seconds: 5),
        content: Text(
          ticket.dishCount == 1
              ? 'Dish deleted'
              : '${ticket.dishCount} dishes deleted',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            undone = true;
            undoTimer?.cancel();
            state.undoDishDeletion(ticket);
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
      await state.commitDishDeletion(ticket);
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
}
