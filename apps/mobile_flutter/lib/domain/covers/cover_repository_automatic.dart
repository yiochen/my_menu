part of 'cover_repository.dart';

extension CoverRepositoryAutomatic on CoverRepository {
  Future<List<String>> _usableAutomaticSourceIds({
    required String dishId,
    required List<String> sourceIds,
  }) async {
    if (sourceIds.isEmpty) return const <String>[];
    final List<db.SourcePhotoRow> rows = await (_database.select(
      _database.sourcePhotos,
    )..where(
            (db.SourcePhotos table) =>
                table.dishId.equals(dishId) & table.id.isIn(sourceIds),
          ))
        .get();
    final Map<String, db.SourcePhotoRow> byId = <String, db.SourcePhotoRow>{
      for (final db.SourcePhotoRow row in rows) row.id: row,
    };
    return sourceIds
        .where((String id) {
          final db.SourcePhotoRow? source = byId[id];
          if (source == null) return false;
          final String ref = source.previewUrl ?? source.url;
          final Uri? uri = Uri.tryParse(ref);
          if (ref.startsWith('asset://') ||
              uri?.scheme == 'http' ||
              uri?.scheme == 'https') {
            return true;
          }
          final File file = File(ref);
          return file.existsSync() && file.lengthSync() > 0;
        })
        .take(3)
        .toList(growable: false);
  }

  Future<bool> restartAutomaticCoverIfPending({
    required String dishId,
    required DateTime now,
  }) async {
    final db.ProcessingOutboxRow? existing = await (_database.select(
      _database.processingOutbox,
    )..where(
            (db.ProcessingOutbox table) =>
                table.requestKind.equals(
                  ProcessingRequestKind.coverGeneration.databaseValue,
                ) &
                table.subjectId.equals(dishId),
          ))
        .getSingleOrNull();
    if (existing == null) return false;
    final Object? decoded = jsonDecode(existing.payloadJson);
    if (decoded is! Map<String, dynamic> ||
        decoded['origin'] != CoverOrigin.automatic.name ||
        <String>{'acknowledged', 'failed', 'expired'}
            .contains(existing.deliveryState) ||
        (existing.deliveryState == ProcessingDeliveryState.canceled.name &&
            decoded['restartAfterCancel'] != true)) {
      return false;
    }
    final List<String> allSourceIds = await (_database.select(
      _database.sourcePhotos,
    )..where((db.SourcePhotos table) => table.dishId.equals(dishId)))
        .get()
        .then(
          (List<db.SourcePhotoRow> rows) =>
              rows.map((db.SourcePhotoRow row) => row.id).take(3).toList(),
        );
    final List<String> sourceIds = await _usableAutomaticSourceIds(
      dishId: dishId,
      sourceIds: allSourceIds,
    );
    if (allSourceIds.isNotEmpty && sourceIds.isEmpty) {
      final Map<String, Object?> terminalPayload =
          Map<String, Object?>.from(decoded)..remove('restartAfterCancel');
      await (_database.update(_database.processingOutbox)
            ..where(
              (db.ProcessingOutbox table) => table.id.equals(existing.id),
            ))
          .write(
        db.ProcessingOutboxCompanion(
          payloadJson: Value<String>(jsonEncode(terminalPayload)),
          deliveryState: Value<String>(ProcessingDeliveryState.canceled.name),
          updatedAt: Value<DateTime>(now),
        ),
      );
      return true;
    }
    final Map<String, Object?> payload = await _automaticPayload(
      dishId: dishId,
      sourceIds: sourceIds,
    );
    payload['restartAfterCancel'] = true;
    await (_database.update(_database.processingOutbox)
          ..where((db.ProcessingOutbox table) => table.id.equals(existing.id)))
        .write(
      db.ProcessingOutboxCompanion(
        payloadJson: Value<String>(jsonEncode(payload)),
        deliveryState: Value<String>(ProcessingDeliveryState.canceled.name),
        updatedAt: Value<DateTime>(now),
      ),
    );
    return true;
  }

  Future<Map<String, Object?>> _automaticPayload({
    required String dishId,
    required List<String> sourceIds,
  }) async {
    final db.DishRow dish = await (_database.select(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(dishId)))
        .getSingle();
    final List<db.DishNoteRow> notes = await (_database.select(
      _database.dishNotes,
    )
          ..where(
            (db.DishNotes table) =>
                table.dishId.equals(dishId) & table.deletedAt.isNull(),
          )
          ..orderBy(<OrderingTerm Function(db.$DishNotesTable)>[
            (db.$DishNotesTable table) => OrderingTerm.asc(table.position),
            (db.$DishNotesTable table) => OrderingTerm.asc(table.createdAt),
          ]))
        .get();
    final List<db.SourcePhotoRow> dishSourceRows = await (_database.select(
      _database.sourcePhotos,
    )..where((db.SourcePhotos table) => table.dishId.equals(dishId)))
        .get();
    final List<String> captureIds = dishSourceRows
        .map((db.SourcePhotoRow source) => source.captureId)
        .whereType<String>()
        .toList(growable: false);
    final List<db.CaptureItemRow> captures = captureIds.isEmpty
        ? const <db.CaptureItemRow>[]
        : await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) => table.id.isIn(captureIds),
              ))
            .get();
    final List<db.CaptureItemRow> orderedCaptures = captures.toList()
      ..sort((db.CaptureItemRow left, db.CaptureItemRow right) {
        final int byOrdinal = left.ordinal.compareTo(right.ordinal);
        return byOrdinal != 0
            ? byOrdinal
            : left.createdAt.compareTo(right.createdAt);
      });
    final db.CaptureItemRow? earliestCapture =
        orderedCaptures.isEmpty ? null : orderedCaptures.first;
    return <String, Object?>{
      'dishTitle': dish.title,
      'sourceIds': sourceIds.take(3).toList(growable: false),
      'notes': notes
          .map((db.DishNoteRow note) => <String, Object?>{
                'body': note.body,
                'position': note.position,
                'createdAt': note.createdAt.toUtc().toIso8601String(),
                'updatedAt': note.updatedAt.toUtc().toIso8601String(),
              })
          .toList(growable: false),
      'treatment': CoverTreatment.defaults.toJson(),
      'origin': CoverOrigin.automatic.name,
      'automaticCaptureBatchId': earliestCapture?.batchId,
      'automaticCaptureOrdinal': earliestCapture?.ordinal,
      'contractVersion': 'cover-generation-v1',
      'coverSnapshot': <String, Object?>{
        'image': dish.heroImageUrl,
        'preview': dish.heroPreviewUrl,
        'thumbnail': dish.heroThumbnailUrl,
        'placeholder': dish.heroPlaceholderUrl,
      },
    };
  }
}
