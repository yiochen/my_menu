part of 'app_repositories.dart';

extension CaptureCorrectionRepositorySupport on CaptureCorrectionRepository {
  CaptureCorrection _correctionFromRow(db.CaptureCorrectionRow row) {
    final Object? captureIds = jsonDecode(row.captureIdsJson);
    final Object? assignments = jsonDecode(row.previousDishIdsJson);
    final Map<String, String> previousDishIds = <String, String>{};
    final Set<String> previouslyUnclassifiedCaptureIds = <String>{};
    final Map<String, String?> previousFailureReasons = <String, String?>{};
    final Map<String, capture_domain.CaptureItemStatus> previousStatuses =
        <String, capture_domain.CaptureItemStatus>{};
    if (assignments is Map<String, dynamic>) {
      for (final MapEntry<String, dynamic> entry in assignments.entries) {
        final Object? value = entry.value;
        if (value is String) {
          previousDishIds[entry.key] = value;
          continue;
        }
        if (value is Map<dynamic, dynamic>) {
          final Object? dishId = value['dishId'];
          if (dishId is String) {
            previousDishIds[entry.key] = dishId;
          } else {
            previouslyUnclassifiedCaptureIds.add(entry.key);
          }
          final Object? reason = value['failureReason'];
          previousFailureReasons[entry.key] = reason is String ? reason : null;
          final Object? status = value['status'];
          if (status is String) {
            previousStatuses[entry.key] =
                capture_domain.CaptureItemStatus.values.byName(status);
          }
        }
      }
    }
    return CaptureCorrection(
      id: row.id,
      batchId: row.batchId,
      type: CaptureCorrectionType.values.byName(row.actionType),
      captureIds: captureIds is List<dynamic>
          ? captureIds.whereType<String>().toList(growable: false)
          : const <String>[],
      previousDishIds: previousDishIds,
      previouslyUnclassifiedCaptureIds: previouslyUnclassifiedCaptureIds,
      previousFailureReasons: previousFailureReasons,
      previousStatuses: previousStatuses,
      targetDishId: row.targetDishId,
      createdDishId: row.createdDishId,
      status: CaptureCorrectionStatus.values.byName(row.status),
      error: row.error,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      undoneAt: row.undoneAt,
    );
  }

  Future<void> insertLocalDish({
    required String id,
    required String title,
    required List<db.CaptureItemRow> items,
  }) async {
    final String heroImageUrl = _photoRef(items.first) ?? '';
    final String? heroPreviewUrl = items.first.localPreviewRef;
    final String? heroThumbnailUrl = items.first.localThumbnailRef;
    final String? heroPlaceholderUrl = items.first.localPlaceholderRef;
    await _database.into(_database.dishes).insert(
          db.DishesCompanion.insert(
            id: id,
            title: title,
            description: 'Created from selected capture photos.',
            heroImageUrl: heroImageUrl,
            heroPreviewUrl: Value<String?>(heroPreviewUrl),
            heroThumbnailUrl: Value<String?>(heroThumbnailUrl),
            heroPlaceholderUrl: Value<String?>(heroPlaceholderUrl),
            category: 'Captured',
            prepMinutes: 0,
            difficulty: 'Not set',
            madeCount: 0,
            lastMadeLabel: 'Today',
            ingredientsJson: '[]',
            recipeStepsJson: '[]',
            notesJson: '[]',
            createdAt: Value<DateTime?>(DateTime.now()),
          ),
        );
  }

  Future<void> moveLocalAssignments({
    required String batchId,
    required List<db.CaptureItemRow> items,
    required String targetDishId,
  }) async {
    final Set<String> dishIds = <String>{
      targetDishId,
      ...items
          .map((db.CaptureItemRow item) => item.appliedDishId)
          .whereType<String>(),
    };
    final Map<String, bool> beforePresence =
        await _batchPresence(batchId, dishIds);
    final Map<String, Set<String>> removedRefsByDish = <String, Set<String>>{};
    for (final db.CaptureItemRow item in items) {
      final String? sourceDishId = item.appliedDishId;
      final String? photoRef = _photoRef(item);
      if (sourceDishId != null &&
          sourceDishId != targetDishId &&
          photoRef != null) {
        removedRefsByDish
            .putIfAbsent(sourceDishId, () => <String>{})
            .add(photoRef);
      }
      await _moveOneLocalAssignment(item: item, targetDishId: targetDishId);
    }
    await _adjustDishCounts(
      dishIds: dishIds,
      beforePresence: beforePresence,
      afterPresence: await _batchPresence(batchId, dishIds),
      removedRefsByDish: removedRefsByDish,
    );
  }

  Future<void> _moveOneLocalAssignment({
    required db.CaptureItemRow item,
    required String targetDishId,
  }) async {
    final String? sourceDishId = item.appliedDishId;
    if (sourceDishId == targetDishId) {
      return;
    }
    final String? photoRef = _photoRef(item);
    if (photoRef != null) {
      final db.SourcePhotoRow? source = sourceDishId == null
          ? null
          : await _sourceForCapture(item, sourceDishId);
      final int moved = source == null
          ? 0
          : await (_database.update(_database.sourcePhotos)
                ..where(
                  (db.SourcePhotos table) => table.id.equals(source.id),
                ))
              .write(
              db.SourcePhotosCompanion(
                dishId: Value<String>(targetDishId),
              ),
            );
      if (moved == 0) {
        await _database.into(_database.sourcePhotos).insertOnConflictUpdate(
              db.SourcePhotosCompanion.insert(
                id: '${item.id}_source',
                dishId: targetDishId,
                url: photoRef,
                previewUrl: Value<String?>(item.localPreviewRef),
                thumbnailUrl: Value<String?>(item.localThumbnailRef),
                placeholderUrl: Value<String?>(item.localPlaceholderRef),
                capturedLabel: 'Today',
                captureId: Value<String?>(item.id),
                capturedAt: Value<DateTime?>(item.capturedAt),
                confidenceLabel: const Value<String?>('User corrected'),
              ),
            );
      }
    }
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(item.id)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(capture_domain.CaptureItemStatus.applied.name),
        appliedDishId: Value<String?>(targetDishId),
        failureReason: const Value<String?>(null),
      ),
    );
  }

  Future<void> _restoreUnclassifiedLocalAssignment({
    required db.CaptureItemRow item,
    required String sourceDishId,
    required String? failureReason,
    required capture_domain.CaptureItemStatus previousStatus,
  }) async {
    final String? photoRef = _photoRef(item);
    if (photoRef != null) {
      final db.SourcePhotoRow? source =
          await _sourceForCapture(item, sourceDishId);
      if (source != null) {
        await (_database.delete(_database.sourcePhotos)
              ..where(
                (db.SourcePhotos table) => table.id.equals(source.id),
              ))
            .go();
      }
    }
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(item.id)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(previousStatus.name),
        appliedDishId: const Value<String?>(null),
        failureReason: Value<String?>(failureReason),
      ),
    );
  }

  Future<Map<String, bool>> _batchPresence(
    String batchId,
    Set<String> dishIds,
  ) async {
    final List<db.CaptureItemRow> rows =
        await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) =>
                    table.batchId.equals(batchId) &
                    table.appliedDishId.isIn(dishIds),
              ))
            .get();
    return <String, bool>{
      for (final String dishId in dishIds)
        dishId: rows.any(
          (db.CaptureItemRow item) => item.appliedDishId == dishId,
        ),
    };
  }

  Future<void> _adjustDishCounts({
    required Set<String> dishIds,
    required Map<String, bool> beforePresence,
    required Map<String, bool> afterPresence,
    Map<String, Set<String>> removedRefsByDish = const <String, Set<String>>{},
  }) async {
    for (final String dishId in dishIds) {
      final List<db.SourcePhotoRow> sources =
          await (_database.select(_database.sourcePhotos)
                ..where(
                  (db.SourcePhotos table) => table.dishId.equals(dishId),
                ))
              .get();
      final int sourceCount = sources.length;
      final db.DishRow? dish = await (_database.select(_database.dishes)
            ..where((db.Dishes table) => table.id.equals(dishId)))
          .getSingleOrNull();
      if (dish == null) {
        continue;
      }
      final int presenceDelta = ((afterPresence[dishId] ?? false) ? 1 : 0) -
          ((beforePresence[dishId] ?? false) ? 1 : 0);
      final int adjustedCount = dish.madeCount + presenceDelta;
      final int madeCount =
          sourceCount == 0 || adjustedCount < 0 ? 0 : adjustedCount;
      final bool removedCurrentHero =
          removedRefsByDish[dishId]?.contains(dish.heroImageUrl) ?? false;
      final String heroImageUrl =
          dish.heroImageUrl.isEmpty || removedCurrentHero
              ? sources.firstOrNull?.url ?? ''
              : dish.heroImageUrl;
      final String? heroPreviewUrl =
          dish.heroImageUrl.isEmpty || removedCurrentHero
              ? sources.firstOrNull?.previewUrl
              : dish.heroPreviewUrl;
      final String? heroThumbnailUrl =
          dish.heroImageUrl.isEmpty || removedCurrentHero
              ? sources.firstOrNull?.thumbnailUrl
              : dish.heroThumbnailUrl;
      final String? heroPlaceholderUrl =
          dish.heroImageUrl.isEmpty || removedCurrentHero
              ? sources.firstOrNull?.placeholderUrl
              : dish.heroPlaceholderUrl;
      await (_database.update(_database.dishes)
            ..where((db.Dishes table) => table.id.equals(dishId)))
          .write(
        db.DishesCompanion(
          heroImageUrl: Value<String>(heroImageUrl),
          heroPreviewUrl: Value<String?>(heroPreviewUrl),
          heroThumbnailUrl: Value<String?>(heroThumbnailUrl),
          heroPlaceholderUrl: Value<String?>(heroPlaceholderUrl),
          madeCount: Value<int>(madeCount),
          lastMadeLabel: Value<String>(
            madeCount == 0 ? 'Not cooked yet' : dish.lastMadeLabel,
          ),
        ),
      );
    }
  }

  String? _photoRef(db.CaptureItemRow item) => item.localMediaRef;

  Future<db.SourcePhotoRow?> _sourceForCapture(
    db.CaptureItemRow item,
    String dishId,
  ) async {
    final db.SourcePhotoRow? identified =
        await (_database.select(_database.sourcePhotos)
              ..where(
                (db.SourcePhotos table) =>
                    table.dishId.equals(dishId) &
                    (table.captureId.equals(item.id) |
                        table.id.equals('${item.id}_source')),
              )
              ..limit(1))
            .getSingleOrNull();
    if (identified != null) {
      return identified;
    }
    final String? photoRef = _photoRef(item);
    if (photoRef == null) {
      return null;
    }
    return (_database.select(_database.sourcePhotos)
          ..where(
            (db.SourcePhotos table) =>
                table.dishId.equals(dishId) & table.url.equals(photoRef),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<bool> _shouldDeleteAutoCreatedDish(
    CaptureCorrection correction,
  ) async {
    final bool knownCreated = correction.createdDishId != null ||
        await (_database.select(_database.captureCorrections)
                  ..where(
                    (db.CaptureCorrections table) =>
                        table.createdDishId.equals(correction.targetDishId),
                  )
                  ..limit(1))
                .getSingleOrNull() !=
            null;
    if (!knownCreated) {
      return false;
    }
    return await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) =>
                    table.appliedDishId.equals(correction.targetDishId),
              )
              ..limit(1))
            .getSingleOrNull() ==
        null;
  }
}
