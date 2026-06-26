part of 'my_menu_state.dart';

extension MyMenuDishEdits on MyMenuState {
  void addDishNote(String dishId, String body) {
    final String trimmed = body.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      unawaited(_addRepositoryNote(dishId, trimmed));
      return;
    }

    _dishes = _dishes.map((Dish dish) {
      if (dish.id != dishId) {
        return dish;
      }
      final DishNote note = DishNote(
        id: '${dish.id}_note_${DateTime.now().microsecondsSinceEpoch}',
        dishId: dish.id,
        body: trimmed,
        position: dish.notes.length,
      );
      return dish.copyWith(notes: <DishNote>[...dish.notes, note]);
    }).toList(growable: false);
    _notifyChanged();
  }

  void updateDishNote(String noteId, String body) {
    final String trimmed = body.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      unawaited(_updateRepositoryNote(noteId, trimmed));
      return;
    }

    _dishes = _dishes.map((Dish dish) {
      return dish.copyWith(
        notes: dish.notes.map((DishNote note) {
          return note.id == noteId ? note.copyWith(body: trimmed) : note;
        }).toList(growable: false),
      );
    }).toList(growable: false);
    _notifyChanged();
  }

  void deleteDishNote(String noteId) {
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      unawaited(_deleteRepositoryNote(noteId));
      return;
    }

    _dishes = _dishes.map((Dish dish) {
      return dish.copyWith(
        notes: dish.notes
            .where((DishNote note) => note.id != noteId)
            .toList(growable: false),
      );
    }).toList(growable: false);
    _notifyChanged();
  }

  void updateDishSections(
    String dishId, {
    List<String>? ingredients,
    List<String>? recipeSteps,
  }) {
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      unawaited(
        _updateRepositorySections(
          dishId,
          ingredients: ingredients,
          recipeSteps: recipeSteps,
        ),
      );
      return;
    }

    _dishes = _dishes.map((Dish dish) {
      return dish.id == dishId
          ? dish.copyWith(
              ingredients: ingredients,
              recipeSteps: recipeSteps,
            )
          : dish;
    }).toList(growable: false);
    _notifyChanged();
  }

  Future<void> _addRepositoryNote(String dishId, String body) async {
    final AppRepositories repositories = _repositories!;
    await repositories.dishRepository.createNote(dishId, body);
    await _reloadFromRepositories();
    await repositories.syncRepository.processPendingOperations();
  }

  Future<void> _updateRepositoryNote(String noteId, String body) async {
    final AppRepositories repositories = _repositories!;
    await repositories.dishRepository.updateNote(noteId, body);
    await _reloadFromRepositories();
    await repositories.syncRepository.processPendingOperations();
  }

  Future<void> _deleteRepositoryNote(String noteId) async {
    final AppRepositories repositories = _repositories!;
    await repositories.dishRepository.deleteNote(noteId);
    await _reloadFromRepositories();
    await repositories.syncRepository.processPendingOperations();
  }

  Future<void> _updateRepositorySections(
    String dishId, {
    List<String>? ingredients,
    List<String>? recipeSteps,
  }) async {
    final AppRepositories repositories = _repositories!;
    await repositories.dishRepository.updateSections(
      dishId,
      ingredients: ingredients,
      recipeSteps: recipeSteps,
    );
    await _reloadFromRepositories();
    await repositories.syncRepository.processPendingOperations();
  }
}

List<DishNote> _notesFor(String dishId, List<String> bodies) {
  return bodies.asMap().entries.map((MapEntry<int, String> entry) {
    return DishNote(
      id: '${dishId}_note_${entry.key}',
      dishId: dishId,
      body: entry.value,
      position: entry.key,
    );
  }).toList(growable: false);
}
