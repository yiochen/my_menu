import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';

enum CapturedPhotoState {
  review,
  failed,
  organizing,
  unorganized,
  notADish,
  organized,
}

class CapturedPhoto {
  const CapturedPhoto({
    required this.item,
    required this.state,
    required this.dateKey,
    this.dish,
    this.reviewItem,
  });

  final CaptureItem item;
  final CapturedPhotoState state;
  final String dateKey;
  final Dish? dish;
  final ReviewItem? reviewItem;

  String get id => item.id;
  String? get batchId => item.batchId;
  int get ordinal => item.ordinal;
  String get imageRef => item.localMediaRef ?? '';
  DateTime get uploadedAt => item.createdAt;
  bool get isOrganized => item.appliedDishId != null;

  String get overlayLabel => switch (state) {
        CapturedPhotoState.review => 'Review',
        CapturedPhotoState.failed => 'Couldn’t organize',
        CapturedPhotoState.organizing => 'Organizing',
        CapturedPhotoState.unorganized => 'Unorganized',
        CapturedPhotoState.notADish => 'Not a dish',
        CapturedPhotoState.organized => dish?.title ?? 'Organized',
      };

  String get semanticsLabel {
    final String organization = isOrganized
        ? 'organized in ${dish?.title ?? 'a dish'}'
        : overlayLabel.toLowerCase();
    return 'Photo from $dateKey, $organization';
  }
}

List<CapturedPhoto> buildCapturedPhotos({
  required List<CaptureItem> items,
  required List<Dish> dishes,
  required List<ReviewItem> reviewItems,
  required List<ProcessingOutboxRequest> processingRequests,
}) {
  final Map<String, Dish> dishesById = <String, Dish>{
    for (final Dish dish in dishes) dish.id: dish,
  };
  final Map<String, ReviewItem> reviewsByCapture = <String, ReviewItem>{
    for (final ReviewItem review in reviewItems)
      if (review.captureId != null) review.captureId!: review,
  };
  final Map<String, ProcessingOutboxRequest> requestsByBatch =
      <String, ProcessingOutboxRequest>{
    for (final ProcessingOutboxRequest request in processingRequests)
      request.subjectId: request,
  };

  final List<CapturedPhoto> photos = items
      .where((CaptureItem item) => item.kind == CaptureItemKind.photo)
      .map((CaptureItem item) {
    final ReviewItem? review = reviewsByCapture[item.id];
    final ProcessingOutboxRequest? request =
        item.batchId == null ? null : requestsByBatch[item.batchId!];
    final CapturedPhotoState state = _photoState(item, review, request);
    return CapturedPhoto(
      item: item,
      state: state,
      dateKey: _localDate(item.createdAt),
      dish: item.appliedDishId == null ? null : dishesById[item.appliedDishId],
      reviewItem: review,
    );
  }).toList(growable: false);
  final Map<String, DateTime> groupTimes = <String, DateTime>{};
  for (final CapturedPhoto photo in photos) {
    final String groupKey = photo.batchId ?? 'photo:${photo.id}';
    final DateTime? current = groupTimes[groupKey];
    if (current == null || photo.uploadedAt.isAfter(current)) {
      groupTimes[groupKey] = photo.uploadedAt;
    }
  }
  return photos
    ..sort((CapturedPhoto left, CapturedPhoto right) {
      final int byDate = right.dateKey.compareTo(left.dateKey);
      if (byDate != 0) {
        return byDate;
      }
      final String leftGroup = left.batchId ?? 'photo:${left.id}';
      final String rightGroup = right.batchId ?? 'photo:${right.id}';
      if (leftGroup == rightGroup) {
        final int byOrdinal = left.ordinal.compareTo(right.ordinal);
        return byOrdinal != 0 ? byOrdinal : left.id.compareTo(right.id);
      }
      final int byGroupTime = groupTimes[rightGroup]!.compareTo(
        groupTimes[leftGroup]!,
      );
      return byGroupTime != 0 ? byGroupTime : leftGroup.compareTo(rightGroup);
    });
}

CapturedPhotoState _photoState(
  CaptureItem item,
  ReviewItem? review,
  ProcessingOutboxRequest? request,
) {
  if (review != null || item.status == CaptureItemStatus.needsReview) {
    return CapturedPhotoState.review;
  }
  if (item.status == CaptureItemStatus.notADish) {
    return CapturedPhotoState.notADish;
  }
  if (item.status == CaptureItemStatus.failed ||
      request?.deliveryState == ProcessingDeliveryState.failed) {
    return CapturedPhotoState.failed;
  }
  if (request != null &&
      request.adoptionState != ProcessingAdoptionState.rejected &&
      request.adoptionState != ProcessingAdoptionState.adopted &&
      <ProcessingDeliveryState>{
        ProcessingDeliveryState.pendingUpload,
        ProcessingDeliveryState.uploading,
        ProcessingDeliveryState.submitted,
      }.contains(request.deliveryState)) {
    return CapturedPhotoState.organizing;
  }
  return item.appliedDishId == null
      ? CapturedPhotoState.unorganized
      : CapturedPhotoState.organized;
}

String _localDate(DateTime value) {
  final DateTime local = value.toLocal();
  final String month = local.month.toString().padLeft(2, '0');
  final String day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
