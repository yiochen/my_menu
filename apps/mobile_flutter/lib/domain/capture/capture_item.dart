enum CaptureItemKind {
  photo,
  idea,
}

enum CaptureItemStatus {
  localOnly,
  pendingUpload,
  uploading,
  uploaded,
  classifying,
  needsReview,
  applied,
  discarded,
  failed,
}

class CaptureItem {
  const CaptureItem({
    required this.id,
    required this.kind,
    required this.status,
    required this.createdAt,
    this.batchId,
    this.ordinal = 0,
    this.localMediaRef,
    this.remoteMediaRef,
    this.text,
    this.appliedDishId,
    this.failureReason,
  });

  final String id;
  final CaptureItemKind kind;
  final CaptureItemStatus status;
  final DateTime createdAt;
  final String? batchId;
  final int ordinal;
  final String? localMediaRef;
  final String? remoteMediaRef;
  final String? text;
  final String? appliedDishId;
  final String? failureReason;
}
