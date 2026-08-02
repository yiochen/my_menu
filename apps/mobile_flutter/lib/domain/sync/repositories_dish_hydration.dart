part of 'repositories.dart';

extension SyncRepositoryDishHydration on SyncRepository {
  Future<void> _cacheLocalDishMedia(
    List<db.DishRow> dishes,
    List<db.SourcePhotoRow> sourcePhotos,
  ) async {
    final Set<String> localDishIds = dishes
        .where((db.DishRow dish) => !Uuid.isValidUUID(fromString: dish.id))
        .map((db.DishRow dish) => dish.id)
        .toSet();
    for (final db.DishRow dish in dishes) {
      if (!localDishIds.contains(dish.id) ||
          !_isNetworkMediaRef(dish.heroImageUrl)) {
        continue;
      }
      final String cachedRef = await _dishImageCache.resolve(
        cacheKey: '${dish.id}_hero',
        remoteRef: dish.heroImageUrl,
      );
      if (cachedRef != dish.heroImageUrl) {
        await (_database.update(_database.dishes)
              ..where((db.Dishes table) => table.id.equals(dish.id)))
            .write(
          db.DishesCompanion(heroImageUrl: Value<String>(cachedRef)),
        );
      }
    }
    for (final db.SourcePhotoRow photo in sourcePhotos) {
      if (!localDishIds.contains(photo.dishId) ||
          !_isNetworkMediaRef(photo.url)) {
        continue;
      }
      final String cachedRef = await _dishImageCache.resolve(
        cacheKey: photo.id,
        remoteRef: photo.url,
      );
      if (cachedRef != photo.url) {
        await (_database.update(_database.sourcePhotos)
              ..where(
                (db.SourcePhotos table) => table.id.equals(photo.id),
              ))
            .write(
          db.SourcePhotosCompanion(url: Value<String>(cachedRef)),
        );
      }
    }
  }

  bool _isNetworkMediaRef(String mediaRef) {
    final Uri? uri = Uri.tryParse(mediaRef);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  bool _mediaNeedsRefresh(String mediaRef) {
    if (_isNetworkMediaRef(mediaRef)) {
      return true;
    }
    final Uri? uri = Uri.tryParse(mediaRef);
    if (uri != null && uri.scheme.isNotEmpty && uri.scheme != 'file') {
      return false;
    }
    final File file =
        uri?.scheme == 'file' ? File.fromUri(uri!) : File(mediaRef);
    return !file.existsSync();
  }

  Future<void> _upsertDish(ApiDish apiDish) async {
    final List<SourcePhoto> sourcePhotos = <SourcePhoto>[];
    for (final ApiSourcePhoto photo in apiDish.sourcePhotos) {
      sourcePhotos.add(
        SourcePhoto(
          id: photo.id,
          url: await _preferredSourceMediaRef(photo),
          capturedLabel: _capturedLabel(photo.capturedAt),
          captureId: photo.captureId,
          cookingOccasionId: photo.cookingOccasionId,
          capturedAt: photo.capturedAt,
          note: photo.note,
          confidenceLabel: photo.confidenceLabel,
        ),
      );
    }
    final SourcePhoto? coverSource = sourcePhotos
        .where((SourcePhoto photo) => photo.id == apiDish.coverImage?.id)
        .firstOrNull;
    final String cachedCover = coverSource?.url ??
        await _cachedCoverMediaRef(apiDish.coverImage) ??
        '';
    final Dish dish = _dishFromApi(
      apiDish,
      sourcePhotos: sourcePhotos,
      heroImageUrl: cachedCover,
    );
    await _database.transaction(() async {
      await _database.into(_database.dishes).insertOnConflictUpdate(
            dish.toCompanion(),
          );
      await (_database.delete(_database.sourcePhotos)
            ..where((db.SourcePhotos table) => table.dishId.equals(apiDish.id)))
          .go();
      await (_database.delete(_database.dishNotes)
            ..where((db.DishNotes table) => table.dishId.equals(apiDish.id)))
          .go();
      for (final SourcePhoto photo in sourcePhotos) {
        await _database.into(_database.sourcePhotos).insertOnConflictUpdate(
              db.SourcePhotosCompanion.insert(
                id: photo.id!,
                dishId: apiDish.id,
                url: photo.url,
                capturedLabel: photo.capturedLabel,
                captureId: Value<String?>(photo.captureId),
                cookingOccasionId: Value<String?>(
                  photo.cookingOccasionId,
                ),
                capturedAt: Value<DateTime?>(photo.capturedAt),
                note: Value<String?>(photo.note),
                confidenceLabel: Value<String?>(photo.confidenceLabel),
              ),
            );
      }
      for (int index = 0; index < apiDish.notes.length; index += 1) {
        final DateTime now = DateTime.now();
        await _database.into(_database.dishNotes).insertOnConflictUpdate(
              db.DishNotesCompanion.insert(
                id: '${apiDish.id}_server_note_$index',
                dishId: apiDish.id,
                body: apiDish.notes[index],
                position: index,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    });
  }

  Future<String> _preferredSourceMediaRef(ApiSourcePhoto photo) async {
    final String? captureId = photo.captureId;
    if (captureId != null) {
      final db.CaptureItemRow? capture =
          await (_database.select(_database.captureItems)
                ..where((db.CaptureItems table) => table.id.equals(captureId)))
              .getSingleOrNull();
      final String? localMediaRef = capture?.localMediaRef;
      if (localMediaRef != null && File(localMediaRef).existsSync()) {
        return localMediaRef;
      }
    }
    return _dishImageCache.resolve(
      cacheKey: photo.id,
      remoteRef: photo.mediaRef,
    );
  }

  Future<String?> _cachedCoverMediaRef(ApiImage? coverImage) async {
    if (coverImage == null) {
      return null;
    }
    return _dishImageCache.resolve(
      cacheKey: coverImage.id,
      remoteRef: coverImage.mediaRef,
    );
  }

  Dish _dishFromApi(
    ApiDish dish, {
    required List<SourcePhoto> sourcePhotos,
    String? heroImageUrl,
  }) {
    final String resolvedHeroImageUrl =
        heroImageUrl ?? (sourcePhotos.isEmpty ? '' : sourcePhotos.first.url);
    final String category = dish.labels.isEmpty ? 'capture' : dish.labels.first;
    return Dish(
      id: dish.id,
      title: dish.title,
      description: dish.description,
      heroImageUrl: resolvedHeroImageUrl,
      category: category,
      prepMinutes: dish.prepMinutes ?? 30,
      difficulty: dish.difficulty ?? 'Draft',
      madeCount: dish.madeCount,
      lastMadeLabel: _lastMadeLabel(dish.lastMadeAt),
      ingredients: dish.ingredients,
      recipeSteps: dish.steps,
      notes: _notesFromApi(dish),
      sourcePhotos: sourcePhotos,
      isFavorite: dish.isFavorite,
      createdAt: dish.createdAt,
    );
  }

  List<DishNote> _notesFromApi(ApiDish dish) {
    return dish.notes.asMap().entries.map((MapEntry<int, String> entry) {
      return DishNote(
        id: '${dish.id}_server_note_${entry.key}',
        dishId: dish.id,
        body: entry.value,
        position: entry.key,
      );
    }).toList(growable: false);
  }
}
