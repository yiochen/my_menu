import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart' as capture_domain;
import 'package:mymenu/domain/capture/capture_mappers.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/dish_mappers.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/planned_meal.dart' as planning_domain;
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:uuid/uuid.dart';

part 'repositories_dishes.dart';
part 'repositories_planning.dart';
part 'repositories_capture.dart';
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

  Future<List<Dish>> processPendingCaptures() async {
    final List<db.CaptureBatchRow> batches =
        await (_database.select(_database.captureBatches)
              ..where(
                (db.$CaptureBatchesTable table) =>
                    table.status.equals(CaptureBatchStatus.pendingUpload.name) |
                    table.status.equals(CaptureBatchStatus.uploading.name) |
                    table.status.equals(CaptureBatchStatus.failed.name),
              )
              ..orderBy(<OrderingTerm Function(db.$CaptureBatchesTable)>[
                (db.$CaptureBatchesTable table) =>
                    OrderingTerm.asc(table.createdAt),
              ]))
            .get();
    _logSync('processPendingCaptureBatches count=${batches.length}');
    for (final db.CaptureBatchRow batch in batches) {
      await _processPhotoBatch(batch);
    }

    final List<db.CaptureItemRow> ideaCaptures = await (_database
            .select(_database.captureItems)
          ..where(
            (db.CaptureItems table) =>
                table.kind.equals(capture_domain.CaptureItemKind.idea.name) &
                table.status
                    .equals(capture_domain.CaptureItemStatus.classifying.name),
          ))
        .get();
    for (final db.CaptureItemRow capture in ideaCaptures) {
      try {
        final ApiClassificationStart result = await _apiClient.classifyCapture(
          captureId: capture.id,
          remoteMediaRef: null,
          ideaText: capture.ideaText,
        );
        await (_database.update(_database.captureItems)
              ..where((db.CaptureItems table) => table.id.equals(capture.id)))
            .write(
          db.CaptureItemsCompanion(status: Value<String>(result.status)),
        );
      } on Object catch (error, stackTrace) {
        _logSync('idea sync failed id=${capture.id}', error, stackTrace);
        await _markCaptureFailed(capture.id);
      }
    }
    return const <Dish>[];
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

  Future<void> _processPhotoBatch(db.CaptureBatchRow batch) async {
    final List<db.CaptureItemRow> initialItems = await _itemsForBatch(batch.id);
    final List<db.CaptureItemRow> photoItems = initialItems
        .where(
          (db.CaptureItemRow item) =>
              item.kind == capture_domain.CaptureItemKind.photo.name &&
              item.status != capture_domain.CaptureItemStatus.discarded.name,
        )
        .toList(growable: false);
    if (photoItems.isEmpty) {
      return;
    }

    try {
      await _apiClient
          .upsertCaptureBatch(
            batchId: batch.id,
            itemCount: photoItems.length,
            createdAt: batch.createdAt,
          )
          .timeout(_controlRequestTimeout);
      await _markBatchStatus(batch.id, CaptureBatchStatus.uploading);
    } on Object catch (error, stackTrace) {
      _logSync('batch upsert failed id=${batch.id}', error, stackTrace);
      if (_isConnectivityError(error)) {
        await _markBatchStatus(
          batch.id,
          CaptureBatchStatus.pendingUpload,
          failureReason: captureWaitingForConnectionReason,
        );
      } else {
        await _markBatchStatus(
          batch.id,
          CaptureBatchStatus.failed,
          failureReason: error.toString(),
        );
      }
      return;
    }

    for (final db.CaptureItemRow item in photoItems) {
      if (item.remoteMediaRef != null ||
          item.status == capture_domain.CaptureItemStatus.failed.name) {
        continue;
      }
      final String? localMediaRef = item.localMediaRef;
      if (localMediaRef == null) {
        await _markCaptureFailed(item.id, 'Missing local photo.');
        continue;
      }
      await _markCaptureStatus(
        item.id,
        capture_domain.CaptureItemStatus.uploading,
      );
      try {
        final String remoteMediaRef = await _apiClient.uploadCaptureMedia(
          captureId: item.id,
          batchId: batch.id,
          ordinal: item.ordinal,
          localMediaRef: localMediaRef,
        );
        await _markCaptureStatus(
          item.id,
          capture_domain.CaptureItemStatus.uploaded,
          remoteMediaRef: remoteMediaRef,
        );
      } on Object catch (error, stackTrace) {
        _logSync('capture upload failed id=${item.id}', error, stackTrace);
        if (_isConnectivityError(error)) {
          await _markCaptureStatus(
            item.id,
            capture_domain.CaptureItemStatus.pendingUpload,
          );
        } else {
          await _markCaptureFailed(item.id, error.toString());
        }
      }
    }

    final List<db.CaptureItemRow> refreshed = await _itemsForBatch(batch.id);
    final List<db.CaptureItemRow> activePhotos = refreshed
        .where(
          (db.CaptureItemRow item) =>
              item.kind == capture_domain.CaptureItemKind.photo.name &&
              item.status != capture_domain.CaptureItemStatus.discarded.name,
        )
        .toList(growable: false);
    final bool allUploaded = activePhotos.isNotEmpty &&
        activePhotos.every(
          (db.CaptureItemRow item) => item.remoteMediaRef != null,
        );
    if (!allUploaded) {
      final bool waitingForConnection = activePhotos.any(
        (db.CaptureItemRow item) =>
            item.remoteMediaRef == null &&
            item.status == capture_domain.CaptureItemStatus.pendingUpload.name,
      );
      if (waitingForConnection) {
        await _markBatchStatus(
          batch.id,
          CaptureBatchStatus.pendingUpload,
          failureReason: captureWaitingForConnectionReason,
        );
      }
      return;
    }

    try {
      await _apiClient
          .markCaptureBatchReady(batchId: batch.id)
          .timeout(_controlRequestTimeout);
      await _markBatchStatus(batch.id, CaptureBatchStatus.readyForAi);
    } on Object catch (error, stackTrace) {
      _logSync('batch ready failed id=${batch.id}', error, stackTrace);
      if (!_isConnectivityError(error)) {
        await _markBatchStatus(
          batch.id,
          CaptureBatchStatus.failed,
          failureReason: error.toString(),
        );
      }
    }
  }

  Future<List<db.CaptureItemRow>> _itemsForBatch(String batchId) {
    return (_database.select(_database.captureItems)
          ..where(
            (db.CaptureItems table) => table.batchId.equals(batchId),
          )
          ..orderBy(<OrderingTerm Function(db.$CaptureItemsTable)>[
            (db.$CaptureItemsTable table) => OrderingTerm.asc(table.ordinal),
          ]))
        .get();
  }

  Future<void> _markCaptureStatus(
    String captureId,
    capture_domain.CaptureItemStatus status, {
    String? remoteMediaRef,
  }) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(captureId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(status.name),
        remoteMediaRef: remoteMediaRef == null
            ? const Value<String?>.absent()
            : Value<String?>(remoteMediaRef),
        failureReason: const Value<String?>(null),
      ),
    );
  }

  Future<void> _markCaptureFailed(
    String captureId, [
    String? failureReason,
  ]) async {
    await (_database.update(_database.captureItems)
          ..where((db.CaptureItems table) => table.id.equals(captureId)))
        .write(
      db.CaptureItemsCompanion(
        status: Value<String>(capture_domain.CaptureItemStatus.failed.name),
        failureReason: Value<String?>(failureReason),
      ),
    );
  }

  Future<void> _markBatchStatus(
    String batchId,
    CaptureBatchStatus status, {
    String? failureReason,
  }) async {
    await (_database.update(_database.captureBatches)
          ..where((db.$CaptureBatchesTable table) => table.id.equals(batchId)))
        .write(
      db.CaptureBatchesCompanion(
        status: Value<String>(status.name),
        updatedAt: Value<DateTime>(DateTime.now()),
        failureReason: Value<String?>(failureReason),
      ),
    );
  }

  bool _isConnectivityError(Object error) {
    if (error is SocketException) {
      return true;
    }
    if (error is TimeoutException) {
      return true;
    }
    final String message = error.toString().toLowerCase();
    return message.contains('socket') ||
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('timed out') ||
        message.contains('failed host lookup');
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
