part of 'app_repositories.dart';

extension DishRepositoryInserts on DishRepository {
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
          createdAt: note.createdAt ?? now,
          updatedAt: note.updatedAt ?? note.createdAt ?? now,
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
          id: photo.id ?? '${dish.id}_source_$index',
          dishId: dish.id,
          url: photo.url,
          previewUrl: Value<String?>(photo.previewUrl),
          thumbnailUrl: Value<String?>(photo.thumbnailUrl),
          placeholderUrl: Value<String?>(photo.placeholderUrl),
          capturedLabel: photo.capturedLabel,
          captureId: Value<String?>(photo.captureId),
          cookingOccasionId: Value<String?>(photo.cookingOccasionId),
          capturedAt: Value<DateTime?>(photo.capturedAt),
          confidenceLabel: Value<String?>(photo.confidenceLabel),
        ),
      );
    }
  }
}
