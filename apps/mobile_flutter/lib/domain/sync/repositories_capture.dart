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

  Future<CaptureBatch?> createPhotoBatch(List<Object> capturedMedia) async {
    final List<CapturedMedia> media = capturedMedia
        .map(_normalizeCapturedMedia)
        .where((CapturedMedia item) => item.path.trim().isNotEmpty)
        .take(maxBatchItems)
        .toList(growable: false);
    if (media.isEmpty) {
      return null;
    }

    final String batchId = _uuid.v4();
    final String jobId = _uuid.v4();
    final DateTime now = DateTime.now();
    final List<String> captureIds = List<String>.generate(
      media.length,
      (_) => _uuid.v4(),
    );
    await _database.transaction(() async {
      await _database.into(_database.captureBatches).insert(
            db.CaptureBatchesCompanion.insert(
              id: batchId,
              status: CaptureBatchStatus.pendingUpload.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (int ordinal = 0; ordinal < media.length; ordinal += 1) {
        final String id = captureIds[ordinal];
        final CapturedMedia item = media[ordinal];
        await _database.into(_database.captureItems).insert(
              db.CaptureItemsCompanion.insert(
                id: id,
                batchId: Value<String?>(batchId),
                ordinal: Value<int>(ordinal),
                kind: capture_domain.CaptureItemKind.photo.name,
                status: capture_domain.CaptureItemStatus.pendingUpload.name,
                createdAt: now,
                localMediaRef: Value<String?>(item.path),
                capturedAt: Value<DateTime?>(item.capturedAt),
                capturedLocalDate: Value<String?>(item.capturedLocalDate),
                captureDateSource: Value<String?>(item.dateSource.apiValue),
              ),
            );
        await _enqueueSync(id, 'capture_item', 'upsert');
      }
      await _enqueueSync(batchId, 'capture_batch', 'upsert');
      await _insertGroupingJob(
        jobId: jobId,
        batchId: batchId,
        captureIds: captureIds,
        now: now,
      );
    });

    return (await listBatches())
        .firstWhere((CaptureBatch batch) => batch.id == batchId);
  }

  Future<List<String>> createPhotoCaptures(
    List<Object> capturedMedia,
  ) async {
    final CaptureBatch? batch = await createPhotoBatch(capturedMedia);
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
    final String jobId = _uuid.v4();
    final DateTime now = DateTime.now();
    final String localDate = _dateKey(now);
    await _database.transaction(() async {
      await _database.into(_database.captureBatches).insert(
            db.CaptureBatchesCompanion.insert(
              id: id,
              status: CaptureBatchStatus.pendingUpload.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database.into(_database.captureItems).insert(
            db.CaptureItemsCompanion.insert(
              id: id,
              batchId: Value<String?>(id),
              kind: capture_domain.CaptureItemKind.idea.name,
              status: capture_domain.CaptureItemStatus.pendingUpload.name,
              createdAt: now,
              ideaText: Value<String?>(trimmed),
              capturedAt: Value<DateTime?>(now),
              capturedLocalDate: Value<String?>(localDate),
              captureDateSource: const Value<String?>('camera'),
            ),
          );
      await _enqueueSync(id, 'capture_item', 'upsert');
      await _enqueueSync(id, 'capture_batch', 'upsert');
      await _insertGroupingJob(
        jobId: jobId,
        batchId: id,
        captureIds: <String>[id],
        now: now,
      );
    });
    return id;
  }

  Future<void> _insertGroupingJob({
    required String jobId,
    required String batchId,
    required List<String> captureIds,
    required DateTime now,
  }) async {
    const String inputVersion = 'date-v1';
    final String canonicalInput = jsonEncode(<String, Object?>{
      'batchId': batchId,
      'captureIds': captureIds,
      'grouping': inputVersion,
    });
    await _database.into(_database.aiJobs).insert(
          db.AiJobsCompanion.insert(
            id: jobId,
            jobType: AiJobType.batchGrouping.apiValue,
            subjectId: batchId,
            status: AiJobStatus.pendingOffline.databaseValue,
            idempotencyKey:
                '${AiJobType.batchGrouping.apiValue}:$batchId:$inputVersion',
            inputHash: base64UrlEncode(utf8.encode(canonicalInput)),
            inputVersion: inputVersion,
            promptVersion: const Value<String>('date-v1'),
            modelVersion: const Value<String>('fake-date-grouper'),
            schemaVersion: const Value<String>('1'),
            pendingAction: const Value<String?>('finalize_capture'),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  CapturedMedia _normalizeCapturedMedia(Object value) {
    if (value is CapturedMedia) {
      return value;
    }
    final DateTime now = DateTime.now();
    return CapturedMedia(
      path: value.toString(),
      capturedAt: now,
      capturedLocalDate: null,
      dateSource: CaptureDateSource.unknown,
    );
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
