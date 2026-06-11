class Dish {
  Dish({
    required this.id,
    required this.title,
    required this.description,
    required this.heroImageUrl,
    required this.category,
    required this.prepMinutes,
    required this.difficulty,
    required this.servings,
    required this.madeCount,
    required this.lastMadeLabel,
    required this.ingredients,
    required this.recipeSteps,
    required this.notes,
    required this.sourcePhotos,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String description;
  final String heroImageUrl;
  final String category;
  final int prepMinutes;
  final String difficulty;
  final int servings;
  final int madeCount;
  final String lastMadeLabel;
  final List<String> ingredients;
  final List<String> recipeSteps;
  final List<String> notes;
  final List<SourcePhoto> sourcePhotos;
  final bool isFavorite;

  Dish copyWith({
    String? title,
    String? description,
    String? heroImageUrl,
    String? category,
    int? prepMinutes,
    String? difficulty,
    int? servings,
    int? madeCount,
    String? lastMadeLabel,
    List<String>? ingredients,
    List<String>? recipeSteps,
    List<String>? notes,
    List<SourcePhoto>? sourcePhotos,
    bool? isFavorite,
  }) {
    return Dish(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      category: category ?? this.category,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      difficulty: difficulty ?? this.difficulty,
      servings: servings ?? this.servings,
      madeCount: madeCount ?? this.madeCount,
      lastMadeLabel: lastMadeLabel ?? this.lastMadeLabel,
      ingredients: ingredients ?? this.ingredients,
      recipeSteps: recipeSteps ?? this.recipeSteps,
      notes: notes ?? this.notes,
      sourcePhotos: sourcePhotos ?? this.sourcePhotos,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class SourcePhoto {
  const SourcePhoto({
    required this.url,
    required this.capturedLabel,
    this.note,
    this.confidenceLabel,
  });

  final String url;
  final String capturedLabel;
  final String? note;
  final String? confidenceLabel;
}
