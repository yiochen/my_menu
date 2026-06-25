part of 'repositories.dart';

extension SyncRepositoryPull on SyncRepository {
  Future<void> pullCaptureSync({int maxPages = 5}) async {
    var cursor = await _readCaptureSyncCursor();
    for (var page = 0; page < maxPages; page += 1) {
      final ApiSyncPull result = await _apiClient.pullSync(
        afterCursor: cursor,
        limit: 200,
      );
      if (result.requiresBootstrap) {
        developer.log(
          'Capture sync requires bootstrap; leaving cursor unchanged.',
          name: 'mymenu.sync',
        );
        return;
      }

      await _applySyncEvents(result.events);
      cursor = result.cursor;
      await _writeCaptureSyncCursor(cursor);

      if (!result.hasMore) {
        return;
      }
    }
  }

  Future<int> _readCaptureSyncCursor() async {
    final db.SyncMetadataRow? row =
        await (_database.select(_database.syncMetadata)
              ..where(
                (db.SyncMetadata table) =>
                    table.key.equals(SyncRepository._captureSyncCursorKey),
              ))
            .getSingleOrNull();
    return int.tryParse(row?.value ?? '') ?? 0;
  }

  Future<void> _writeCaptureSyncCursor(int cursor) async {
    await _database.into(_database.syncMetadata).insertOnConflictUpdate(
          db.SyncMetadataCompanion.insert(
            key: SyncRepository._captureSyncCursorKey,
            value: cursor.toString(),
          ),
        );
  }

  Future<void> _applySyncEvents(List<ApiSyncEvent> events) async {
    if (events.isEmpty) {
      return;
    }

    final Set<String> captureIds = <String>{};
    final Set<String> dishIds = <String>{};
    final Set<String> reviewItemIds = <String>{};
    final Set<String> deletedCaptureIds = <String>{};
    final Set<String> deletedDishIds = <String>{};
    final Set<String> deletedReviewItemIds = <String>{};

    for (final ApiSyncEvent event in events) {
      final String? captureId = event.entityIds['captureId'];
      final String? dishId = event.entityIds['dishId'];
      final String? reviewItemId = event.entityIds['reviewItemId'];

      switch (event.type) {
        case 'capture.classifying':
          if (captureId != null && !await _captureExists(captureId)) {
            captureIds.add(captureId);
          }
        case 'capture.needs_review':
          if (captureId != null) {
            captureIds.add(captureId);
          }
          if (reviewItemId != null) {
            reviewItemIds.add(reviewItemId);
          }
        case 'capture.applied_to_new_dish':
        case 'capture.applied_to_existing_dish':
          if (captureId != null) {
            captureIds.add(captureId);
          }
          if (dishId != null) {
            dishIds.add(dishId);
          }
        case 'capture.failed':
        case 'capture.discarded':
          if (captureId != null) {
            captureIds.add(captureId);
          }
        case 'capture.deleted':
          if (captureId != null) {
            deletedCaptureIds.add(captureId);
          }
        case 'dish.created':
        case 'dish.updated':
          if (dishId != null) {
            dishIds.add(dishId);
          }
        case 'dish.deleted':
          if (dishId != null) {
            deletedDishIds.add(dishId);
          }
        case 'review_item.created':
        case 'review_item.updated':
          if (reviewItemId != null) {
            reviewItemIds.add(reviewItemId);
          }
        case 'review_item.deleted':
          if (reviewItemId != null) {
            deletedReviewItemIds.add(reviewItemId);
          }
        default:
      }
    }

    final List<ApiCapture> captures =
        await _apiClient.getCaptures(captureIds.toList(growable: false));
    final List<ApiDish> dishes =
        await _apiClient.getDishes(dishIds.toList(growable: false));
    final List<ApiReviewItem> reviewItems =
        await _apiClient.getReviewItems(reviewItemIds.toList(growable: false));

    await _database.transaction(() async {
      await _deleteSyncedRows(
        captureIds: deletedCaptureIds,
        dishIds: deletedDishIds,
        reviewItemIds: deletedReviewItemIds,
      );
      for (final ApiCapture capture in captures) {
        await _upsertCapture(capture);
      }
      for (final ApiDish dish in dishes) {
        await _upsertDish(dish);
      }
      for (final ApiReviewItem item in reviewItems) {
        await _upsertReviewItem(item);
      }
    });
  }

  Future<bool> _captureExists(String captureId) async {
    final db.CaptureItemRow? row =
        await (_database.select(_database.captureItems)
              ..where((db.CaptureItems table) => table.id.equals(captureId)))
            .getSingleOrNull();
    return row != null;
  }

  Future<void> _deleteSyncedRows({
    required Set<String> captureIds,
    required Set<String> dishIds,
    required Set<String> reviewItemIds,
  }) async {
    for (final String captureId in captureIds) {
      await (_database.delete(_database.captureItems)
            ..where((db.CaptureItems table) => table.id.equals(captureId)))
          .go();
    }
    for (final String dishId in dishIds) {
      await (_database.delete(_database.sourcePhotos)
            ..where((db.SourcePhotos table) => table.dishId.equals(dishId)))
          .go();
      await (_database.delete(_database.plannedMeals)
            ..where((db.PlannedMeals table) => table.dishId.equals(dishId)))
          .go();
      await (_database.delete(_database.dishes)
            ..where((db.Dishes table) => table.id.equals(dishId)))
          .go();
    }
    for (final String reviewItemId in reviewItemIds) {
      await (_database.delete(_database.reviewItems)
            ..where((db.ReviewItems table) => table.id.equals(reviewItemId)))
          .go();
    }
  }

  Future<void> _upsertCapture(ApiCapture capture) async {
    final db.CaptureItemRow? existing =
        await (_database.select(_database.captureItems)
              ..where((db.CaptureItems table) => table.id.equals(capture.id)))
            .getSingleOrNull();

    await _database.into(_database.captureItems).insertOnConflictUpdate(
          db.CaptureItemsCompanion.insert(
            id: capture.id,
            kind: capture.kind,
            status: _localCaptureStatus(capture.status),
            createdAt: capture.capturedAt,
            localMediaRef: Value<String?>(existing?.localMediaRef),
            remoteMediaRef: Value<String?>(capture.image?.mediaRef),
            ideaText: Value<String?>(capture.ideaText),
            appliedDishId: Value<String?>(capture.appliedDishId),
          ),
        );
  }

  Future<void> _upsertDish(ApiDish apiDish) async {
    final Dish dish = _dishFromApi(apiDish);
    await _database.into(_database.dishes).insertOnConflictUpdate(
          dish.toCompanion(),
        );
    await (_database.delete(_database.sourcePhotos)
          ..where((db.SourcePhotos table) => table.dishId.equals(apiDish.id)))
        .go();
    for (final ApiSourcePhoto photo in apiDish.sourcePhotos) {
      await _database.into(_database.sourcePhotos).insertOnConflictUpdate(
            db.SourcePhotosCompanion.insert(
              id: photo.id,
              dishId: apiDish.id,
              url: photo.mediaRef,
              capturedLabel: _capturedLabel(photo.capturedAt),
              note: Value<String?>(photo.note),
              confidenceLabel: Value<String?>(photo.confidenceLabel),
            ),
          );
    }
  }

  Future<void> _upsertReviewItem(ApiReviewItem item) async {
    await _database.into(_database.reviewItems).insertOnConflictUpdate(
          db.ReviewItemsCompanion.insert(
            id: item.id,
            summary: item.summary,
            suggestedDishIdsJson: jsonEncode(item.suggestedDishIds),
            confidenceLabel: item.confidenceLabel ?? item.status,
          ),
        );
  }

  Dish _dishFromApi(ApiDish dish) {
    final String fallbackImage = seededDishes.first.heroImageUrl;
    final String heroImageUrl = dish.coverImage?.mediaRef ??
        (dish.sourcePhotos.isEmpty
            ? fallbackImage
            : dish.sourcePhotos.first.mediaRef);
    final String category = dish.labels.isEmpty ? 'capture' : dish.labels.first;
    return Dish(
      id: dish.id,
      title: dish.title,
      description: dish.description,
      heroImageUrl: heroImageUrl,
      category: category,
      prepMinutes: dish.prepMinutes ?? 30,
      difficulty: dish.difficulty ?? 'Draft',
      madeCount: dish.madeCount,
      lastMadeLabel: _lastMadeLabel(dish.lastMadeAt),
      ingredients: dish.ingredients,
      recipeSteps: dish.steps,
      notes: dish.notes,
      sourcePhotos: dish.sourcePhotos.map((ApiSourcePhoto photo) {
        return SourcePhoto(
          url: photo.mediaRef,
          capturedLabel: _capturedLabel(photo.capturedAt),
          note: photo.note,
          confidenceLabel: photo.confidenceLabel,
        );
      }).toList(growable: false),
      isFavorite: dish.isFavorite,
    );
  }

  String _localCaptureStatus(String status) {
    return switch (status) {
      'needs_review' => capture_domain.CaptureItemStatus.needsReview.name,
      _ => status,
    };
  }

  String _lastMadeLabel(DateTime? value) {
    if (value == null) {
      return 'Not cooked yet';
    }
    return _capturedLabel(value);
  }

  String _capturedLabel(DateTime? value) {
    if (value == null) {
      return 'Unknown date';
    }
    final DateTime local = value.toLocal();
    final DateTime now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return 'Today';
    }
    return '${local.month}/${local.day}/${local.year}';
  }
}
