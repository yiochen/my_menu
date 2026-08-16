part of 'app_repositories.dart';

extension _DishDeletionSupport on DishRepository {
  Future<List<db.CaptureCorrectionRow>> _relatedCorrections(
    List<String> dishIds,
    List<db.CaptureItemRow> captureRows,
  ) async {
    final Set<String> captureIds =
        captureRows.map((db.CaptureItemRow row) => row.id).toSet();
    final List<db.CaptureCorrectionRow> rows =
        await _database.select(_database.captureCorrections).get();
    return rows.where((db.CaptureCorrectionRow row) {
      final List<String> correctedCaptureIds =
          _jsonStringList(row.captureIdsJson);
      final List<String> previousDishIds =
          _jsonStringValues(row.previousDishIdsJson);
      return dishIds.contains(row.targetDishId) ||
          (row.createdDishId != null && dishIds.contains(row.createdDishId)) ||
          correctedCaptureIds.any(captureIds.contains) ||
          previousDishIds.any(dishIds.contains);
    }).toList(growable: false);
  }

  Future<void> _removeDeletedDishReviewItems({
    required List<String> dishIds,
    required List<String> captureIds,
  }) async {
    final Set<String> deletedDishes = dishIds.toSet();
    final Set<String> deletedCaptures = captureIds.toSet();
    final List<db.ReviewItemRow> rows =
        await _database.select(_database.reviewItems).get();
    for (final db.ReviewItemRow row in rows) {
      if (row.captureId != null && deletedCaptures.contains(row.captureId)) {
        await (_database.delete(_database.reviewItems)
              ..where((db.ReviewItems table) => table.id.equals(row.id)))
            .go();
        continue;
      }
      final List<String> current = _jsonStringList(row.suggestedDishIdsJson);
      final List<String> remaining =
          current.where((String id) => !deletedDishes.contains(id)).toList();
      if (remaining.length == current.length) {
        continue;
      }
      if (remaining.isEmpty) {
        await (_database.delete(_database.reviewItems)
              ..where((db.ReviewItems table) => table.id.equals(row.id)))
            .go();
        continue;
      }
      await (_database.update(_database.reviewItems)
            ..where((db.ReviewItems table) => table.id.equals(row.id)))
          .write(
        db.ReviewItemsCompanion(
          suggestedDishIdsJson: Value<String>(jsonEncode(remaining)),
        ),
      );
    }
  }

  List<String> _jsonStringList(String value) {
    final Object? decoded = jsonDecode(value);
    return decoded is List<dynamic>
        ? decoded.whereType<String>().toList(growable: false)
        : const <String>[];
  }

  List<String> _jsonStringValues(String value) {
    final Object? decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) {
      return decoded.values.whereType<String>().toList(growable: false);
    }
    return _jsonStringList(value);
  }

  Future<void> _deleteOwnedCaptureFiles(Iterable<String?> refs) async {
    for (final String path in refs.whereType<String>().toSet()) {
      try {
        final File file = File(path);
        if (file.existsSync()) {
          await file.delete();
        }
      } on Object {
        // Database deletion and remote retry should not be blocked by a
        // missing or externally removed local capture copy.
      }
    }
  }
}
