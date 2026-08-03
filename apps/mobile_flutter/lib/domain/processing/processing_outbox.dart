enum ProcessingRequestKind {
  captureGrouping('capture_grouping');

  const ProcessingRequestKind(this.databaseValue);

  final String databaseValue;

  static ProcessingRequestKind fromDatabase(String value) {
    return values.firstWhere(
      (ProcessingRequestKind kind) => kind.databaseValue == value,
    );
  }
}

enum ProcessingDeliveryState {
  waitingForConsent,
  pendingUpload,
  uploading,
  submitted,
  downloading,
  acknowledged,
  failed,
  expired,
  canceled,
}

enum ProcessingAdoptionState {
  awaitingProposal,
  readyForAdoption,
  adopted,
  rejected,
}

class ProcessingOutboxRequest {
  const ProcessingOutboxRequest({
    required this.id,
    required this.kind,
    required this.subjectId,
    required this.payload,
    required this.deliveryState,
    required this.adoptionState,
    required this.createdAt,
    required this.updatedAt,
    this.privacyNoticeVersion,
    this.idempotencyKey = '',
    this.serverJobId,
    this.serverExpiresAt,
    this.uploadedAssetIds = const <String>{},
    this.resultPayload,
    this.resultSchemaVersion,
    this.attemptCount = 0,
    this.nextRetryAt,
    this.failureCode,
  });

  final String id;
  final ProcessingRequestKind kind;
  final String subjectId;
  final Map<String, Object?> payload;
  final ProcessingDeliveryState deliveryState;
  final ProcessingAdoptionState adoptionState;
  final String? privacyNoticeVersion;
  final String idempotencyKey;
  final String? serverJobId;
  final DateTime? serverExpiresAt;
  final Set<String> uploadedAssetIds;
  final Map<String, Object?>? resultPayload;
  final String? resultSchemaVersion;
  final int attemptCount;
  final DateTime? nextRetryAt;
  final String? failureCode;
  final DateTime createdAt;
  final DateTime updatedAt;
}
