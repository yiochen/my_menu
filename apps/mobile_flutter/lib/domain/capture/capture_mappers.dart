import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';

extension CaptureItemRowMapper on db.CaptureItemRow {
  CaptureItem toDomain() {
    return CaptureItem(
      id: id,
      kind: CaptureItemKind.values.byName(kind),
      status: _statusFromDatabase(status),
      createdAt: createdAt,
      batchId: batchId,
      ordinal: ordinal,
      localMediaRef: localMediaRef,
      remoteMediaRef: remoteMediaRef,
      text: ideaText,
      capturedAt: capturedAt,
      capturedLocalDate: capturedLocalDate,
      captureDateSource: captureDateSource,
      appliedDishId: appliedDishId,
      failureReason: failureReason,
    );
  }
}

CaptureBatchStatus captureBatchStatusFromDatabase(String status) {
  return switch (status) {
    'pending_upload' => CaptureBatchStatus.pendingUpload,
    'ready_for_ai' => CaptureBatchStatus.readyForAi,
    _ => CaptureBatchStatus.values.byName(status),
  };
}

CaptureItemStatus _statusFromDatabase(String status) {
  return switch (status) {
    'needs_review' => CaptureItemStatus.needsReview,
    _ => CaptureItemStatus.values.byName(status),
  };
}
