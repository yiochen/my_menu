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

  test('batch groups stay contiguous and retain picker ordinal order', () {
    final MyMenuState state = MyMenuState.forTesting(
      captureItems: <CaptureItem>[
        _photo(
          'batch-a-first',
          batchId: 'batch-a',
          capturedAt: DateTime.utc(2026, 8, 2, 8),
        ),
        _photo(
          'batch-a-second',
          batchId: 'batch-a',
          ordinal: 1,
          capturedAt: DateTime.utc(2026, 8, 2, 10),
        ),
        _photo(
          'batch-b',
          batchId: 'batch-b',
          capturedAt: DateTime.utc(2026, 8, 2, 9),
        ),
      ],
    );

    expect(
      state.photos.map((photo) => photo.id),
      <String>['batch-a-first', 'batch-a-second', 'batch-b'],
    );
  });

  test('photos use app upload date instead of photo shoot date', () {
    final MyMenuState state = MyMenuState.forTesting(
      captureItems: <CaptureItem>[
        _photo(
          'shot-recently-uploaded-earlier',
          batchId: 'earlier-upload',
          createdAt: DateTime(2026, 8, 2, 12),
          capturedAt: DateTime(2026, 8, 2, 11),
        ),
        _photo(
          'shot-years-ago-uploaded-today',
          batchId: 'latest-upload',
          createdAt: DateTime(2026, 8, 3, 12),
          capturedAt: DateTime(2020, 1, 1, 11),
          capturedLocalDate: '2020-01-01',
        ),
      ],
    );

    expect(
      state.photos.map((photo) => photo.id),
      <String>[
        'shot-years-ago-uploaded-today',
        'shot-recently-uploaded-earlier',
      ],
    );
    expect(
      state.photos.map((photo) => photo.dateKey),
      <String>['2026-08-03', '2026-08-02'],
    );
  });
}

CaptureItem _photo(
  String id, {
  int ordinal = 0,
  String batchId = 'batch',
  String? dishId,
  CaptureItemStatus status = CaptureItemStatus.localOnly,
  DateTime? createdAt,
  DateTime? capturedAt,
  String capturedLocalDate = '2026-08-02',
}) {
  return CaptureItem(
    id: id,
    batchId: batchId,
    ordinal: ordinal,
    kind: CaptureItemKind.photo,
    status: status,
    createdAt: createdAt ?? DateTime.utc(2026, 8, 2),
    capturedLocalDate: capturedLocalDate,
    capturedAt: capturedAt,
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
