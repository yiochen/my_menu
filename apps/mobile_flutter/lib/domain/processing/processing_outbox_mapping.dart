part of 'processing_outbox_repository.dart';

ProcessingOutboxRequest _requestFromRow(db.ProcessingOutboxRow row) {
  final Object? decoded = jsonDecode(row.payloadJson);
  return ProcessingOutboxRequest(
    id: row.id,
    kind: ProcessingRequestKind.fromDatabase(row.requestKind),
    subjectId: row.subjectId,
    payload: decoded is Map<String, dynamic>
        ? Map<String, Object?>.from(decoded)
        : const <String, Object?>{},
    deliveryState: ProcessingDeliveryState.values.byName(row.deliveryState),
    adoptionState: ProcessingAdoptionState.values.byName(row.adoptionState),
    privacyNoticeVersion: row.privacyNoticeVersion,
    idempotencyKey: row.idempotencyKey.isEmpty ? row.id : row.idempotencyKey,
    serverJobId: row.serverJobId,
    serverExpiresAt: row.serverExpiresAt,
    uploadedAssetIds: _stringSet(row.uploadedAssetIdsJson),
    resultPayload: _jsonObject(row.resultPayloadJson),
    resultSchemaVersion: row.resultSchemaVersion,
    attemptCount: row.attemptCount,
    nextRetryAt: row.nextRetryAt,
    failureCode: row.failureCode,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

Set<String> _stringSet(String value) {
  final Object? decoded = jsonDecode(value);
  if (decoded is! List<Object?>) return <String>{};
  return decoded.whereType<String>().toSet();
}

Map<String, Object?>? _jsonObject(String? value) {
  if (value == null) return null;
  final Object? decoded = jsonDecode(value);
  return decoded is Map<String, dynamic>
      ? Map<String, Object?>.from(decoded)
      : null;
}
