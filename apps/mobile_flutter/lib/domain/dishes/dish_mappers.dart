import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/domain/dishes/dish.dart';

extension DishRowMapper on db.DishRow {
  Dish toDomain(List<SourcePhoto> sourcePhotos) {
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
      notes: _stringListFromJson(notesJson),
      sourcePhotos: sourcePhotos,
      isFavorite: isFavorite,
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
      notesJson: jsonEncode(notes),
      isFavorite: Value<bool>(isFavorite),
    );
  }
}

extension SourcePhotoRowMapper on db.SourcePhotoRow {
  SourcePhoto toDomain() {
    return SourcePhoto(
      url: url,
      capturedLabel: capturedLabel,
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
