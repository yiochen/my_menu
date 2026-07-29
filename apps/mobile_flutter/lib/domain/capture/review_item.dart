class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.summary,
    required this.suggestedDishIds,
    required this.confidenceLabel,
    this.captureId,
    this.imageRef,
  });

  final String id;
  final String? captureId;
  final String summary;
  final List<String> suggestedDishIds;
  final String confidenceLabel;
  final String? imageRef;

  ReviewItem copyWith({
    List<String>? suggestedDishIds,
  }) {
    return ReviewItem(
      id: id,
      captureId: captureId,
      summary: summary,
      suggestedDishIds: suggestedDishIds ?? this.suggestedDishIds,
      confidenceLabel: confidenceLabel,
      imageRef: imageRef,
    );
  }
}
