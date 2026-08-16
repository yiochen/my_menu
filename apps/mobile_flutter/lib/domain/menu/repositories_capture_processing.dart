part of 'app_repositories.dart';

class LocalCaptureProcessingStore implements CaptureProcessingLocalStore {
  LocalCaptureProcessingStore(this._repository);

  final CaptureRepository _repository;

  @override
  Future<List<db.CaptureItemRow>> activeItemsForBatch(String batchId) {
    return (_repository._database.select(_repository._database.captureItems)
          ..where(
            (db.CaptureItems table) =>
                table.batchId.equals(batchId) &
                table.status
                    .equals(capture_domain.CaptureItemStatus.discarded.name)
                    .not(),
          )
          ..orderBy(<OrderingTerm Function(db.$CaptureItemsTable)>[
            (db.$CaptureItemsTable table) => OrderingTerm.asc(table.ordinal),
          ]))
        .get();
  }

  @override
  Future<void> updatePreviewRefs(
    String captureId,
    ImageDerivativeSet previews,
  ) {
    return (_repository._database.update(
      _repository._database.captureItems,
    )..where((db.CaptureItems table) => table.id.equals(captureId)))
        .write(
      db.CaptureItemsCompanion(
        localPreviewRef: Value<String?>(previews.processingRef),
        localThumbnailRef: Value<String?>(previews.cardRef),
        localPlaceholderRef: Value<String?>(previews.placeholderRef),
      ),
    );
  }

  @override
  Future<void> markCaptureStatus(
    String captureId,
    capture_domain.CaptureItemStatus status,
  ) {
    return (_repository._database.update(
      _repository._database.captureItems,
    )..where((db.CaptureItems table) => table.id.equals(captureId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(status.name),
        failureReason: const Value<String?>(null),
      ),
    );
  }

  @override
  Future<void> markCapturesClassifying(String batchId) async {
    await (_repository._database.update(_repository._database.captureItems)
          ..where((db.CaptureItems table) => table.batchId.equals(batchId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(
          capture_domain.CaptureItemStatus.classifying.name,
        ),
      ),
    );
    await markBatchStatus(batchId, CaptureBatchStatus.processing);
  }

  @override
  Future<void> markCapturesPending(String batchId) {
    return (_repository._database.update(_repository._database.captureItems)
          ..where((db.CaptureItems table) => table.batchId.equals(batchId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(
          capture_domain.CaptureItemStatus.pendingUpload.name,
        ),
        failureReason: const Value<String?>(null),
      ),
    );
  }

  @override
  Future<void> markCapturesFailed(String batchId, String reason) {
    return (_repository._database.update(_repository._database.captureItems)
          ..where((db.CaptureItems table) => table.batchId.equals(batchId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(capture_domain.CaptureItemStatus.failed.name),
        failureReason: Value<String?>(reason),
      ),
    );
  }

  @override
  Future<void> markBatchStatus(
    String batchId,
    CaptureBatchStatus status, {
    String? failureReason,
  }) {
    return (_repository._database.update(_repository._database.captureBatches)
          ..where((db.CaptureBatches table) => table.id.equals(batchId)))
        .write(
      db.CaptureBatchesCompanion(
        status: Value<String>(status.name),
        updatedAt: Value<DateTime>(DateTime.now()),
        failureReason: Value<String?>(failureReason),
      ),
    );
  }
}
