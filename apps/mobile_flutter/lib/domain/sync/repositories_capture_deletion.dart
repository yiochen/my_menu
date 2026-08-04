part of 'repositories.dart';

extension CaptureRepositoryDeletion on CaptureRepository {
  Future<void> discardCapture(String captureId) async {
    await dismissSuggestion(captureId);
  }

  Future<void> dismissSuggestion(String captureId) async {
    final db.CaptureItemRow? item =
        await (_database.select(_database.captureItems)
              ..where((db.CaptureItems table) => table.id.equals(captureId)))
            .getSingleOrNull();
    if (item == null) {
      return;
    }
    await _database.transaction(() async {
      await (_database.delete(_database.reviewItems)
            ..where(
              (db.ReviewItems table) => table.captureId.equals(captureId),
            ))
          .go();
      await (_database.update(_database.captureItems)
            ..where((db.CaptureItems table) => table.id.equals(captureId)))
          .write(
        db.CaptureItemsCompanion(
          status: Value<String>(
            item.appliedDishId == null
                ? capture_domain.CaptureItemStatus.localOnly.name
                : capture_domain.CaptureItemStatus.applied.name,
          ),
          failureReason: const Value<String?>(null),
        ),
      );
      if (item.batchId case final String batchId) {
        await _processingOutboxRepository.supersedeCaptureGrouping(batchId);
      }
    });
  }

  Future<void> deleteCapture(String captureId) async {
    final db.CaptureItemRow? capture =
        await (_database.select(_database.captureItems)
              ..where((db.CaptureItems table) => table.id.equals(captureId)))
            .getSingleOrNull();
    if (capture == null) {
      return;
    }
    final String? affectedDishId = capture.appliedDishId;
    await _database.transaction(() async {
      if (capture.batchId case final String batchId) {
        await _processingOutboxRepository.supersedeCaptureGrouping(batchId);
        await (_database.delete(_database.aiJobs)
              ..where((db.AiJobs table) => table.subjectId.equals(batchId)))
            .go();
      }
      await (_database.delete(_database.reviewItems)
            ..where(
              (db.ReviewItems table) => table.captureId.equals(captureId),
            ))
          .go();
      await (_database.delete(_database.sourcePhotos)
            ..where(
              (db.SourcePhotos table) =>
                  table.captureId.equals(captureId) |
                  table.id.equals('${captureId}_source'),
            ))
          .go();
      await (_database.delete(_database.captureItems)
            ..where((db.CaptureItems table) => table.id.equals(captureId)))
          .go();
      await (_database.delete(_database.syncOperations)
            ..where(
              (db.SyncOperations table) => table.entityId.equals(captureId),
            ))
          .go();
      if (affectedDishId != null && capture.batchId != null) {
        await _refreshDishAfterCaptureRemoval(
          dishId: affectedDishId,
          batchId: capture.batchId!,
          removedRefs: <String>{
            ...<String?>[capture.localMediaRef, capture.remoteMediaRef]
                .whereType<String>(),
          },
        );
      }
    });
    await _deleteLocalCaptureCopies(<String?>[capture.localMediaRef]);
    await _imageDerivativeStore.remove(
      refs: <String?>[
        capture.localPreviewRef,
        capture.localThumbnailRef,
        capture.localPlaceholderRef,
      ],
    );
  }

  Future<void> retryBatch(String batchId) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await (_database.update(_database.captureItems)
            ..where(
              (db.$CaptureItemsTable table) =>
                  table.batchId.equals(batchId) &
                  table.status.equals(
                    capture_domain.CaptureItemStatus.failed.name,
                  ),
            ))
          .write(
        db.CaptureItemsCompanion(
          status: Value<String>(
            capture_domain.CaptureItemStatus.pendingUpload.name,
          ),
          failureReason: const Value<String?>(null),
        ),
      );
      await (_database.update(
        _database.captureBatches,
      )..where((db.$CaptureBatchesTable table) => table.id.equals(batchId)))
          .write(
        db.CaptureBatchesCompanion(
          status: Value<String>(CaptureBatchStatus.pendingUpload.name),
          updatedAt: Value<DateTime>(now),
          failureReason: const Value<String?>(null),
        ),
      );
      await _processingOutboxRepository.retryCaptureGrouping(
        batchId: batchId,
        now: now,
      );
    });
  }

  Future<void> deleteBatch(String batchId) async {
    final List<db.CaptureItemRow> captures = await (_database.select(
      _database.captureItems,
    )..where((db.CaptureItems table) => table.batchId.equals(batchId)))
        .get();
    final List<String> captureIds = captures
        .map((db.CaptureItemRow capture) => capture.id)
        .toList(growable: false);
    final Set<String> affectedDishIds = captures
        .map((db.CaptureItemRow capture) => capture.appliedDishId)
        .whereType<String>()
        .toSet();
    final Map<String, Set<String>> removedRefsByDish = <String, Set<String>>{};
    for (final db.CaptureItemRow capture in captures) {
      final String? dishId = capture.appliedDishId;
      if (dishId == null) {
        continue;
      }
      removedRefsByDish.putIfAbsent(dishId, () => <String>{}).addAll(
            <String?>[capture.localMediaRef, capture.remoteMediaRef]
                .whereType<String>(),
          );
    }
    await _database.transaction(() async {
      await _processingOutboxRepository.supersedeCaptureGrouping(batchId);
      await (_database.delete(_database.syncOperations)
            ..where(
              (db.SyncOperations table) =>
                  (table.entity.equals('capture_item') &
                      table.entityId.isIn(captureIds)) |
                  (table.entity.equals('capture_batch') &
                      table.entityId.equals(batchId)),
            ))
          .go();
      if (captureIds.isNotEmpty) {
        await (_database.delete(_database.reviewItems)
              ..where(
                (db.ReviewItems table) => table.captureId.isIn(captureIds),
              ))
            .go();
        await (_database.delete(_database.sourcePhotos)
              ..where(
                (db.SourcePhotos table) =>
                    table.captureId.isIn(captureIds) |
                    table.id.isIn(
                      captureIds
                          .map((String id) => '${id}_source')
                          .toList(growable: false),
                    ),
              ))
            .go();
      }
      await (_database.delete(_database.captureCorrections)
            ..where(
              (db.CaptureCorrections table) => table.batchId.equals(batchId),
            ))
          .go();
      await (_database.delete(_database.aiJobs)
            ..where((db.AiJobs table) => table.subjectId.equals(batchId)))
          .go();
      await (_database.delete(_database.captureItems)
            ..where((db.CaptureItems table) => table.batchId.equals(batchId)))
          .go();
      await (_database.delete(_database.captureBatches)
            ..where((db.CaptureBatches table) => table.id.equals(batchId)))
          .go();
      for (final String dishId in affectedDishIds) {
        await _refreshDishAfterCaptureRemoval(
          dishId: dishId,
          batchId: batchId,
          removedRefs: removedRefsByDish[dishId] ?? const <String>{},
        );
      }
    });

    await _deleteLocalCaptureCopies(
      captures.map((db.CaptureItemRow capture) => capture.localMediaRef),
    );
    await _imageDerivativeStore.remove(
      refs: captures.expand(
        (db.CaptureItemRow capture) => <String?>[
          capture.localPreviewRef,
          capture.localThumbnailRef,
          capture.localPlaceholderRef,
        ],
      ),
    );
  }

  Future<void> _refreshDishAfterCaptureRemoval({
    required String dishId,
    required String batchId,
    required Set<String> removedRefs,
  }) async {
    final db.DishRow? dish = await (_database.select(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(dishId)))
        .getSingleOrNull();
    if (dish == null) {
      return;
    }
    final List<db.SourcePhotoRow> sources =
        await (_database.select(_database.sourcePhotos)
              ..where(
                (db.SourcePhotos table) => table.dishId.equals(dishId),
              ))
            .get();
    final bool batchStillPresent =
        await (_database.select(_database.captureItems)
                  ..where(
                    (db.CaptureItems table) =>
                        table.batchId.equals(batchId) &
                        table.appliedDishId.equals(dishId),
                  )
                  ..limit(1))
                .getSingleOrNull() !=
            null;
    final String heroImageUrl = removedRefs.contains(dish.heroImageUrl)
        ? sources.firstOrNull?.url ?? ''
        : dish.heroImageUrl;
    final String? heroPreviewUrl = removedRefs.contains(dish.heroImageUrl)
        ? sources.firstOrNull?.previewUrl
        : dish.heroPreviewUrl;
    final String? heroThumbnailUrl = removedRefs.contains(dish.heroImageUrl)
        ? sources.firstOrNull?.thumbnailUrl
        : dish.heroThumbnailUrl;
    final String? heroPlaceholderUrl = removedRefs.contains(dish.heroImageUrl)
        ? sources.firstOrNull?.placeholderUrl
        : dish.heroPlaceholderUrl;
    final int madeCount = sources.isEmpty
        ? 0
        : batchStillPresent
            ? dish.madeCount
            : dish.madeCount > 0
                ? dish.madeCount - 1
                : 0;
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

  Future<void> _deleteLocalCaptureCopies(Iterable<String?> refs) async {
    for (final String path in refs.whereType<String>().toSet()) {
      try {
        final File file = File(path);
        if (file.existsSync()) {
          await file.delete();
        }
      } on Object {
        // Local capture cleanup is best-effort. The database mutation and
        // remote retry must survive a missing or locked cache file.
      }
    }
  }
}
