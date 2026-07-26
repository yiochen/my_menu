class ApiClassificationStart {
  const ApiClassificationStart({
    required this.captureId,
    required this.status,
  });

  final String captureId;
  final String status;
}

class ApiCaptureBatch {
  const ApiCaptureBatch({
    required this.id,
    required this.status,
    required this.itemCount,
    required this.uploadedItemCount,
  });

  final String id;
  final String status;
  final int itemCount;
  final int uploadedItemCount;
}

class ApiSyncPull {
  const ApiSyncPull({
    required this.cursor,
    required this.hasMore,
    required this.requiresBootstrap,
    required this.events,
  });

  final int cursor;
  final bool hasMore;
  final bool requiresBootstrap;
  final List<ApiSyncEvent> events;
}

class ApiSyncEvent {
  const ApiSyncEvent({
    required this.cursor,
    required this.type,
    required this.entityIds,
  });

  final int cursor;
  final String type;
  final Map<String, String> entityIds;
}

class ApiImage {
  const ApiImage({
    required this.id,
    required this.kind,
    required this.mediaRef,
  });

  final String id;
  final String kind;
  final String mediaRef;
}

class ApiCapture {
  const ApiCapture({
    required this.id,
    required this.kind,
    required this.status,
    required this.capturedAt,
    this.batchId,
    this.ordinal,
    this.ideaText,
    this.appliedDishId,
    this.failureReason,
    this.image,
  });

  final String id;
  final String kind;
  final String status;
  final DateTime capturedAt;
  final String? batchId;
  final int? ordinal;
  final String? ideaText;
  final String? appliedDishId;
  final String? failureReason;
  final ApiImage? image;
}

class ApiDish {
  const ApiDish({
    required this.id,
    required this.title,
    required this.description,
    required this.labels,
    required this.isFavorite,
    required this.madeCount,
    required this.sourcePhotos,
    required this.ingredients,
    required this.steps,
    required this.notes,
    this.prepMinutes,
    this.difficulty,
    this.lastMadeAt,
    this.coverImage,
  });

  final String id;
  final String title;
  final String description;
  final List<String> labels;
  final int? prepMinutes;
  final String? difficulty;
  final bool isFavorite;
  final int madeCount;
  final DateTime? lastMadeAt;
  final ApiImage? coverImage;
  final List<ApiSourcePhoto> sourcePhotos;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> notes;
}

class ApiSourcePhoto {
  const ApiSourcePhoto({
    required this.id,
    required this.mediaRef,
    this.capturedAt,
    this.note,
    this.confidenceLabel,
  });

  final String id;
  final String mediaRef;
  final DateTime? capturedAt;
  final String? note;
  final String? confidenceLabel;
}

class ApiReviewItem {
  const ApiReviewItem({
    required this.id,
    required this.captureId,
    required this.status,
    required this.summary,
    required this.suggestedDishIds,
    this.confidenceLabel,
  });

  final String id;
  final String captureId;
  final String status;
  final String summary;
  final List<String> suggestedDishIds;
  final String? confidenceLabel;
}
