part of 'cover_repository.dart';

extension CoverRepositorySelection on CoverRepository {
  Future<void> keepCurrent(String coverId) async {
    await (_database.update(_database.generatedCovers)
          ..where(
            (db.GeneratedCovers table) =>
                table.id.equals(coverId) &
                table.state.equals(GeneratedCoverState.proposed.name),
          ))
        .write(db.GeneratedCoversCompanion(
      state: Value<String>(GeneratedCoverState.history.name),
    ));
  }

  Future<void> selectGenerated(String coverId) async {
    await _database.transaction(() async {
      final db.GeneratedCoverRow cover = await (_database.select(
        _database.generatedCovers,
      )..where((db.GeneratedCovers table) => table.id.equals(coverId)))
          .getSingle();
      await (_database.update(_database.generatedCovers)
            ..where(
              (db.GeneratedCovers table) =>
                  table.dishId.equals(cover.dishId) &
                  table.state.equals(GeneratedCoverState.current.name),
            ))
          .write(db.GeneratedCoversCompanion(
        state: Value<String>(GeneratedCoverState.history.name),
        automaticUndoAvailable: const Value<bool>(false),
      ));
      await (_database.update(_database.generatedCovers)
            ..where((db.GeneratedCovers table) => table.id.equals(coverId)))
          .write(db.GeneratedCoversCompanion(
        state: Value<String>(GeneratedCoverState.current.name),
        automaticUndoAvailable: const Value<bool>(false),
      ));
      await _writeDishCover(cover);
    });
  }

  Future<void> selectSource(String dishId, String sourceId) async {
    await _database.transaction(() async {
      final db.SourcePhotoRow source = await (_database.select(
        _database.sourcePhotos,
      )..where((db.SourcePhotos table) =>
              table.id.equals(sourceId) & table.dishId.equals(dishId)))
          .getSingle();
      await (_database.update(_database.generatedCovers)
            ..where((db.GeneratedCovers table) =>
                table.dishId.equals(dishId) &
                table.state.equals(GeneratedCoverState.current.name)))
          .write(db.GeneratedCoversCompanion(
        state: Value<String>(GeneratedCoverState.history.name),
        automaticUndoAvailable: const Value<bool>(false),
      ));
      await (_database.update(_database.dishes)
            ..where((db.Dishes table) => table.id.equals(dishId)))
          .write(db.DishesCompanion(
        heroImageUrl: Value<String>(source.url),
        heroPreviewUrl: Value<String?>(source.previewUrl),
        heroThumbnailUrl: Value<String?>(source.thumbnailUrl),
        heroPlaceholderUrl: Value<String?>(source.placeholderUrl),
      ));
    });
  }

  Future<void> acknowledgeAutomatic(String coverId) async {
    await (_database.update(_database.generatedCovers)
          ..where((db.GeneratedCovers table) => table.id.equals(coverId)))
        .write(const db.GeneratedCoversCompanion(
      automaticAcknowledged: Value<bool>(true),
    ));
  }

  Future<void> deleteGenerated(String coverId) async {
    final db.GeneratedCoverRow? cover = await (_database.select(
      _database.generatedCovers,
    )..where((db.GeneratedCovers table) => table.id.equals(coverId)))
        .getSingleOrNull();
    if (cover == null) return;
    await _database.transaction(() async {
      if (cover.state == GeneratedCoverState.current.name) {
        await (_database.update(_database.dishes)
              ..where((db.Dishes table) => table.id.equals(cover.dishId)))
            .write(const db.DishesCompanion(
          heroImageUrl: Value<String>(''),
          heroPreviewUrl: Value<String?>(null),
          heroThumbnailUrl: Value<String?>(null),
          heroPlaceholderUrl: Value<String?>(null),
        ));
      }
      await (_database.delete(_database.generatedCovers)
            ..where((db.GeneratedCovers table) => table.id.equals(coverId)))
          .go();
      await (_database.delete(_database.processingOutbox)
            ..where((db.ProcessingOutbox table) => table.id.equals(coverId)))
          .go();
    });
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

  Future<void> _writeDishCover(db.GeneratedCoverRow cover) async {
    await (_database.update(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(cover.dishId)))
        .write(db.DishesCompanion(
      heroImageUrl: Value<String>(cover.localPath),
      heroPreviewUrl: Value<String?>(cover.previewPath),
      heroThumbnailUrl: Value<String?>(cover.thumbnailPath),
      heroPlaceholderUrl: Value<String?>(cover.placeholderPath),
    ));
  }

  GeneratedCover _fromRow(db.GeneratedCoverRow row) {
    final Object? decodedSources = jsonDecode(row.selectedSourceIdsJson);
    return GeneratedCover(
      id: row.id,
      dishId: row.dishId,
      localPath: row.localPath,
      previewPath: row.previewPath,
      thumbnailPath: row.thumbnailPath,
      placeholderPath: row.placeholderPath,
      origin: CoverOrigin.values.byName(row.origin),
      grounding: CoverGrounding.values.byName(row.grounding),
      selectedSourceIds: decodedSources is List<dynamic>
          ? decodedSources.whereType<String>().toList(growable: false)
          : const <String>[],
      treatment: CoverTreatment(
        look: CoverLook.values.firstWhere(
          (CoverLook value) => value.apiValue == row.look,
        ),
        view: CoverView.values.firstWhere(
          (CoverView value) => value.apiValue == row.view,
        ),
        finish: CoverFinish.values.firstWhere(
          (CoverFinish value) => value.apiValue == row.finish,
        ),
      ),
      contractVersion: row.contractVersion,
      proposalId: row.proposalId,
      state: GeneratedCoverState.values.byName(row.state),
      createdAt: row.createdAt,
      automaticAcknowledged: row.automaticAcknowledged,
      automaticUndoAvailable: row.automaticUndoAvailable,
    );
  }
}
