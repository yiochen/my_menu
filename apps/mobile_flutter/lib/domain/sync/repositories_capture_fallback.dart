part of 'repositories.dart';

extension CaptureRepositoryFallback on CaptureRepository {
  Future<void> adoptDeclinedPhotoCapturesLocally() async {
    final ProcessingConsentDecision consent =
        await ProcessingConsentRepository(_database).currentDecision();
    if (consent != ProcessingConsentDecision.declined) {
      return;
    }
    final List<db.ProcessingOutboxRow> requests =
        await (_database.select(_database.processingOutbox)
              ..where(
                (db.ProcessingOutbox table) =>
                    table.requestKind.equals(
                      ProcessingRequestKind.captureGrouping.databaseValue,
                    ) &
                    table.deliveryState.equals(
                      ProcessingDeliveryState.waitingForConsent.name,
                    ),
              ))
            .get();
    for (final db.ProcessingOutboxRow request in requests) {
      await _adoptWaitingPhotoBatch(request);
    }
  }

  Future<void> _adoptWaitingPhotoBatch(
    db.ProcessingOutboxRow request,
  ) async {
    final List<db.CaptureItemRow> items =
        await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) =>
                    table.batchId.equals(request.subjectId) &
                    table.kind.equals(
                      capture_domain.CaptureItemKind.photo.name,
                    ) &
                    table.status
                        .equals(
                          capture_domain.CaptureItemStatus.discarded.name,
                        )
                        .not(),
              ))
            .get();
    if (items.isEmpty ||
        items.any(
          (db.CaptureItemRow item) =>
              item.localMediaRef == null && item.remoteMediaRef == null,
        )) {
      return;
    }
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      for (final db.CaptureItemRow item in items) {
        if (item.appliedDishId != null) {
          continue;
        }
        final String dishId = _uuid.v4();
        await _insertUntitledPhotoDish(
          dishId: dishId,
          captureId: item.id,
          imageRef: item.localMediaRef ?? item.remoteMediaRef!,
          capturedAt: item.capturedAt ?? item.createdAt,
          createdAt: now,
        );
        await (_database.update(_database.captureItems)
              ..where(
                (db.CaptureItems table) => table.id.equals(item.id),
              ))
            .write(
          db.CaptureItemsCompanion(
            status: Value<String>(
              capture_domain.CaptureItemStatus.applied.name,
            ),
            appliedDishId: Value<String?>(dishId),
            failureReason: const Value<String?>(null),
          ),
        );
      }
      await (_database.update(_database.captureBatches)
            ..where(
              (db.CaptureBatches table) => table.id.equals(request.subjectId),
            ))
          .write(
        db.CaptureBatchesCompanion(
          status: Value<String>(CaptureBatchStatus.applied.name),
          updatedAt: Value<DateTime>(now),
          failureReason: const Value<String?>(null),
        ),
      );
      final List<String> localEntityIds = <String>[
        request.subjectId,
        ...items.map((db.CaptureItemRow item) => item.id),
      ];
      await (_database.delete(_database.syncOperations)
            ..where(
              (db.SyncOperations table) => table.entityId.isIn(localEntityIds),
            ))
          .go();
      await (_database.delete(_database.aiJobs)
            ..where(
              (db.AiJobs table) => table.subjectId.equals(request.subjectId),
            ))
          .go();
      await _processingOutboxRepository.cancelBeforeUpload(request.id);
    });
  }

  Future<void> _insertUntitledPhotoDish({
    required String dishId,
    required String captureId,
    required String imageRef,
    required DateTime capturedAt,
    required DateTime createdAt,
  }) async {
    await _database.into(_database.dishes).insert(
          db.DishesCompanion.insert(
            id: dishId,
            title: 'Untitled dish',
            description: '',
            heroImageUrl: imageRef,
            category: 'Captured',
            prepMinutes: 0,
            difficulty: 'Not set',
            madeCount: 0,
            lastMadeLabel: 'Not cooked yet',
            ingredientsJson: '[]',
            recipeStepsJson: '[]',
            notesJson: '[]',
            createdAt: Value<DateTime?>(createdAt),
          ),
        );
    await _database.into(_database.sourcePhotos).insert(
          db.SourcePhotosCompanion.insert(
            id: '${captureId}_source',
            dishId: dishId,
            url: imageRef,
            capturedLabel: 'Today',
            captureId: Value<String?>(captureId),
            capturedAt: Value<DateTime?>(capturedAt),
          ),
        );
  }
}
