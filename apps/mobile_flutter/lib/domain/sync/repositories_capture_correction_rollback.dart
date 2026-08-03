part of 'repositories.dart';

extension CaptureCorrectionRepositoryRollback on CaptureCorrectionRepository {
  Future<void> markSynced(String actionId) async {
    await (_database.update(_database.captureCorrections)
          ..where(
            (db.CaptureCorrections table) => table.id.equals(actionId),
          ))
        .write(
      db.CaptureCorrectionsCompanion(
        status: Value<String>(CaptureCorrectionStatus.synced.name),
        updatedAt: Value<DateTime>(DateTime.now()),
        error: const Value<String?>(null),
      ),
    );
  }

  Future<void> rollbackFailed(String actionId, Object error) async {
    final db.CaptureCorrectionRow? row =
        await (_database.select(_database.captureCorrections)
              ..where(
                (db.CaptureCorrections table) => table.id.equals(actionId),
              ))
            .getSingleOrNull();
    if (row == null || row.status != CaptureCorrectionStatus.pending.name) {
      return;
    }
    final CaptureCorrection correction = _correctionFromRow(row);
    final List<db.CaptureItemRow> items =
        await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) => table.id.isIn(correction.captureIds),
              ))
            .get();
    final Set<String> affectedDishIds = <String>{
      correction.targetDishId,
      ...correction.previousDishIds.values,
    };
    final Map<String, bool> beforePresence = await _batchPresence(
      correction.batchId,
      affectedDishIds,
    );
    final Map<String, Set<String>> removedRefsByDish = <String, Set<String>>{};
    for (final db.CaptureItemRow item in items) {
      final String? photoRef = _photoRef(item);
      if (photoRef != null && item.appliedDishId != null) {
        removedRefsByDish
            .putIfAbsent(item.appliedDishId!, () => <String>{})
            .add(photoRef);
      }
    }
    await _database.transaction(() async {
      for (final db.CaptureItemRow item in items) {
        if (correction.previouslyUnclassifiedCaptureIds.contains(item.id)) {
          await _restoreUnclassifiedLocalAssignment(
            item: item,
            sourceDishId: correction.targetDishId,
            failureReason: correction.previousFailureReasons[item.id],
            previousStatus: correction.previousStatuses[item.id] ??
                capture_domain.CaptureItemStatus.localOnly,
          );
        } else {
          await _moveOneLocalAssignment(
            item: item,
            targetDishId: correction.previousDishIds[item.id]!,
          );
        }
      }
      await _adjustDishCounts(
        dishIds: affectedDishIds,
        beforePresence: beforePresence,
        afterPresence: await _batchPresence(
          correction.batchId,
          affectedDishIds,
        ),
        removedRefsByDish: removedRefsByDish,
      );
      if (await _shouldDeleteAutoCreatedDish(correction)) {
        final String createdDishId = correction.targetDishId;
        await (_database.delete(_database.sourcePhotos)
              ..where(
                (db.SourcePhotos table) => table.dishId.equals(createdDishId),
              ))
            .go();
        await (_database.delete(_database.dishes)
              ..where((db.Dishes table) => table.id.equals(createdDishId)))
            .go();
      }
      await (_database.update(_database.captureCorrections)
            ..where(
              (db.CaptureCorrections table) => table.id.equals(actionId),
            ))
          .write(
        db.CaptureCorrectionsCompanion(
          status: Value<String>(CaptureCorrectionStatus.failed.name),
          updatedAt: Value<DateTime>(DateTime.now()),
          error: Value<String?>(error.toString()),
        ),
      );
    });
  }
}
