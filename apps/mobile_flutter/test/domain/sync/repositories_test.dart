import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/files/dish_image_cache.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/domain/ai/ai_job.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_correction.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/domain/sync/repositories.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('repositories', () {
    late AppDatabase database;
    late AppRepositories repositories;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
      await repositories.processingConsentRepository.acceptCurrentNotice();
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

    test('production preparation replaces mock covers with real sources',
        () async {
      final Dish userDish = Dish(
        id: 'user_dish',
        title: 'Saved Idea',
        description: '',
        heroImageUrl: 'asset://assets/dish_art/linguine.png',
        category: 'Ideas',
        prepMinutes: 0,
        difficulty: 'Draft',
        madeCount: 0,
        lastMadeLabel: 'Not cooked yet',
        ingredients: const <String>[],
        recipeSteps: const <String>[],
        notes: const <DishNote>[],
        sourcePhotos: const <SourcePhoto>[
          SourcePhoto(
            url: '/captures/saved-idea.jpg',
            capturedLabel: 'Today',
          ),
        ],
      );
      await repositories.dishRepository.createDish(
        seededDishes.first.copyWith(
          heroImageUrl: 'asset://assets/dish_art/miso-salmon.png',
        ),
      );
      await repositories.dishRepository.createDish(userDish);
      await repositories.dishRepository.createDish(
        userDish.copyWith(
          id: 'idea_without_source',
          heroImageUrl: 'asset://assets/dish_art/katsu.png',
          sourcePhotos: const <SourcePhoto>[],
        ),
      );

      await repositories.prepareLocalData();

      final List<Dish> dishes = await repositories.dishRepository.listDishes();
      expect(
        dishes
            .singleWhere((Dish dish) => dish.id == 'dish_salmon')
            .heroImageUrl,
        seededDishes.first.sourcePhotos.first.url,
      );
      expect(
        dishes.singleWhere((Dish dish) => dish.id == userDish.id).heroImageUrl,
        '/captures/saved-idea.jpg',
      );
      expect(
        dishes
            .singleWhere((Dish dish) => dish.id == 'idea_without_source')
            .heroImageUrl,
        isEmpty,
      );
    });

    test('production preparation does not seed an empty menu', () async {
      await repositories.prepareLocalData();

      expect(await repositories.dishRepository.listDishes(), isEmpty);
      expect(await database.select(database.plannedMeals).get(), isEmpty);
    });

    test('empty local menu and plan stay empty after bootstrap restart',
        () async {
      final Directory temp =
          await Directory.systemTemp.createTemp('mymenu_empty_restart_');
      addTearDown(() => temp.delete(recursive: true));
      final File databaseFile = File('${temp.path}/mymenu.sqlite');
      final AppDatabase firstDatabase =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      final AppRepositories firstRepositories = AppRepositories(
        database: firstDatabase,
        apiClient: _OfflineApiClient(),
      );
      await firstRepositories.seedIfNeeded();
      final List<String> dishIds =
          (await firstDatabase.select(firstDatabase.dishes).get())
              .map((DishRow dish) => dish.id)
              .toList(growable: false);
      await firstRepositories.dishRepository.deleteDishes(dishIds);
      await firstRepositories.planRepository.replaceMeals(
        const <PlannedMeal>[],
      );
      await firstDatabase.close();

      final AppDatabase restartedDatabase =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      addTearDown(restartedDatabase.close);
      final AppRepositories restartedRepositories = AppRepositories(
        database: restartedDatabase,
        apiClient: _OfflineApiClient(),
      );
      await restartedRepositories.seedIfNeeded();

      expect(await restartedDatabase.select(restartedDatabase.dishes).get(),
          isEmpty);
      expect(
        await restartedDatabase.select(restartedDatabase.plannedMeals).get(),
        isEmpty,
      );
    });

    test('loading plans removes references to missing dishes', () async {
      await repositories.seedIfNeeded();
      await database.into(database.plannedMeals).insert(
            PlannedMealsCompanion.insert(
              id: 'orphaned_plan',
              dayKey: '2026-07-28',
              dishId: 'deleted_dish',
            ),
          );

      final Set<String> validDishIds =
          (await database.select(database.dishes).get())
              .map((DishRow dish) => dish.id)
              .toSet();
      final meals = await repositories.planRepository.listMeals(
        validDishIds: validDishIds,
      );

      expect(
        meals.map((meal) => meal.id),
        isNot(contains('orphaned_plan')),
      );
      expect(
        await (database.select(database.plannedMeals)
              ..where(
                (PlannedMeals table) => table.id.equals('orphaned_plan'),
              ))
            .get(),
        isEmpty,
      );
    });

    test('plan repository replaces and reloads the local plan in order',
        () async {
      await repositories.seedIfNeeded();
      const List<PlannedMeal> expected = <PlannedMeal>[
        PlannedMeal(
          id: 'plan_local_second',
          dayKey: '2026-08-03',
          dishId: 'dish_linguine',
          label: 'Dinner',
        ),
        PlannedMeal(
          id: 'plan_local_first',
          dayKey: '2026-08-03',
          dishId: 'dish_salmon',
          label: 'Lunch',
        ),
      ];

      await repositories.planRepository.replaceMeals(expected);
      final List<PlannedMeal> saved =
          await repositories.planRepository.listMeals(
        validDishIds: const <String>{'dish_linguine', 'dish_salmon'},
      );

      expect(saved.map((PlannedMeal meal) => meal.id),
          <String>['plan_local_second', 'plan_local_first']);
      expect(saved.map((PlannedMeal meal) => meal.label),
          <String>['Dinner', 'Lunch']);
      expect(await database.select(database.syncOperations).get(), isEmpty);
    });

    test('schema 10 plan rows migrate without losing their order', () async {
      final Directory temp =
          await Directory.systemTemp.createTemp('mymenu_plan_migration_');
      addTearDown(() => temp.delete(recursive: true));
      final File databaseFile = File('${temp.path}/mymenu.sqlite');
      final AppDatabase currentDatabase =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      final AppRepositories currentRepositories = AppRepositories(
        database: currentDatabase,
        apiClient: FakeMyMenuApiClient(),
      );
      await currentRepositories.seedIfNeeded();
      final List<String> expectedIds =
          (await currentDatabase.select(currentDatabase.plannedMeals).get())
              .map((PlannedMealRow meal) => meal.id)
              .toList(growable: false);
      await currentDatabase.close();
      sqlite.sqlite3.open(databaseFile.path)
        ..execute('ALTER TABLE planned_meals DROP COLUMN position')
        ..execute('PRAGMA user_version = 10')
        ..close();

      final AppDatabase migratedDatabase =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      addTearDown(migratedDatabase.close);
      final AppRepositories migratedRepositories = AppRepositories(
        database: migratedDatabase,
        apiClient: FakeMyMenuApiClient(),
      );
      final List<String> migratedIds =
          (await migratedRepositories.planRepository.listMeals(
        validDishIds: seededDishes.map((Dish dish) => dish.id).toSet(),
      ))
              .map((PlannedMeal meal) => meal.id)
              .toList(growable: false);

      expect(migratedIds, expectedIds);
      expect(migratedDatabase.schemaVersion, 13);
    });

    test('sync caches local dish web images once', () async {
      final Directory supportDirectory =
          await Directory.systemTemp.createTemp('mymenu_seed_image_cache_');
      addTearDown(() => supportDirectory.delete(recursive: true));
      var downloadCount = 0;
      repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
        dishImageCache: DishImageCache(
          directoryProvider: () async => supportDirectory,
          downloader: (Uri uri) async {
            downloadCount += 1;
            return <int>[1, 2, 3];
          },
        ),
      );
      await repositories.seedIfNeeded();
      final int remoteMediaCount =
          (await database.select(database.sourcePhotos).get())
                  .where(
                    (SourcePhotoRow photo) => photo.url.startsWith('https://'),
                  )
                  .length +
              (await database.select(database.dishes).get())
                  .where(
                    (DishRow dish) => dish.heroImageUrl.startsWith('https://'),
                  )
                  .length;

      await repositories.syncRepository.pullCaptureSync();
      await repositories.syncRepository.pullCaptureSync();

      final List<SourcePhotoRow> cachedSources =
          await database.select(database.sourcePhotos).get();
      final List<DishRow> cachedDishes =
          await database.select(database.dishes).get();
      expect(remoteMediaCount, greaterThan(0));
      expect(downloadCount, remoteMediaCount);
      expect(
        cachedSources
            .every((SourcePhotoRow photo) => File(photo.url).existsSync()),
        isTrue,
      );
      expect(
        cachedDishes.every(
          (DishRow dish) => File(dish.heroImageUrl).existsSync(),
        ),
        isTrue,
      );
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

    test('dish repository creates and edits local dish knowledge without sync',
        () async {
      final Dish dish = Dish(
        id: 'dish_local_idea',
        title: 'Gochujang Noodles',
        description: 'An idea saved on this device.',
        heroImageUrl: '',
        category: 'Ideas',
        prepMinutes: 0,
        difficulty: 'Not set',
        madeCount: 0,
        lastMadeLabel: 'Not cooked yet',
        ingredients: const <String>[],
        recipeSteps: const <String>[],
        notes: const <DishNote>[
          DishNote(
            id: 'dish_local_idea_note_0',
            dishId: 'dish_local_idea',
            body: 'Try sesame and scallions.',
            position: 0,
          ),
        ],
        sourcePhotos: const <SourcePhoto>[],
        createdAt: DateTime.utc(2026, 8),
      );

      await repositories.dishRepository.createDish(dish);
      await repositories.dishRepository.setFavorite(dish.id, isFavorite: true);
      await repositories.dishRepository.updateSections(
        dish.id,
        ingredients: const <String>['Noodles|8 oz', 'Gochujang|2 tbsp'],
        recipeSteps: const <String>['Boil noodles.', 'Toss with sauce.'],
      );

      final Dish saved = (await repositories.dishRepository.listDishes())
          .singleWhere((Dish item) => item.id == dish.id);
      expect(saved.title, 'Gochujang Noodles');
      expect(saved.notes.single.body, 'Try sesame and scallions.');
      expect(saved.isFavorite, isTrue);
      expect(saved.ingredients, <String>['Noodles|8 oz', 'Gochujang|2 tbsp']);
      expect(saved.recipeSteps, <String>['Boil noodles.', 'Toss with sauce.']);
      expect(await database.select(database.syncOperations).get(), isEmpty);
    });

    test('adding an idea does not depend on seeded dishes being present',
        () async {
      await repositories.seedIfNeeded();
      await repositories.dishRepository.deleteDishes(
        seededDishes.map((Dish dish) => dish.id),
      );
      await repositories.dishRepository.createDish(
        seededDishes.first.copyWith(
          id: 'user_dish',
          title: 'Family Soup',
          notes: const <DishNote>[],
          sourcePhotos: const <SourcePhoto>[],
        ),
      );
      final MyMenuState state = MyMenuState(
        repositories: repositories,
        networkStatusMonitor: const InertNetworkStatusMonitor(),
      );
      addTearDown(state.dispose);
      await state.initialized;

      await state.addIdea(
        'offline gnocchi',
        note: 'Use the preserved lemons.',
      );

      final Dish saved = state.dishes.singleWhere(
        (Dish dish) => dish.title == 'Offline Gnocchi',
      );
      expect(saved.heroImageUrl, isEmpty);
      expect(saved.category, 'Ideas');
      expect(saved.prepMinutes, 0);
      expect(saved.ingredients, isEmpty);
      expect(saved.recipeSteps, isEmpty);
      expect(saved.notes.single.body, 'Use the preserved lemons.');
      expect(
        (await repositories.dishRepository.listDishes())
            .map((Dish dish) => dish.id),
        contains(saved.id),
      );
      expect(await database.select(database.syncOperations).get(), isEmpty);
    });

    test('creating a dish from review consumes the review locally', () async {
      await repositories.seedIfNeeded();
      await database.into(database.reviewItems).insert(
            ReviewItemsCompanion.insert(
              id: 'review_1',
              summary: 'Captured salmon bowl from tonight.',
              suggestedDishIdsJson: '["dish_salmon"]',
              confidenceLabel: 'Needs review',
            ),
          );
      final MyMenuState state = MyMenuState(
        repositories: repositories,
        networkStatusMonitor: const InertNetworkStatusMonitor(),
      );
      addTearDown(state.dispose);
      await state.initialized;
      final int dishCount = state.dishes.length;

      await state.createDishFromReview('review_1');

      expect(await repositories.dishRepository.listDishes(),
          hasLength(dishCount + 1));
      expect(state.reviewItems.map((ReviewItem item) => item.id),
          isNot(contains('review_1')));
      expect(await database.select(database.reviewItems).get(), isEmpty);
      expect(await database.select(database.syncOperations).get(), isEmpty);
    });

    test('local dish knowledge and plan survive database restart', () async {
      final Directory temp =
          await Directory.systemTemp.createTemp('mymenu_local_menu_restart_');
      addTearDown(() => temp.delete(recursive: true));
      final File databaseFile = File('${temp.path}/mymenu.sqlite');
      final AppDatabase firstDatabase =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      final AppRepositories firstRepositories = AppRepositories(
        database: firstDatabase,
        apiClient: _OfflineApiClient(),
      );
      final Dish dish = Dish(
        id: 'restart_dish',
        title: 'Offline Udon',
        description: 'Saved without a server.',
        heroImageUrl: '/captures/offline-udon.jpg',
        category: 'Ideas',
        prepMinutes: 20,
        difficulty: 'Easy',
        madeCount: 0,
        lastMadeLabel: 'Not cooked yet',
        ingredients: const <String>[],
        recipeSteps: const <String>[],
        notes: const <DishNote>[],
        sourcePhotos: const <SourcePhoto>[],
        createdAt: DateTime.utc(2026, 8),
      );
      await firstRepositories.dishRepository.createDish(dish);
      final DishNote note = await firstRepositories.dishRepository.createNote(
        dish.id,
        'Use frozen udon.',
      );
      await firstRepositories.dishRepository.updateNote(
        note.id,
        'Use two packs of frozen udon.',
      );
      await firstRepositories.dishRepository.setFavorite(
        dish.id,
        isFavorite: true,
      );
      await firstRepositories.dishRepository.updateSections(
        dish.id,
        ingredients: const <String>['Frozen udon|2 packs'],
        recipeSteps: const <String>['Boil.', 'Toss.'],
      );
      await firstRepositories.planRepository.replaceMeals(
        const <PlannedMeal>[
          PlannedMeal(
            id: 'restart_plan',
            dayKey: '2026-08-04',
            dishId: 'restart_dish',
            label: 'Dinner',
          ),
        ],
      );
      await firstDatabase.close();

      final AppDatabase restartedDatabase =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      addTearDown(restartedDatabase.close);
      final AppRepositories restartedRepositories = AppRepositories(
        database: restartedDatabase,
        apiClient: _OfflineApiClient(),
      );
      final Dish saved =
          (await restartedRepositories.dishRepository.listDishes()).single;
      final List<PlannedMeal> savedPlan =
          await restartedRepositories.planRepository.listMeals(
        validDishIds: <String>{saved.id},
      );

      expect(saved.title, 'Offline Udon');
      expect(saved.notes.single.body, 'Use two packs of frozen udon.');
      expect(saved.isFavorite, isTrue);
      expect(saved.ingredients, <String>['Frozen udon|2 packs']);
      expect(saved.recipeSteps, <String>['Boil.', 'Toss.']);
      expect(savedPlan.single.id, 'restart_plan');
      expect(savedPlan.single.label, 'Dinner');
      expect(
        await restartedDatabase.select(restartedDatabase.syncOperations).get(),
        isEmpty,
      );
    });

    test('failed local writes do not publish favorite or plan state', () async {
      final AppDatabase failingDatabase =
          AppDatabase.forTesting(NativeDatabase.memory());
      final AppRepositories failingRepositories = AppRepositories(
        database: failingDatabase,
        apiClient: _OfflineApiClient(),
      );
      await failingRepositories.seedIfNeeded();
      await failingDatabase.into(failingDatabase.reviewItems).insert(
            ReviewItemsCompanion.insert(
              id: 'review_1',
              summary: 'Captured salmon bowl from tonight.',
              suggestedDishIdsJson: '["dish_salmon"]',
              confidenceLabel: 'Needs review',
            ),
          );
      final MyMenuState state = MyMenuState(
        repositories: failingRepositories,
        networkStatusMonitor: const InertNetworkStatusMonitor(),
      );
      addTearDown(state.dispose);
      await state.initialized;
      await state.refreshFromServer();
      final Dish beforeDish = state.dishById('dish_salmon');
      final List<PlannedMeal> beforePlan = state.plan;
      await failingDatabase.close();

      await expectLater(
        state.toggleFavorite(beforeDish.id),
        throwsA(isA<Object>()),
      );
      await expectLater(
        state.addPlannedMeal(
          beforePlan.first.dayKey,
          beforeDish.id,
          label: 'Snack',
        ),
        throwsA(isA<Object>()),
      );
      await expectLater(
        state.createDishFromReview('review_1'),
        throwsA(isA<Object>()),
      );

      expect(state.dishById(beforeDish.id).isFavorite, beforeDish.isFavorite);
      expect(state.plan, beforePlan);
      expect(
        state.reviewItems.map((ReviewItem item) => item.id),
        contains('review_1'),
      );
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

    test('dish repository creates, updates, and deletes notes locally',
        () async {
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
      expect(await database.select(database.syncOperations).get(), isEmpty);
    });

    test(
        'dish deletion removes local history, notes, plans, captures, jobs, '
        'corrections, reviews, and owned files', () async {
      final Directory supportDirectory =
          await Directory.systemTemp.createTemp('mymenu_delete_cache_');
      final Directory captureDirectory =
          await Directory.systemTemp.createTemp('mymenu_delete_capture_');
      addTearDown(() => supportDirectory.delete(recursive: true));
      addTearDown(() => captureDirectory.delete(recursive: true));
      final DishImageCache cache = DishImageCache(
        directoryProvider: () async => supportDirectory,
        downloader: (_) async => <int>[1, 2, 3, 4],
      );
      final _RecordingApiClient apiClient = _RecordingApiClient();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
        dishImageCache: cache,
      );
      await repositories.seedIfNeeded();
      const String dishId = 'dish_salmon';
      const String captureId = 'capture_delete_graph';
      const String batchId = 'batch_delete_graph';
      const String correctionId = 'correction_delete_graph';
      final DateTime now = DateTime.utc(2026, 7, 28);
      final File captureFile =
          File('${captureDirectory.path}/owned_source.jpg');
      await captureFile.writeAsBytes(<int>[5, 6, 7]);
      final SourcePhotoRow source = await (database.select(
        database.sourcePhotos,
      )
            ..where((SourcePhotos table) => table.dishId.equals(dishId))
            ..limit(1))
          .getSingle();
      final String cachedSource = await cache.resolve(
        cacheKey: source.id,
        remoteRef: 'https://example.test/source.jpg',
      );
      await (database.update(database.sourcePhotos)
            ..where((SourcePhotos table) => table.id.equals(source.id)))
          .write(
        SourcePhotosCompanion(url: Value<String>(cachedSource)),
      );
      await database.into(database.captureBatches).insert(
            CaptureBatchesCompanion.insert(
              id: batchId,
              status: CaptureBatchStatus.applied.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database.into(database.captureItems).insert(
            CaptureItemsCompanion.insert(
              id: captureId,
              batchId: const Value<String?>(batchId),
              kind: CaptureItemKind.photo.name,
              status: CaptureItemStatus.applied.name,
              createdAt: now,
              localMediaRef: Value<String?>(captureFile.path),
              appliedDishId: const Value<String?>(dishId),
            ),
          );
      await database.into(database.captureCorrections).insert(
            CaptureCorrectionsCompanion.insert(
              id: correctionId,
              batchId: batchId,
              actionType: 'move',
              captureIdsJson: jsonEncode(<String>[captureId]),
              previousDishIdsJson: jsonEncode(<String>[dishId]),
              targetDishId: dishId,
              status: 'applied',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database.into(database.plannedMeals).insert(
            PlannedMealsCompanion.insert(
              id: 'plan_delete_graph',
              dayKey: '2026-07-29',
              dishId: dishId,
            ),
          );
      await database.into(database.reviewItems).insert(
            ReviewItemsCompanion.insert(
              id: 'review_delete_graph',
              captureId: const Value<String?>(captureId),
              summary: 'Related review',
              suggestedDishIdsJson: jsonEncode(<String>[dishId]),
              confidenceLabel: 'high',
            ),
          );
      await database.into(database.aiJobs).insert(
            AiJobsCompanion.insert(
              id: 'job_delete_graph',
              jobType: 'cover_generation',
              subjectId: dishId,
              status: 'succeeded',
              idempotencyKey: 'cover:$dishId',
              inputHash: 'hash',
              inputVersion: '1',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await repositories.dishRepository.deleteDishes(<String>[dishId]);

      expect(
        await (database.select(database.dishes)
              ..where((Dishes table) => table.id.equals(dishId)))
            .getSingleOrNull(),
        isNull,
      );
      expect(
        await (database.select(database.dishNotes)
              ..where((DishNotes table) => table.dishId.equals(dishId)))
            .get(),
        isEmpty,
      );
      expect(
        await (database.select(database.sourcePhotos)
              ..where((SourcePhotos table) => table.dishId.equals(dishId)))
            .get(),
        isEmpty,
      );
      expect(
        await (database.select(database.plannedMeals)
              ..where((PlannedMeals table) => table.dishId.equals(dishId)))
            .get(),
        isEmpty,
      );
      expect(
        await (database.select(database.captureItems)
              ..where((CaptureItems table) => table.id.equals(captureId)))
            .getSingleOrNull(),
        isNull,
      );
      expect(
        await (database.select(database.captureBatches)
              ..where((CaptureBatches table) => table.id.equals(batchId)))
            .getSingleOrNull(),
        isNull,
      );
      expect(
        await database.select(database.captureCorrections).get(),
        isEmpty,
      );
      expect(
        await database.select(database.reviewItems).get(),
        isEmpty,
      );
      expect(
        await (database.select(database.aiJobs)
              ..where((AiJobs table) => table.subjectId.equals(dishId)))
            .get(),
        isEmpty,
      );
      expect(captureFile.existsSync(), isFalse);
      expect(File(cachedSource).existsSync(), isFalse);
      expect(
        (await repositories.dishRepository.listDishes())
            .any((Dish dish) => dish.id == 'dish_linguine'),
        isTrue,
      );

      expect(await database.select(database.syncOperations).get(), isEmpty);
      expect(apiClient.deletedDishIds, isEmpty);
    });

    test('photo capture sync queues its batch for AI after upload', () async {
      final File photo = await _temporaryPhoto('capture');
      await repositories.seedIfNeeded();
      await repositories.captureRepository.createPhotoCaptures(
        <String>[photo.path],
      );

      var feedItems = await repositories.captureRepository.listFeedItems();
      expect(feedItems.single.status, CaptureItemStatus.pendingUpload);

      final createdDishes =
          await repositories.syncRepository.processPendingCaptures();
      feedItems = await repositories.captureRepository.listFeedItems();

      expect(createdDishes, isEmpty);
      final batches = await repositories.captureRepository.listBatches();
      expect(feedItems.single.status, CaptureItemStatus.applied);
      expect(batches.single.status, CaptureBatchStatus.applied);
      expect(feedItems.single.appliedDishId, isNotNull);
      expect(feedItems.single.remoteMediaRef, isNull);
      final ProcessingOutboxRequest request =
          (await repositories.processingOutboxRepository.listRequests()).single;
      expect(request.deliveryState, ProcessingDeliveryState.acknowledged);
      expect(request.adoptionState, ProcessingAdoptionState.adopted);
    });

    test('photo capture ignores empty refs and uses only processing delivery',
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
      expect(syncOperations, isEmpty);
      expect(
        await repositories.processingOutboxRepository.listRequests(),
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

    test('idea capture trims text and queues processing delivery', () async {
      final String? id = await repositories.captureRepository
          .createIdeaCapture('  kimchi rice  ');

      final feedItems = await repositories.captureRepository.listFeedItems();
      final syncOperations =
          await database.select(database.syncOperations).get();

      expect(id, isNotNull);
      expect(feedItems.single.kind, CaptureItemKind.idea);
      expect(feedItems.single.status, CaptureItemStatus.pendingUpload);
      expect(feedItems.single.text, 'kimchi rice');
      expect(syncOperations, isEmpty);
      final ProcessingOutboxRequest request =
          (await repositories.processingOutboxRepository.listRequests()).single;
      expect(request.subjectId, id);
      expect(request.payload['captureIds'], <String>[id!]);
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

    test('idea capture sync adopts the backend decision locally', () async {
      await repositories.seedIfNeeded();
      final String? id = await repositories.captureRepository
          .createIdeaCapture('late night udon');

      final List<Dish> createdDishes =
          await repositories.syncRepository.processPendingCaptures();
      final feedItems = await repositories.captureRepository.listFeedItems();

      expect(id, isNotNull);
      expect(createdDishes, isEmpty);
      expect(feedItems.single.status, CaptureItemStatus.applied);
      expect(feedItems.single.appliedDishId, isNotNull);
    });

    test('an unresolved idea can be manually assigned to a dish', () async {
      const String dishId = 'dish_manual_idea';
      await repositories.dishRepository.upsertDish(
        _zeroHistoryDish(id: dishId, title: 'Manual Idea'),
      );
      final String ideaId = (await repositories.captureRepository
          .createIdeaCapture('ambiguous noodles'))!;
      final CaptureItem idea =
          (await repositories.captureRepository.listFeedItems()).single;

      await repositories.captureCorrectionRepository.assignCaptures(
        batchId: idea.batchId!,
        captureIds: <String>[ideaId],
        targetDishId: dishId,
      );

      final CaptureItem assigned =
          (await repositories.captureRepository.listFeedItems()).single;
      expect(assigned.status, CaptureItemStatus.applied);
      expect(assigned.appliedDishId, dishId);
    });

    test('dismissed suggestion keeps the photo and cancels processing',
        () async {
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
      expect(feedItems.single.status, CaptureItemStatus.localOnly);
      final request =
          (await repositories.processingOutboxRepository.listRequests()).single;
      expect(request.deliveryState, ProcessingDeliveryState.canceled);
      expect(request.adoptionState, ProcessingAdoptionState.rejected);
    });

    test('deleting an unclassified capture is device-local', () async {
      final DateTime now = DateTime.utc(2026, 7, 27);
      await database.into(database.captureItems).insert(
            CaptureItemsCompanion.insert(
              id: 'unclassified_capture',
              batchId: const Value<String?>('unclassified_batch'),
              kind: 'photo',
              status: 'discarded',
              createdAt: now,
              failureReason:
                  const Value<String?>('No prepared dish was recognized.'),
            ),
          );

      await repositories.captureRepository
          .deleteCapture('unclassified_capture');

      expect(
        await (database.select(database.captureItems)
              ..where(
                (CaptureItems table) => table.id.equals('unclassified_capture'),
              ))
            .getSingleOrNull(),
        isNull,
      );
      expect(await database.select(database.syncOperations).get(), isEmpty);
    });

    test('deleting a pending batch removes its local graph without legacy sync',
        () async {
      final Directory directory =
          await Directory.systemTemp.createTemp('mymenu_pending_batch_');
      addTearDown(() => directory.delete(recursive: true));
      final File firstFile = File('${directory.path}/first.jpg');
      final File secondFile = File('${directory.path}/second.jpg');
      await firstFile.writeAsBytes(<int>[1, 2]);
      await secondFile.writeAsBytes(<int>[3, 4]);
      final DateTime now = DateTime.utc(2026, 7, 28);
      const String batchId = 'pending_batch_to_delete';
      const List<String> captureIds = <String>[
        'pending_capture_a',
        'pending_capture_b',
      ];
      final _RecordingApiClient apiClient = _RecordingApiClient();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
      );
      await database.into(database.captureBatches).insert(
            CaptureBatchesCompanion.insert(
              id: batchId,
              status: CaptureBatchStatus.pendingUpload.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database.batch((Batch batch) {
        for (var index = 0; index < captureIds.length; index += 1) {
          batch.insert(
            database.captureItems,
            CaptureItemsCompanion.insert(
              id: captureIds[index],
              batchId: const Value<String?>(batchId),
              ordinal: Value<int>(index),
              kind: CaptureItemKind.photo.name,
              status: CaptureItemStatus.pendingUpload.name,
              createdAt: now,
              localMediaRef: Value<String?>(
                index == 0 ? firstFile.path : secondFile.path,
              ),
            ),
          );
        }
      });
      await database.into(database.aiJobs).insert(
            AiJobsCompanion.insert(
              id: 'pending_batch_job',
              jobType: AiJobType.batchGrouping.apiValue,
              subjectId: batchId,
              status: AiJobStatus.pendingOffline.databaseValue,
              idempotencyKey: 'pending:$batchId',
              inputHash: 'hash',
              inputVersion: '1',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database.into(database.reviewItems).insert(
            ReviewItemsCompanion.insert(
              id: 'pending_batch_review',
              captureId: Value<String?>(captureIds.first),
              summary: 'Pending review',
              suggestedDishIdsJson: '[]',
              confidenceLabel: 'low',
            ),
          );

      await repositories.captureRepository.deleteBatch(batchId);

      expect(await database.select(database.captureBatches).get(), isEmpty);
      expect(await database.select(database.captureItems).get(), isEmpty);
      expect(await database.select(database.aiJobs).get(), isEmpty);
      expect(await database.select(database.reviewItems).get(), isEmpty);
      expect(firstFile.existsSync(), isFalse);
      expect(secondFile.existsSync(), isFalse);
      final List<SyncOperationRow> operations =
          await database.select(database.syncOperations).get();
      expect(operations, isEmpty);

      await repositories.syncRepository.processPendingOperations();

      expect(apiClient.deletedBatchIds, isEmpty);
    });

    test('sync repository uploads photos without retaining remote refs',
        () async {
      final File photo = await _temporaryPhoto('capture');
      final FakeMyMenuApiClient apiClient = FakeMyMenuApiClient();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
      );
      await repositories.captureRepository.createPhotoCaptures(
        <String>[photo.path],
      );

      await repositories.syncRepository.processPendingCaptures();
      final feedItems = await repositories.captureRepository.listFeedItems();
      final ProcessingOutboxRequest request =
          (await repositories.processingOutboxRepository.listRequests()).single;

      expect(apiClient.processingJobCreationCount, 1);
      expect(request.deliveryState, ProcessingDeliveryState.acknowledged);
      expect(feedItems.single.remoteMediaRef, isNull);
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
    });

    test('sync repository marks captures failed when remote sync throws',
        () async {
      final File photo = await _temporaryPhoto('failure');
      repositories = AppRepositories(
        database: database,
        apiClient: _ThrowingApiClient(),
      );
      await repositories.captureRepository.createPhotoCaptures(
        <String>[photo.path],
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
      final File photo = await _temporaryPhoto('offline');
      repositories = AppRepositories(
        database: database,
        apiClient: _OfflineApiClient(),
      );
      await repositories.captureRepository.createPhotoBatch(
        <String>[photo.path],
      );

      await repositories.syncRepository.processPendingCaptures();
      final CaptureBatch batch =
          (await repositories.captureRepository.listBatches()).single;

      expect(batch.status, CaptureBatchStatus.pendingUpload);
      expect(batch.isWaitingForConnection, isTrue);
      expect(batch.items.single.status, CaptureItemStatus.pendingUpload);
      expect(batch.items.single.remoteMediaRef, isNull);
    });

    test('retry resumes the same job after an interrupted signed upload',
        () async {
      final File photo = await _temporaryPhoto('interrupted');
      final FakeMyMenuApiClient apiClient = FakeMyMenuApiClient()
        ..interruptNextProcessingUpload();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
      );
      await repositories.captureRepository.createPhotoBatch(<String>[
        photo.path,
      ]);

      await repositories.syncRepository.processPendingCaptures();
      await repositories.syncRepository.processPendingCaptures();

      final CaptureBatch recovered =
          (await repositories.captureRepository.listBatches()).single;
      final ProcessingOutboxRequest request =
          (await repositories.processingOutboxRepository.listRequests()).single;
      expect(apiClient.processingJobCreationCount, 1);
      expect(recovered.items.single.status, CaptureItemStatus.applied);
      expect(recovered.items.single.failureReason, isNull);
      expect(recovered.status, CaptureBatchStatus.applied);
      expect(request.deliveryState, ProcessingDeliveryState.acknowledged);
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

      final File zero = await _temporaryPhoto('zero');
      final File one = await _temporaryPhoto('one');
      final CaptureBatch? created =
          await state.addPhotoCaptures(<String>[zero.path, one.path]);
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
              batch.status == CaptureBatchStatus.applied,
        ),
      );

      final CaptureBatch synced = state.captureBatches.firstWhere(
        (CaptureBatch batch) => batch.id == createdBatch.id,
      );
      expect(synced.isWaitingForConnection, isFalse);
      expect(apiClient.processingJobCreationCount, 1);
      await state.refreshFromServer();
    });

    test('reconnect creates one remote batch and uploads each item once',
        () async {
      final _ReconnectApiClient apiClient = _ReconnectApiClient();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
      );
      final File zero = await _temporaryPhoto('zero');
      final File one = await _temporaryPhoto('one');
      final File two = await _temporaryPhoto('two');
      final CaptureBatch batch =
          (await repositories.captureRepository.createPhotoBatch(
        <String>[zero.path, one.path, two.path],
      ))!;

      await repositories.syncRepository.processPendingCaptures();
      expect(
        (await repositories.captureRepository.listBatches()).single.status,
        CaptureBatchStatus.pendingUpload,
      );
      expect(apiClient.processingJobCreationCount, 0);

      apiClient.isOnline = true;
      await repositories.syncRepository.processPendingCaptures();
      await repositories.syncRepository.processPendingCaptures();
      final CaptureBatch synced =
          (await repositories.captureRepository.listBatches()).single;

      expect(apiClient.processingJobCreationCount, 1);
      expect(apiClient.uploadedAssetIds.toSet(), hasLength(3));
      expect(apiClient.uploadedAssetIds.toSet(),
          batch.items.map((CaptureItem item) => item.id).toSet());
      expect(synced.status, CaptureBatchStatus.applied);
    });

    test('explicit retry starts a fresh attempt and reuploads all assets',
        () async {
      final _PartialFailureApiClient apiClient = _PartialFailureApiClient();
      repositories = AppRepositories(
        database: database,
        apiClient: apiClient,
      );
      final File zero = await _temporaryPhoto('zero');
      final File one = await _temporaryPhoto('one');
      final File two = await _temporaryPhoto('two');
      final CaptureBatch batch =
          (await repositories.captureRepository.createPhotoBatch(
        <String>[zero.path, one.path, two.path],
      ))!;

      await repositories.syncRepository.processPendingCaptures();
      var refreshed =
          (await repositories.captureRepository.listBatches()).single;

      expect(refreshed.status, CaptureBatchStatus.failed);
      expect(
        refreshed.items.every(
          (CaptureItem item) => item.status == CaptureItemStatus.failed,
        ),
        isTrue,
      );
      expect(apiClient.uploadedAssetIds, <String>[
        batch.items[0].id,
        batch.items[1].id,
      ]);
      final ProcessingOutboxRequest failedRequest =
          (await repositories.processingOutboxRepository.listRequests()).single;

      await repositories.syncRepository.processPendingCaptures();
      expect(apiClient.uploadedAssetIds, hasLength(2));

      await repositories.captureRepository.retryBatch(batch.id);
      final ProcessingOutboxRequest retryRequest =
          (await repositories.processingOutboxRepository.listRequests()).single;
      expect(retryRequest.idempotencyKey, isNot(failedRequest.idempotencyKey));
      await repositories.syncRepository.processPendingCaptures();
      refreshed = (await repositories.captureRepository.listBatches()).single;

      expect(apiClient.uploadedAssetIds, <String>[
        batch.items[0].id,
        batch.items[1].id,
        batch.items[0].id,
        batch.items[1].id,
        batch.items[2].id,
      ]);
      expect(
        refreshed.items.every(
          (CaptureItem item) => item.status == CaptureItemStatus.applied,
        ),
        isTrue,
      );
      expect(refreshed.status, CaptureBatchStatus.applied);
      expect(apiClient.processingJobCreationCount, 2);
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

    test('fake API upload and batch finalization return expected DTOs',
        () async {
      final FakeMyMenuApiClient apiClient = FakeMyMenuApiClient();

      final String mediaRef = await apiClient.uploadCaptureMedia(
        captureId: 'capture_1',
        batchId: 'batch_1',
        ordinal: 0,
        localMediaRef: '/tmp/photo.jpg',
      );
      final ApiAiJob result = await apiClient.finalizeCaptureBatch(
        batchId: 'batch_1',
        kind: 'photo',
        ideaText: null,
        capturedAt: DateTime.utc(2026, 7, 20),
        capturedLocalDate: '2026-07-20',
        captureDateSource: 'exif_original',
        jobId: 'job_1',
        idempotencyKey: 'batch_grouping:batch_1:date-v1',
        inputHash: 'hash',
        inputVersion: 'date-v1',
        maxAttempts: 3,
      );

      expect(mediaRef, 'fake://captures/capture_1');
      expect(result.subjectId, 'batch_1');
      expect(result.status, 'queued');
    });

    test('processing adopts a proposal without creating server menu data',
        () async {
      final File july20a = await _temporaryPhoto('july20-a');
      final File july20b = await _temporaryPhoto('july20-b');
      final File july21 = await _temporaryPhoto('july21');
      final File unknown = await _temporaryPhoto('unknown');
      await repositories.captureRepository.createPhotoBatch(
        <CapturedMedia>[
          CapturedMedia(
            path: july20a.path,
            capturedAt: DateTime(2026, 7, 20, 12),
            capturedLocalDate: '2026-07-20',
            dateSource: CaptureDateSource.exifOriginal,
          ),
          CapturedMedia(
            path: july20b.path,
            capturedAt: DateTime(2026, 7, 20, 18),
            capturedLocalDate: '2026-07-20',
            dateSource: CaptureDateSource.exifOriginal,
          ),
          CapturedMedia(
            path: july21.path,
            capturedAt: DateTime(2026, 7, 21, 12),
            capturedLocalDate: '2026-07-21',
            dateSource: CaptureDateSource.exifOriginal,
          ),
          CapturedMedia(
            path: unknown.path,
            capturedAt: DateTime(2026, 7, 22, 12),
            capturedLocalDate: null,
            dateSource: CaptureDateSource.unknown,
          ),
        ],
      );

      await repositories.syncRepository.processPendingCaptures();

      final List<Dish> dishes = await repositories.dishRepository.listDishes();
      final ProcessingOutboxRequest request =
          (await repositories.processingOutboxRepository.listRequests()).single;

      expect(dishes, hasLength(4));
      expect(request.deliveryState, ProcessingDeliveryState.acknowledged);
      expect(request.adoptionState, ProcessingAdoptionState.adopted);
      expect(request.resultPayload?['decisions'], hasLength(4));
    });

    test('direct routing adopts mixed outcomes once and keeps them undoable',
        () async {
      const String existingDishId = 'dish_existing_route';
      await repositories.dishRepository.upsertDish(
        _zeroHistoryDish(id: existingDishId, title: 'Existing Route'),
      );
      final CaptureBatch batch =
          (await repositories.captureRepository.createPhotoBatch(
        <String>[
          (await _temporaryPhoto('existing-route')).path,
          (await _temporaryPhoto('unclear-route')).path,
          (await _temporaryPhoto('not-a-dish')).path,
        ],
      ))!;
      final ProcessingOutboxRequest pending =
          (await repositories.processingOutboxRepository.listRequests()).single;
      final List<String> captureIds = batch.items
          .map((CaptureItem item) => item.id)
          .toList(growable: false);
      final Map<String, Object?> result = <String, Object?>{
        'operation': 'capture_grouping',
        'schemaVersion': 'capture-grouping-result-v2',
        'decisions': <Map<String, Object?>>[
          <String, Object?>{
            'captureIds': <String>[captureIds[0]],
            'outcome': <String, Object?>{
              'type': 'existing_dish',
              'localDishId': existingDishId,
            },
            'evidence': <String>['Matches the saved dish.'],
            'uncertainty': <String>[],
          },
          <String, Object?>{
            'captureIds': <String>[captureIds[1]],
            'outcome': <String, Object?>{'type': 'unresolved'},
            'evidence': <String>['A prepared dish is visible.'],
            'uncertainty': <String>['The destination is unclear.'],
          },
          <String, Object?>{
            'captureIds': <String>[captureIds[2]],
            'outcome': <String, Object?>{'type': 'not_a_dish'},
            'evidence': <String>['The photo contains no prepared dish.'],
            'uncertainty': <String>[],
          },
        ],
      };
      await (database.update(database.processingOutbox)
            ..where((table) => table.id.equals(pending.id)))
          .write(
        ProcessingOutboxCompanion(
          payloadJson: Value<String>(jsonEncode(<String, Object?>{
            'batchId': batch.id,
            'captureIds': captureIds,
            'submittedDishIds': <String>[existingDishId],
          })),
          deliveryState:
              Value<String>(ProcessingDeliveryState.acknowledged.name),
          adoptionState:
              Value<String>(ProcessingAdoptionState.readyForAdoption.name),
          resultPayloadJson: Value<String?>(jsonEncode(result)),
          resultSchemaVersion:
              const Value<String?>('capture-grouping-result-v2'),
        ),
      );

      await repositories.syncRepository.processPendingCaptures();
      await repositories.syncRepository.processPendingCaptures();

      final Map<String, CaptureItem> captures = <String, CaptureItem>{
        for (final CaptureItem item
            in await repositories.captureRepository.listFeedItems())
          item.id: item,
      };
      expect(captures[captureIds[0]]!.status, CaptureItemStatus.applied);
      expect(captures[captureIds[0]]!.appliedDishId, existingDishId);
      expect(captures[captureIds[1]]!.status, CaptureItemStatus.needsReview);
      expect(captures[captureIds[2]]!.status, CaptureItemStatus.notADish);
      expect(
        (await repositories.captureRepository.listReviewItems()).single.id,
        'review_${pending.id}_${captureIds[1]}',
      );
      expect(
        await repositories.captureCorrectionRepository.listCorrections(),
        hasLength(1),
      );
      expect(
        (await repositories.processingOutboxRepository.listRequests())
            .single
            .adoptionState,
        ProcessingAdoptionState.adopted,
      );

      await repositories.captureCorrectionRepository.undoLatest(
        batch.id,
        captureId: captureIds[0],
      );
      final CaptureItem restored =
          (await repositories.captureRepository.listFeedItems())
              .singleWhere((CaptureItem item) => item.id == captureIds[0]);
      expect(restored.appliedDishId, isNull);
    });

    test('pullCaptureSync applies capture result events and advances cursor',
        () async {
      final Directory mediaDirectory =
          await Directory.systemTemp.createTemp('mymenu_local_source_');
      addTearDown(() => mediaDirectory.delete(recursive: true));
      final File localPhoto = File('${mediaDirectory.path}/capture.jpg');
      await localPhoto.writeAsBytes(<int>[0xff, 0xd8, 0xff, 0xd9]);
      await database.into(database.captureItems).insert(
            CaptureItemsCompanion.insert(
              id: 'capture_sync_result',
              kind: 'photo',
              status: 'uploaded',
              createdAt: DateTime.utc(2026, 6, 20, 12),
              localMediaRef: Value<String?>(localPhoto.path),
            ),
          );
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
      expect(dishes.single.sourcePhotos.single.url, localPhoto.path);
      expect(
        dishes.single.sourcePhotos.single.cookingOccasionId,
        'occasion_sync_result',
      );
      expect(
        dishes.single.createdAt?.toUtc(),
        DateTime.utc(2026, 6, 20, 11),
      );
      expect(cursor.value, '42');

      final CaptureCorrection automatic =
          (await repositories.captureCorrectionRepository.listCorrections())
              .single;
      expect(automatic.type, CaptureCorrectionType.autoAssign);
      expect(automatic.isUserAuthored, isFalse);

      await repositories.captureCorrectionRepository.undoLatest(
        'capture_sync_result',
      );
      final CaptureItem restored =
          (await repositories.captureRepository.listFeedItems()).single;
      expect(restored.status, CaptureItemStatus.uploaded);
      expect(restored.appliedDishId, isNull);
      expect(await repositories.dishRepository.listDishes(), isEmpty);
    });

    test('late result cannot resurrect a locally deleted photo or dish',
        () async {
      final DateTime now = DateTime.utc(2026, 6, 20, 12);
      await database.into(database.captureBatches).insert(
            CaptureBatchesCompanion.insert(
              id: 'capture_sync_result',
              status: CaptureBatchStatus.processing.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database.into(database.captureItems).insert(
            CaptureItemsCompanion.insert(
              id: 'capture_sync_result',
              batchId: const Value<String?>('capture_sync_result'),
              kind: CaptureItemKind.photo.name,
              status: CaptureItemStatus.classifying.name,
              createdAt: now,
              localMediaRef: const Value<String?>('/tmp/deleted-photo.jpg'),
            ),
          );
      await database.into(database.processingOutbox).insert(
            ProcessingOutboxCompanion.insert(
              id: 'request_deleted_capture',
              requestKind: ProcessingRequestKind.captureGrouping.databaseValue,
              subjectId: 'capture_sync_result',
              payloadJson: '{"captureIds":["capture_sync_result"]}',
              deliveryState: ProcessingDeliveryState.submitted.name,
              adoptionState: ProcessingAdoptionState.awaitingProposal.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      repositories = AppRepositories(
        database: database,
        apiClient: _SyncResultApiClient(),
      );

      await repositories.captureRepository.deleteCapture(
        'capture_sync_result',
      );
      await repositories.syncRepository.pullCaptureSync();

      expect(await repositories.captureRepository.listFeedItems(), isEmpty);
      expect(await repositories.dishRepository.listDishes(), isEmpty);
      expect(await repositories.captureRepository.listReviewItems(), isEmpty);
    });

    test('late rejected organization cannot hydrate an empty AI dish',
        () async {
      final DateTime now = DateTime.utc(2026, 6, 20, 12);
      await repositories.dishRepository.upsertDish(
        _zeroHistoryDish(id: 'dish_manual', title: 'Manual choice'),
      );
      await database.into(database.captureBatches).insert(
            CaptureBatchesCompanion.insert(
              id: 'capture_sync_result',
              status: CaptureBatchStatus.applied.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database.into(database.captureItems).insert(
            CaptureItemsCompanion.insert(
              id: 'capture_sync_result',
              batchId: const Value<String?>('capture_sync_result'),
              kind: CaptureItemKind.photo.name,
              status: CaptureItemStatus.applied.name,
              createdAt: now,
              localMediaRef: const Value<String?>('/tmp/manual-choice.jpg'),
              appliedDishId: const Value<String?>('dish_manual'),
            ),
          );
      await database.into(database.processingOutbox).insert(
            ProcessingOutboxCompanion.insert(
              id: 'request_rejected_capture',
              requestKind: ProcessingRequestKind.captureGrouping.databaseValue,
              subjectId: 'capture_sync_result',
              payloadJson: '{"captureIds":["capture_sync_result"]}',
              deliveryState: ProcessingDeliveryState.submitted.name,
              adoptionState: ProcessingAdoptionState.rejected.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      repositories = AppRepositories(
        database: database,
        apiClient: _SyncResultApiClient(),
      );

      await repositories.syncRepository.pullCaptureSync();

      final CaptureItem capture =
          (await repositories.captureRepository.listFeedItems()).single;
      final List<Dish> dishes = await repositories.dishRepository.listDishes();
      expect(capture.appliedDishId, 'dish_manual');
      expect(dishes.map((Dish dish) => dish.id), <String>['dish_manual']);
    });

    test('dish-context capture assigns atomically without processing work',
        () async {
      await repositories.dishRepository.upsertDish(
        _zeroHistoryDish(id: 'dish_direct', title: 'Direct dish'),
      );

      final CaptureBatch batch =
          (await repositories.captureRepository.createPhotoBatch(
        const <String>['/tmp/direct-one.jpg', '/tmp/direct-two.jpg'],
        targetDishId: 'dish_direct',
      ))!;
      final Dish dish = (await repositories.dishRepository.listDishes())
          .singleWhere((Dish dish) => dish.id == 'dish_direct');

      expect(batch.status, CaptureBatchStatus.applied);
      expect(
        batch.items.map((CaptureItem item) => item.appliedDishId).toSet(),
        <String>{'dish_direct'},
      );
      expect(dish.sourcePhotos, hasLength(2));
      expect(dish.heroImageUrl, '/tmp/direct-one.jpg');
      expect(dish.madeCount, 1);
      expect(
        await repositories.processingOutboxRepository.listRequests(),
        isEmpty,
      );
      expect(
        await repositories.captureCorrectionRepository.listCorrections(),
        hasLength(1),
      );

      await repositories.captureRepository.deleteCapture(batch.items[0].id);
      final Dish afterFirstDelete =
          (await repositories.dishRepository.listDishes())
              .singleWhere((Dish dish) => dish.id == 'dish_direct');
      expect(afterFirstDelete.heroImageUrl, '/tmp/direct-two.jpg');
      expect(afterFirstDelete.madeCount, 1);

      await repositories.captureRepository.deleteCapture(batch.items[1].id);
      final Dish afterSecondDelete =
          (await repositories.dishRepository.listDishes())
              .singleWhere((Dish dish) => dish.id == 'dish_direct');
      expect(afterSecondDelete.heroImageUrl, isEmpty);
      expect(afterSecondDelete.madeCount, 0);
    });

    test(
        'authoritative dish deletion survives a later hydration failure '
        'without deleting unrelated zero-history dishes', () async {
      await repositories.dishRepository.upsertDish(
        _zeroHistoryDish(id: 'emptied_ai_dish', title: 'Old capture dish'),
      );
      await repositories.dishRepository.upsertDish(
        _zeroHistoryDish(id: 'idea_dish', title: 'Dinner idea'),
      );
      repositories = AppRepositories(
        database: database,
        apiClient: _DeleteThenHydrationFailureApiClient(),
      );

      await expectLater(
        repositories.syncRepository.pullCaptureSync(),
        throwsA(isA<StateError>()),
      );

      final Set<String> dishIds =
          (await repositories.dishRepository.listDishes())
              .map((Dish dish) => dish.id)
              .toSet();
      expect(dishIds, isNot(contains('emptied_ai_dish')));
      expect(dishIds, contains('idea_dish'));
    });
  });
}

Future<File> _temporaryPhoto(String name) async {
  final Directory directory =
      await Directory.systemTemp.createTemp('mymenu_processing_fixture_');
  addTearDown(() => directory.delete(recursive: true));
  return File('${directory.path}/$name.jpg').writeAsBytes(
    <int>[0xff, 0xd8, 0xff, 0xd9],
  );
}

Dish _zeroHistoryDish({required String id, required String title}) {
  return Dish(
    id: id,
    title: title,
    description: '',
    heroImageUrl: '',
    category: 'Idea',
    prepMinutes: 0,
    difficulty: 'Not set',
    madeCount: 0,
    lastMadeLabel: 'Not cooked yet',
    ingredients: const <String>[],
    recipeSteps: const <String>[],
    notes: const <DishNote>[],
    sourcePhotos: const <SourcePhoto>[],
  );
}

class _RecordingApiClient extends MyMenuApiClient {
  final List<String> uploadedCaptureIds = <String>[];
  final List<String> createdNoteIds = <String>[];
  final List<String> readyBatchIds = <String>[];
  final List<String> deletedDishIds = <String>[];
  final List<String> deletedBatchIds = <String>[];

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
  Future<ApiAiJob> finalizeCaptureBatch({
    required String batchId,
    required String kind,
    required String? ideaText,
    required DateTime capturedAt,
    required String? capturedLocalDate,
    required String captureDateSource,
    required String jobId,
    required String idempotencyKey,
    required String inputHash,
    required String inputVersion,
    required int maxAttempts,
  }) {
    readyBatchIds.add(batchId);
    return super.finalizeCaptureBatch(
      batchId: batchId,
      kind: kind,
      ideaText: ideaText,
      capturedAt: capturedAt,
      capturedLocalDate: capturedLocalDate,
      captureDateSource: captureDateSource,
      jobId: jobId,
      idempotencyKey: idempotencyKey,
      inputHash: inputHash,
      inputVersion: inputVersion,
      maxAttempts: maxAttempts,
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
  Future<void> deleteDishes({required List<String> dishIds}) async {
    deletedDishIds.addAll(dishIds);
  }

  @override
  Future<void> deleteCaptureBatch({required String batchId}) async {
    deletedBatchIds.add(batchId);
  }

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
  Future<ApiProcessingJob> createProcessingJob({
    required String operation,
    required String idempotencyKey,
    required String inputSchemaVersion,
    required String resultSchemaVersion,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) {
    throw const SocketException('No network');
  }
}

class _ReconnectApiClient extends FakeMyMenuApiClient {
  bool isOnline = false;
  final List<String> uploadedAssetIds = <String>[];

  @override
  Future<ApiProcessingJob> createProcessingJob({
    required String operation,
    required String idempotencyKey,
    required String inputSchemaVersion,
    required String resultSchemaVersion,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) {
    if (!isOnline) {
      throw const SocketException('No network');
    }
    return super.createProcessingJob(
      operation: operation,
      idempotencyKey: idempotencyKey,
      inputSchemaVersion: inputSchemaVersion,
      resultSchemaVersion: resultSchemaVersion,
      privacyNoticeVersion: privacyNoticeVersion,
      assets: assets,
    );
  }

  @override
  Future<void> uploadProcessingAsset({
    required ApiProcessingUploadTarget target,
    required String localPath,
  }) async {
    uploadedAssetIds.add(target.assetId);
    await super.uploadProcessingAsset(target: target, localPath: localPath);
  }
}

class _HangingReconnectApiClient extends _ReconnectApiClient {
  @override
  Future<ApiProcessingJob> createProcessingJob({
    required String operation,
    required String idempotencyKey,
    required String inputSchemaVersion,
    required String resultSchemaVersion,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) {
    if (!isOnline) {
      return Completer<ApiProcessingJob>().future;
    }
    return super.createProcessingJob(
      operation: operation,
      idempotencyKey: idempotencyKey,
      inputSchemaVersion: inputSchemaVersion,
      resultSchemaVersion: resultSchemaVersion,
      privacyNoticeVersion: privacyNoticeVersion,
      assets: assets,
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
  final List<String> uploadedAssetIds = <String>[];
  bool _failedOnce = false;

  @override
  Future<void> uploadProcessingAsset({
    required ApiProcessingUploadTarget target,
    required String localPath,
  }) async {
    uploadedAssetIds.add(target.assetId);
    if (uploadedAssetIds.length == 2 && !_failedOnce) {
      _failedOnce = true;
      throw StateError('Injected item upload failure');
    }
    await super.uploadProcessingAsset(target: target, localPath: localPath);
  }
}

class _ThrowingApiClient extends MyMenuApiClient {
  @override
  Future<ApiProcessingJob> createProcessingJob({
    required String operation,
    required String idempotencyKey,
    required String inputSchemaVersion,
    required String resultSchemaVersion,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) {
    throw StateError('Remote sync unavailable.');
  }

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
          batchId: 'capture_sync_result',
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
              captureId: 'capture_sync_result',
              cookingOccasionId: 'occasion_sync_result',
              capturedAt: DateTime.utc(2026, 6, 20, 12),
              confidenceLabel: 'AI',
            ),
          ],
          ingredients: const <String>['noodles'],
          steps: const <String>['Cook noodles.'],
          notes: const <String>['Synced from server.'],
          createdAt: DateTime.utc(2026, 6, 20, 11),
        ),
    ];
  }

  @override
  Future<List<ApiReviewItem>> getReviewItems(List<String> ids) async {
    return const <ApiReviewItem>[];
  }
}

class _DeleteThenHydrationFailureApiClient extends FakeMyMenuApiClient {
  @override
  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  }) async {
    return const ApiSyncPull(
      cursor: 2,
      hasMore: false,
      requiresBootstrap: false,
      events: <ApiSyncEvent>[
        ApiSyncEvent(
          cursor: 1,
          type: 'dish.deleted',
          entityIds: <String, String>{'dishId': 'emptied_ai_dish'},
        ),
        ApiSyncEvent(
          cursor: 2,
          type: 'dish.created',
          entityIds: <String, String>{'dishId': 'new_split_dish'},
        ),
      ],
    );
  }

  @override
  Future<List<ApiDish>> getDishes(List<String> ids) {
    throw StateError('Dish hydration failed.');
  }
}
