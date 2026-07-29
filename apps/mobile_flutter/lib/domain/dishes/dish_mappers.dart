import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/domain/dishes/dish.dart';

extension DishRowMapper on db.DishRow {
  Dish toDomain(List<SourcePhoto> sourcePhotos, List<DishNote> notes) {
    return Dish(
      id: id,
      title: title,
      description: description,
      heroImageUrl: heroImageUrl,
      category: category,
      prepMinutes: prepMinutes,
      difficulty: difficulty,
      madeCount: madeCount,
      lastMadeLabel: lastMadeLabel,
      ingredients: _stringListFromJson(ingredientsJson),
      recipeSteps: _stringListFromJson(recipeStepsJson),
      notes: notes,
      sourcePhotos: sourcePhotos,
      isFavorite: isFavorite,
      createdAt: createdAt,
    );
  }
}

extension DishCompanionMapper on Dish {
  db.DishesCompanion toCompanion() {
    return db.DishesCompanion.insert(
      id: id,
      title: title,
      description: description,
      heroImageUrl: heroImageUrl,
      category: category,
      prepMinutes: prepMinutes,
      difficulty: difficulty,
      madeCount: madeCount,
      lastMadeLabel: lastMadeLabel,
      ingredientsJson: jsonEncode(ingredients),
      recipeStepsJson: jsonEncode(recipeSteps),
      notesJson: jsonEncode(notes.map((DishNote note) => note.body).toList()),
      isFavorite: Value<bool>(isFavorite),
      createdAt: Value<DateTime?>(createdAt),
    );
  }
}

extension DishNoteRowMapper on db.DishNoteRow {
  DishNote toDomain() {
    return DishNote(
      id: id,
      dishId: dishId,
      body: body,
      position: position,
    );
  }
}

extension SourcePhotoRowMapper on db.SourcePhotoRow {
  SourcePhoto toDomain() {
    return SourcePhoto(
      id: id,
      url: url,
      capturedLabel: capturedLabel,
      captureId: captureId,
      cookingOccasionId: cookingOccasionId,
      capturedAt: capturedAt,
      note: note,
      confidenceLabel: confidenceLabel,
    );
  }
}

List<String> _stringListFromJson(String value) {
  final Object? decoded = jsonDecode(value);
  if (decoded is! List<dynamic>) {
    return const <String>[];
  }
  return decoded.whereType<String>().toList(growable: false);
}
