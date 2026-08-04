part of 'repositories.dart';

extension CaptureCorrectionRepositoryBulk on CaptureCorrectionRepository {
  Future<List<CaptureCorrection>> applyAssignments(
    Map<String, String> dishIdByCaptureId,
  ) async {
    if (dishIdByCaptureId.isEmpty) {
      return const <CaptureCorrection>[];
    }
    final List<db.CaptureItemRow> items =
        await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) =>
                    table.id.isIn(dishIdByCaptureId.keys),
              ))
            .get();
    if (items.length != dishIdByCaptureId.length ||
        items.any((db.CaptureItemRow item) => item.batchId == null)) {
      throw StateError('Every selected photo must still be available.');
    }
    final Map<(String, String, bool), List<String>> groups =
        <(String, String, bool), List<String>>{};
    for (final db.CaptureItemRow item in items) {
      final String targetDishId = dishIdByCaptureId[item.id]!;
      if (item.appliedDishId == targetDishId) {
        continue;
      }
      groups.putIfAbsent(
        (item.batchId!, targetDishId, item.appliedDishId == null),
        () => <String>[],
      ).add(item.id);
    }
    final List<CaptureCorrection> corrections = <CaptureCorrection>[];
    await _database.transaction(() async {
      for (final MapEntry<(String, String, bool), List<String>> group
          in groups.entries) {
        final CaptureCorrection? correction = await _applyCorrection(
          batchId: group.key.$1,
          captureIds: group.value,
          targetDishId: group.key.$2,
          type: group.key.$3
              ? CaptureCorrectionType.assign
              : CaptureCorrectionType.move,
          insideTransaction: true,
        );
        if (correction != null) {
          corrections.add(correction);
        }
      }
    });
    return corrections;
  }

  Future<List<CaptureCorrection>> undoCorrections(
    Iterable<String> correctionIds,
  ) async {
    final Set<String> ids = correctionIds.toSet();
    if (ids.isEmpty) {
      return const <CaptureCorrection>[];
    }
    final List<db.CaptureCorrectionRow> rows =
        await (_database.select(_database.captureCorrections)
              ..where(
                (db.CaptureCorrections table) =>
                    table.id.isIn(ids) &
                    table.status.isIn(<String>[
                      CaptureCorrectionStatus.pending.name,
                      CaptureCorrectionStatus.synced.name,
                    ]),
              ))
            .get();
    if (rows.length != ids.length) {
      throw StateError('One or more organization changes cannot be undone.');
    }
    final List<CaptureCorrection> undone = <CaptureCorrection>[];
    final List<String> deletedCoverPaths = <String>[];
    await _database.transaction(() async {
      for (final db.CaptureCorrectionRow row in rows) {
        undone.add(
          await _undoCorrection(
            row,
            insideTransaction: true,
            deletedCoverPaths: deletedCoverPaths,
          ),
        );
      }
    });
    await _deleteCoverPaths(deletedCoverPaths);
    return undone;
  }
}
