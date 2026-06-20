import 'package:drift/drift.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/domain/capture/capture_item.dart' as capture_domain;
import 'package:mymenu/domain/capture/capture_mappers.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/dish_mappers.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/planned_meal.dart' as planning_domain;
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:uuid/uuid.dart';

class AppRepositories {
  AppRepositories({
    required this.database,
    required this.apiClient,
  })  : dishRepository = DishRepository(database),
        planRepository = PlanRepository(database),
        captureRepository = CaptureRepository(database),
        syncRepository = SyncRepository(database, apiClient);

  final db.AppDatabase database;
  final MyMenuApiClient apiClient;
  final DishRepository dishRepository;
  final PlanRepository planRepository;
  final CaptureRepository captureRepository;
  final SyncRepository syncRepository;

  Future<void> seedIfNeeded() async {
    await dishRepository.seedIfNeeded();
    await planRepository.seedIfNeeded();
  }
}

class DishRepository {
  DishRepository(this._database);

  final db.AppDatabase _database;

  Future<void> seedIfNeeded() async {
    final int existingCount =
        await _database.select(_database.dishes).get().then(
              (List<db.DishRow> rows) => rows.length,
            );
    if (existingCount > 0) {
      return;
    }

    await _database.batch((Batch batch) {
      for (final Dish dish in seededDishes) {
        batch.insert(_database.dishes, dish.toCompanion());
        for (int index = 0; index < dish.sourcePhotos.length; index += 1) {
          final SourcePhoto photo = dish.sourcePhotos[index];
          batch.insert(
            _database.sourcePhotos,
            db.SourcePhotosCompanion.insert(
              id: '${dish.id}_source_$index',
              dishId: dish.id,
              url: photo.url,
              capturedLabel: photo.capturedLabel,
              note: Value<String?>(photo.note),
              confidenceLabel: Value<String?>(photo.confidenceLabel),
            ),
          );
        }
      }
    });
  }

  Future<List<Dish>> listDishes() async {
    final List<db.DishRow> rows =
        await _database.select(_database.dishes).get();
    final List<Dish> dishes = <Dish>[];
    for (final db.DishRow row in rows) {
      final List<db.SourcePhotoRow> photoRows = await (_database.select(
        _database.sourcePhotos,
      )..where((db.SourcePhotos table) => table.dishId.equals(row.id)))
          .get();
      dishes.add(
        row.toDomain(
          photoRows.map((db.SourcePhotoRow row) => row.toDomain()).toList(),
        ),
      );
    }
    return dishes;
  }

  Future<void> upsertDish(Dish dish) async {
    await _database
        .into(_database.dishes)
        .insertOnConflictUpdate(dish.toCompanion());
  }
}

class PlanRepository {
  PlanRepository(this._database);

  final db.AppDatabase _database;

  Future<void> seedIfNeeded() async {
    final List<db.PlannedMealRow> rows =
        await _database.select(_database.plannedMeals).get();
    if (rows.isNotEmpty) {
      return;
    }

    await _database.batch((Batch batch) {
      for (final planning_domain.PlannedMeal meal in buildSeededPlan()) {
        batch.insert(
          _database.plannedMeals,
          db.PlannedMealsCompanion.insert(
            id: meal.id,
            dayKey: meal.dayKey,
            dishId: meal.dishId,
            label: Value<String?>(meal.label),
          ),
        );
      }
    });
  }
}

class CaptureRepository {
  CaptureRepository(this._database);

  final db.AppDatabase _database;
  final Uuid _uuid = const Uuid();

  Future<List<capture_domain.CaptureItem>> listFeedItems() async {
    final List<db.CaptureItemRow> rows =
        await (_database.select(_database.captureItems)
              ..orderBy(<OrderingTerm Function(db.$CaptureItemsTable)>[
                (db.CaptureItems table) => OrderingTerm.desc(table.createdAt),
              ]))
            .get();
    return rows.map((db.CaptureItemRow row) => row.toDomain()).toList();
  }

  Future<List<String>> createPhotoCaptures(List<String> imageRefs) async {
    final List<String> ids = <String>[];
    await _database.batch((Batch batch) {
      for (final String imageRef in imageRefs) {
        final String trimmed = imageRef.trim();
        if (trimmed.isEmpty) {
          continue;
        }
        final String id = _uuid.v4();
        ids.add(id);
        batch.insert(
          _database.captureItems,
          db.CaptureItemsCompanion.insert(
            id: id,
            kind: capture_domain.CaptureItemKind.photo.name,
            status: capture_domain.CaptureItemStatus.pendingUpload.name,
            createdAt: DateTime.now(),
            localMediaRef: Value<String?>(trimmed),
          ),
        );
        _enqueueSync(batch, id, 'capture_item', 'upsert');
      }
    });
    return ids;
  }

  Future<String?> createIdeaCapture(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final String id = _uuid.v4();
    await _database.into(_database.captureItems).insert(
          db.CaptureItemsCompanion.insert(
            id: id,
            kind: capture_domain.CaptureItemKind.idea.name,
            status: capture_domain.CaptureItemStatus.classifying.name,
            createdAt: DateTime.now(),
            ideaText: Value<String?>(trimmed),
          ),
        );
    await _database.into(_database.syncOperations).insert(
          db.SyncOperationsCompanion.insert(
            id: _uuid.v4(),
            entity: 'capture_item',
            entityId: id,
            operationType: 'upsert',
            payloadJson: '{}',
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<void> discardCapture(String captureId) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(captureId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(capture_domain.CaptureItemStatus.discarded.name),
      ),
    );
    await _database.into(_database.syncOperations).insert(
          db.SyncOperationsCompanion.insert(
            id: _uuid.v4(),
            entity: 'capture_item',
            entityId: captureId,
            operationType: 'discard',
            payloadJson: '{}',
            createdAt: DateTime.now(),
          ),
        );
  }

  void _enqueueSync(
    Batch batch,
    String entityId,
    String entity,
    String operationType,
  ) {
    batch.insert(
      _database.syncOperations,
      db.SyncOperationsCompanion.insert(
        id: _uuid.v4(),
        entity: entity,
        entityId: entityId,
        operationType: operationType,
        payloadJson: '{}',
        createdAt: DateTime.now(),
      ),
    );
  }
}

class SyncRepository {
  SyncRepository(this._database, this._apiClient);

  final db.AppDatabase _database;
  final MyMenuApiClient _apiClient;

  Future<List<Dish>> processPendingCaptures() async {
    final List<db.CaptureItemRow> captures =
        await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) =>
                    table.status.equals(
                      capture_domain.CaptureItemStatus.pendingUpload.name,
                    ) |
                    table.status.equals(
                      capture_domain.CaptureItemStatus.classifying.name,
                    ),
              ))
            .get();
    final List<Dish> createdDishes = <Dish>[];

    for (final db.CaptureItemRow capture in captures) {
      if (capture.status == capture_domain.CaptureItemStatus.discarded.name) {
        continue;
      }

      String? remoteMediaRef = capture.remoteMediaRef;
      if (capture.kind == capture_domain.CaptureItemKind.photo.name &&
          capture.localMediaRef != null &&
          remoteMediaRef == null) {
        remoteMediaRef = await _apiClient.uploadCaptureMedia(
          captureId: capture.id,
          localMediaRef: capture.localMediaRef!,
        );
        await (_database.update(_database.captureItems)
              ..where((db.CaptureItems table) => table.id.equals(capture.id)))
            .write(
          db.CaptureItemsCompanion(
            status: Value<String>(
              capture_domain.CaptureItemStatus.classifying.name,
            ),
            remoteMediaRef: Value<String?>(remoteMediaRef),
          ),
        );
      }

      final ApiCaptureResult result = await _apiClient.classifyCapture(
        captureId: capture.id,
        remoteMediaRef: remoteMediaRef,
        ideaText: capture.ideaText,
      );
      final Dish dish = _dishFromApiResult(result, capture);
      await _database.transaction(() async {
        await _database
            .into(_database.dishes)
            .insertOnConflictUpdate(dish.toCompanion());
        if (capture.kind == capture_domain.CaptureItemKind.photo.name) {
          await _database.into(_database.sourcePhotos).insert(
                db.SourcePhotosCompanion.insert(
                  id: 'source_${capture.id}',
                  dishId: dish.id,
                  url: capture.localMediaRef ?? result.mediaRef,
                  capturedLabel: 'Today',
                  note: const Value<String?>('Created from capture.'),
                  confidenceLabel: const Value<String?>('Fake API'),
                ),
              );
        }
        await (_database.update(_database.captureItems)
              ..where((db.CaptureItems table) => table.id.equals(capture.id)))
            .write(
          db.CaptureItemsCompanion(
            status:
                Value<String>(capture_domain.CaptureItemStatus.applied.name),
            remoteMediaRef: Value<String?>(remoteMediaRef),
            appliedDishId: Value<String?>(dish.id),
          ),
        );
      });
      createdDishes.add(dish);
    }
    return createdDishes;
  }

  Dish _dishFromApiResult(ApiCaptureResult result, db.CaptureItemRow capture) {
    final String heroImage = capture.localMediaRef ??
        result.mediaRef.ifEmpty(seededDishes.first.heroImageUrl);
    return Dish(
      id: result.dishId,
      title: result.title,
      description: result.description,
      heroImageUrl: heroImage,
      category: result.category,
      prepMinutes: 30,
      difficulty: 'Easy',
      madeCount:
          capture.kind == capture_domain.CaptureItemKind.photo.name ? 1 : 0,
      lastMadeLabel: capture.kind == capture_domain.CaptureItemKind.photo.name
          ? 'Today'
          : 'Not cooked yet',
      ingredients: const <String>['AI draft ingredient'],
      recipeSteps: const <String>['Review and edit this AI-assisted draft.'],
      notes: const <String>['Created by fake API classification.'],
      sourcePhotos: capture.kind == capture_domain.CaptureItemKind.photo.name
          ? <SourcePhoto>[
              SourcePhoto(
                url: heroImage,
                capturedLabel: 'Today',
                note: 'Created from capture.',
                confidenceLabel: 'Fake API',
              ),
            ]
          : const <SourcePhoto>[],
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
