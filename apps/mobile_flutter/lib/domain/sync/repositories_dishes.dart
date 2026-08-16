part of 'repositories.dart';

class DishRepository {
  DishRepository(
    this._database,
    this._dishImageCache,
    this._imageDerivativeStore,
  );

  final db.AppDatabase _database;
  final DishImageCache _dishImageCache;
  final ImageDerivativeStore _imageDerivativeStore;

  Future<void> _seedIfEmpty() async {
    final int existingCount =
        await _database.select(_database.dishes).get().then(
              (List<db.DishRow> rows) => rows.length,
            );
    if (existingCount > 0) {
      return;
    }

    await _database.batch((Batch batch) {
      for (final Dish dish in seededDishes) {
        batch.insert(_database.dishes, dish.toCompanion());
        _insertNotes(batch, dish);
        _insertSourcePhotos(batch, dish);
      }
    });
  }

  Future<List<Dish>> listDishes() async {
    final List<db.DishRow> rows =
        await _database.select(_database.dishes).get();
    if (rows.isEmpty) {
      return const <Dish>[];
    }

    final List<String> dishIds =
        rows.map((db.DishRow row) => row.id).toList(growable: false);
    final List<db.SourcePhotoRow> sourceRows = await (_database.select(
      _database.sourcePhotos,
    )..where((db.SourcePhotos table) => table.dishId.isIn(dishIds)))
        .get();
    final List<db.DishNoteRow> noteRows = await (_database.select(
      _database.dishNotes,
    )
          ..where(
            (db.DishNotes table) =>
                table.dishId.isIn(dishIds) & table.deletedAt.isNull(),
          )
          ..orderBy(<OrderingTerm Function(db.$DishNotesTable)>[
            (db.DishNotes table) => OrderingTerm.asc(table.dishId),
            (db.DishNotes table) => OrderingTerm.asc(table.position),
            (db.DishNotes table) => OrderingTerm.asc(table.createdAt),
          ]))
        .get();
    final Map<String, List<SourcePhoto>> sourcesByDishId =
        <String, List<SourcePhoto>>{};
    for (final db.SourcePhotoRow row in sourceRows) {
      sourcesByDishId
          .putIfAbsent(row.dishId, () => <SourcePhoto>[])
          .add(row.toDomain());
    }
    final Map<String, List<DishNote>> notesByDishId =
        <String, List<DishNote>>{};
    for (final db.DishNoteRow row in noteRows) {
      notesByDishId
          .putIfAbsent(row.dishId, () => <DishNote>[])
          .add(row.toDomain());
    }

    return rows
        .map(
          (db.DishRow row) => row.toDomain(
            sourcesByDishId[row.id] ?? const <SourcePhoto>[],
            notesByDishId[row.id] ?? const <DishNote>[],
          ),
        )
        .toList(growable: false);
  }

  Future<void> upsertDish(Dish dish) async {
    await _database
        .into(_database.dishes)
        .insertOnConflictUpdate(dish.toCompanion());
  }

  Future<void> createDish(
    Dish dish, {
    String? consumedReviewId,
  }) async {
    await _database.transaction(() async {
      await _database.batch((Batch batch) {
        batch.insert(_database.dishes, dish.toCompanion());
        _insertNotes(batch, dish);
        _insertSourcePhotos(batch, dish);
      });
      if (consumedReviewId != null) {
        await (_database.delete(_database.reviewItems)
              ..where(
                (db.ReviewItems table) => table.id.equals(consumedReviewId),
              ))
            .go();
      }
    });
  }

  Future<void> setFavorite(
    String dishId, {
    required bool isFavorite,
  }) async {
    await (_database.update(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(dishId)))
        .write(
      db.DishesCompanion(isFavorite: Value<bool>(isFavorite)),
    );
  }

  Future<void> markOpened(String dishId, DateTime openedAt) async {
    await (_database.update(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(dishId)))
        .write(
      db.DishesCompanion(openedAt: Value<DateTime?>(openedAt)),
    );
  }

  Future<void> updateDetails(
    String dishId, {
    required String title,
    required String description,
  }) async {
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Dish title cannot be blank.');
    }
    await (_database.update(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(dishId)))
        .write(
      db.DishesCompanion(
        title: Value<String>(trimmedTitle),
        description: Value<String>(description.trim()),
      ),
    );
  }

  Future<void> deleteDishes(Iterable<String> dishIds) {
    return deleteLocalDishes(dishIds);
  }

  Future<void> deleteLocalDishes(Iterable<String> dishIds) async {
    final List<String> ids = dishIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) {
      return;
    }

    final List<db.DishRow> dishRows = await (_database.select(
      _database.dishes,
    )..where((db.Dishes table) => table.id.isIn(ids)))
        .get();
    final List<db.SourcePhotoRow> sourceRows = await (_database.select(
      _database.sourcePhotos,
    )..where((db.SourcePhotos table) => table.dishId.isIn(ids)))
        .get();
    final List<db.DishNoteRow> noteRows = await (_database.select(
      _database.dishNotes,
    )..where((db.DishNotes table) => table.dishId.isIn(ids)))
        .get();
    final List<db.GeneratedCoverRow> generatedCoverRows =
        await (_database.select(_database.generatedCovers)
              ..where(
                (db.GeneratedCovers table) => table.dishId.isIn(ids),
              ))
            .get();
    final List<db.CaptureItemRow> captureRows = await (_database.select(
      _database.captureItems,
    )..where((db.CaptureItems table) => table.appliedDishId.isIn(ids)))
        .get();
    final List<db.CaptureCorrectionRow> correctionRows =
        await _relatedCorrections(ids, captureRows);
    final List<String> captureIds =
        captureRows.map((db.CaptureItemRow row) => row.id).toList();
    final Set<String> batchIds = captureRows
        .map((db.CaptureItemRow row) => row.batchId)
        .whereType<String>()
        .toSet();

    await _database.transaction(() async {
      await _deleteSupersededSyncOperations(
        dishIds: ids,
        noteIds: noteRows.map((db.DishNoteRow row) => row.id).toList(),
        captureIds: captureIds,
        batchIds: batchIds.toList(),
        correctionIds: correctionRows
            .map((db.CaptureCorrectionRow row) => row.id)
            .toList(),
      );
      if (correctionRows.isNotEmpty) {
        final List<String> correctionIds = correctionRows
            .map((db.CaptureCorrectionRow row) => row.id)
            .toList(growable: false);
        await (_database.delete(_database.captureCorrections)
              ..where(
                (db.CaptureCorrections table) => table.id.isIn(correctionIds),
              ))
            .go();
      }
      await _removeDeletedDishReviewItems(
        dishIds: ids,
        captureIds: captureIds,
      );
      await (_database.delete(_database.sourcePhotos)
            ..where((db.SourcePhotos table) => table.dishId.isIn(ids)))
          .go();
      await (_database.delete(_database.dishNotes)
            ..where((db.DishNotes table) => table.dishId.isIn(ids)))
          .go();
      await (_database.delete(_database.plannedMeals)
            ..where((db.PlannedMeals table) => table.dishId.isIn(ids)))
          .go();
      for (final String dishId in ids) {
        await _database.customStatement(
          "UPDATE processing_outbox SET delivery_state = 'canceled', "
          r"payload_json = json_remove(payload_json, '$.restartAfterCancel'), "
          'updated_at = ? WHERE request_kind = ? AND subject_id = ?',
          <Object?>[
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
            ProcessingRequestKind.coverGeneration.databaseValue,
            dishId,
          ],
        );
      }
      await (_database.delete(_database.generatedCovers)
            ..where((db.GeneratedCovers table) => table.dishId.isIn(ids)))
          .go();
      await (_database.delete(_database.captureItems)
            ..where((db.CaptureItems table) => table.appliedDishId.isIn(ids)))
          .go();
      await (_database.delete(_database.aiJobs)
            ..where(
              (db.AiJobs table) =>
                  table.subjectId.isIn(<String>[...ids, ...batchIds]),
            ))
          .go();
      await (_database.delete(_database.dishes)
            ..where((db.Dishes table) => table.id.isIn(ids)))
          .go();

      for (final String batchId in batchIds) {
        final Expression<int> countExpression =
            _database.captureItems.id.count();
        final int remaining = await (_database.selectOnly(
          _database.captureItems,
        )
              ..addColumns(<Expression<Object>>[countExpression])
              ..where(_database.captureItems.batchId.equals(batchId)))
            .map(
              (TypedResult row) => row.read(countExpression) ?? 0,
            )
            .getSingle();
        if (remaining != 0) {
          continue;
        }
        await (_database.delete(_database.captureBatches)
              ..where(
                (db.CaptureBatches table) => table.id.equals(batchId),
              ))
            .go();
      }
    });

    for (final db.GeneratedCoverRow cover in generatedCoverRows) {
      for (final String path in <String>{
        cover.localPath,
        if (cover.previewPath != null) cover.previewPath!,
        if (cover.thumbnailPath != null) cover.thumbnailPath!,
        if (cover.placeholderPath != null) cover.placeholderPath!,
      }) {
        final File file = File(path);
        if (file.existsSync()) file.deleteSync();
      }
    }

    await _dishImageCache.remove(
      cacheKeys: <String>[
        ...dishRows.expand(
          (db.DishRow row) => <String>[
            '${row.id}_hero',
            '${row.id}_fallback',
          ],
        ),
        ...sourceRows.map((db.SourcePhotoRow row) => row.id),
      ],
      localRefs: <String>[
        ...dishRows.map((db.DishRow row) => row.heroImageUrl),
        ...sourceRows.map((db.SourcePhotoRow row) => row.url),
      ],
    );
    await _imageDerivativeStore.remove(
      refs: <String?>[
        ...dishRows.map((db.DishRow row) => row.heroPreviewUrl),
        ...dishRows.map((db.DishRow row) => row.heroThumbnailUrl),
        ...dishRows.map((db.DishRow row) => row.heroPlaceholderUrl),
        ...sourceRows.map((db.SourcePhotoRow row) => row.previewUrl),
        ...sourceRows.map((db.SourcePhotoRow row) => row.thumbnailUrl),
        ...sourceRows.map((db.SourcePhotoRow row) => row.placeholderUrl),
        ...captureRows.map(
          (db.CaptureItemRow row) => row.localPreviewRef,
        ),
        ...captureRows.map(
          (db.CaptureItemRow row) => row.localThumbnailRef,
        ),
        ...captureRows.map(
          (db.CaptureItemRow row) => row.localPlaceholderRef,
        ),
      ],
    );
    await _deleteOwnedCaptureFiles(
      captureRows.map((db.CaptureItemRow row) => row.localMediaRef),
    );
  }

  Future<DishNote> createNote(String dishId, String body) async {
    final String trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(body, 'body', 'Note body cannot be blank.');
    }
    final List<DishNote> existingNotes = await _notesFor(dishId);
    final DateTime now = DateTime.now();
    final DishNote note = DishNote(
      id: const Uuid().v4(),
      dishId: dishId,
      body: trimmed,
      position: existingNotes.length,
    );
    await _database.into(_database.dishNotes).insert(
          db.DishNotesCompanion.insert(
            id: note.id,
            dishId: note.dishId,
            body: note.body,
            position: note.position,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return note;
  }

  Future<void> updateNote(String noteId, String body) async {
    final String trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(body, 'body', 'Note body cannot be blank.');
    }
    await (_database.update(_database.dishNotes)
          ..where((db.DishNotes table) => table.id.equals(noteId)))
        .write(
      db.DishNotesCompanion(
        body: Value<String>(trimmed),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> deleteNote(String noteId) async {
    await (_database.delete(_database.dishNotes)
          ..where((db.DishNotes table) => table.id.equals(noteId)))
        .go();
  }

  Future<void> updateSections(
    String dishId, {
    List<String>? ingredients,
    List<String>? recipeSteps,
  }) async {
    final db.DishesCompanion patch = db.DishesCompanion(
      ingredientsJson: ingredients == null
          ? const Value<String>.absent()
          : Value<String>(jsonEncode(ingredients)),
      recipeStepsJson: recipeSteps == null
          ? const Value<String>.absent()
          : Value<String>(jsonEncode(recipeSteps)),
    );
    await (_database.update(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(dishId)))
        .write(patch);
  }
}
