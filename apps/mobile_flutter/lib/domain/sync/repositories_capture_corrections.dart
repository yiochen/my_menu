part of 'repositories.dart';

class CaptureCorrectionRepository {
  CaptureCorrectionRepository(this._database);

  final db.AppDatabase _database;
  final Uuid _uuid = const Uuid();

  Future<List<CaptureCorrection>> listCorrections() async {
    final List<db.CaptureCorrectionRow> rows =
        await (_database.select(_database.captureCorrections)
              ..orderBy(
                <OrderingTerm Function(db.$CaptureCorrectionsTable)>[
                  (db.$CaptureCorrectionsTable table) =>
                      OrderingTerm.desc(table.createdAt),
                ],
              ))
            .get();
    return rows.map(_correctionFromRow).toList(growable: false);
  }

  Future<CaptureCorrection?> moveCaptures({
    required String batchId,
    required List<String> captureIds,
    required String targetDishId,
  }) {
    return _applyCorrection(
      batchId: batchId,
      captureIds: captureIds,
      targetDishId: targetDishId,
      type: CaptureCorrectionType.move,
    );
  }

  Future<CaptureCorrection?> splitCaptures({
    required String batchId,
    required List<String> captureIds,
    required String title,
  }) {
    final String trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(title, 'title', 'A new dish needs a name.');
    }
    return _applyCorrection(
      batchId: batchId,
      captureIds: captureIds,
      targetDishId: _uuid.v4(),
      type: CaptureCorrectionType.split,
      newDishTitle: trimmed,
    );
  }

  Future<CaptureCorrection?> assignCaptures({
    required String batchId,
    required List<String> captureIds,
    required String targetDishId,
  }) {
    return _applyCorrection(
      batchId: batchId,
      captureIds: captureIds,
      targetDishId: targetDishId,
      type: CaptureCorrectionType.assign,
    );
  }

  Future<CaptureCorrection?> assignCapturesToNewDish({
    required String batchId,
    required List<String> captureIds,
    required String title,
  }) {
    final String trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(title, 'title', 'A new dish needs a name.');
    }
    return _applyCorrection(
      batchId: batchId,
      captureIds: captureIds,
      targetDishId: _uuid.v4(),
      type: CaptureCorrectionType.assignSplit,
      newDishTitle: trimmed,
    );
  }

  Future<CaptureCorrection?> _applyCorrection({
    required String batchId,
    required List<String> captureIds,
    required String targetDishId,
    required CaptureCorrectionType type,
    String? newDishTitle,
    bool insideTransaction = false,
  }) async {
    final List<String> selectedIds = captureIds.toSet().toList(growable: false);
    if (selectedIds.isEmpty) {
      return null;
    }
    final List<db.CaptureItemRow> items =
        await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) =>
                    table.batchId.equals(batchId) & table.id.isIn(selectedIds),
              ))
            .get();
    final bool isAssignment = type == CaptureCorrectionType.assign ||
        type == CaptureCorrectionType.assignSplit;
    final bool hasExpectedState = isAssignment
        ? items.every(
            (db.CaptureItemRow item) =>
                item.kind == capture_domain.CaptureItemKind.photo.name &&
                item.appliedDishId == null,
          )
        : items.every(
            (db.CaptureItemRow item) =>
                item.status == capture_domain.CaptureItemStatus.applied.name &&
                item.appliedDishId != null,
          );
    if (items.length != selectedIds.length || !hasExpectedState) {
      throw StateError(
        isAssignment
            ? 'Every selected photo must be unclassified.'
            : 'Every selected photo must be actively organized.',
      );
    }
    if (type == CaptureCorrectionType.move &&
        items.every(
          (db.CaptureItemRow item) => item.appliedDishId == targetDishId,
        )) {
      return null;
    }

    final String actionId = _uuid.v4();
    final DateTime now = DateTime.now();
    final Map<String, Object?> previousStates = <String, Object?>{
      for (final db.CaptureItemRow item in items)
        item.id: <String, Object?>{
          'dishId': item.appliedDishId,
          'status': item.status,
          'failureReason': item.failureReason,
        },
    };

    Future<void> apply() async {
      if (type == CaptureCorrectionType.split ||
          type == CaptureCorrectionType.assignSplit) {
        await _insertLocalDish(
          id: targetDishId,
          title: newDishTitle!,
          items: items,
        );
      }
      await _moveLocalAssignments(
        batchId: batchId,
        items: items,
        targetDishId: targetDishId,
      );
      await _database.into(_database.captureCorrections).insert(
            db.CaptureCorrectionsCompanion.insert(
              id: actionId,
              batchId: batchId,
              actionType: type.name,
              captureIdsJson: jsonEncode(selectedIds),
              previousDishIdsJson: jsonEncode(previousStates),
              targetDishId: targetDishId,
              createdDishId: Value<String?>(
                type == CaptureCorrectionType.split ||
                        type == CaptureCorrectionType.assignSplit
                    ? targetDishId
                    : null,
              ),
              status: CaptureCorrectionStatus.synced.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await ProcessingOutboxRepository(_database).supersedeCaptureGrouping(
        batchId,
      );
    }

    if (insideTransaction) {
      await apply();
    } else {
      await _database.transaction(apply);
    }

    return (await listCorrections())
        .firstWhere((CaptureCorrection item) => item.id == actionId);
  }

  Future<CaptureCorrection?> undoLatest(
    String batchId, {
    String? captureId,
  }) async {
    final List<db.CaptureCorrectionRow> rows =
        await (_database.select(_database.captureCorrections)
              ..where(
                (db.CaptureCorrections table) =>
                    table.batchId.equals(batchId) &
                    table.status.isIn(<String>[
                      CaptureCorrectionStatus.pending.name,
                      CaptureCorrectionStatus.synced.name,
                    ]),
              )
              ..orderBy(
                <OrderingTerm Function(db.$CaptureCorrectionsTable)>[
                  (db.$CaptureCorrectionsTable table) =>
                      OrderingTerm.desc(table.createdAt),
                ],
              ))
            .get();
    final db.CaptureCorrectionRow? row = rows.where((row) {
      return captureId == null ||
          _correctionFromRow(row).captureIds.contains(captureId);
    }).firstOrNull;
    if (row == null) {
      return null;
    }
    return _undoCorrection(row);
  }

  Future<CaptureCorrection> _undoCorrection(
    db.CaptureCorrectionRow row, {
    bool insideTransaction = false,
  }) async {
    final CaptureCorrection correction = _correctionFromRow(row);
    final List<db.CaptureItemRow> items =
        await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) => table.id.isIn(correction.captureIds),
              ))
            .get();
    final DateTime now = DateTime.now();
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

    Future<void> apply() async {
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
          final String previousDishId = correction.previousDishIds[item.id]!;
          await _moveOneLocalAssignment(
            item: item,
            targetDishId: previousDishId,
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
              (db.CaptureCorrections table) => table.id.equals(correction.id),
            ))
          .write(
        db.CaptureCorrectionsCompanion(
          status: Value<String>(CaptureCorrectionStatus.undone.name),
          updatedAt: Value<DateTime>(now),
          undoneAt: Value<DateTime?>(now),
          error: const Value<String?>(null),
        ),
      );
      await ProcessingOutboxRepository(_database).supersedeCaptureGrouping(
        correction.batchId,
      );
    }

    if (insideTransaction) {
      await apply();
    } else {
      await _database.transaction(apply);
    }
    return _correctionFromRow(
      await (_database.select(_database.captureCorrections)
            ..where(
              (db.CaptureCorrections table) => table.id.equals(correction.id),
            ))
          .getSingle(),
    );
  }
}
