import 'package:mymenu/domain/capture/review_item.dart';

const List<ReviewItem> seededReviewItems = <ReviewItem>[
  ReviewItem(
    id: 'review_1',
    summary: 'Captured salmon bowl from tonight.',
    suggestedDishIds: <String>['dish_salmon', 'dish_linguine'],
    confidenceLabel: '86%',
  ),
  ReviewItem(
    id: 'review_2',
    summary: 'Possible pho capture from a dimly lit dinner bowl.',
    suggestedDishIds: <String>['dish_pho', 'dish_katsu'],
    confidenceLabel: '54%',
  ),
];
