part of 'repositories.dart';

extension AppRepositoriesMediaPreviews on AppRepositories {
  Future<void> _prepareImagePreviews() async {
    final List<db.CaptureItemRow> captures =
        await database.select(database.captureItems).get();
    final Map<String, ImageDerivativeSet> capturePreviews =
        <String, ImageDerivativeSet>{};
    await _forEachPair(captures, (db.CaptureItemRow capture) async {
      final String? sourcePath = _localFilePath(capture.localMediaRef);
      if (sourcePath == null ||
          capture.kind != capture_domain.CaptureItemKind.photo.name) {
        return;
      }
      final ImageDerivativeSet previews = await _imageDerivativeStore.ensureSet(
        key: 'capture_${capture.id}',
        sourcePath: sourcePath,
        existingProcessingRef: capture.localPreviewRef,
        existingCardRef: capture.localThumbnailRef,
        existingPlaceholderRef: capture.localPlaceholderRef,
      );
      capturePreviews[capture.id] = previews;
      if (previews.processingRef != capture.localPreviewRef ||
          previews.cardRef != capture.localThumbnailRef ||
          previews.placeholderRef != capture.localPlaceholderRef) {
        await (database.update(database.captureItems)
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
    });

    final List<db.SourcePhotoRow> sources =
        await database.select(database.sourcePhotos).get();
    final Map<String, ImageDerivativeSet> sourcePreviews =
        <String, ImageDerivativeSet>{};
    await _forEachPair(sources, (db.SourcePhotoRow source) async {
      ImageDerivativeSet? previews =
          source.captureId == null ? null : capturePreviews[source.captureId!];
      final String? sourcePath = _localFilePath(source.url);
      if (previews == null && sourcePath != null) {
        previews = await _imageDerivativeStore.ensureSet(
          key: 'source_${source.id}',
          sourcePath: sourcePath,
          existingProcessingRef: source.previewUrl,
          existingCardRef: source.thumbnailUrl,
          existingPlaceholderRef: source.placeholderUrl,
        );
      }
      if (previews == null) {
        return;
      }
      sourcePreviews[source.id] = previews;
      if (previews.processingRef != source.previewUrl ||
          previews.cardRef != source.thumbnailUrl ||
          previews.placeholderRef != source.placeholderUrl) {
        await (database.update(database.sourcePhotos)
              ..where(
                (db.SourcePhotos table) => table.id.equals(source.id),
              ))
            .write(
          db.SourcePhotosCompanion(
            previewUrl: Value<String?>(previews.processingRef),
            thumbnailUrl: Value<String?>(previews.cardRef),
            placeholderUrl: Value<String?>(previews.placeholderRef),
          ),
        );
      }
    });

    final List<db.DishRow> dishes =
        await database.select(database.dishes).get();
    await _forEachPair(dishes, (db.DishRow dish) async {
      final db.SourcePhotoRow? heroSource = sources
          .where((db.SourcePhotoRow source) => source.dishId == dish.id)
          .where((db.SourcePhotoRow source) => source.url == dish.heroImageUrl)
          .firstOrNull;
      ImageDerivativeSet? previews = heroSource == null
          ? null
          : sourcePreviews[heroSource.id] ??
              ImageDerivativeSet(
                processingRef: heroSource.previewUrl,
                cardRef: heroSource.thumbnailUrl,
                placeholderRef: heroSource.placeholderUrl,
              );
      final String? heroPath = _localFilePath(dish.heroImageUrl);
      if (previews == null && heroPath != null) {
        previews = await _imageDerivativeStore.ensureSet(
          key: 'dish_${dish.id}_hero',
          sourcePath: heroPath,
          existingProcessingRef: dish.heroPreviewUrl,
          existingCardRef: dish.heroThumbnailUrl,
          existingPlaceholderRef: dish.heroPlaceholderUrl,
        );
      }
      if (previews == null) {
        return;
      }
      if (previews.processingRef != dish.heroPreviewUrl ||
          previews.cardRef != dish.heroThumbnailUrl ||
          previews.placeholderRef != dish.heroPlaceholderUrl) {
        await (database.update(database.dishes)
              ..where((db.Dishes table) => table.id.equals(dish.id)))
            .write(
          db.DishesCompanion(
            heroPreviewUrl: Value<String?>(previews.processingRef),
            heroThumbnailUrl: Value<String?>(previews.cardRef),
            heroPlaceholderUrl: Value<String?>(previews.placeholderRef),
          ),
        );
      }
    });

    final List<db.CaptureItemRow> refreshedCaptures =
        await database.select(database.captureItems).get();
    final List<db.SourcePhotoRow> refreshedSources =
        await database.select(database.sourcePhotos).get();
    final List<db.DishRow> refreshedDishes =
        await database.select(database.dishes).get();
    await _imageDerivativeStore.cleanup(
      referencedRefs: <String?>[
        ...refreshedCaptures.map(
          (db.CaptureItemRow capture) => capture.localPreviewRef,
        ),
        ...refreshedCaptures.map(
          (db.CaptureItemRow capture) => capture.localThumbnailRef,
        ),
        ...refreshedCaptures.map(
          (db.CaptureItemRow capture) => capture.localPlaceholderRef,
        ),
        ...refreshedSources.map(
          (db.SourcePhotoRow source) => source.previewUrl,
        ),
        ...refreshedSources.map(
          (db.SourcePhotoRow source) => source.thumbnailUrl,
        ),
        ...refreshedSources.map(
          (db.SourcePhotoRow source) => source.placeholderUrl,
        ),
        ...refreshedDishes.map((db.DishRow dish) => dish.heroPreviewUrl),
        ...refreshedDishes.map((db.DishRow dish) => dish.heroThumbnailUrl),
        ...refreshedDishes.map((db.DishRow dish) => dish.heroPlaceholderUrl),
      ],
    );
  }

  Future<void> _forEachPair<T>(
    List<T> values,
    Future<void> Function(T value) action,
  ) async {
    for (int index = 0; index < values.length; index += 2) {
      await Future.wait(
        values.skip(index).take(2).map(action),
      );
    }
  }

  String? _localFilePath(String? ref) {
    final String value = ref?.trim() ?? '';
    if (value.isEmpty) {
      return null;
    }
    final Uri? uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.isEmpty) {
      return value;
    }
    if (uri.scheme == 'file') {
      return File.fromUri(uri).path;
    }
    return null;
  }
}
