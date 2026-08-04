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
      final ImageDerivativeSet? previews = await _previewsForLocalMedia(
        cacheKey: 'dish_${dish.id}_hero',
        mediaRef: cachedRef,
        existingProcessingRef: dish.heroPreviewUrl,
        existingCardRef: dish.heroThumbnailUrl,
        existingPlaceholderRef: dish.heroPlaceholderUrl,
      );
      if (cachedRef != dish.heroImageUrl ||
          previews?.processingRef != dish.heroPreviewUrl ||
          previews?.cardRef != dish.heroThumbnailUrl ||
          previews?.placeholderRef != dish.heroPlaceholderUrl) {
        await (_database.update(_database.dishes)
              ..where((db.Dishes table) => table.id.equals(dish.id)))
            .write(
          db.DishesCompanion(
            heroImageUrl: Value<String>(cachedRef),
            heroPreviewUrl: Value<String?>(previews?.processingRef),
            heroThumbnailUrl: Value<String?>(previews?.cardRef),
            heroPlaceholderUrl: Value<String?>(previews?.placeholderRef),
          ),
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
      final ImageDerivativeSet? previews = await _previewsForLocalMedia(
        cacheKey: 'source_${photo.id}',
        mediaRef: cachedRef,
        existingProcessingRef: photo.previewUrl,
        existingCardRef: photo.thumbnailUrl,
        existingPlaceholderRef: photo.placeholderUrl,
      );
      if (cachedRef != photo.url ||
          previews?.processingRef != photo.previewUrl ||
          previews?.cardRef != photo.thumbnailUrl ||
          previews?.placeholderRef != photo.placeholderUrl) {
        await (_database.update(_database.sourcePhotos)
              ..where(
                (db.SourcePhotos table) => table.id.equals(photo.id),
              ))
            .write(
          db.SourcePhotosCompanion(
            url: Value<String>(cachedRef),
            previewUrl: Value<String?>(previews?.processingRef),
            thumbnailUrl: Value<String?>(previews?.cardRef),
            placeholderUrl: Value<String?>(previews?.placeholderRef),
          ),
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
      final ({String original, ImageDerivativeSet? previews}) media =
          await _preferredSourceMedia(photo);
      sourcePhotos.add(
        SourcePhoto(
          id: photo.id,
          url: media.original,
          previewUrl: media.previews?.processingRef,
          thumbnailUrl: media.previews?.cardRef,
          placeholderUrl: media.previews?.placeholderRef,
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
    final ImageDerivativeSet? cachedCoverPreviews = coverSource == null
        ? await _cachedCoverPreviews(apiDish.coverImage, cachedCover)
        : ImageDerivativeSet(
            processingRef: coverSource.previewUrl,
            cardRef: coverSource.thumbnailUrl,
            placeholderRef: coverSource.placeholderUrl,
          );
    final Dish dish = _dishFromApi(
      apiDish,
      sourcePhotos: sourcePhotos,
      heroImageUrl: cachedCover,
      heroPreviewUrl: cachedCoverPreviews?.processingRef,
      heroThumbnailUrl: cachedCoverPreviews?.cardRef,
      heroPlaceholderUrl: cachedCoverPreviews?.placeholderRef,
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
                previewUrl: Value<String?>(photo.previewUrl),
                thumbnailUrl: Value<String?>(photo.thumbnailUrl),
                placeholderUrl: Value<String?>(photo.placeholderUrl),
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

  Future<({String original, ImageDerivativeSet? previews})>
      _preferredSourceMedia(
    ApiSourcePhoto photo,
  ) async {
    final String? captureId = photo.captureId;
    if (captureId != null) {
      final db.CaptureItemRow? capture =
          await (_database.select(_database.captureItems)
                ..where((db.CaptureItems table) => table.id.equals(captureId)))
              .getSingleOrNull();
      final String? localMediaRef = capture?.localMediaRef;
      if (localMediaRef != null && File(localMediaRef).existsSync()) {
        final ImageDerivativeSet previews =
            await _imageDerivativeStore.ensureSet(
          key: 'capture_${capture!.id}',
          sourcePath: localMediaRef,
          existingProcessingRef: capture.localPreviewRef,
          existingCardRef: capture.localThumbnailRef,
          existingPlaceholderRef: capture.localPlaceholderRef,
        );
        if (previews.processingRef != capture.localPreviewRef ||
            previews.cardRef != capture.localThumbnailRef ||
            previews.placeholderRef != capture.localPlaceholderRef) {
          await (_database.update(_database.captureItems)
                ..where(
                  (db.CaptureItems table) => table.id.equals(capture.id),
                ))
              .write(
            db.CaptureItemsCompanion(
              localPreviewRef: Value<String?>(previews.processingRef),
              localThumbnailRef: Value<String?>(previews.cardRef),
              localPlaceholderRef: Value<String?>(previews.placeholderRef),
            ),
          );
        }
        return (original: localMediaRef, previews: previews);
      }
    }
    final String original = await _dishImageCache.resolve(
      cacheKey: photo.id,
      remoteRef: photo.mediaRef,
    );
    return (
      original: original,
      previews: await _previewsForLocalMedia(
        cacheKey: 'source_${photo.id}',
        mediaRef: original,
      ),
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

  Future<ImageDerivativeSet?> _cachedCoverPreviews(
    ApiImage? coverImage,
    String cachedCover,
  ) async {
    if (coverImage == null) {
      return null;
    }
    return _previewsForLocalMedia(
      cacheKey: 'cover_${coverImage.id}',
      mediaRef: cachedCover,
    );
  }

  Future<ImageDerivativeSet?> _previewsForLocalMedia({
    required String cacheKey,
    required String mediaRef,
    String? existingProcessingRef,
    String? existingCardRef,
    String? existingPlaceholderRef,
  }) async {
    if (_isNetworkMediaRef(mediaRef)) {
      return null;
    }
    final Uri? uri = Uri.tryParse(mediaRef);
    if (uri != null && uri.scheme.isNotEmpty && uri.scheme != 'file') {
      return null;
    }
    return _imageDerivativeStore.ensureSet(
      key: cacheKey,
      sourcePath: mediaRef,
      existingProcessingRef: existingProcessingRef,
      existingCardRef: existingCardRef,
      existingPlaceholderRef: existingPlaceholderRef,
    );
  }

  Dish _dishFromApi(
    ApiDish dish, {
    required List<SourcePhoto> sourcePhotos,
    String? heroImageUrl,
    String? heroPreviewUrl,
    String? heroThumbnailUrl,
    String? heroPlaceholderUrl,
  }) {
    final String resolvedHeroImageUrl =
        heroImageUrl ?? (sourcePhotos.isEmpty ? '' : sourcePhotos.first.url);
    final String category = dish.labels.isEmpty ? 'capture' : dish.labels.first;
    return Dish(
      id: dish.id,
      title: dish.title,
      description: dish.description,
      heroImageUrl: resolvedHeroImageUrl,
      heroPreviewUrl: heroPreviewUrl,
      heroThumbnailUrl: heroThumbnailUrl,
      heroPlaceholderUrl: heroPlaceholderUrl,
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
