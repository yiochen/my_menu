part of 'my_menu_state.dart';

extension MyMenuDishEdits on MyMenuState {
  Future<void> addIdea(String text, {String? note}) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final Dish nextDish = _buildIdeaDish(trimmed, note: note);

    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      await repositories.dishRepository.createDish(nextDish);
      await _reloadFromRepositories();
      return;
    }
    _dishes = <Dish>[nextDish, ..._dishes];
    _notifyChanged();
  }

  Future<void> createDishFromReview(String reviewId) async {
    final ReviewItem item =
        _reviewItems.firstWhere((ReviewItem review) => review.id == reviewId);
    final Dish nextDish = item.imageRef == null
        ? _buildIdeaDish(item.summary)
        : _dishFromPhotoReview(
            item,
            _repositories == null
                ? 'dish_capture_${_dishes.length}'
                : const Uuid().v4(),
            _templateFor(item.summary),
          );
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      await repositories.dishRepository.createDish(
        nextDish,
        consumedReviewId: reviewId,
      );
      await _reloadFromRepositories();
      _reviewItems = _reviewItems
          .where((ReviewItem review) => review.id != reviewId)
          .toList(growable: false);
      _notifyChanged();
      return;
    }
    _reviewItems = _reviewItems
        .where((ReviewItem review) => review.id != reviewId)
        .toList(growable: false);
    _dishes = <Dish>[nextDish, ..._dishes];
    _notifyChanged();
  }

  Dish _buildIdeaDish(String text, {String? note}) {
    final Dish template = _templateFor(text);
    final String idBase =
        text.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');
    final String dishId = _repositories == null
        ? 'dish_$idBase${_dishes.length}'
        : const Uuid().v4();
    final String trimmedNote = note?.trim() ?? '';
    return Dish(
      id: dishId,
      title: _titleCase(text),
      description:
          'A saved dish idea for ${text.toLowerCase()}, ready to refine the next time you cook it.',
      heroImageUrl: template.heroImageUrl,
      category: template.category,
      prepMinutes: template.prepMinutes,
      difficulty: template.difficulty,
      madeCount: 0,
      lastMadeLabel: 'Not cooked yet',
      ingredients: template.ingredients,
      recipeSteps: template.recipeSteps,
      notes: _notesFor(
        dishId,
        trimmedNote.isEmpty ? const <String>[] : <String>[trimmedNote],
      ),
      sourcePhotos: const <SourcePhoto>[],
      createdAt: DateTime.now(),
    );
  }

  Future<void> addDishNote(String dishId, String body) async {
    final String trimmed = body.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      await _addRepositoryNote(dishId, trimmed);
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

  Future<void> updateDishNote(String noteId, String body) async {
    final String trimmed = body.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      await _updateRepositoryNote(noteId, trimmed);
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

  Future<void> deleteDishNote(String noteId) async {
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      await _deleteRepositoryNote(noteId);
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

  Future<void> updateDishSections(
    String dishId, {
    List<String>? ingredients,
    List<String>? recipeSteps,
  }) async {
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      await _updateRepositorySections(
        dishId,
        ingredients: ingredients,
        recipeSteps: recipeSteps,
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
  }

  Future<void> _updateRepositoryNote(String noteId, String body) async {
    final AppRepositories repositories = _repositories!;
    await repositories.dishRepository.updateNote(noteId, body);
    await _reloadFromRepositories();
  }

  Future<void> _deleteRepositoryNote(String noteId) async {
    final AppRepositories repositories = _repositories!;
    await repositories.dishRepository.deleteNote(noteId);
    await _reloadFromRepositories();
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
