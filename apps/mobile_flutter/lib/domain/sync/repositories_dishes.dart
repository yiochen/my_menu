part of 'repositories.dart';

class DishRepository {
  DishRepository(this._database);

  final db.AppDatabase _database;

  Future<void> seedIfNeeded() async {
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
    final List<Dish> dishes = <Dish>[];
    for (final db.DishRow row in rows) {
      dishes.add(
        row.toDomain(
          await _sourcePhotosFor(row.id),
          await _notesFor(row.id),
        ),
      );
    }
    return dishes;
  }

  Future<void> upsertDish(Dish dish) async {
    await _database
        .into(_database.dishes)
        .insertOnConflictUpdate(dish.toCompanion());
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
    await _database.transaction(() async {
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
      await _enqueueSync(
        note.id,
        'dish_note',
        'create',
        <String, Object?>{
          'dishId': dishId,
          'body': trimmed,
          'position': note.position,
        },
      );
    });
    return note;
  }

  Future<void> updateNote(String noteId, String body) async {
    final String trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(body, 'body', 'Note body cannot be blank.');
    }
    await _database.transaction(() async {
      await (_database.update(_database.dishNotes)
            ..where((db.DishNotes table) => table.id.equals(noteId)))
          .write(
        db.DishNotesCompanion(
          body: Value<String>(trimmed),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );
      await _enqueueSync(
        noteId,
        'dish_note',
        'update',
        <String, Object?>{'body': trimmed},
      );
    });
  }

  Future<void> deleteNote(String noteId) async {
    await _database.transaction(() async {
      await (_database.update(_database.dishNotes)
            ..where((db.DishNotes table) => table.id.equals(noteId)))
          .write(
        db.DishNotesCompanion(
          deletedAt: Value<DateTime?>(DateTime.now()),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );
      await _enqueueSync(
        noteId,
        'dish_note',
        'delete',
        const <String, Object?>{},
      );
    });
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
    await _database.transaction(() async {
      await (_database.update(_database.dishes)
            ..where((db.Dishes table) => table.id.equals(dishId)))
          .write(patch);
      await _enqueueSync(
        dishId,
        'dish',
        'update',
        <String, Object?>{
          if (ingredients != null) 'ingredients': ingredients,
          if (recipeSteps != null) 'steps': recipeSteps,
        },
      );
    });
  }

  void _insertNotes(Batch batch, Dish dish) {
    final DateTime now = DateTime.now();
    for (final DishNote note in dish.notes) {
      batch.insert(
        _database.dishNotes,
        db.DishNotesCompanion.insert(
          id: note.id,
          dishId: note.dishId,
          body: note.body,
          position: note.position,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  void _insertSourcePhotos(Batch batch, Dish dish) {
    for (int index = 0; index < dish.sourcePhotos.length; index += 1) {
      final SourcePhoto photo = dish.sourcePhotos[index];
      batch.insert(
        _database.sourcePhotos,
        db.SourcePhotosCompanion.insert(
          id: '${dish.id}_source_$index',
          dishId: dish.id,
          url: photo.url,
          capturedLabel: photo.capturedLabel,
          note: Value<String?>(photo.note),
          confidenceLabel: Value<String?>(photo.confidenceLabel),
        ),
      );
    }
  }

  Future<List<SourcePhoto>> _sourcePhotosFor(String dishId) async {
    final List<db.SourcePhotoRow> rows = await (_database.select(
      _database.sourcePhotos,
    )..where((db.SourcePhotos table) => table.dishId.equals(dishId)))
        .get();
    return rows.map((db.SourcePhotoRow row) => row.toDomain()).toList();
  }

  Future<List<DishNote>> _notesFor(String dishId) async {
    final List<db.DishNoteRow> rows =
        await (_database.select(_database.dishNotes)
              ..where(
                (db.DishNotes table) =>
                    table.dishId.equals(dishId) & table.deletedAt.isNull(),
              )
              ..orderBy(<OrderingTerm Function(db.$DishNotesTable)>[
                (db.DishNotes table) => OrderingTerm.asc(table.position),
                (db.DishNotes table) => OrderingTerm.asc(table.createdAt),
              ]))
            .get();
    return rows.map((db.DishNoteRow row) => row.toDomain()).toList();
  }

  Future<void> _enqueueSync(
    String entityId,
    String entity,
    String operationType,
    Map<String, Object?> payload,
  ) async {
    await _database.into(_database.syncOperations).insert(
          db.SyncOperationsCompanion.insert(
            id: const Uuid().v4(),
            entity: entity,
            entityId: entityId,
            operationType: operationType,
            payloadJson: jsonEncode(payload),
            createdAt: DateTime.now(),
          ),
        );
  }
}
