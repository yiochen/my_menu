part of 'app_repositories.dart';

extension CaptureRepositoryFallback on CaptureRepository {
  Future<void> keepQuotaLimitedPhotoCapturesLocal() async {
    final List<db.ProcessingOutboxRow> requests =
        await (_database.select(_database.processingOutbox)
              ..where(
                (db.ProcessingOutbox table) =>
                    table.requestKind.equals(
                      ProcessingRequestKind.captureGrouping.databaseValue,
                    ) &
                    table.deliveryState.equals(
                      ProcessingDeliveryState.failed.name,
                    ) &
                    table.failureCode.equals(
                      processingFreeAllowanceExhaustedCode,
                    ),
              ))
            .get();
    for (final db.ProcessingOutboxRow request in requests) {
      await _keepPhotoBatchUnorganized(request.subjectId);
    }
  }

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
      await _keepWaitingPhotoBatchLocal(request);
    }
  }

  Future<void> _keepWaitingPhotoBatchLocal(
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
    if (items.isEmpty) {
      return;
    }
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      for (final db.CaptureItemRow item in items) {
        if (item.appliedDishId != null) {
          continue;
        }
        await (_database.update(_database.captureItems)
              ..where(
                (db.CaptureItems table) => table.id.equals(item.id),
              ))
            .write(
          db.CaptureItemsCompanion(
            status: Value<String>(
              capture_domain.CaptureItemStatus.localOnly.name,
            ),
            appliedDishId: const Value<String?>(null),
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
      await _processingOutboxRepository.cancelBeforeUpload(request.id);
      await _processingOutboxRepository.rejectProposal(request.id);
    });
  }

  Future<void> _keepPhotoBatchUnorganized(String batchId) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await (_database.update(_database.captureItems)
            ..where(
              (db.CaptureItems table) =>
                  table.batchId.equals(batchId) &
                  table.appliedDishId.isNull() &
                  table.status
                      .equals(
                        capture_domain.CaptureItemStatus.discarded.name,
                      )
                      .not() &
                  (table.status
                          .equals(
                            capture_domain.CaptureItemStatus.localOnly.name,
                          )
                          .not() |
                      table.failureReason.isNotNull()),
            ))
          .write(
        db.CaptureItemsCompanion(
          status: Value<String>(
            capture_domain.CaptureItemStatus.localOnly.name,
          ),
          failureReason: const Value<String?>(null),
        ),
      );
      await (_database.update(_database.captureBatches)
            ..where(
              (db.CaptureBatches table) =>
                  table.id.equals(batchId) &
                  (table.status.equals(CaptureBatchStatus.local.name).not() |
                      table.failureReason.isNotNull()),
            ))
          .write(
        db.CaptureBatchesCompanion(
          status: Value<String>(CaptureBatchStatus.local.name),
          updatedAt: Value<DateTime>(now),
          failureReason: const Value<String?>(null),
        ),
      );
    });
  }
}
