part of 'repositories.dart';

extension CaptureCorrectionRepositorySupport on CaptureCorrectionRepository {
  CaptureCorrection _correctionFromRow(db.CaptureCorrectionRow row) {
    final Object? captureIds = jsonDecode(row.captureIdsJson);
    final Object? assignments = jsonDecode(row.previousDishIdsJson);
    final Map<String, String> previousDishIds = <String, String>{};
    final Set<String> previouslyUnclassifiedCaptureIds = <String>{};
    final Map<String, String?> previousFailureReasons = <String, String?>{};
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
      targetDishId: row.targetDishId,
      createdDishId: row.createdDishId,
      status: CaptureCorrectionStatus.values.byName(row.status),
      error: row.error,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      undoneAt: row.undoneAt,
    );
  }

  Future<void> _insertLocalDish({
    required String id,
    required String title,
    required List<db.CaptureItemRow> items,
  }) async {
    final String heroImageUrl = _photoRef(items.first) ?? '';
    await _database.into(_database.dishes).insert(
          db.DishesCompanion.insert(
            id: id,
            title: title,
            description: 'Created from selected capture photos.',
            heroImageUrl: heroImageUrl,
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

  Future<void> _moveLocalAssignments({
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
    for (final db.CaptureItemRow item in items) {
      await _moveOneLocalAssignment(item: item, targetDishId: targetDishId);
    }
    await _adjustDishCounts(
      dishIds: dishIds,
      beforePresence: beforePresence,
      afterPresence: await _batchPresence(batchId, dishIds),
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
      final int moved = sourceDishId == null
          ? 0
          : await (_database.update(_database.sourcePhotos)
                ..where(
                  (db.SourcePhotos table) =>
                      table.dishId.equals(sourceDishId) &
                      table.url.equals(photoRef),
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
                capturedLabel: 'Today',
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
  }) async {
    final String? photoRef = _photoRef(item);
    if (photoRef != null) {
      await (_database.delete(_database.sourcePhotos)
            ..where(
              (db.SourcePhotos table) =>
                  table.dishId.equals(sourceDishId) &
                  table.url.equals(photoRef),
            ))
          .go();
    }
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(item.id)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(capture_domain.CaptureItemStatus.discarded.name),
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
  }) async {
    for (final String dishId in dishIds) {
      final int sourceCount = await (_database.selectOnly(
        _database.sourcePhotos,
      )
            ..addColumns(<Expression<Object>>[
              _database.sourcePhotos.id.count(),
            ])
            ..where(_database.sourcePhotos.dishId.equals(dishId)))
          .map(
            (TypedResult row) =>
                row.read(_database.sourcePhotos.id.count()) ?? 0,
          )
          .getSingle();
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
      await (_database.update(_database.dishes)
            ..where((db.Dishes table) => table.id.equals(dishId)))
          .write(
        db.DishesCompanion(
          madeCount: Value<int>(madeCount),
          lastMadeLabel: Value<String>(
            madeCount == 0 ? 'Not cooked yet' : dish.lastMadeLabel,
          ),
        ),
      );
    }
  }

  String? _photoRef(db.CaptureItemRow item) =>
      item.remoteMediaRef ?? item.localMediaRef;
}
