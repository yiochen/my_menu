import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/covers/cover_repository.dart';
import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_outbox_repository.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/domain/sync/repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test(
    'accepted Add Idea creates a Dish and a separate context-grounded Cover request',
    () async {
      final AppDatabase database =
          AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
      await repositories.processingConsentRepository.acceptCurrentNotice();
      final MyMenuState state = MyMenuState(repositories: repositories);
      addTearDown(state.dispose);
      await state.initialized;

      await state.addIdea(
        'charred corn ramen',
        note: 'Serve with lime and scallions.',
      );

      final dishes = await repositories.dishRepository.listDishes();
      final requests =
          await repositories.processingOutboxRepository.listRequests();
      final captures = await repositories.captureRepository.listBatches();

      expect(dishes, hasLength(1));
      expect(dishes.single.title, 'Charred Corn Ramen');
      expect(dishes.single.notes.single.body, 'Serve with lime and scallions.');
      expect(captures, isEmpty);
      expect(requests, hasLength(1));
      expect(requests.single.kind, ProcessingRequestKind.coverGeneration);
      expect(requests.single.subjectId, dishes.single.id);
      final Map<String, Object?> payload =
          Map<String, Object?>.from(requests.single.payload);
      final List<Object?> notes = payload.remove('notes')! as List<Object?>;
      final Map<String, Object?> note =
          Map<String, Object?>.from(notes.single! as Map<String, Object?>);
      expect(note['body'], 'Serve with lime and scallions.');
      expect(note['position'], 0);
      expect(DateTime.tryParse(note['createdAt']! as String) != null, isTrue);
      expect(DateTime.tryParse(note['updatedAt']! as String) != null, isTrue);
      expect(payload, <String, Object?>{
        'dishTitle': 'Charred Corn Ramen',
        'sourceIds': <String>[],
        'treatment': <String, Object?>{
          'look': 'natural_polish',
          'view': 'auto',
          'finish': 'menu_ready',
        },
        'origin': 'automatic',
        'automaticCaptureBatchId': null,
        'automaticCaptureOrdinal': null,
        'contractVersion': 'cover-generation-v1',
        'coverSnapshot': <String, Object?>{
          'image': '',
          'preview': null,
          'thumbnail': null,
          'placeholder': null,
        },
      });
      expect(
        requests.single.deliveryState,
        ProcessingDeliveryState.pendingUpload,
      );
    },
  );

  test('a delivered manual Cover waits as one durable proposal', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.dishRepository.createDish(_dish('dish-manual'));

    await repositories.coverRepository.storeDeliveredCover(
      id: 'cover-1',
      dishId: 'dish-manual',
      localPath: '/tmp/generated-cover.jpg',
      origin: CoverOrigin.manual,
      grounding: CoverGrounding.context,
      selectedSourceIds: const <String>[],
      treatment: CoverTreatment.defaults,
      proposalId: 'proposal-1',
      createdAt: DateTime.utc(2026, 8, 4, 12),
    );

    final Dish unchanged =
        (await repositories.dishRepository.listDishes()).single;
    final List<GeneratedCover> history =
        await repositories.coverRepository.listForDish('dish-manual');

    expect(unchanged.heroImageUrl, '/tmp/current.jpg');
    expect(history, hasLength(1));
    expect(history.single.state, GeneratedCoverState.proposed);
    expect(history.single.localPath, '/tmp/generated-cover.jpg');
    expect(history.single.proposalId, 'proposal-1');
  });

  test('accepting a Proposed Cover changes the Cover and retains history',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.dishRepository.createDish(_dish('dish-accept'));
    await repositories.coverRepository.storeDeliveredCover(
      id: 'cover-accepted',
      dishId: 'dish-accept',
      localPath: '/tmp/accepted.jpg',
      origin: CoverOrigin.manual,
      grounding: CoverGrounding.context,
      selectedSourceIds: const <String>[],
      treatment: CoverTreatment.defaults,
      proposalId: 'proposal-accepted',
      createdAt: DateTime.utc(2026, 8, 4, 13),
    );

    await repositories.coverRepository.acceptProposal('cover-accepted');

    final Dish changed =
        (await repositories.dishRepository.listDishes()).single;
    final GeneratedCover retained =
        (await repositories.coverRepository.listForDish('dish-accept')).single;
    expect(changed.heroImageUrl, '/tmp/accepted.jpg');
    expect(retained.state, GeneratedCoverState.current);
  });

  test('an automatic Cover is adopted, undoable, and retained after Undo',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.dishRepository.createDish(_dish('dish-auto'));

    await repositories.coverRepository.storeDeliveredCover(
      id: 'cover-auto',
      dishId: 'dish-auto',
      localPath: '/tmp/automatic.jpg',
      origin: CoverOrigin.automatic,
      grounding: CoverGrounding.context,
      selectedSourceIds: const <String>[],
      treatment: CoverTreatment.defaults,
      proposalId: 'proposal-auto',
      createdAt: DateTime.utc(2026, 8, 4, 14),
    );

    Dish dish = (await repositories.dishRepository.listDishes()).single;
    GeneratedCover cover =
        (await repositories.coverRepository.listForDish('dish-auto')).single;
    expect(dish.heroImageUrl, '/tmp/automatic.jpg');
    expect(cover.state, GeneratedCoverState.current);
    expect(cover.automaticUndoAvailable, isTrue);

    await repositories.coverRepository.undoAutomatic('cover-auto');

    dish = (await repositories.dishRepository.listDishes()).single;
    cover =
        (await repositories.coverRepository.listForDish('dish-auto')).single;
    expect(dish.heroImageUrl, '/tmp/current.jpg');
    expect(cover.state, GeneratedCoverState.history);
    expect(cover.automaticUndoAvailable, isFalse);
  });

  test('manual Improve Cover snapshots selected Sources, Notes, and treatment',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.dishRepository.createDish(
      _dish('dish-request').copyWith(
        notes: const <DishNote>[
          DishNote(
            id: 'note-request',
            dishId: 'dish-request',
            body: 'Add charred corn.',
            position: 0,
          ),
        ],
        sourcePhotos: const <SourcePhoto>[
          SourcePhoto(
            id: 'source-request',
            url: '/tmp/source.jpg',
            capturedLabel: 'Today',
          ),
        ],
      ),
    );
    final MyMenuState state = MyMenuState(repositories: repositories);
    addTearDown(state.dispose);
    await state.initialized;
    final String selectedSourceId = state.dishes.single.sourcePhotos.single.id!;
    const CoverTreatment treatment = CoverTreatment(
      look: CoverLook.warmCozy,
      view: CoverView.angled,
      finish: CoverFinish.editorial,
    );

    await state.startManualCoverGeneration(
      dishId: 'dish-request',
      selectedSourceIds: <String>[selectedSourceId],
      treatment: treatment,
    );

    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(request.kind, ProcessingRequestKind.coverGeneration);
    expect(request.payload['origin'], 'manual');
    expect(request.payload['sourceIds'], <String>[selectedSourceId]);
    final List<Object?> notes = request.payload['notes']! as List<Object?>;
    final Map<String, Object?> note =
        Map<String, Object?>.from(notes.single! as Map<String, Object?>);
    expect(note['body'], 'Add charred corn.');
    expect(note['position'], 0);
    expect(DateTime.tryParse(note['createdAt']! as String) != null, isTrue);
    expect(DateTime.tryParse(note['updatedAt']! as String) != null, isTrue);
    expect(request.payload['treatment'], treatment.toJson());
  });

  test(
      'background processing durably adopts and acknowledges an automatic Cover',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final FakeMyMenuApiClient api = FakeMyMenuApiClient();
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: api,
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    final MyMenuState state = MyMenuState(repositories: repositories);
    addTearDown(state.dispose);
    await state.initialized;
    await state.addIdea('sesame udon');

    await repositories.syncRepository.processPendingCovers();

    final Dish dish = (await repositories.dishRepository.listDishes()).single;
    final GeneratedCover cover =
        (await repositories.coverRepository.listForDish(dish.id)).single;
    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(cover.origin, CoverOrigin.automatic);
    expect(cover.state, GeneratedCoverState.current);
    expect(dish.heroImageUrl, cover.localPath);
    expect(request.deliveryState, ProcessingDeliveryState.acknowledged);
    expect(request.adoptionState, ProcessingAdoptionState.adopted);
    expect(api.hasPayloadForProcessingJob(request.serverJobId!), isFalse);
  });

  test('a newly grouped photo Dish starts a separate automatic Cover job',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_cover_grouping_');
    addTearDown(() => temp.delete(recursive: true));
    final File photo = File('${temp.path}/ramen.jpg')
      ..writeAsBytesSync(<int>[0xff, 0xd8, 0xff, 0xd9]);
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.captureRepository.createPhotoBatch(
      <CapturedMedia>[
        CapturedMedia(
          path: photo.path,
          capturedAt: DateTime.utc(2026, 8, 4, 15),
          capturedLocalDate: '2026-08-04',
          dateSource: CaptureDateSource.camera,
        ),
      ],
    );

    await repositories.syncRepository.processPendingCaptures();

    final Dish dish = (await repositories.dishRepository.listDishes()).single;
    final List<ProcessingOutboxRequest> requests =
        await repositories.processingOutboxRepository.listRequests();
    final ProcessingOutboxRequest coverRequest = requests.singleWhere(
      (ProcessingOutboxRequest request) =>
          request.kind == ProcessingRequestKind.coverGeneration,
    );
    expect(coverRequest.subjectId, dish.id);
    expect(coverRequest.payload['origin'], 'automatic');
    expect(coverRequest.payload['sourceIds'], hasLength(1));
    expect(
      requests
          .singleWhere(
            (ProcessingOutboxRequest request) =>
                request.kind == ProcessingRequestKind.captureGrouping,
          )
          .adoptionState,
      ProcessingAdoptionState.adopted,
    );
  });

  test('automatic Cover order uses the Dish earliest Source position',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_cover_order_');
    addTearDown(() => temp.delete(recursive: true));
    final File sourceFile = File('${temp.path}/source.jpg')
      ..writeAsBytesSync(<int>[1]);
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    final DateTime capturedAt = DateTime.utc(2026, 8, 4, 15);
    await database.into(database.captureBatches).insert(
          CaptureBatchesCompanion.insert(
            id: 'batch-order',
            status: 'completed',
            createdAt: capturedAt,
            updatedAt: capturedAt,
          ),
        );
    for (final (String id, int ordinal) in <(String, int)>[
      ('capture-first', 0),
      ('capture-selected', 4),
    ]) {
      await database.into(database.captureItems).insert(
            CaptureItemsCompanion.insert(
              id: id,
              batchId: const Value<String?>('batch-order'),
              ordinal: Value<int>(ordinal),
              kind: 'photo',
              status: 'organized',
              createdAt: capturedAt,
            ),
          );
    }
    await repositories.dishRepository.createDish(
      _dish('dish-source-order').copyWith(
        sourcePhotos: <SourcePhoto>[
          SourcePhoto(
            id: 'source-first',
            captureId: 'capture-first',
            url: sourceFile.path,
            previewUrl: sourceFile.path,
            capturedLabel: 'Today',
          ),
          SourcePhoto(
            id: 'source-selected',
            captureId: 'capture-selected',
            url: sourceFile.path,
            previewUrl: sourceFile.path,
            capturedLabel: 'Today',
          ),
        ],
      ),
    );

    await repositories.coverRepository.enqueueAutomaticCover(
      dishId: 'dish-source-order',
      sourceIds: const <String>['source-selected'],
      now: capturedAt,
    );

    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(request.payload['sourceIds'], <String>['source-selected']);
    expect(request.payload['automaticCaptureBatchId'], 'batch-order');
    expect(request.payload['automaticCaptureOrdinal'], 0);
  });

  test('manual generation supersedes one in-flight automatic request',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.dishRepository.createDish(_dish('dish-supersede'));
    final MyMenuState state = MyMenuState(repositories: repositories);
    addTearDown(state.dispose);
    await state.initialized;
    expect(await state.enqueueAutomaticCoverForDish('dish-supersede'), isTrue);

    expect(
      await state.startManualCoverGeneration(
        dishId: 'dish-supersede',
        selectedSourceIds: const <String>[],
        treatment: const CoverTreatment(
          look: CoverLook.brightFresh,
          view: CoverView.overhead,
          finish: CoverFinish.lightTouch,
        ),
      ),
      isTrue,
    );

    await Future<void>.delayed(Duration.zero);
    final List<ProcessingOutboxRequest> requests =
        await repositories.processingOutboxRepository.listRequests();
    expect(requests, hasLength(1));
    expect(requests.single.payload['origin'], CoverOrigin.manual.name);
    expect(
      requests.single.payload['treatment'],
      const CoverTreatment(
        look: CoverLook.brightFresh,
        view: CoverView.overhead,
        finish: CoverFinish.lightTouch,
      ).toJson(),
    );
    await state.refreshFromServer();
  });

  test('replaying the same automatic delivery preserves its original Undo',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.dishRepository.createDish(_dish('dish-idempotent'));

    for (final String path in <String>['/tmp/first.jpg', '/tmp/replayed.jpg']) {
      await repositories.coverRepository.storeDeliveredCover(
        id: 'cover-idempotent',
        dishId: 'dish-idempotent',
        localPath: path,
        origin: CoverOrigin.automatic,
        grounding: CoverGrounding.context,
        selectedSourceIds: const <String>[],
        treatment: CoverTreatment.defaults,
        proposalId: 'proposal-idempotent',
        createdAt: DateTime.utc(2026, 8, 4, 16),
      );
    }

    await repositories.coverRepository.undoAutomatic('cover-idempotent');
    final Dish dish = (await repositories.dishRepository.listDishes()).single;
    expect(dish.heroImageUrl, '/tmp/current.jpg');
    expect(
      await repositories.coverRepository.listForDish('dish-idempotent'),
      hasLength(1),
    );
  });

  test('automatic generation skips a Dish whose Source is unavailable',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.dishRepository.createDish(
      _dish('dish-unusable').copyWith(
        sourcePhotos: const <SourcePhoto>[
          SourcePhoto(
            id: 'missing-source',
            url: '/path/that/does/not/exist.jpg',
            capturedLabel: 'Today',
          ),
        ],
      ),
    );

    expect(
      await repositories.coverRepository.enqueueAutomaticCover(
        dishId: 'dish-unusable',
        sourceIds: const <String>['missing-source'],
        now: DateTime.utc(2026, 8, 4, 17),
      ),
      isFalse,
    );
    expect(
      await repositories.processingOutboxRepository.listRequests(),
      isEmpty,
    );
  });

  test('a source-less Dish gets one automatic opportunity with first Sources',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_first_sources_');
    addTearDown(() => temp.delete(recursive: true));
    final File photo = File('${temp.path}/first.jpg')
      ..writeAsBytesSync(<int>[0xff, 0xd8, 0xff, 0xd9]);
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.dishRepository.createDish(_dish('dish-first-source'));
    final MyMenuState state = MyMenuState(repositories: repositories);
    addTearDown(state.dispose);
    await state.initialized;

    await state.addPhotoCaptures(
      <Object>[photo.path],
      targetDishId: 'dish-first-source',
    );

    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(request.kind, ProcessingRequestKind.coverGeneration);
    expect(request.subjectId, 'dish-first-source');
    expect(request.payload['sourceIds'], hasLength(1));
  });

  test('deleting generated history also deletes its downloaded result payload',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.dishRepository.createDish(_dish('dish-delete-cover'));
    await repositories.processingOutboxRepository.enqueueCoverGeneration(
      requestId: 'cover-delete',
      dishId: 'dish-delete-cover',
      payload: const <String, Object?>{'origin': 'manual'},
      now: DateTime.utc(2026, 8, 4, 18),
    );
    await repositories.processingOutboxRepository.storeResult(
      requestId: 'cover-delete',
      result: const <String, Object?>{'imageBase64': 'sensitive-output'},
      schemaVersion: 'cover-generation-result-v1',
    );
    await repositories.coverRepository.storeDeliveredCover(
      id: 'cover-delete',
      dishId: 'dish-delete-cover',
      localPath: '/tmp/deleted-cover.jpg',
      origin: CoverOrigin.manual,
      grounding: CoverGrounding.context,
      selectedSourceIds: const <String>[],
      treatment: CoverTreatment.defaults,
      proposalId: 'proposal-delete',
      createdAt: DateTime.utc(2026, 8, 4, 18),
    );

    await repositories.coverRepository.deleteGenerated('cover-delete');

    expect(
      await repositories.coverRepository.listForDish('dish-delete-cover'),
      isEmpty,
    );
    expect(
      await repositories.processingOutboxRepository.listRequests(),
      isEmpty,
    );
  });

  test('consent withdrawal clears a queued manual restart', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.dishRepository.createDish(_dish('dish-no-resurrect'));
    final MyMenuState state = MyMenuState(repositories: repositories);
    addTearDown(state.dispose);
    await state.initialized;
    await state.enqueueAutomaticCoverForDish('dish-no-resurrect');
    await state.startManualCoverGeneration(
      dishId: 'dish-no-resurrect',
      selectedSourceIds: const <String>[],
      treatment: CoverTreatment.defaults,
    );

    await state.disableAiProcessing();

    final ProcessingOutboxRequest canceled =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(canceled.deliveryState, ProcessingDeliveryState.canceled);
    expect(canceled.payload, isNot(contains('restartAfterCancel')));
    await repositories.syncRepository.processPendingCovers();
    expect(
      await repositories.processingOutboxRepository.listRequests(),
      isEmpty,
    );
  });

  test('an immediate correction Undo replaces a queued restart payload',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_cover_restart_');
    addTearDown(() => temp.delete(recursive: true));
    final File first = File('${temp.path}/first.jpg')
      ..writeAsBytesSync(<int>[1]);
    final File second = File('${temp.path}/second.jpg')
      ..writeAsBytesSync(<int>[2]);
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.dishRepository.createDish(
      _dish('dish-restored').copyWith(
        sourcePhotos: <SourcePhoto>[
          SourcePhoto(id: 'source-a', url: first.path, capturedLabel: 'Today'),
          SourcePhoto(id: 'source-b', url: second.path, capturedLabel: 'Today'),
        ],
      ),
    );
    await repositories.dishRepository.createDish(_dish('dish-split'));
    await repositories.coverRepository.enqueueAutomaticCover(
      dishId: 'dish-restored',
      sourceIds: const <String>['source-a', 'source-b'],
      now: DateTime.utc(2026, 8, 4, 19),
    );
    await (database.update(database.sourcePhotos)
          ..where((SourcePhotos table) => table.id.equals('source-b')))
        .write(
      const SourcePhotosCompanion(dishId: Value<String>('dish-split')),
    );
    await repositories.coverRepository.restartAutomaticCoverIfPending(
      dishId: 'dish-restored',
      now: DateTime.utc(2026, 8, 4, 19, 1),
    );
    await (database.update(database.sourcePhotos)
          ..where((SourcePhotos table) => table.id.equals('source-b')))
        .write(
      const SourcePhotosCompanion(dishId: Value<String>('dish-restored')),
    );

    expect(
      await repositories.coverRepository.restartAutomaticCoverIfPending(
        dishId: 'dish-restored',
        now: DateTime.utc(2026, 8, 4, 19, 2),
      ),
      isTrue,
    );

    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(request.deliveryState, ProcessingDeliveryState.canceled);
    expect(request.payload['restartAfterCancel'], isTrue);
    expect(
      request.payload['sourceIds'],
      containsAll(<String>['source-a', 'source-b']),
    );
  });
}

Dish _dish(String id) {
  return Dish(
    id: id,
    title: 'Miso Ramen',
    description: '',
    heroImageUrl: '/tmp/current.jpg',
    category: 'Ideas',
    prepMinutes: 0,
    difficulty: 'Draft',
    madeCount: 0,
    lastMadeLabel: 'Not cooked yet',
    ingredients: const <String>[],
    recipeSteps: const <String>[],
    notes: const <DishNote>[],
    sourcePhotos: const <SourcePhoto>[],
  );
}
