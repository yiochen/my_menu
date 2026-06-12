import 'package:mymenu/domain/capture/review_item.dart';

const List<ReviewItem> seededReviewItems = <ReviewItem>[
  ReviewItem(
    id: 'review_1',
    summary: 'Possible pho capture from a dimly lit dinner bowl.',
    suggestedDishIds: <String>['dish_pho', 'dish_katsu'],
    confidenceLabel: '54%',
  ),
];
