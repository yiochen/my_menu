import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:mymenu/domain/sync/repositories.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('repositories', () {
    late AppDatabase database;
    late AppRepositories repositories;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('seeds dishes and plan into local storage', () async {
      await repositories.seedIfNeeded();

      final dishes = await repositories.dishRepository.listDishes();
      final plannedMeals = await database.select(database.plannedMeals).get();

      expect(dishes.length, seededDishes.length);
      expect(dishes.first.sourcePhotos, isNotEmpty);
      expect(plannedMeals.length, buildSeededPlan().length);
    });

    test('seedIfNeeded is idempotent', () async {
      await repositories.seedIfNeeded();
      await repositories.seedIfNeeded();

      final dishes = await database.select(database.dishes).get();
      final plannedMeals = await database.select(database.plannedMeals).get();

      expect(dishes.length, seededDishes.length);
      expect(plannedMeals.length, buildSeededPlan().length);
    });

    test('dish repository upserts and hydrates source photos', () async {
      await repositories.seedIfNeeded();
      final Dish original =
          (await repositories.dishRepository.listDishes()).first;
      final Dish updated = original.copyWith(
        title: 'Renamed ${original.title}',
        isFavorite: !original.isFavorite,
      );

      await repositories.dishRepository.upsertDish(updated);
      final dishes = await repositories.dishRepository.listDishes();
      final Dish saved =
          dishes.firstWhere((Dish dish) => dish.id == original.id);

      expect(saved.title, updated.title);
      expect(saved.isFavorite, updated.isFavorite);
      expect(saved.sourcePhotos.length, original.sourcePhotos.length);
    });

    test('photo capture sync starts backend classification', () async {
      await repositories.seedIfNeeded();
      await repositories.captureRepository.createPhotoCaptures(
        const <String>['/tmp/capture.jpg'],
      );

      var feedItems = await repositories.captureRepository.listFeedItems();
      expect(feedItems.single.status, CaptureItemStatus.pendingUpload);

      final createdDishes =
          await repositories.syncRepository.processPendingCaptures();
      feedItems = await repositories.captureRepository.listFeedItems();

      expect(createdDishes, isEmpty);
      expect(feedItems.single.status, CaptureItemStatus.classifying);
      expect(feedItems.single.appliedDishId, isNull);
      expect(feedItems.single.remoteMediaRef, startsWith('fake://captures/'));
    });

    test('photo capture ignores empty refs and creates sync operations',
        () async {
      final List<String> ids =
          await repositories.captureRepository.createPhotoCaptures(
        const <String>['', '  ', '/tmp/one.jpg', '/tmp/two.jpg'],
      );

      final feedItems = await repositories.captureRepository.listFeedItems();
      final syncOperations =
          await database.select(database.syncOperations).get();

      expect(ids.length, 2);
      expect(feedItems.length, 2);
      expect(
          feedItems.map((CaptureItem item) => item.localMediaRef),
          containsAll(
            const <String>['/tmp/one.jpg', '/tmp/two.jpg'],
          ));
      expect(syncOperations.length, 2);
      expect(
          syncOperations
              .every((operation) => operation.entity == 'capture_item'),
          isTrue);
    });

    test('idea capture trims text and starts classifying', () async {
      final String? id = await repositories.captureRepository
          .createIdeaCapture('  kimchi rice  ');

      final feedItems = await repositories.captureRepository.listFeedItems();
      final syncOperations =
          await database.select(database.syncOperations).get();

      expect(id, isNotNull);
      expect(feedItems.single.kind, CaptureItemKind.idea);
      expect(feedItems.single.status, CaptureItemStatus.classifying);
      expect(feedItems.single.text, 'kimchi rice');
      expect(syncOperations.single.entityId, id);
    });

    test('blank idea capture is ignored', () async {
      final String? id =
          await repositories.captureRepository.createIdeaCapture('   ');

      final feedItems = await repositories.captureRepository.listFeedItems();
      final syncOperations =
          await database.select(database.syncOperations).get();

      expect(id, isNull);
      expect(feedItems, isEmpty);
      expect(syncOperations, isEmpty);
    });

    test('idea capture sync starts backend classification', () async {
      await repositories.seedIfNeeded();
      final String? id = await repositories.captureRepository
          .createIdeaCapture('late night udon');

      final List<Dish> createdDishes =
          await repositories.syncRepository.processPendingCaptures();
      final feedItems = await repositories.captureRepository.listFeedItems();

      expect(id, isNotNull);
      expect(createdDishes, isEmpty);
      expect(feedItems.single.status, CaptureItemStatus.classifying);
      expect(feedItems.single.appliedDishId, isNull);
    });

    test('discarded capture is not processed by sync', () async {
      await repositories.seedIfNeeded();
      final List<String> ids =
          await repositories.captureRepository.createPhotoCaptures(
        const <String>['/tmp/capture.jpg'],
      );

      await repositories.captureRepository.discardCapture(ids.single);
      final createdDishes =
          await repositories.syncRepository.processPendingCaptures();
      final feedItems = await repositories.captureRepository.listFeedItems();

      expect(createdDishes, isEmpty);
      expect(feedItems.single.status, CaptureItemStatus.discarded);
    });

    test('sync repository uploads photos before classification', () async {
      final _RecordingApiClient apiClient = _RecordingApiClient();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
      );
      await repositories.captureRepository.createPhotoCaptures(
        const <String>['/tmp/capture.jpg'],
      );

      await repositories.syncRepository.processPendingCaptures();
      final feedItems = await repositories.captureRepository.listFeedItems();

      expect(apiClient.uploadedCaptureIds, hasLength(1));
      expect(
          apiClient.classifiedRemoteMediaRefs.single, startsWith('remote://'));
      expect(feedItems.single.remoteMediaRef,
          apiClient.classifiedRemoteMediaRefs.single);
    });

    test('sync repository does nothing when no captures are pending', () async {
      final _RecordingApiClient apiClient = _RecordingApiClient();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
      );

      final List<Dish> createdDishes =
          await repositories.syncRepository.processPendingCaptures();

      expect(createdDishes, isEmpty);
      expect(apiClient.uploadedCaptureIds, isEmpty);
      expect(apiClient.classifiedCaptureIds, isEmpty);
    });

    test('sync repository marks captures failed when remote sync throws',
        () async {
      repositories = AppRepositories(
        database: database,
        apiClient: _ThrowingApiClient(),
      );
      await repositories.captureRepository.createPhotoCaptures(
        const <String>['/tmp/capture.jpg'],
      );

      final List<Dish> createdDishes =
          await repositories.syncRepository.processPendingCaptures();
      final feedItems = await repositories.captureRepository.listFeedItems();

      expect(createdDishes, isEmpty);
      expect(feedItems.single.status, CaptureItemStatus.failed);
    });

    test('fake API upload and idea classification start return expected DTOs',
        () async {
      final FakeMyMenuApiClient apiClient = FakeMyMenuApiClient();

      final String mediaRef = await apiClient.uploadCaptureMedia(
        captureId: 'capture_1',
        localMediaRef: '/tmp/photo.jpg',
      );
      final ApiClassificationStart result = await apiClient.classifyCapture(
        captureId: 'capture_1',
        remoteMediaRef: mediaRef,
        ideaText: 'crispy tofu bowls',
      );

      expect(mediaRef, 'fake://captures/capture_1');
      expect(result.captureId, 'capture_1');
      expect(result.status, CaptureItemStatus.classifying.name);
    });

    test('pullCaptureSync applies capture result events and advances cursor',
        () async {
      repositories = AppRepositories(
        database: database,
        apiClient: _SyncResultApiClient(),
      );

      await repositories.syncRepository.pullCaptureSync();

      final feedItems = await repositories.captureRepository.listFeedItems();
      final dishes = await repositories.dishRepository.listDishes();
      final cursor = await (database.select(database.syncMetadata)
            ..where((table) => table.key.equals('capture_sync_cursor')))
          .getSingle();

      expect(feedItems.single.status, CaptureItemStatus.applied);
      expect(feedItems.single.appliedDishId, 'dish_sync_result');
      expect(dishes.single.title, 'Sync Result Noodles');
      expect(
          dishes.single.sourcePhotos.single.url, 'https://example.com/a.jpg');
      expect(cursor.value, '42');
    });
  });
}

class _RecordingApiClient implements MyMenuApiClient {
  final List<String> uploadedCaptureIds = <String>[];
  final List<String> classifiedCaptureIds = <String>[];
  final List<String?> classifiedRemoteMediaRefs = <String?>[];

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String localMediaRef,
  }) async {
    uploadedCaptureIds.add(captureId);
    return 'remote://$captureId';
  }

  @override
  Future<ApiClassificationStart> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  }) async {
    classifiedCaptureIds.add(captureId);
    classifiedRemoteMediaRefs.add(remoteMediaRef);
    return ApiClassificationStart(
      captureId: captureId,
      status: CaptureItemStatus.classifying.name,
    );
  }

  @override
  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  }) async {
    return ApiSyncPull(
      cursor: afterCursor,
      hasMore: false,
      requiresBootstrap: false,
      events: const <ApiSyncEvent>[],
    );
  }

  @override
  Future<List<ApiCapture>> getCaptures(List<String> ids) async {
    return const <ApiCapture>[];
  }

  @override
  Future<List<ApiDish>> getDishes(List<String> ids) async {
    return const <ApiDish>[];
  }

  @override
  Future<List<ApiReviewItem>> getReviewItems(List<String> ids) async {
    return const <ApiReviewItem>[];
  }
}

class _ThrowingApiClient implements MyMenuApiClient {
  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String localMediaRef,
  }) {
    throw StateError('Remote sync unavailable.');
  }

  @override
  Future<ApiClassificationStart> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  }) {
    throw StateError('Remote sync unavailable.');
  }

  @override
  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  }) {
    throw StateError('Remote sync unavailable.');
  }

  @override
  Future<List<ApiCapture>> getCaptures(List<String> ids) {
    throw StateError('Remote sync unavailable.');
  }

  @override
  Future<List<ApiDish>> getDishes(List<String> ids) {
    throw StateError('Remote sync unavailable.');
  }

  @override
  Future<List<ApiReviewItem>> getReviewItems(List<String> ids) {
    throw StateError('Remote sync unavailable.');
  }
}

class _SyncResultApiClient implements MyMenuApiClient {
  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String localMediaRef,
  }) {
    throw StateError('Unexpected upload.');
  }

  @override
  Future<ApiClassificationStart> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  }) {
    throw StateError('Unexpected classification.');
  }

  @override
  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  }) async {
    if (afterCursor >= 42) {
      return const ApiSyncPull(
        cursor: 42,
        hasMore: false,
        requiresBootstrap: false,
        events: <ApiSyncEvent>[],
      );
    }

    return const ApiSyncPull(
      cursor: 42,
      hasMore: false,
      requiresBootstrap: false,
      events: <ApiSyncEvent>[
        ApiSyncEvent(
          cursor: 42,
          type: 'capture.applied_to_new_dish',
          entityIds: <String, String>{
            'captureId': 'capture_sync_result',
            'dishId': 'dish_sync_result',
            'sourceImageId': 'source_sync_result',
          },
        ),
      ],
    );
  }

  @override
  Future<List<ApiCapture>> getCaptures(List<String> ids) async {
    return <ApiCapture>[
      if (ids.contains('capture_sync_result'))
        ApiCapture(
          id: 'capture_sync_result',
          kind: CaptureItemKind.photo.name,
          status: CaptureItemStatus.applied.name,
          capturedAt: DateTime.utc(2026, 6, 20, 12),
          appliedDishId: 'dish_sync_result',
          image: const ApiImage(
            id: 'source_sync_result',
            kind: 'source_photo',
            mediaRef: 'https://example.com/a.jpg',
          ),
        ),
    ];
  }

  @override
  Future<List<ApiDish>> getDishes(List<String> ids) async {
    return <ApiDish>[
      if (ids.contains('dish_sync_result'))
        ApiDish(
          id: 'dish_sync_result',
          title: 'Sync Result Noodles',
          description: 'Created from sync.',
          labels: const <String>['noodles'],
          isFavorite: true,
          madeCount: 1,
          lastMadeAt: DateTime.utc(2026, 6, 20, 12),
          coverImage: const ApiImage(
            id: 'source_sync_result',
            kind: 'source_photo',
            mediaRef: 'https://example.com/a.jpg',
          ),
          sourcePhotos: <ApiSourcePhoto>[
            ApiSourcePhoto(
              id: 'source_sync_result',
              mediaRef: 'https://example.com/a.jpg',
              capturedAt: DateTime.utc(2026, 6, 20, 12),
              confidenceLabel: 'AI',
            ),
          ],
          ingredients: const <String>['noodles'],
          steps: const <String>['Cook noodles.'],
          notes: const <String>['Synced from server.'],
        ),
    ];
  }

  @override
  Future<List<ApiReviewItem>> getReviewItems(List<String> ids) async {
    return const <ApiReviewItem>[];
  }
}
