import 'package:mymenu/domain/capture/capture_item.dart';

const String captureWaitingForConnectionReason = 'Waiting for connection.';

enum CaptureBatchStatus {
  local,
  pendingUpload,
  uploading,
  readyForAi,
  processing,
  applied,
  failed,
  discarded,
}

class CaptureBatch {
  const CaptureBatch({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.failureReason,
  });

  final String id;
  final CaptureBatchStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CaptureItem> items;
  final String? failureReason;

  bool get isWaitingForConnection =>
      failureReason == captureWaitingForConnectionReason;

  int get uploadedItemCount => items
      .where(
        (CaptureItem item) => item.status == CaptureItemStatus.uploaded,
      )
      .length;

  int get failedItemCount => items
      .where((CaptureItem item) => item.status == CaptureItemStatus.failed)
      .length;
}
