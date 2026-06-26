import 'dart:convert';
import 'dart:developer' as developer;

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

part 'repositories_dishes.dart';

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

      try {
        final Dish? dish = await _processCapture(capture);
        if (dish != null) {
          createdDishes.add(dish);
        }
      } on Object catch (error, stackTrace) {
        developer.log(
          'Capture sync failed.',
          name: 'mymenu.sync',
          error: error,
          stackTrace: stackTrace,
        );
        await _markCaptureFailed(capture.id);
      }
    }
    return createdDishes;
  }

  Future<void> processPendingOperations() async {
    final List<db.SyncOperationRow> operations =
        await (_database.select(_database.syncOperations)
              ..where(
                (db.SyncOperations table) =>
                    table.completedAt.isNull() &
                    (table.entity.equals('dish_note') |
                        table.entity.equals('dish')),
              )
              ..orderBy(<OrderingTerm Function(db.$SyncOperationsTable)>[
                (db.SyncOperations table) => OrderingTerm.asc(table.createdAt),
              ]))
            .get();

    for (final db.SyncOperationRow operation in operations) {
      try {
        await _processOperation(operation);
        await (_database.update(_database.syncOperations)
              ..where(
                (db.SyncOperations table) => table.id.equals(operation.id),
              ))
            .write(
          db.SyncOperationsCompanion(
            completedAt: Value<DateTime?>(DateTime.now()),
          ),
        );
      } on Object catch (error, stackTrace) {
        developer.log(
          'Edit sync failed.',
          name: 'mymenu.sync',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<Dish?> _processCapture(db.CaptureItemRow capture) async {
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

    final ApiClassificationStart result = await _apiClient.classifyCapture(
      captureId: capture.id,
      remoteMediaRef: remoteMediaRef,
      ideaText: capture.ideaText,
    );
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(capture.id)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(result.status),
        remoteMediaRef: Value<String?>(remoteMediaRef),
      ),
    );
    return null;
  }

  Future<void> _markCaptureFailed(String captureId) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(captureId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(capture_domain.CaptureItemStatus.failed.name),
      ),
    );
  }

  Future<void> _processOperation(db.SyncOperationRow operation) async {
    final Map<String, Object?> payload =
        _payloadObject(operation.payloadJson);
    if (operation.entity == 'dish_note') {
      await _processNoteOperation(operation, payload);
      return;
    }
    if (operation.entity == 'dish' && operation.operationType == 'update') {
      await _apiClient.updateDish(
        clientMutationId: operation.id,
        dishId: operation.entityId,
        patch: payload,
      );
    }
  }

  Future<void> _processNoteOperation(
    db.SyncOperationRow operation,
    Map<String, Object?> payload,
  ) async {
    switch (operation.operationType) {
      case 'create':
        await _apiClient.createDishNote(
          noteId: operation.entityId,
          dishId: _requiredPayloadString(payload, 'dishId'),
          body: _requiredPayloadString(payload, 'body'),
          position: _payloadInt(payload, 'position') ?? 0,
        );
      case 'update':
        await _apiClient.updateDishNote(
          noteId: operation.entityId,
          body: _requiredPayloadString(payload, 'body'),
          position: _payloadInt(payload, 'position'),
        );
      case 'delete':
        await _apiClient.deleteDishNote(noteId: operation.entityId);
    }
  }

  Map<String, Object?> _payloadObject(String payloadJson) {
    final Object? decoded = jsonDecode(payloadJson);
    if (decoded is Map<String, dynamic>) {
      return Map<String, Object?>.from(decoded);
    }
    return const <String, Object?>{};
  }

  String _requiredPayloadString(Map<String, Object?> payload, String key) {
    final Object? value = payload[key];
    if (value is String) {
      return value;
    }
    throw StateError('Missing payload string: $key');
  }

  int? _payloadInt(Map<String, Object?> payload, String key) {
    final Object? value = payload[key];
    return value is int ? value : null;
  }
}
