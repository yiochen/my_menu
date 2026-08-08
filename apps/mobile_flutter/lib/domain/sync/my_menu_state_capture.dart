part of 'my_menu_state.dart';

String _titleCase(String input) {
  return input
      .split(' ')
      .where((String part) => part.trim().isNotEmpty)
      .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

List<ReviewItem> _reviewItemsWithPhotoCaptures(
  List<String> imageRefs,
  List<ReviewItem> currentItems,
) {
  final List<String> refs = imageRefs
      .map((String imageRef) => imageRef.trim())
      .where((String imageRef) => imageRef.isNotEmpty)
      .toList(growable: false);
  if (refs.isEmpty) {
    return currentItems;
  }

  return <ReviewItem>[
    for (int index = 0; index < refs.length; index += 1)
      ReviewItem(
        id: 'review_${currentItems.length + index + 1}',
        summary: 'Photo capture ready to organize.',
        suggestedDishIds: const <String>['dish_salmon', 'dish_linguine'],
        confidenceLabel: 'Needs review',
        imageRef: refs[index],
      ),
    ...currentItems,
  ];
}

Dish _dishFromPhotoReview(ReviewItem item, String dishId) {
  return Dish(
    id: dishId,
    title: 'Captured Dish',
    description: 'Created from a photo capture.',
    heroImageUrl: item.imageRef!,
    category: 'Captured',
    prepMinutes: 0,
    difficulty: 'Draft',
    madeCount: 1,
    lastMadeLabel: 'Today',
    ingredients: const <String>[],
    recipeSteps: const <String>[],
    notes: _notesFor(dishId, const <String>[
      'Created from capture.',
    ]),
    sourcePhotos: <SourcePhoto>[
      SourcePhoto(
        url: item.imageRef!,
        capturedLabel: 'Today',
        confidenceLabel: item.confidenceLabel,
      ),
    ],
  );
}

int _globalInsertIndexForDay(
  List<PlannedMeal> plan, {
  required String dayKey,
  required int indexInDay,
}) {
  final List<int> dayIndices = <int>[];
  for (int index = 0; index < plan.length; index++) {
    if (plan[index].dayKey == dayKey) {
      dayIndices.add(index);
    }
  }

  if (dayIndices.isEmpty) {
    for (int index = 0; index < plan.length; index++) {
      if (plan[index].dayKey.compareTo(dayKey) > 0) {
        return index;
      }
    }
    return plan.length;
  }

  if (indexInDay <= 0) {
    return dayIndices.first;
  }
  if (indexInDay >= dayIndices.length) {
    return dayIndices.last + 1;
  }
  return dayIndices[indexInDay];
}
