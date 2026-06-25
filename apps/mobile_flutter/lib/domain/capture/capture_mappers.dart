import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/domain/capture/capture_item.dart';

extension CaptureItemRowMapper on db.CaptureItemRow {
  CaptureItem toDomain() {
    return CaptureItem(
      id: id,
      kind: CaptureItemKind.values.byName(kind),
      status: _statusFromDatabase(status),
      createdAt: createdAt,
      localMediaRef: localMediaRef,
      remoteMediaRef: remoteMediaRef,
      text: ideaText,
      appliedDishId: appliedDishId,
    );
  }
}

CaptureItemStatus _statusFromDatabase(String status) {
  return switch (status) {
    'needs_review' => CaptureItemStatus.needsReview,
    _ => CaptureItemStatus.values.byName(status),
  };
}
