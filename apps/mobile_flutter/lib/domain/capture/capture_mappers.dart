import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/domain/capture/capture_item.dart';

extension CaptureItemRowMapper on db.CaptureItemRow {
  CaptureItem toDomain() {
    return CaptureItem(
      id: id,
      kind: CaptureItemKind.values.byName(kind),
      status: CaptureItemStatus.values.byName(status),
      createdAt: createdAt,
      localMediaRef: localMediaRef,
      remoteMediaRef: remoteMediaRef,
      text: ideaText,
      appliedDishId: appliedDishId,
    );
  }
}
