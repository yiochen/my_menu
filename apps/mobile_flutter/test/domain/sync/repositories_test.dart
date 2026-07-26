import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/domain/sync/repositories.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

    test('dish repository hydrates notes from separate rows', () async {
      await repositories.seedIfNeeded();

      final List<Dish> dishes = await repositories.dishRepository.listDishes();
      final Dish linguine =
          dishes.firstWhere((Dish dish) => dish.id == 'dish_linguine');

      expect(linguine.notes, hasLength(3));
      expect(linguine.notes.first.id, 'dish_linguine_note_0');
      expect(linguine.notes.first.body, 'Use more lemon next time.');
    });

    test('dish repository creates, updates, and deletes note rows', () async {
      await repositories.seedIfNeeded();
      final Dish dish = (await repositories.dishRepository.listDishes()).first;

      final DishNote note =
          await repositories.dishRepository.createNote(dish.id, ' Add lime ');
      await repositories.dishRepository.updateNote(note.id, 'Add lime zest');
      var dishes = await repositories.dishRepository.listDishes();
      var saved = dishes.firstWhere((Dish item) => item.id == dish.id);

      expect(saved.notes.last.body, 'Add lime zest');

      await repositories.dishRepository.deleteNote(note.id);
      dishes = await repositories.dishRepository.listDishes();
      saved = dishes.firstWhere((Dish item) => item.id == dish.id);

      expect(saved.notes.any((DishNote item) => item.id == note.id), isFalse);
      expect(
        (await database.select(database.syncOperations).get())
            .where((row) => row.entity == 'dish_note'),
        hasLength(3),
      );
    });

    test('sync repository sends pending note operations', () async {
      final _RecordingApiClient apiClient = _RecordingApiClient();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
      );
      await repositories.seedIfNeeded();
      final Dish dish = (await repositories.dishRepository.listDishes()).first;

      final DishNote note =
          await repositories.dishRepository.createNote(dish.id, 'Use chives');
      await repositories.syncRepository.processPendingOperations();
      final List<SyncOperationRow> operations =
          await database.select(database.syncOperations).get();

      expect(apiClient.createdNoteIds, <String>[note.id]);
      expect(operations.where((row) => row.completedAt != null), hasLength(1));
    });

    test('photo capture sync marks its batch ready after upload', () async {
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
      final batches = await repositories.captureRepository.listBatches();
      expect(feedItems.single.status, CaptureItemStatus.uploaded);
      expect(batches.single.status, CaptureBatchStatus.readyForAi);
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
      expect(syncOperations.length, 3);
      expect(
        syncOperations.where((operation) => operation.entity == 'capture_item'),
        hasLength(2),
      );
      expect(
        syncOperations
            .where((operation) => operation.entity == 'capture_batch'),
        hasLength(1),
      );
    });

    test('photo batch rows and sync work roll back atomically', () async {
      await database.customStatement('''
        CREATE TRIGGER reject_second_capture_item
        BEFORE INSERT ON capture_items
        WHEN (SELECT count(*) FROM capture_items) >= 1
        BEGIN
          SELECT RAISE(ABORT, 'injected batch item failure');
        END
      ''');

      await expectLater(
        repositories.captureRepository.createPhotoBatch(
          const <String>['/tmp/first.jpg', '/tmp/second.jpg'],
        ),
        throwsA(isA<Exception>()),
      );

      expect(await database.select(database.captureBatches).get(), isEmpty);
      expect(await database.select(database.captureItems).get(), isEmpty);
      expect(await database.select(database.syncOperations).get(), isEmpty);
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
      expect(
        syncOperations
            .singleWhere((operation) => operation.entity == 'capture_item')
            .entityId,
        id,
      );
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

    test('sync repository uploads photos before marking batch ready', () async {
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
      expect(apiClient.classifiedRemoteMediaRefs, isEmpty);
      expect(apiClient.readyBatchIds, hasLength(1));
      expect(feedItems.single.remoteMediaRef, startsWith('remote://'));
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

    test('photo batch preserves ordering and caps intake at nine', () async {
      final List<String> refs =
          List<String>.generate(11, (int index) => '/tmp/photo_$index.jpg');

      final CaptureBatch? batch =
          await repositories.captureRepository.createPhotoBatch(refs);

      expect(batch, isNotNull);
      expect(batch!.items, hasLength(9));
      expect(
        batch.items.map((CaptureItem item) => item.ordinal),
        orderedEquals(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8]),
      );
      expect(
        batch.items.map((CaptureItem item) => item.localMediaRef),
        orderedEquals(refs.take(9)),
      );
    });

    test('offline batch remains pending for restart retry', () async {
      repositories = AppRepositories(
        database: database,
        apiClient: _OfflineApiClient(),
      );
      await repositories.captureRepository.createPhotoBatch(
        const <String>['/tmp/offline.jpg'],
      );

      await repositories.syncRepository.processPendingCaptures();
      final CaptureBatch batch =
          (await repositories.captureRepository.listBatches()).single;

      expect(batch.status, CaptureBatchStatus.pendingUpload);
      expect(batch.isWaitingForConnection, isTrue);
      expect(batch.items.single.status, CaptureItemStatus.pendingUpload);
      expect(batch.items.single.remoteMediaRef, isNull);
    });

    test('network change retries an offline batch and clears its marker',
        () async {
      final _HangingReconnectApiClient apiClient = _HangingReconnectApiClient();
      final _TestNetworkStatusMonitor networkStatusMonitor =
          _TestNetworkStatusMonitor();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
        captureControlRequestTimeout: const Duration(milliseconds: 20),
      );
      final MyMenuState state = MyMenuState(
        repositories: repositories,
        networkStatusMonitor: networkStatusMonitor,
      );
      addTearDown(state.dispose);
      addTearDown(networkStatusMonitor.close);

      final CaptureBatch? created = await state.addPhotoCaptures(
        const <String>['/tmp/zero.jpg', '/tmp/one.jpg'],
      );
      expect(created, isNotNull);
      final CaptureBatch createdBatch = created!;
      await _waitFor(
        () => state.captureBatches.any(
          (CaptureBatch batch) =>
              batch.id == createdBatch.id && batch.isWaitingForConnection,
        ),
      );

      apiClient.isOnline = true;
      networkStatusMonitor.emit();
      await _waitFor(
        () => state.captureBatches.any(
          (CaptureBatch batch) =>
              batch.id == createdBatch.id &&
              batch.status == CaptureBatchStatus.readyForAi,
        ),
      );

      final CaptureBatch synced = state.captureBatches.firstWhere(
        (CaptureBatch batch) => batch.id == createdBatch.id,
      );
      expect(synced.isWaitingForConnection, isFalse);
      expect(apiClient.remoteBatchIds, <String>{createdBatch.id});
      expect(
        apiClient.uploadedCaptureIds,
        orderedEquals(
          createdBatch.items.map((CaptureItem item) => item.id),
        ),
      );
    });

    test('reconnect creates one remote batch and uploads each item once',
        () async {
      final _ReconnectApiClient apiClient = _ReconnectApiClient();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
      );
      final CaptureBatch batch =
          (await repositories.captureRepository.createPhotoBatch(
        const <String>['/tmp/zero.jpg', '/tmp/one.jpg', '/tmp/two.jpg'],
      ))!;

      await repositories.syncRepository.processPendingCaptures();
      expect(
        (await repositories.captureRepository.listBatches()).single.status,
        CaptureBatchStatus.pendingUpload,
      );
      expect(apiClient.remoteBatchIds, isEmpty);
      expect(apiClient.uploadedCaptureIds, isEmpty);

      apiClient.isOnline = true;
      await repositories.syncRepository.processPendingCaptures();
      await repositories.syncRepository.processPendingCaptures();
      final CaptureBatch synced =
          (await repositories.captureRepository.listBatches()).single;

      expect(apiClient.remoteBatchIds, <String>{batch.id});
      expect(
        apiClient.uploadedCaptureIds,
        orderedEquals(batch.items.map((CaptureItem item) => item.id)),
      );
      expect(apiClient.uploadedCaptureIds.toSet(), hasLength(3));
      expect(synced.status, CaptureBatchStatus.readyForAi);
    });

    test('partial retry uploads only the failed item', () async {
      final _PartialFailureApiClient apiClient = _PartialFailureApiClient();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
      );
      final CaptureBatch batch =
          (await repositories.captureRepository.createPhotoBatch(
        const <String>['/tmp/zero.jpg', '/tmp/one.jpg', '/tmp/two.jpg'],
      ))!;

      await repositories.syncRepository.processPendingCaptures();
      var refreshed =
          (await repositories.captureRepository.listBatches()).single;

      expect(
        refreshed.items.map((CaptureItem item) => item.status),
        orderedEquals(<CaptureItemStatus>[
          CaptureItemStatus.uploaded,
          CaptureItemStatus.failed,
          CaptureItemStatus.uploaded,
        ]),
      );
      expect(refreshed.status, CaptureBatchStatus.uploading);
      expect(apiClient.uploadedOrdinals, <int>[0, 1, 2]);
      expect(apiClient.readyBatchIds, isEmpty);

      await repositories.syncRepository.processPendingCaptures();
      expect(
        apiClient.uploadedOrdinals,
        <int>[0, 1, 2],
        reason: 'A failed item must wait for explicit retry intent.',
      );

      await repositories.captureRepository.retryBatch(batch.id);
      await repositories.syncRepository.processPendingCaptures();
      refreshed = (await repositories.captureRepository.listBatches()).single;

      expect(apiClient.uploadedOrdinals, <int>[0, 1, 2, 1]);
      expect(
        refreshed.items.every(
          (CaptureItem item) => item.status == CaptureItemStatus.uploaded,
        ),
        isTrue,
      );
      expect(refreshed.status, CaptureBatchStatus.readyForAi);
      expect(apiClient.readyBatchIds, <String>[batch.id]);
    });

    test('batch rows and durable files rehydrate after database restart',
        () async {
      final Directory temp = await Directory.systemTemp.createTemp(
        'mymenu_capture_restart_',
      );
      addTearDown(() => temp.delete(recursive: true));
      final File first =
          await File('${temp.path}/first.jpg').writeAsString('1');
      final File second =
          await File('${temp.path}/second.jpg').writeAsString('2');
      final File databaseFile = File('${temp.path}/mymenu.sqlite');

      final AppDatabase firstDatabase =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      final AppRepositories firstRepositories = AppRepositories(
        database: firstDatabase,
        apiClient: _OfflineApiClient(),
      );
      await firstRepositories.captureRepository.createPhotoBatch(
        <String>[first.path, second.path],
      );
      await firstDatabase.close();

      final AppDatabase restartedDatabase =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      addTearDown(restartedDatabase.close);
      final AppRepositories restartedRepositories = AppRepositories(
        database: restartedDatabase,
        apiClient: _OfflineApiClient(),
      );
      final CaptureBatch rehydrated =
          (await restartedRepositories.captureRepository.listBatches()).single;

      expect(rehydrated.items, hasLength(2));
      expect(
        rehydrated.items.map((CaptureItem item) => item.ordinal),
        orderedEquals(<int>[0, 1]),
      );
      expect(File(rehydrated.items[0].localMediaRef!).existsSync(), isTrue);
      expect(File(rehydrated.items[1].localMediaRef!).existsSync(), isTrue);
      expect(rehydrated.status, CaptureBatchStatus.pendingUpload);
    });

    test('schema 2 photo capture migrates to a one-item batch', () async {
      final Directory temp = await Directory.systemTemp.createTemp(
        'mymenu_capture_migration_',
      );
      addTearDown(() => temp.delete(recursive: true));
      final File databaseFile = File('${temp.path}/mymenu.sqlite');
      sqlite.sqlite3.open(databaseFile.path)
        ..execute('''
          CREATE TABLE capture_items (
            id TEXT NOT NULL PRIMARY KEY,
            kind TEXT NOT NULL,
            status TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            local_media_ref TEXT,
            remote_media_ref TEXT,
            idea_text TEXT,
            applied_dish_id TEXT
          )
        ''')
        ..execute(
          '''
            INSERT INTO capture_items (
              id,
              kind,
              status,
              created_at,
              local_media_ref,
              remote_media_ref
            ) VALUES (?, ?, ?, ?, ?, ?)
          ''',
          <Object?>[
            'legacy_capture',
            'photo',
            'pendingUpload',
            1784995200,
            '/documents/captures/legacy.jpg',
            'menu-media:users/example/legacy.jpg',
          ],
        )
        ..execute('PRAGMA user_version = 2')
        ..close();

      final AppDatabase migrated =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      addTearDown(migrated.close);
      final CaptureBatch batch =
          (await CaptureRepository(migrated).listBatches()).single;

      expect(batch.id, 'legacy_capture');
      expect(batch.status, CaptureBatchStatus.pendingUpload);
      expect(batch.items, hasLength(1));
      expect(batch.items.single.batchId, 'legacy_capture');
      expect(batch.items.single.ordinal, 0);
      expect(
        batch.items.single.localMediaRef,
        '/documents/captures/legacy.jpg',
      );
      expect(
        batch.items.single.remoteMediaRef,
        'menu-media:users/example/legacy.jpg',
      );
    });

    test('fake API upload and idea classification start return expected DTOs',
        () async {
      final FakeMyMenuApiClient apiClient = FakeMyMenuApiClient();

      final String mediaRef = await apiClient.uploadCaptureMedia(
        captureId: 'capture_1',
        batchId: 'batch_1',
        ordinal: 0,
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

class _RecordingApiClient extends MyMenuApiClient {
  final List<String> uploadedCaptureIds = <String>[];
  final List<String> classifiedCaptureIds = <String>[];
  final List<String?> classifiedRemoteMediaRefs = <String?>[];
  final List<String> createdNoteIds = <String>[];
  final List<String> readyBatchIds = <String>[];

  @override
  Future<void> upsertCaptureBatch({
    required String batchId,
    required int itemCount,
    required DateTime createdAt,
  }) async {}

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
  }) async {
    uploadedCaptureIds.add(captureId);
    return 'remote://$captureId';
  }

  @override
  Future<void> markCaptureBatchReady({required String batchId}) async {
    readyBatchIds.add(batchId);
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
  Future<void> createDishNote({
    required String noteId,
    required String dishId,
    required String body,
    required int position,
  }) async {
    createdNoteIds.add(noteId);
  }

  @override
  Future<void> updateDishNote({
    required String noteId,
    required String body,
    required int? position,
  }) async {}

  @override
  Future<void> deleteDishNote({required String noteId}) async {}

  @override
  Future<void> updateDish({
    required String clientMutationId,
    required String dishId,
    required Map<String, Object?> patch,
  }) async {}

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

class _OfflineApiClient extends FakeMyMenuApiClient {
  @override
  Future<void> upsertCaptureBatch({
    required String batchId,
    required int itemCount,
    required DateTime createdAt,
  }) {
    throw const SocketException('No network');
  }
}

class _ReconnectApiClient extends FakeMyMenuApiClient {
  bool isOnline = false;
  final Set<String> remoteBatchIds = <String>{};
  final List<String> uploadedCaptureIds = <String>[];

  @override
  Future<void> upsertCaptureBatch({
    required String batchId,
    required int itemCount,
    required DateTime createdAt,
  }) async {
    if (!isOnline) {
      throw const SocketException('No network');
    }
    remoteBatchIds.add(batchId);
  }

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
  }) async {
    uploadedCaptureIds.add(captureId);
    return 'remote://$captureId';
  }
}

class _HangingReconnectApiClient extends _ReconnectApiClient {
  @override
  Future<void> upsertCaptureBatch({
    required String batchId,
    required int itemCount,
    required DateTime createdAt,
  }) {
    if (!isOnline) {
      return Completer<void>().future;
    }
    return super.upsertCaptureBatch(
      batchId: batchId,
      itemCount: itemCount,
      createdAt: createdAt,
    );
  }
}

class _TestNetworkStatusMonitor implements NetworkStatusMonitor {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _controller.stream;

  void emit() => _controller.add(null);

  Future<void> close() => _controller.close();
}

Future<void> _waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Condition was not met within $timeout.');
}

class _PartialFailureApiClient extends FakeMyMenuApiClient {
  final List<int> uploadedOrdinals = <int>[];
  final List<String> readyBatchIds = <String>[];
  bool _failedOnce = false;

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
  }) async {
    uploadedOrdinals.add(ordinal);
    if (ordinal == 1 && !_failedOnce) {
      _failedOnce = true;
      throw StateError('Injected item upload failure');
    }
    return 'remote://$captureId';
  }

  @override
  Future<void> markCaptureBatchReady({required String batchId}) async {
    readyBatchIds.add(batchId);
  }
}

class _ThrowingApiClient extends MyMenuApiClient {
  @override
  Future<void> upsertCaptureBatch({
    required String batchId,
    required int itemCount,
    required DateTime createdAt,
  }) async {}

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
  }) {
    throw StateError('Remote sync unavailable.');
  }

  @override
  Future<void> markCaptureBatchReady({required String batchId}) async {}

  @override
  Future<ApiClassificationStart> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  }) {
    throw StateError('Remote sync unavailable.');
  }

  @override
  Future<void> createDishNote({
    required String noteId,
    required String dishId,
    required String body,
    required int position,
  }) {
    throw StateError('Remote sync unavailable.');
  }

  @override
  Future<void> updateDishNote({
    required String noteId,
    required String body,
    required int? position,
  }) {
    throw StateError('Remote sync unavailable.');
  }

  @override
  Future<void> deleteDishNote({required String noteId}) {
    throw StateError('Remote sync unavailable.');
  }

  @override
  Future<void> updateDish({
    required String clientMutationId,
    required String dishId,
    required Map<String, Object?> patch,
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

class _SyncResultApiClient extends MyMenuApiClient {
  @override
  Future<void> upsertCaptureBatch({
    required String batchId,
    required int itemCount,
    required DateTime createdAt,
  }) {
    throw StateError('Unexpected batch upsert.');
  }

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
  }) {
    throw StateError('Unexpected upload.');
  }

  @override
  Future<void> markCaptureBatchReady({required String batchId}) {
    throw StateError('Unexpected ready transition.');
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
  Future<void> createDishNote({
    required String noteId,
    required String dishId,
    required String body,
    required int position,
  }) {
    throw StateError('Unexpected note create.');
  }

  @override
  Future<void> updateDishNote({
    required String noteId,
    required String body,
    required int? position,
  }) {
    throw StateError('Unexpected note update.');
  }

  @override
  Future<void> deleteDishNote({required String noteId}) {
    throw StateError('Unexpected note delete.');
  }

  @override
  Future<void> updateDish({
    required String clientMutationId,
    required String dishId,
    required Map<String, Object?> patch,
  }) {
    throw StateError('Unexpected dish update.');
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
