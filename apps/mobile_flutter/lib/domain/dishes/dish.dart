class Dish {
  Dish({
    required this.id,
    required this.title,
    required this.description,
    required this.heroImageUrl,
    required this.category,
    required this.prepMinutes,
    required this.difficulty,
    required this.madeCount,
    required this.lastMadeLabel,
    required this.ingredients,
    required this.recipeSteps,
    required this.notes,
    required this.sourcePhotos,
    this.isFavorite = false,
    this.createdAt,
    this.heroPreviewUrl,
    this.heroThumbnailUrl,
    this.heroPlaceholderUrl,
  });

  final String id;
  final String title;
  final String description;
  final String heroImageUrl;
  final String? heroPreviewUrl;
  final String? heroThumbnailUrl;
  final String? heroPlaceholderUrl;
  final String category;
  final int prepMinutes;
  final String difficulty;
  final int madeCount;
  final String lastMadeLabel;
  final List<String> ingredients;
  final List<String> recipeSteps;
  final List<DishNote> notes;
  final List<SourcePhoto> sourcePhotos;
  final bool isFavorite;
  final DateTime? createdAt;

  String get cardImageUrl {
    final String thumbnail = heroThumbnailUrl?.trim() ?? '';
    if (thumbnail.isNotEmpty) {
      return thumbnail;
    }
    final String preview = heroPreviewUrl?.trim() ?? '';
    return preview.isEmpty ? heroImageUrl : preview;
  }

  String? get cardPlaceholderUrl {
    final String placeholder = heroPlaceholderUrl?.trim() ?? '';
    return placeholder.isEmpty ? null : placeholder;
  }

  Dish copyWith({
    String? id,
    String? title,
    String? description,
    String? heroImageUrl,
    String? heroPreviewUrl,
    String? heroThumbnailUrl,
    String? heroPlaceholderUrl,
    String? category,
    int? prepMinutes,
    String? difficulty,
    int? madeCount,
    String? lastMadeLabel,
    List<String>? ingredients,
    List<String>? recipeSteps,
    List<DishNote>? notes,
    List<SourcePhoto>? sourcePhotos,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Dish(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      heroPreviewUrl: heroPreviewUrl ?? this.heroPreviewUrl,
      heroThumbnailUrl: heroThumbnailUrl ?? this.heroThumbnailUrl,
      heroPlaceholderUrl: heroPlaceholderUrl ?? this.heroPlaceholderUrl,
      category: category ?? this.category,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      difficulty: difficulty ?? this.difficulty,
      madeCount: madeCount ?? this.madeCount,
      lastMadeLabel: lastMadeLabel ?? this.lastMadeLabel,
      ingredients: ingredients ?? this.ingredients,
      recipeSteps: recipeSteps ?? this.recipeSteps,
      notes: notes ?? this.notes,
      sourcePhotos: sourcePhotos ?? this.sourcePhotos,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DishNote {
  const DishNote({
    required this.id,
    required this.dishId,
    required this.body,
    required this.position,
  });

  final String id;
  final String dishId;
  final String body;
  final int position;

  DishNote copyWith({
    String? body,
    int? position,
  }) {
    return DishNote(
      id: id,
      dishId: dishId,
      body: body ?? this.body,
      position: position ?? this.position,
    );
  }
}

class SourcePhoto {
  const SourcePhoto({
    required this.url,
    required this.capturedLabel,
    this.id,
    this.captureId,
    this.cookingOccasionId,
    this.capturedAt,
    this.confidenceLabel,
    this.previewUrl,
    this.thumbnailUrl,
    this.placeholderUrl,
  });

  final String? id;
  final String url;
  final String capturedLabel;
  final String? captureId;
  final String? cookingOccasionId;
  final DateTime? capturedAt;
  final String? confidenceLabel;
  final String? previewUrl;
  final String? thumbnailUrl;
  final String? placeholderUrl;
}
