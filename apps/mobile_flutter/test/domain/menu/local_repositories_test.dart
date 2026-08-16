import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/core/network/processing_api_client.dart';
import 'package:mymenu/domain/capture/capture_correction.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/app_repositories.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dish knowledge and planning survive a database restart', () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_local_menu_');
    addTearDown(() => temp.delete(recursive: true));
    final File databaseFile = File('${temp.path}/mymenu.sqlite');

    final AppDatabase firstDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    final AppRepositories first = AppRepositories(
      database: firstDatabase,
      processingApiClient: _NoProcessingClient(),
      seedSampleDataOnPrepare: true,
    );
    await first.prepareLocalData();
    await first.dishRepository.setFavorite('dish_salmon', isFavorite: true);
    await first.dishRepository.createNote('dish_salmon', 'Keep this note.');
    await first.planRepository.replaceMeals(<PlannedMeal>[
      const PlannedMeal(
        id: 'local_plan',
        dayKey: '2026-08-16',
        dishId: 'dish_salmon',
      ),
    ]);
    await firstDatabase.close();

    final AppDatabase restartedDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    addTearDown(restartedDatabase.close);
    final AppRepositories restarted = AppRepositories(
      database: restartedDatabase,
      processingApiClient: _NoProcessingClient(),
    );
    final Dish dish = (await restarted.dishRepository.listDishes())
        .singleWhere((Dish item) => item.id == 'dish_salmon');
    final List<PlannedMeal> plan = await restarted.planRepository.listMeals(
      validDishIds: <String>{dish.id},
    );

    expect(dish.isFavorite, isTrue);
    expect(dish.notes.last.body, 'Keep this note.');
    expect(plan.single.id, 'local_plan');
  });

  test('resumeProcessing leaves the local menu unchanged without outbox work',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      processingApiClient: _NoProcessingClient(),
      seedSampleDataOnPrepare: true,
    );
    final MyMenuState state = MyMenuState(
      repositories: repositories,
      networkStatusMonitor: const InertNetworkStatusMonitor(),
    );
    addTearDown(state.dispose);
    await state.initialized;
    final List<String> before =
        state.dishes.map((Dish dish) => dish.id).toList(growable: false);

    await state.resumeProcessing();

    expect(state.dishes.map((Dish dish) => dish.id), before);
    expect(state.processingRequests, isEmpty);
  });

  test('capture corrections are immediate local mutations that survive restart',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_local_correction_');
    addTearDown(() => temp.delete(recursive: true));
    final File databaseFile = File('${temp.path}/mymenu.sqlite');
    final AppDatabase firstDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    await _seedCorrectionFixture(firstDatabase);
    final AppRepositories first = AppRepositories(
      database: firstDatabase,
      processingApiClient: _NoProcessingClient(),
    );

    final CaptureCorrection correction =
        (await first.captureCorrectionRepository.moveCaptures(
      batchId: 'batch_1',
      captureIds: const <String>['capture_1'],
      targetDishId: 'dish_b',
    ))!;
    expect(correction.status, CaptureCorrectionStatus.applied);
    await firstDatabase.close();

    final AppDatabase restartedDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    addTearDown(restartedDatabase.close);
    final AppRepositories restarted = AppRepositories(
      database: restartedDatabase,
      processingApiClient: _NoProcessingClient(),
    );
    final CaptureItemRow capture = await (restartedDatabase.select(
      restartedDatabase.captureItems,
    )..where((CaptureItems table) => table.id.equals('capture_1')))
        .getSingle();
    final CaptureCorrection restored =
        (await restarted.captureCorrectionRepository.listCorrections()).single;

    expect(capture.appliedDishId, 'dish_b');
    expect(restored.id, correction.id);
    expect(restored.status, CaptureCorrectionStatus.applied);
  });

  test('split and undo restore the original local assignment', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _seedCorrectionFixture(database);
    final AppRepositories repositories = AppRepositories(
      database: database,
      processingApiClient: _NoProcessingClient(),
    );

    final CaptureCorrection split =
        (await repositories.captureCorrectionRepository.splitCaptures(
      batchId: 'batch_1',
      captureIds: const <String>['capture_1'],
      title: 'Weekend Dish',
    ))!;
    expect(split.createdDishId, isNotNull);
    expect(await _assignedDish(database, 'capture_1'), split.createdDishId);

    final CaptureCorrection undone =
        (await repositories.captureCorrectionRepository.undoLatest('batch_1'))!;
    expect(undone.status, CaptureCorrectionStatus.undone);
    expect(await _assignedDish(database, 'capture_1'), 'dish_a');
    expect(
      await (database.select(database.dishes)
            ..where((Dishes table) => table.id.equals(split.createdDishId!)))
          .getSingleOrNull(),
      isNull,
    );
  });

  test('assigning an unclassified capture is locally undoable', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _seedCorrectionFixture(database);
    final DateTime now = DateTime.utc(2026, 8, 15);
    await database.into(database.captureItems).insert(
          CaptureItemsCompanion.insert(
            id: 'capture_unclassified',
            batchId: const Value<String?>('batch_1'),
            ordinal: const Value<int>(1),
            kind: 'photo',
            status: 'discarded',
            createdAt: now,
            localMediaRef: const Value<String?>('asset://unclassified'),
            failureReason: const Value<String?>('Not recognized.'),
          ),
        );
    final AppRepositories repositories = AppRepositories(
      database: database,
      processingApiClient: _NoProcessingClient(),
    );

    await repositories.captureCorrectionRepository.assignCaptures(
      batchId: 'batch_1',
      captureIds: const <String>['capture_unclassified'],
      targetDishId: 'dish_b',
    );
    expect(await _assignedDish(database, 'capture_unclassified'), 'dish_b');

    await repositories.captureCorrectionRepository.undoLatest('batch_1');
    final CaptureItemRow restored = await (database.select(
      database.captureItems,
    )..where((CaptureItems table) => table.id.equals('capture_unclassified')))
        .getSingle();
    expect(restored.appliedDishId, isNull);
    expect(restored.status, 'discarded');
    expect(restored.failureReason, 'Not recognized.');
  });

  test('a local correction rejects a late processing proposal', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _seedCorrectionFixture(database);
    final AppRepositories repositories = AppRepositories(
      database: database,
      processingApiClient: _NoProcessingClient(),
    );
    await repositories.processingOutboxRepository.enqueueCaptureGrouping(
      requestId: 'request_1',
      batchId: 'batch_1',
      captureIds: const <String>['capture_1'],
      now: DateTime.utc(2026, 8, 15),
    );

    await repositories.captureCorrectionRepository.moveCaptures(
      batchId: 'batch_1',
      captureIds: const <String>['capture_1'],
      targetDishId: 'dish_b',
    );

    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(request.deliveryState, ProcessingDeliveryState.canceled);
    expect(request.adoptionState, ProcessingAdoptionState.rejected);
    expect(await _assignedDish(database, 'capture_1'), 'dish_b');
  });
}

Future<String?> _assignedDish(AppDatabase database, String captureId) async {
  return (await (database.select(database.captureItems)
            ..where((CaptureItems table) => table.id.equals(captureId)))
          .getSingle())
      .appliedDishId;
}

Future<void> _seedCorrectionFixture(AppDatabase database) async {
  final DateTime now = DateTime.utc(2026, 8, 15);
  for (final String id in <String>['dish_a', 'dish_b']) {
    await database.into(database.dishes).insert(
          DishesCompanion.insert(
            id: id,
            title: id,
            description: '',
            heroImageUrl: 'asset://local',
            category: 'Captured',
            prepMinutes: 0,
            difficulty: 'Draft',
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
  await database.into(database.captureItems).insert(
        CaptureItemsCompanion.insert(
          id: 'capture_1',
          batchId: const Value<String?>('batch_1'),
          kind: 'photo',
          status: 'applied',
          createdAt: now,
          localMediaRef: const Value<String?>('asset://local'),
          appliedDishId: const Value<String?>('dish_a'),
        ),
      );
  await database.into(database.sourcePhotos).insert(
        SourcePhotosCompanion.insert(
          id: 'capture_1_source',
          dishId: 'dish_a',
          url: 'asset://local',
          capturedLabel: 'Today',
          captureId: const Value<String?>('capture_1'),
        ),
      );
}

class _NoProcessingClient extends ProcessingApiClient {}
