enum CaptureItemKind {
  photo,
  idea,
}

enum CaptureItemStatus {
  localOnly,
  pendingUpload,
  uploaded,
  classifying,
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
    this.localMediaRef,
    this.remoteMediaRef,
    this.text,
    this.appliedDishId,
  });

  final String id;
  final CaptureItemKind kind;
  final CaptureItemStatus status;
  final DateTime createdAt;
  final String? localMediaRef;
  final String? remoteMediaRef;
  final String? text;
  final String? appliedDishId;
}
