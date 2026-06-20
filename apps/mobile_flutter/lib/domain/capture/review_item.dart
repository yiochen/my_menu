class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.summary,
    required this.suggestedDishIds,
    required this.confidenceLabel,
    this.imageRef,
  });

  final String id;
  final String summary;
  final List<String> suggestedDishIds;
  final String confidenceLabel;
  final String? imageRef;
}
