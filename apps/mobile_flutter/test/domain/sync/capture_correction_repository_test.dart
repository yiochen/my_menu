import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/domain/capture/capture_correction.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/sync/repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('capture grouping corrections', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      await _seedGrouping(database);
    });

    tearDown(() => database.close());

    test('optimistically moves multiple photos without duplicating sources',
        () async {
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );

      final CaptureCorrection? correction =
          await repositories.captureCorrectionRepository.moveCaptures(
        batchId: 'batch_1',
        captureIds: const <String>['capture_a', 'capture_b'],
        targetDishId: 'dish_b',
      );

      expect(correction?.status, CaptureCorrectionStatus.synced);
      expect(await _assignedDish(database, 'capture_a'), 'dish_b');
      expect(await _assignedDish(database, 'capture_b'), 'dish_b');
      expect(await _sourceCount(database, 'dish_a'), 0);
      expect(await _sourceCount(database, 'dish_b'), 3);
      expect(await _madeCount(database, 'dish_a'), 0);
      expect(await _madeCount(database, 'dish_b'), 1);
      expect(
        await _pendingCorrectionOperations(database),
        isEmpty,
      );

      await repositories.syncRepository.processPendingOperations();

      expect(
        (await repositories.captureCorrectionRepository.listCorrections())
            .single
            .status,
        CaptureCorrectionStatus.synced,
      );
      expect(await _pendingCorrectionOperations(database), isEmpty);
    });

    test('split creates one local dish and undo restores every association',
        () async {
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );

      final CaptureCorrection correction =
          (await repositories.captureCorrectionRepository.splitCaptures(
        batchId: 'batch_1',
        captureIds: const <String>['capture_a', 'capture_b'],
        title: 'Weekend Salmon',
      ))!;
      final String createdDishId = correction.createdDishId!;

      expect(await _dishCount(database, createdDishId), 1);
      expect(await _sourceCount(database, createdDishId), 2);
      expect(await _madeCount(database, createdDishId), 1);
      expect(await _assignedDish(database, 'capture_a'), createdDishId);
      expect(await _assignedDish(database, 'capture_b'), createdDishId);

      final CaptureCorrection? undone =
          await repositories.captureCorrectionRepository.undoLatest('batch_1');

      expect(undone?.status, CaptureCorrectionStatus.undone);
      expect(await _dishCount(database, createdDishId), 0);
      expect(await _assignedDish(database, 'capture_a'), 'dish_a');
      expect(await _assignedDish(database, 'capture_b'), 'dish_a');
      expect(await _sourceCount(database, 'dish_a'), 2);
      expect(await _madeCount(database, 'dish_a'), 1);
      expect(await _pendingCorrectionOperations(database), isEmpty);
    });

    test('offline correction survives repository restart as a local decision',
        () async {
      final AppRepositories firstRepositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
      final CaptureCorrection correction =
          (await firstRepositories.captureCorrectionRepository.moveCaptures(
        batchId: 'batch_1',
        captureIds: const <String>['capture_a'],
        targetDishId: 'dish_b',
      ))!;

      final AppRepositories restartedRepositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
      final CaptureCorrection rehydrated = (await restartedRepositories
              .captureCorrectionRepository
              .listCorrections())
          .single;

      expect(rehydrated.id, correction.id);
      expect(rehydrated.status, CaptureCorrectionStatus.synced);
      expect(await _assignedDish(database, 'capture_a'), 'dish_b');
      expect(await _pendingCorrectionOperations(database), isEmpty);
    });

    test('server processing cannot reject a device-local correction', () async {
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
      await repositories.captureCorrectionRepository.moveCaptures(
        batchId: 'batch_1',
        captureIds: const <String>['capture_a'],
        targetDishId: 'dish_b',
      );
      expect(await _assignedDish(database, 'capture_a'), 'dish_b');

      await repositories.syncRepository.processPendingOperations();

      final CaptureCorrection correction =
          (await repositories.captureCorrectionRepository.listCorrections())
              .single;
      expect(correction.status, CaptureCorrectionStatus.synced);
      expect(correction.error, isNull);
      expect(await _assignedDish(database, 'capture_a'), 'dish_b');
      expect(await _sourceCount(database, 'dish_a'), 1);
      expect(await _sourceCount(database, 'dish_b'), 2);
      expect(await _pendingCorrectionOperations(database), isEmpty);
    });

    test('photo-targeted undo does not revert a sibling correction', () async {
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
      await repositories.captureCorrectionRepository.moveCaptures(
        batchId: 'batch_1',
        captureIds: const <String>['capture_a'],
        targetDishId: 'dish_b',
      );
      await repositories.captureCorrectionRepository.moveCaptures(
        batchId: 'batch_1',
        captureIds: const <String>['capture_b'],
        targetDishId: 'dish_b',
      );

      await repositories.captureCorrectionRepository.undoLatest(
        'batch_1',
        captureId: 'capture_a',
      );

      expect(await _assignedDish(database, 'capture_a'), 'dish_a');
      expect(await _assignedDish(database, 'capture_b'), 'dish_b');
    });

    test('moving a duplicate media path updates only its capture source',
        () async {
      await (database.update(database.captureItems)
            ..where(
              (CaptureItems table) => table.id.isIn(
                const <String>['capture_a', 'capture_b'],
              ),
            ))
          .write(
        const CaptureItemsCompanion(
          localMediaRef: Value<String?>('fake://duplicate'),
          remoteMediaRef: Value<String?>('fake://duplicate'),
        ),
      );
      await (database.update(database.sourcePhotos)
            ..where(
              (SourcePhotos table) => table.id.isIn(
                const <String>['capture_a_source', 'capture_b_source'],
              ),
            ))
          .write(
        const SourcePhotosCompanion(url: Value<String>('fake://duplicate')),
      );
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );

      await repositories.captureCorrectionRepository.moveCaptures(
        batchId: 'batch_1',
        captureIds: const <String>['capture_a'],
        targetDishId: 'dish_b',
      );

      expect(await _sourceDish(database, 'capture_a_source'), 'dish_b');
      expect(await _sourceDish(database, 'capture_b_source'), 'dish_a');
    });

    test('targeted undo keeps an AI-created dish used by a sibling', () async {
      final DateTime now = DateTime.utc(2026, 7, 27, 12);
      await database.into(database.dishes).insert(
            DishesCompanion.insert(
              id: 'dish_ai',
              title: 'AI grouped dish',
              description: '',
              heroImageUrl: 'fake://capture_a',
              category: 'Captured',
              prepMinutes: 0,
              difficulty: 'Not set',
              madeCount: 1,
              lastMadeLabel: 'Today',
              ingredientsJson: '[]',
              recipeStepsJson: '[]',
              notesJson: '[]',
            ),
          );
      for (final String captureId in <String>['capture_a', 'capture_b']) {
        await (database.update(database.captureItems)
              ..where(
                (CaptureItems table) => table.id.equals(captureId),
              ))
            .write(
          const CaptureItemsCompanion(
            appliedDishId: Value<String?>('dish_ai'),
          ),
        );
        await (database.update(database.sourcePhotos)
              ..where(
                (SourcePhotos table) => table.id.equals('${captureId}_source'),
              ))
            .write(
          const SourcePhotosCompanion(dishId: Value<String>('dish_ai')),
        );
        await database.into(database.captureCorrections).insert(
              CaptureCorrectionsCompanion.insert(
                id: 'auto_$captureId',
                batchId: 'batch_1',
                actionType: CaptureCorrectionType.autoAssign.name,
                captureIdsJson: jsonEncode(<String>[captureId]),
                previousDishIdsJson: jsonEncode(<String, Object?>{
                  captureId: <String, Object?>{
                    'dishId': 'dish_a',
                    'status': 'applied',
                    'failureReason': null,
                  },
                }),
                targetDishId: 'dish_ai',
                createdDishId: const Value<String?>('dish_ai'),
                status: CaptureCorrectionStatus.synced.name,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );

      await repositories.captureCorrectionRepository.undoLatest(
        'batch_1',
        captureId: 'capture_a',
      );

      expect(await _dishCount(database, 'dish_ai'), 1);
      expect(await _assignedDish(database, 'capture_a'), 'dish_a');
      expect(await _assignedDish(database, 'capture_b'), 'dish_ai');
      expect(await _sourceDish(database, 'capture_b_source'), 'dish_ai');
    });

    test('bulk split and undo restore the whole user action', () async {
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );

      final List<CaptureCorrection> corrections = await repositories
          .captureCorrectionRepository
          .applyAssignments(const <String, String>{
        'capture_a': 'dish_b',
        'capture_c': 'dish_a',
      });
      expect(corrections, hasLength(2));
      expect(await _assignedDish(database, 'capture_a'), 'dish_b');
      expect(await _assignedDish(database, 'capture_c'), 'dish_a');

      await repositories.captureCorrectionRepository.undoCorrections(
        corrections.map((CaptureCorrection correction) => correction.id),
      );

      expect(await _assignedDish(database, 'capture_a'), 'dish_a');
      expect(await _assignedDish(database, 'capture_c'), 'dish_b');
    });

    test('manual assignment can restore an unclassified photo with undo',
        () async {
      final DateTime now = DateTime.utc(2026, 7, 27, 12, 3);
      await database.into(database.captureItems).insert(
            CaptureItemsCompanion.insert(
              id: 'capture_rejected',
              batchId: const Value<String?>('batch_1'),
              ordinal: const Value<int>(3),
              kind: 'photo',
              status: 'discarded',
              createdAt: now,
              localMediaRef: const Value<String?>('fake://capture_rejected'),
              remoteMediaRef: const Value<String?>('fake://capture_rejected'),
              failureReason:
                  const Value<String?>('No prepared dish was recognized.'),
            ),
          );
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );

      final CaptureCorrection correction =
          (await repositories.captureCorrectionRepository.assignCaptures(
        batchId: 'batch_1',
        captureIds: const <String>['capture_rejected'],
        targetDishId: 'dish_b',
      ))!;

      expect(correction.type, CaptureCorrectionType.assign);
      expect(
        correction.previouslyUnclassifiedCaptureIds,
        contains('capture_rejected'),
      );
      expect(await _captureStatus(database, 'capture_rejected'), 'applied');
      expect(await _assignedDish(database, 'capture_rejected'), 'dish_b');
      expect(await _sourceCount(database, 'dish_b'), 2);

      await repositories.captureCorrectionRepository.undoLatest('batch_1');

      expect(await _captureStatus(database, 'capture_rejected'), 'discarded');
      expect(await _assignedDish(database, 'capture_rejected'), isNull);
      expect(
        await _failureReason(database, 'capture_rejected'),
        'No prepared dish was recognized.',
      );
      expect(await _sourceCount(database, 'dish_b'), 1);
    });

    test('manual organization cancels adoption of a late AI proposal',
        () async {
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
      await repositories.processingOutboxRepository.enqueueCaptureGrouping(
        requestId: 'request_1',
        batchId: 'batch_1',
        captureIds: const <String>['capture_a', 'capture_b'],
        now: DateTime.utc(2026, 7, 27),
      );

      await repositories.captureCorrectionRepository.moveCaptures(
        batchId: 'batch_1',
        captureIds: const <String>['capture_a'],
        targetDishId: 'dish_b',
      );

      final request =
          (await repositories.processingOutboxRepository.listRequests()).single;
      expect(request.deliveryState, ProcessingDeliveryState.canceled);
      expect(request.adoptionState, ProcessingAdoptionState.rejected);
      expect(await _assignedDish(database, 'capture_a'), 'dish_b');
    });

    test('deleting an organized photo keeps its dish and other photos',
        () async {
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );

      await repositories.captureRepository.deleteCapture('capture_a');

      expect(await _dishCount(database, 'dish_a'), 1);
      expect(await _sourceCount(database, 'dish_a'), 1);
      expect(
        await (database.select(database.captureItems)
              ..where((CaptureItems table) => table.id.equals('capture_a')))
            .getSingleOrNull(),
        isNull,
      );
      expect(await _assignedDish(database, 'capture_b'), 'dish_a');
      expect(await _pendingCorrectionOperations(database), isEmpty);
    });
  });
}

Future<void> _seedGrouping(AppDatabase database) async {
  final DateTime now = DateTime.utc(2026, 7, 27);
  for (final (String id, String title) in <(String, String)>[
    ('dish_a', 'Miso Salmon'),
    ('dish_b', 'Charred Corn Ramen'),
  ]) {
    await database.into(database.dishes).insert(
          DishesCompanion.insert(
            id: id,
            title: title,
            description: '',
            heroImageUrl: 'fake://$id',
            category: 'Captured',
            prepMinutes: 0,
            difficulty: 'Not set',
            madeCount: 1,
            lastMadeLabel: 'Today',
            ingredientsJson: '[]',
            recipeStepsJson: '[]',
            notesJson: '[]',
          ),
        );
  }
  await database.into(database.captureBatches).insert(
        CaptureBatchesCompanion.insert(
          id: 'batch_1',
          status: 'applied',
          createdAt: now,
          updatedAt: now,
        ),
      );
  for (final (String id, int ordinal, String dishId) in <(String, int, String)>[
    ('capture_a', 0, 'dish_a'),
    ('capture_b', 1, 'dish_a'),
    ('capture_c', 2, 'dish_b'),
  ]) {
    final String mediaRef = 'fake://$id';
    await database.into(database.captureItems).insert(
          CaptureItemsCompanion.insert(
            id: id,
            batchId: const Value<String?>('batch_1'),
            ordinal: Value<int>(ordinal),
            kind: 'photo',
            status: 'applied',
            createdAt: now,
            localMediaRef: Value<String?>(mediaRef),
            remoteMediaRef: Value<String?>(mediaRef),
            appliedDishId: Value<String?>(dishId),
          ),
        );
    await database.into(database.sourcePhotos).insert(
          SourcePhotosCompanion.insert(
            id: '${id}_source',
            dishId: dishId,
            url: mediaRef,
            capturedLabel: 'Today',
          ),
        );
  }
}

Future<String?> _assignedDish(AppDatabase database, String captureId) async {
  return (await (database.select(database.captureItems)
            ..where((CaptureItems table) => table.id.equals(captureId)))
          .getSingle())
      .appliedDishId;
}

Future<String> _captureStatus(AppDatabase database, String captureId) async {
  return (await (database.select(database.captureItems)
            ..where((CaptureItems table) => table.id.equals(captureId)))
          .getSingle())
      .status;
}

Future<String?> _failureReason(AppDatabase database, String captureId) async {
  return (await (database.select(database.captureItems)
            ..where((CaptureItems table) => table.id.equals(captureId)))
          .getSingle())
      .failureReason;
}

Future<int> _sourceCount(AppDatabase database, String dishId) async {
  return (await (database.select(database.sourcePhotos)
            ..where((SourcePhotos table) => table.dishId.equals(dishId)))
          .get())
      .length;
}

Future<int> _dishCount(AppDatabase database, String dishId) async {
  return (await (database.select(database.dishes)
            ..where((Dishes table) => table.id.equals(dishId)))
          .get())
      .length;
}

Future<String> _sourceDish(AppDatabase database, String sourceId) async {
  return (await (database.select(database.sourcePhotos)
            ..where((SourcePhotos table) => table.id.equals(sourceId)))
          .getSingle())
      .dishId;
}

Future<int> _madeCount(AppDatabase database, String dishId) async {
  return (await (database.select(database.dishes)
            ..where((Dishes table) => table.id.equals(dishId)))
          .getSingle())
      .madeCount;
}

Future<List<SyncOperationRow>> _pendingCorrectionOperations(
  AppDatabase database,
) {
  return (database.select(database.syncOperations)
        ..where(
          (SyncOperations table) =>
              table.entity.equals('capture_correction') &
              table.completedAt.isNull(),
        ))
      .get();
}
