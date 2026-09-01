part of 'app_repositories.dart';

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
      if (item.ingestId case final String ingestId) {
        await _processingOutboxRepository.supersedeCaptureGrouping(ingestId);
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
      if (capture.ingestId case final String ingestId) {
        await _processingOutboxRepository.supersedeCaptureGrouping(ingestId);
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
      if (affectedDishId != null && capture.ingestId != null) {
        await _refreshDishAfterCaptureRemoval(
          dishId: affectedDishId,
          removedRefs:
              <String?>[capture.localMediaRef].whereType<String>().toSet(),
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

  Future<void> retryIngest(String ingestId) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await (_database.update(_database.captureItems)
            ..where(
              (db.$CaptureItemsTable table) =>
                  table.ingestId.equals(ingestId) &
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
      await _processingOutboxRepository.retryCaptureGrouping(
        ingestId: ingestId,
        now: now,
      );
    });
  }

  Future<void> deleteIngest(String ingestId) async {
    final List<db.CaptureItemRow> captures = await (_database.select(
      _database.captureItems,
    )..where((db.CaptureItems table) => table.ingestId.equals(ingestId)))
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
            <String?>[capture.localMediaRef].whereType<String>(),
          );
    }
    await _database.transaction(() async {
      await _processingOutboxRepository.supersedeCaptureGrouping(ingestId);
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
              (db.CaptureCorrections table) => table.ingestId.equals(ingestId),
            ))
          .go();
      await (_database.delete(_database.captureItems)
            ..where((db.CaptureItems table) => table.ingestId.equals(ingestId)))
          .go();
      for (final String dishId in affectedDishIds) {
        await _refreshDishAfterCaptureRemoval(
          dishId: dishId,
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
    required Set<String> removedRefs,
  }) async {
    final db.DishRow? dish = await (_database.select(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(dishId)))
        .getSingleOrNull();
    if (dish == null) {
      return;
    }
    final bool removedCurrentCover = removedRefs.contains(dish.heroImageUrl);
    final String heroImageUrl = removedCurrentCover ? '' : dish.heroImageUrl;
    final String? heroPreviewUrl =
        removedCurrentCover ? null : dish.heroPreviewUrl;
    final String? heroThumbnailUrl =
        removedCurrentCover ? null : dish.heroThumbnailUrl;
    final String? heroPlaceholderUrl =
        removedCurrentCover ? null : dish.heroPlaceholderUrl;
    await (_database.update(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(dishId)))
        .write(
      db.DishesCompanion(
        heroImageUrl: Value<String>(heroImageUrl),
        heroPreviewUrl: Value<String?>(heroPreviewUrl),
        heroThumbnailUrl: Value<String?>(heroThumbnailUrl),
        heroPlaceholderUrl: Value<String?>(heroPlaceholderUrl),
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
