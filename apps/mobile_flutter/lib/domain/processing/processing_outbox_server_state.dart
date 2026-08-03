part of 'processing_outbox_repository.dart';

extension ProcessingOutboxServerState on ProcessingOutboxRepository {
  Future<void> recordSubmittedDishIds(
    String requestId,
    Iterable<String> dishIds,
  ) async {
    final db.ProcessingOutboxRow row = await (_database.select(
      _database.processingOutbox,
    )..where((db.ProcessingOutbox table) => table.id.equals(requestId)))
        .getSingle();
    final Object? decoded = jsonDecode(row.payloadJson);
    final Map<String, Object?> payload = decoded is Map<String, dynamic>
        ? Map<String, Object?>.from(decoded)
        : <String, Object?>{};
    payload['submittedDishIds'] = dishIds.toSet().toList()..sort();
    await (_database.update(_database.processingOutbox)
          ..where((db.ProcessingOutbox table) => table.id.equals(requestId)))
        .write(
      db.ProcessingOutboxCompanion(
        payloadJson: Value<String>(jsonEncode(payload)),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> recordServerJob({
    required String requestId,
    required String serverJobId,
    required DateTime expiresAt,
  }) async {
    await (_database.update(_database.processingOutbox)
          ..where((db.ProcessingOutbox table) => table.id.equals(requestId)))
        .write(
      db.ProcessingOutboxCompanion(
        serverJobId: Value<String?>(serverJobId),
        serverExpiresAt: Value<DateTime?>(expiresAt),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> markAssetUploaded(String requestId, String assetId) async {
    await _database.transaction(() async {
      final db.ProcessingOutboxRow row = await (_database.select(
        _database.processingOutbox,
      )..where((db.ProcessingOutbox table) => table.id.equals(requestId)))
          .getSingle();
      final Set<String> ids = _stringSet(row.uploadedAssetIdsJson)
        ..add(assetId);
      await (_database.update(_database.processingOutbox)
            ..where((db.ProcessingOutbox table) => table.id.equals(requestId)))
          .write(
        db.ProcessingOutboxCompanion(
          uploadedAssetIdsJson: Value<String>(jsonEncode(ids.toList()..sort())),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );
    });
  }

  Future<void> storeResult({
    required String requestId,
    required Map<String, Object?> result,
    required String schemaVersion,
  }) async {
    await (_database.update(_database.processingOutbox)
          ..where((db.ProcessingOutbox table) => table.id.equals(requestId)))
        .write(
      db.ProcessingOutboxCompanion(
        resultPayloadJson: Value<String?>(jsonEncode(result)),
        resultSchemaVersion: Value<String?>(schemaVersion),
        adoptionState: Value<String>(
          ProcessingAdoptionState.readyForAdoption.name,
        ),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> markAcknowledged(String requestId) {
    return _setDeliveryState(
      requestId,
      ProcessingDeliveryState.acknowledged,
      from: ProcessingDeliveryState.submitted,
    );
  }

  Future<void> clearServerJob(String requestId) async {
    await (_database.update(_database.processingOutbox)
          ..where((db.ProcessingOutbox table) => table.id.equals(requestId)))
        .write(
      db.ProcessingOutboxCompanion(
        serverJobId: const Value<String?>(null),
        serverExpiresAt: const Value<DateTime?>(null),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> markExpired(String requestId) {
    return _setDeliveryState(
      requestId,
      ProcessingDeliveryState.expired,
      from: ProcessingDeliveryState.submitted,
    );
  }

  Future<void> _setDeliveryState(
    String requestId,
    ProcessingDeliveryState next, {
    required ProcessingDeliveryState from,
  }) async {
    await (_database.update(_database.processingOutbox)
          ..where(
            (db.ProcessingOutbox table) =>
                table.id.equals(requestId) &
                table.deliveryState.equals(from.name),
          ))
        .write(
      db.ProcessingOutboxCompanion(
        deliveryState: Value<String>(next.name),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }
}
