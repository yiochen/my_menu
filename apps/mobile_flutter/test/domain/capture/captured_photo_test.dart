import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';

void main() {
  test('photos exclude ideas and organization is derived from assignment', () {
    final MyMenuState state = MyMenuState.forTesting(
      dishes: <Dish>[_dish('dish_1', 'Miso salmon')],
      captureItems: <CaptureItem>[
        _photo('newer', ordinal: 1),
        _photo('older'),
        _photo('organized', ordinal: 2, dishId: 'dish_1'),
        CaptureItem(
          id: 'idea',
          kind: CaptureItemKind.idea,
          status: CaptureItemStatus.localOnly,
          createdAt: DateTime.utc(2026, 8, 2),
          text: 'try noodles',
        ),
      ],
    );

    expect(state.photos.map((photo) => photo.id),
        <String>['older', 'newer', 'organized']);
    expect(state.unorganizedPhotoCount, 2);
    expect(state.organizedPhotoCount, 1);
    expect(state.photos.last.overlayLabel, 'Miso salmon');
  });

  test('overlay priority is review, failure, organizing, unorganized, dish',
      () {
    final MyMenuState state = MyMenuState.forTesting(
      dishes: <Dish>[_dish('dish_1', 'Miso salmon')],
      captureItems: <CaptureItem>[
        _photo('review', status: CaptureItemStatus.needsReview),
        _photo('failed', status: CaptureItemStatus.failed),
        _photo('organizing', batchId: 'working'),
        _photo('plain'),
        _photo('organized', dishId: 'dish_1'),
      ],
      reviewItems: const <ReviewItem>[
        ReviewItem(
          id: 'review_1',
          captureId: 'review',
          summary: 'Could be salmon',
          suggestedDishIds: <String>['dish_1'],
          confidenceLabel: '60%',
        ),
      ],
      processingRequests: <ProcessingOutboxRequest>[
        ProcessingOutboxRequest(
          id: 'request_1',
          kind: ProcessingRequestKind.captureGrouping,
          subjectId: 'working',
          payload: const <String, Object?>{},
          deliveryState: ProcessingDeliveryState.uploading,
          adoptionState: ProcessingAdoptionState.awaitingProposal,
          createdAt: DateTime.utc(2026, 8, 2),
          updatedAt: DateTime.utc(2026, 8, 2),
        ),
      ],
    );

    expect(
      state.photos.map((photo) => photo.overlayLabel).toSet(),
      <String>{
        'Review',
        'Couldn’t organize',
        'Organizing',
        'Unorganized',
        'Miso salmon',
      },
    );
    expect(state.isOrganizingPhotos, isTrue);
  });
}

CaptureItem _photo(
  String id, {
  int ordinal = 0,
  String batchId = 'batch',
  String? dishId,
  CaptureItemStatus status = CaptureItemStatus.localOnly,
}) {
  return CaptureItem(
    id: id,
    batchId: batchId,
    ordinal: ordinal,
    kind: CaptureItemKind.photo,
    status: status,
    createdAt: DateTime.utc(2026, 8, 2),
    capturedLocalDate: '2026-08-02',
    localMediaRef: 'fake://$id',
    appliedDishId: dishId,
  );
}

Dish _dish(String id, String title) {
  return Dish(
    id: id,
    title: title,
    description: '',
    heroImageUrl: '',
    category: '',
    prepMinutes: 0,
    difficulty: '',
    madeCount: 0,
    lastMadeLabel: '',
    ingredients: const <String>[],
    recipeSteps: const <String>[],
    notes: const <DishNote>[],
    sourcePhotos: const <SourcePhoto>[],
  );
}
