part of 'repositories.dart';

extension CaptureRepositoryDeletion on CaptureRepository {
  Future<void> deleteBatch(String batchId) async {
    final List<db.CaptureItemRow> captures = await (_database.select(
      _database.captureItems,
    )..where((db.CaptureItems table) => table.batchId.equals(batchId)))
        .get();
    final List<String> captureIds = captures
        .map((db.CaptureItemRow capture) => capture.id)
        .toList(growable: false);
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
    });

    await _deleteLocalCaptureCopies(
      captures.map((db.CaptureItemRow capture) => capture.localMediaRef),
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
