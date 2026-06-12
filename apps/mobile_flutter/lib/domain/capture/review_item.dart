class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.summary,
    required this.suggestedDishIds,
    required this.confidenceLabel,
  });

  final String id;
  final String summary;
  final List<String> suggestedDishIds;
  final String confidenceLabel;
}
