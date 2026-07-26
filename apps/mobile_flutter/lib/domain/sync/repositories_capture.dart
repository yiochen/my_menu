part of 'repositories.dart';

class CaptureRepository {
  CaptureRepository(this._database);

  final db.AppDatabase _database;
  final Uuid _uuid = const Uuid();
  static const int maxBatchItems = 9;

  Future<List<capture_domain.CaptureItem>> listFeedItems() async {
    final List<db.CaptureItemRow> rows =
        await (_database.select(_database.captureItems)
              ..orderBy(<OrderingTerm Function(db.$CaptureItemsTable)>[
                (db.CaptureItems table) => OrderingTerm.desc(table.createdAt),
              ]))
            .get();
    return rows.map((db.CaptureItemRow row) => row.toDomain()).toList();
  }

  Future<List<CaptureBatch>> listBatches() async {
    final List<db.CaptureBatchRow> batchRows =
        await (_database.select(_database.captureBatches)
              ..orderBy(<OrderingTerm Function(db.$CaptureBatchesTable)>[
                (db.$CaptureBatchesTable table) =>
                    OrderingTerm.desc(table.createdAt),
              ]))
            .get();
    final List<db.CaptureItemRow> itemRows =
        await (_database.select(_database.captureItems)
              ..orderBy(<OrderingTerm Function(db.$CaptureItemsTable)>[
                (db.$CaptureItemsTable table) =>
                    OrderingTerm.asc(table.ordinal),
              ]))
            .get();
    final Map<String, List<capture_domain.CaptureItem>> itemsByBatch =
        <String, List<capture_domain.CaptureItem>>{};
    for (final db.CaptureItemRow row in itemRows) {
      final String? batchId = row.batchId;
      if (batchId == null) {
        continue;
      }
      itemsByBatch
          .putIfAbsent(batchId, () => <capture_domain.CaptureItem>[])
          .add(row.toDomain());
    }
    return batchRows.map((db.CaptureBatchRow row) {
      return CaptureBatch(
        id: row.id,
        status: captureBatchStatusFromDatabase(row.status),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        items: List<capture_domain.CaptureItem>.unmodifiable(
          itemsByBatch[row.id] ?? const <capture_domain.CaptureItem>[],
        ),
        failureReason: row.failureReason,
      );
    }).toList(growable: false);
  }

  Future<CaptureBatch?> createPhotoBatch(List<String> imageRefs) async {
    final List<String> refs = imageRefs
        .map((String imageRef) => imageRef.trim())
        .where((String imageRef) => imageRef.isNotEmpty)
        .take(maxBatchItems)
        .toList(growable: false);
    if (refs.isEmpty) {
      return null;
    }

    final String batchId = _uuid.v4();
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _database.into(_database.captureBatches).insert(
            db.CaptureBatchesCompanion.insert(
              id: batchId,
              status: CaptureBatchStatus.pendingUpload.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (int ordinal = 0; ordinal < refs.length; ordinal += 1) {
        final String id = _uuid.v4();
        await _database.into(_database.captureItems).insert(
              db.CaptureItemsCompanion.insert(
                id: id,
                batchId: Value<String?>(batchId),
                ordinal: Value<int>(ordinal),
                kind: capture_domain.CaptureItemKind.photo.name,
                status: capture_domain.CaptureItemStatus.pendingUpload.name,
                createdAt: now,
                localMediaRef: Value<String?>(refs[ordinal]),
              ),
            );
        await _enqueueSync(id, 'capture_item', 'upsert');
      }
      await _enqueueSync(batchId, 'capture_batch', 'upsert');
    });

    return (await listBatches())
        .firstWhere((CaptureBatch batch) => batch.id == batchId);
  }

  Future<List<String>> createPhotoCaptures(List<String> imageRefs) async {
    final CaptureBatch? batch = await createPhotoBatch(imageRefs);
    return batch?.items
            .map((capture_domain.CaptureItem item) => item.id)
            .toList(growable: false) ??
        const <String>[];
  }

  Future<String?> createIdeaCapture(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final String id = _uuid.v4();
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _database.into(_database.captureBatches).insert(
            db.CaptureBatchesCompanion.insert(
              id: id,
              status: CaptureBatchStatus.processing.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database.into(_database.captureItems).insert(
            db.CaptureItemsCompanion.insert(
              id: id,
              batchId: Value<String?>(id),
              kind: capture_domain.CaptureItemKind.idea.name,
              status: capture_domain.CaptureItemStatus.classifying.name,
              createdAt: now,
              ideaText: Value<String?>(trimmed),
            ),
          );
      await _enqueueSync(id, 'capture_item', 'upsert');
      await _enqueueSync(id, 'capture_batch', 'upsert');
    });
    return id;
  }

  Future<void> discardCapture(String captureId) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(captureId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(capture_domain.CaptureItemStatus.discarded.name),
      ),
    );
    await _enqueueSync(captureId, 'capture_item', 'discard');
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
      await (_database.update(_database.captureBatches)
            ..where(
                (db.$CaptureBatchesTable table) => table.id.equals(batchId)))
          .write(
        db.CaptureBatchesCompanion(
          status: Value<String>(CaptureBatchStatus.pendingUpload.name),
          updatedAt: Value<DateTime>(now),
          failureReason: const Value<String?>(null),
        ),
      );
    });
  }

  Future<void> _enqueueSync(
    String entityId,
    String entity,
    String operationType,
  ) async {
    await _database.into(_database.syncOperations).insert(
          db.SyncOperationsCompanion.insert(
            id: _uuid.v4(),
            entity: entity,
            entityId: entityId,
            operationType: operationType,
            payloadJson: '{}',
            createdAt: DateTime.now(),
          ),
        );
  }
}
