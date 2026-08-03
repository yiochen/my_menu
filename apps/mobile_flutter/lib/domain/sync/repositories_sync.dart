part of 'repositories.dart';

extension SyncRepositoryPull on SyncRepository {
  Future<void> pullCaptureSync({int maxPages = 5}) async {
    await _refreshKnownDishes();
    var cursor = await _readCaptureSyncCursor();
    for (var page = 0; page < maxPages; page += 1) {
      final ApiSyncPull result = await _apiClient
          .pullSync(
            afterCursor: cursor,
            limit: 200,
          )
          .timeout(_controlRequestTimeout);
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

  Future<void> _refreshKnownDishes() async {
    final List<db.DishRow> localDishes =
        await _database.select(_database.dishes).get();
    final List<db.SourcePhotoRow> sourcePhotos =
        await _database.select(_database.sourcePhotos).get();
    await _cacheLocalDishMedia(localDishes, sourcePhotos);
    final Set<String> dishesWithUncachedSources = sourcePhotos
        .where((db.SourcePhotoRow photo) => _mediaNeedsRefresh(photo.url))
        .map((db.SourcePhotoRow photo) => photo.dishId)
        .toSet();
    final List<String> remoteDishIds = localDishes
        .where(
          (db.DishRow dish) =>
              Uuid.isValidUUID(fromString: dish.id) &&
              (_mediaNeedsRefresh(dish.heroImageUrl) ||
                  dishesWithUncachedSources.contains(dish.id)),
        )
        .map((db.DishRow dish) => dish.id)
        .toList(growable: false);
    if (remoteDishIds.isEmpty) {
      return;
    }
    final List<ApiDish> dishes = await _apiClient
        .getDishes(remoteDishIds)
        .timeout(_controlRequestTimeout);
    for (final ApiDish dish in dishes) {
      await _upsertDish(dish);
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
    final Set<String> captureBatchIds = <String>{};
    final Set<String> dishIds = <String>{};
    final Set<String> reviewItemIds = <String>{};
    final Set<String> aiJobIds = <String>{};
    final Set<String> deletedCaptureIds = <String>{};
    final Set<String> deletedCaptureBatchIds = <String>{};
    final Set<String> deletedDishIds = <String>{};
    final Set<String> deletedReviewItemIds = <String>{};
    final Set<String> deletedAiJobIds = <String>{};
    final Set<String> capturesAppliedToNewDishes = <String>{};

    for (final ApiSyncEvent event in events) {
      final String? captureId = event.entityIds['captureId'];
      final String? batchId = event.entityIds['batchId'];
      final String? dishId = event.entityIds['dishId'];
      final String? reviewItemId = event.entityIds['reviewItemId'];
      final String? aiJobId = event.entityIds['aiJobId'];

      switch (event.type) {
        case 'capture_batch.pending_upload':
        case 'capture_batch.uploading':
        case 'capture_batch.ready_for_ai':
        case 'capture_batch.processing':
        case 'capture_batch.applied':
        case 'capture_batch.failed':
        case 'capture_batch.discarded':
          if (batchId != null) {
            captureBatchIds.add(batchId);
          }
        case 'capture_batch.deleted':
          if (batchId != null) {
            deletedCaptureBatchIds.add(batchId);
          }
        case 'capture.uploaded':
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
          if (captureId != null) {
            capturesAppliedToNewDishes.add(captureId);
          }
          if (captureId != null) {
            captureIds.add(captureId);
          }
          if (dishId != null) {
            dishIds.add(dishId);
          }
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
        case 'ai_job.queued':
        case 'ai_job.running':
        case 'ai_job.retrying':
        case 'ai_job.succeeded':
        case 'ai_job.failed':
        case 'ai_job.canceled':
          if (aiJobId != null) {
            aiJobIds.add(aiJobId);
          }
        case 'ai_job.deleted':
          if (aiJobId != null) {
            deletedAiJobIds.add(aiJobId);
          }
        default:
      }
    }
    captureBatchIds.removeAll(deletedCaptureBatchIds);
    captureIds.removeAll(deletedCaptureIds);
    dishIds.removeAll(deletedDishIds);
    reviewItemIds.removeAll(deletedReviewItemIds);
    aiJobIds.removeAll(deletedAiJobIds);

    // Apply authoritative removals before hydrating upserts. If one of the
    // follow-up fetches fails, deleted dishes must not linger locally as empty
    // cards. Replaying the same deletion is safe because each delete is
    // idempotent.
    await _deleteSyncedRows(
      captureIds: deletedCaptureIds,
      captureBatchIds: deletedCaptureBatchIds,
      dishIds: deletedDishIds,
      reviewItemIds: deletedReviewItemIds,
      aiJobIds: deletedAiJobIds,
    );

    final List<ApiCaptureBatch> batches = await _apiClient
        .getCaptureBatches(captureBatchIds.toList(growable: false));
    final List<ApiCapture> captures =
        await _apiClient.getCaptures(captureIds.toList(growable: false));
    final List<ApiDish> dishes =
        await _apiClient.getDishes(dishIds.toList(growable: false));
    final List<ApiReviewItem> reviewItems =
        await _apiClient.getReviewItems(reviewItemIds.toList(growable: false));
    final List<ApiAiJob> aiJobs =
        await _apiClient.getAiJobs(aiJobIds.toList(growable: false));

    final Set<String> rejectedResultDishIds = <String>{};
    await _database.transaction(() async {
      for (final ApiCaptureBatch batch in batches) {
        await _upsertCaptureBatch(batch);
      }
      for (final ApiCapture capture in captures) {
        final bool adopted = await _upsertCapture(
          capture,
          createdDishId: capturesAppliedToNewDishes.contains(capture.id)
              ? capture.appliedDishId
              : null,
        );
        if (!adopted && capture.appliedDishId != null) {
          rejectedResultDishIds.add(capture.appliedDishId!);
        }
      }
      for (final ApiReviewItem item in reviewItems) {
        await _upsertReviewItem(item);
      }
      for (final ApiAiJob job in aiJobs) {
        await _upsertAiJob(job);
      }
    });
    for (final ApiDish dish in dishes) {
      if (!rejectedResultDishIds.contains(dish.id)) {
        await _upsertDish(dish);
      }
    }
  }

  Future<void> _upsertCaptureBatch(ApiCaptureBatch batch) async {
    final db.CaptureBatchRow? existing =
        await (_database.select(_database.captureBatches)
              ..where(
                (db.$CaptureBatchesTable table) => table.id.equals(batch.id),
              ))
            .getSingleOrNull();
    final DateTime now = DateTime.now();
    await _database.into(_database.captureBatches).insertOnConflictUpdate(
          db.CaptureBatchesCompanion.insert(
            id: batch.id,
            status: _localBatchStatus(batch.status),
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ),
        );
    if (batch.status == 'applied') {
      await ProcessingOutboxRepository(_database).markAdoptedForSubject(
        kind: ProcessingRequestKind.captureGrouping,
        subjectId: batch.id,
      );
    }
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
    required Set<String> captureBatchIds,
    required Set<String> dishIds,
    required Set<String> reviewItemIds,
    required Set<String> aiJobIds,
  }) async {
    await DishRepository(_database, _dishImageCache).deleteLocalDishes(dishIds);
    final List<db.CaptureItemRow> captureRows = captureIds.isEmpty
        ? const <db.CaptureItemRow>[]
        : await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) => table.id.isIn(captureIds),
              ))
            .get();
    await _database.transaction(() async {
      for (final String captureId in captureIds) {
        await (_database.delete(_database.captureItems)
              ..where((db.CaptureItems table) => table.id.equals(captureId)))
            .go();
      }
      for (final String reviewItemId in reviewItemIds) {
        await (_database.delete(_database.reviewItems)
              ..where(
                (db.ReviewItems table) => table.id.equals(reviewItemId),
              ))
            .go();
      }
      for (final String aiJobId in aiJobIds) {
        await (_database.delete(_database.aiJobs)
              ..where((db.AiJobs table) => table.id.equals(aiJobId)))
            .go();
      }
      for (final String batchId in captureBatchIds) {
        await (_database.delete(_database.captureBatches)
              ..where((db.CaptureBatches table) => table.id.equals(batchId)))
            .go();
      }
    });
    for (final String path in captureRows
        .map((db.CaptureItemRow row) => row.localMediaRef)
        .whereType<String>()
        .toSet()) {
      try {
        final File file = File(path);
        if (file.existsSync()) {
          await file.delete();
        }
      } on Object {
        // The authoritative row is gone; a missing local copy is harmless.
      }
    }
  }

  String _localBatchStatus(String status) {
    return switch (status) {
      'pending_upload' => CaptureBatchStatus.pendingUpload.name,
      'ready_for_ai' => CaptureBatchStatus.readyForAi.name,
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
