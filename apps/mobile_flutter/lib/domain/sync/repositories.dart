import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/domain/ai/ai_job.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart' as capture_domain;
import 'package:mymenu/domain/capture/capture_mappers.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/dish_mappers.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/planned_meal.dart' as planning_domain;
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:uuid/uuid.dart';

part 'repositories_dishes.dart';
part 'repositories_ai.dart';
part 'repositories_planning.dart';
part 'repositories_capture.dart';
part 'repositories_capture_sync.dart';
part 'repositories_support.dart';
part 'repositories_sync.dart';

class AppRepositories {
  AppRepositories({
    required this.database,
    required this.apiClient,
    this.captureControlRequestTimeout = const Duration(seconds: 5),
  })  : dishRepository = DishRepository(database),
        planRepository = PlanRepository(database),
        captureRepository = CaptureRepository(database),
        aiJobRepository = AiJobRepository(database),
        syncRepository = SyncRepository(
          database,
          apiClient,
          controlRequestTimeout: captureControlRequestTimeout,
        );

  final db.AppDatabase database;
  final MyMenuApiClient apiClient;
  final Duration captureControlRequestTimeout;
  final DishRepository dishRepository;
  final PlanRepository planRepository;
  final CaptureRepository captureRepository;
  final AiJobRepository aiJobRepository;
  final SyncRepository syncRepository;

  Future<void> seedIfNeeded() async {
    await dishRepository.seedIfNeeded();
    await planRepository.seedIfNeeded();
  }
}

class SyncRepository {
  SyncRepository(
    this._database,
    this._apiClient, {
    required Duration controlRequestTimeout,
  }) : _controlRequestTimeout = controlRequestTimeout;

  final db.AppDatabase _database;
  final MyMenuApiClient _apiClient;
  final Duration _controlRequestTimeout;
  static const String _captureSyncCursorKey = 'capture_sync_cursor';

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

  Future<void> _processOperation(db.SyncOperationRow operation) async {
    final Map<String, Object?> payload = _payloadObject(operation.payloadJson);
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
}
