import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/core/files/dish_image_cache.dart';
import 'package:mymenu/core/files/image_derivative_store.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/domain/ai/ai_job.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_correction.dart';
import 'package:mymenu/domain/capture/capture_item.dart' as capture_domain;
import 'package:mymenu/domain/capture/capture_mappers.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/covers/cover_repository.dart';
import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/dish_mappers.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/planned_meal.dart' as planning_domain;
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:mymenu/domain/processing/processing_consent_repository.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_outbox_repository.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'repositories_dishes.dart';
part 'repositories_dish_deletion.dart';
part 'repositories_ai.dart';
part 'repositories_planning.dart';
part 'repositories_capture.dart';
part 'repositories_capture_fallback.dart';
part 'repositories_capture_deletion.dart';
part 'repositories_capture_corrections.dart';
part 'repositories_capture_bulk_corrections.dart';
part 'repositories_capture_correction_rollback.dart';
part 'repositories_capture_correction_support.dart';
part 'repositories_capture_sync.dart';
part 'repositories_capture_routing_adoption.dart';
part 'repositories_capture_routing_contract.dart';
part 'repositories_capture_processing_support.dart';
part 'repositories_cover_processing.dart';
part 'repositories_cover_processing_delivery.dart';
part 'repositories_dish_hydration.dart';
part 'repositories_dish_notes_query.dart';
part 'repositories_support.dart';
part 'repositories_media_previews.dart';
part 'repositories_sync.dart';
part 'repositories_sync_capture_adoption.dart';

const Set<String> _bundledMockImageRefs = <String>{
  'asset://assets/dish_art/miso-salmon.png',
  'asset://assets/dish_art/miso-salmon-improved.png',
  'asset://assets/dish_art/linguine.png',
  'asset://assets/dish_art/katsu.png',
  'asset://assets/dish_art/pho.png',
};

class AppRepositories {
  AppRepositories({
    required this.database,
    required this.apiClient,
    this.captureControlRequestTimeout = const Duration(seconds: 5),
    this.seedSampleDataOnPrepare = false,
    DishImageCache? dishImageCache,
    ImageDerivativeStore? imageDerivativeStore,
  }) {
    final DishImageCache resolvedImageCache =
        dishImageCache ?? DishImageCache();
    final ImageDerivativeStore resolvedDerivativeStore =
        imageDerivativeStore ?? ImageDerivativeStore();
    _prepareImagePreviewsOnBootstrap = imageDerivativeStore != null ||
        Platform.environment['FLUTTER_TEST'] != 'true';
    _imageDerivativeStore = resolvedDerivativeStore;
    dishRepository = DishRepository(
      database,
      resolvedImageCache,
      resolvedDerivativeStore,
    );
    coverRepository = CoverRepository(database);
    planRepository = PlanRepository(database);
    processingConsentRepository = ProcessingConsentRepository(database);
    processingOutboxRepository = ProcessingOutboxRepository(database);
    captureRepository = CaptureRepository(
      database,
      processingOutboxRepository,
      resolvedDerivativeStore,
    );
    captureCorrectionRepository = CaptureCorrectionRepository(database);
    aiJobRepository = AiJobRepository(database);
    syncRepository = SyncRepository(
      database,
      apiClient,
      controlRequestTimeout: captureControlRequestTimeout,
      dishImageCache: resolvedImageCache,
      imageDerivativeStore: resolvedDerivativeStore,
    );
  }

  final db.AppDatabase database;
  final MyMenuApiClient apiClient;
  final Duration captureControlRequestTimeout;
  @visibleForTesting
  final bool seedSampleDataOnPrepare;
  late final ImageDerivativeStore _imageDerivativeStore;
  late final bool _prepareImagePreviewsOnBootstrap;
  late final DishRepository dishRepository;
  late final CoverRepository coverRepository;
  late final PlanRepository planRepository;
  late final CaptureRepository captureRepository;
  late final ProcessingOutboxRepository processingOutboxRepository;
  late final ProcessingConsentRepository processingConsentRepository;
  late final CaptureCorrectionRepository captureCorrectionRepository;
  late final AiJobRepository aiJobRepository;
  late final SyncRepository syncRepository;

  @visibleForTesting
  Future<void> seedIfNeeded() async {
    await database.transaction(() async {
      final db.LocalSettingRow? marker =
          await (database.select(database.localSettings)
                ..where(
                  (db.LocalSettings table) => table.key.equals(
                    db.localSeedDataInitializedKey,
                  ),
                ))
              .getSingleOrNull();
      if (marker != null) {
        return;
      }
      await dishRepository._seedIfEmpty();
      await planRepository._seedIfEmpty();
      await database.into(database.localSettings).insert(
            db.LocalSettingsCompanion.insert(
              key: db.localSeedDataInitializedKey,
              value: 'true',
            ),
          );
    });
  }

  Future<void> prepareLocalData() async {
    if (seedSampleDataOnPrepare) {
      await seedIfNeeded();
    }
    await _removeBundledMockImageRefs();
    if (_prepareImagePreviewsOnBootstrap) {
      await _prepareImagePreviews();
    }
    await database.into(database.localSettings).insertOnConflictUpdate(
          db.LocalSettingsCompanion.insert(
            key: db.localSeedDataInitializedKey,
            value: 'true',
          ),
        );
  }

  Future<void> _removeBundledMockImageRefs() async {
    final List<db.DishRow> affectedDishes = await (database.select(
      database.dishes,
    )..where(
            (db.Dishes table) => table.heroImageUrl.isIn(_bundledMockImageRefs),
          ))
        .get();
    await (database.delete(database.sourcePhotos)
          ..where(
            (db.SourcePhotos table) => table.url.isIn(_bundledMockImageRefs),
          ))
        .go();

    for (final db.DishRow dish in affectedDishes) {
      final db.SourcePhotoRow? replacement = await (database.select(
        database.sourcePhotos,
      )
            ..where((db.SourcePhotos table) => table.dishId.equals(dish.id))
            ..limit(1))
          .getSingleOrNull();
      await (database.update(database.dishes)
            ..where((db.Dishes table) => table.id.equals(dish.id)))
          .write(
        db.DishesCompanion(
          heroImageUrl: Value<String>(replacement?.url ?? ''),
          heroPreviewUrl: Value<String?>(replacement?.previewUrl),
          heroThumbnailUrl: Value<String?>(replacement?.thumbnailUrl),
          heroPlaceholderUrl: Value<String?>(replacement?.placeholderUrl),
        ),
      );
    }
  }
}

class SyncRepository {
  SyncRepository(
    this._database,
    this._apiClient, {
    required Duration controlRequestTimeout,
    required DishImageCache dishImageCache,
    required ImageDerivativeStore imageDerivativeStore,
  })  : _controlRequestTimeout = controlRequestTimeout,
        _dishImageCache = dishImageCache,
        _imageDerivativeStore = imageDerivativeStore;

  final db.AppDatabase _database;
  final MyMenuApiClient _apiClient;
  final Duration _controlRequestTimeout;
  final DishImageCache _dishImageCache;
  final ImageDerivativeStore _imageDerivativeStore;
  static const String _captureSyncCursorKey = 'capture_sync_cursor';

  Future<void> processPendingOperations() async {
    final List<db.SyncOperationRow> operations =
        await (_database.select(_database.syncOperations)
              ..where(
                (db.SyncOperations table) =>
                    table.completedAt.isNull() &
                    (table.entity.equals('dish_note') |
                        table.entity.equals('dish') |
                        table.entity.equals('dish_collection') |
                        table.entity.equals('capture_item') |
                        table.entity.equals('capture_batch') |
                        table.entity.equals('capture_correction')),
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
        if (operation.entity == 'capture_correction' &&
            operation.operationType != 'undo' &&
            !_isNetworkFailure(error)) {
          await CaptureCorrectionRepository(_database).rollbackFailed(
            operation.entityId,
            error,
          );
          await (_database.update(_database.syncOperations)
                ..where(
                  (db.SyncOperations table) => table.id.equals(operation.id),
                ))
              .write(
            db.SyncOperationsCompanion(
              completedAt: Value<DateTime?>(DateTime.now()),
            ),
          );
        }
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
      return;
    }
    if (operation.entity == 'dish_collection' &&
        operation.operationType == 'delete') {
      await _apiClient.deleteDishes(
        dishIds: _payloadStringList(payload, 'dishIds'),
      );
      return;
    }
    if (operation.entity == 'capture_item' &&
        operation.operationType == 'delete') {
      await _apiClient.deleteCapture(captureId: operation.entityId);
      return;
    }
    if (operation.entity == 'capture_batch' &&
        operation.operationType == 'delete') {
      await _apiClient.deleteCaptureBatch(batchId: operation.entityId);
      return;
    }
    if (operation.entity == 'capture_correction') {
      if (operation.operationType == 'undo') {
        await _apiClient.undoCaptureGrouping(
          clientMutationId: operation.id,
          actionId: operation.entityId,
        );
        return;
      }
      await _apiClient.correctCaptureGrouping(
        clientMutationId: operation.id,
        batchId: _requiredPayloadString(payload, 'batchId'),
        actionType: operation.operationType,
        captureIds: _payloadStringList(payload, 'captureIds'),
        targetDishId: _requiredPayloadString(payload, 'targetDishId'),
        newDishTitle: payload['newDishTitle'] as String?,
      );
      await CaptureCorrectionRepository(_database)
          .markSynced(operation.entityId);
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

bool _isNetworkFailure(Object error) {
  if (error is SocketException || error is TimeoutException) {
    return true;
  }
  final String message = error.toString().toLowerCase();
  return message.contains('socket') ||
      message.contains('network') ||
      message.contains('connection') ||
      message.contains('timed out') ||
      message.contains('failed host lookup');
}
