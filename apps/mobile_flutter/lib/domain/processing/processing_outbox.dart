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
  failed,
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
  });

  final String id;
  final ProcessingRequestKind kind;
  final String subjectId;
  final Map<String, Object?> payload;
  final ProcessingDeliveryState deliveryState;
  final ProcessingAdoptionState adoptionState;
  final String? privacyNoticeVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
}
