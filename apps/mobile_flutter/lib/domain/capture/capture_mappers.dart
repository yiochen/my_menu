import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/domain/capture/capture_item.dart';

extension CaptureItemRowMapper on db.CaptureItemRow {
  CaptureItem toDomain() {
    return CaptureItem(
      id: id,
      kind: CaptureItemKind.values.byName(kind),
      status: _statusFromDatabase(status),
      createdAt: createdAt,
      ingestId: ingestId,
      ordinal: ordinal,
      localMediaRef: localMediaRef,
      localPreviewRef: localPreviewRef,
      localThumbnailRef: localThumbnailRef,
      localPlaceholderRef: localPlaceholderRef,
      text: ideaText,
      capturedAt: capturedAt,
      capturedLocalDate: capturedLocalDate,
      captureDateSource: captureDateSource,
      appliedDishId: appliedDishId,
      failureReason: failureReason,
    );
  }
}

CaptureItemStatus _statusFromDatabase(String status) {
  return switch (status) {
    'needs_review' => CaptureItemStatus.needsReview,
    _ => CaptureItemStatus.values.byName(status),
  };
}
