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
      await _keepPhotoIngestUnorganized(request.subjectId);
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
      await _keepWaitingPhotoIngestLocal(request);
    }
  }

  Future<void> _keepWaitingPhotoIngestLocal(
    db.ProcessingOutboxRow request,
  ) async {
    final List<db.CaptureItemRow> items =
        await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) =>
                    table.ingestId.equals(request.subjectId) &
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
      await _processingOutboxRepository.cancelBeforeUpload(request.id);
      await _processingOutboxRepository.rejectProposal(request.id);
    });
  }

  Future<void> _keepPhotoIngestUnorganized(String ingestId) async {
    await _database.transaction(() async {
      await (_database.update(_database.captureItems)
            ..where(
              (db.CaptureItems table) =>
                  table.ingestId.equals(ingestId) &
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
    });
  }
}
