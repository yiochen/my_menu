import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mymenu/core/network/my_menu_api_models.dart';
import 'package:mymenu/core/network/my_menu_api_parsers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:mymenu/core/network/my_menu_api_models.dart';

part 'fake_my_menu_api_client.dart';
part 'fake_capture_record.dart';
part 'fake_capture_grouping.dart';
part 'my_menu_ai_api.dart';
part 'my_menu_api_config.dart';
part 'supabase_capture_api.dart';
part 'supabase_my_menu_api_helpers.dart';

abstract class MyMenuApiClient with AiJobApiDefaults {
  Future<void> upsertCaptureBatch({
    required String batchId,
    required int itemCount,
    required DateTime createdAt,
  });

  Future<String> uploadCaptureMedia({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
  });

  Future<String> uploadCaptureMediaWithMetadata({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
    required DateTime capturedAt,
    required String? capturedLocalDate,
    required String captureDateSource,
  }) {
    return uploadCaptureMedia(
      captureId: captureId,
      batchId: batchId,
      ordinal: ordinal,
      localMediaRef: localMediaRef,
    );
  }

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
    final DateTime now = DateTime.now();
    return Future<ApiAiJob>.value(
      ApiAiJob(
        id: jobId,
        jobType: 'batch_grouping',
        subjectId: batchId,
        status: 'queued',
        idempotencyKey: idempotencyKey,
        inputHash: inputHash,
        inputVersion: inputVersion,
        attemptCount: 0,
        maxAttempts: maxAttempts,
        promptVersion: 'batch-grouping-v2',
        modelVersion: 'server-selected',
        schemaVersion: 'batch-grouping-v2',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<List<ApiCaptureBatch>> getCaptureBatches(List<String> ids) async {
    return const <ApiCaptureBatch>[];
  }

  Future<void> deleteCapture({required String captureId}) {
    return Future<void>.error(
      UnsupportedError('Capture deletion is unavailable.'),
    );
  }

  Future<void> deleteCaptureBatch({required String batchId}) {
    return Future<void>.error(
      UnsupportedError('Capture batch deletion is unavailable.'),
    );
  }

  Future<void> correctCaptureGrouping({
    required String clientMutationId,
    required String batchId,
    required String actionType,
    required List<String> captureIds,
    required String targetDishId,
    String? newDishTitle,
  }) {
    return Future<void>.error(
      UnsupportedError('Capture grouping correction is unavailable.'),
    );
  }

  Future<void> undoCaptureGrouping({
    required String clientMutationId,
    required String actionId,
  }) {
    return Future<void>.error(
      UnsupportedError('Capture grouping undo is unavailable.'),
    );
  }

  Future<void> createDishNote({
    required String noteId,
    required String dishId,
    required String body,
    required int position,
  });

  Future<void> updateDishNote({
    required String noteId,
    required String body,
    required int? position,
  });

  Future<void> deleteDishNote({required String noteId});

  Future<void> deleteDishes({required List<String> dishIds}) {
    return Future<void>.error(
      UnsupportedError('Dish deletion is unavailable.'),
    );
  }

  Future<void> updateDish({
    required String clientMutationId,
    required String dishId,
    required Map<String, Object?> patch,
  });

  Future<ApiSyncPull> pullSync({required int afterCursor, required int limit});

  Future<List<ApiCapture>> getCaptures(List<String> ids);

  Future<List<ApiDish>> getDishes(List<String> ids);

  Future<List<ApiReviewItem>> getReviewItems(List<String> ids);
}

class SupabaseMyMenuApiClient extends MyMenuApiClient with SupabaseCaptureApi {
  SupabaseMyMenuApiClient({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  final SupabaseClient _client;

  @override
  Future<ApiAiJob> scheduleAiJob({
    required String jobId,
    required String jobType,
    required String subjectId,
    required String idempotencyKey,
    required String inputHash,
    required String inputVersion,
    required String promptVersion,
    required String modelVersion,
    required String schemaVersion,
    required int maxAttempts,
  }) async {
    return _singleAiJobRpc(this, 'api_schedule_ai_job', <String, Object?>{
      'p_job_id': jobId,
      'p_job_type': jobType,
      'p_subject_id': subjectId,
      'p_idempotency_key': idempotencyKey,
      'p_input_hash': inputHash,
      'p_input_version': inputVersion,
      'p_prompt_version': promptVersion,
      'p_model_version': modelVersion,
      'p_schema_version': schemaVersion,
      'p_max_attempts': maxAttempts,
    });
  }

  @override
  Future<List<ApiAiJob>> getAiJobs(List<String> ids) {
    return _getAiJobs(this, ids);
  }

  @override
  Future<ApiAiJob> retryAiJob({required String jobId}) {
    return _singleAiJobRpc(this, 'api_retry_ai_job', <String, Object?>{
      'p_job_id': jobId,
    });
  }

  @override
  Future<ApiAiJob> cancelAiJob({required String jobId}) {
    return _singleAiJobRpc(this, 'api_cancel_ai_job', <String, Object?>{
      'p_job_id': jobId,
    });
  }

  @override
  Future<void> createDishNote({
    required String noteId,
    required String dishId,
    required String body,
    required int position,
  }) async {
    await _ensureSession();
    await _invokeJson('createDishNote', <String, Object?>{
      'noteId': noteId,
      'dishId': dishId,
      'body': body,
      'position': position,
    });
  }

  @override
  Future<void> updateDishNote({
    required String noteId,
    required String body,
    required int? position,
  }) async {
    await _ensureSession();
    await _invokeJson('updateDishNote', <String, Object?>{
      'noteId': noteId,
      'body': body,
      if (position != null) 'position': position,
    });
  }

  @override
  Future<void> deleteDishNote({required String noteId}) async {
    await _ensureSession();
    await _invokeJson('deleteDishNote', <String, Object?>{'noteId': noteId});
  }

  @override
  Future<void> deleteDishes({required List<String> dishIds}) async {
    if (dishIds.isEmpty) {
      return;
    }
    await _ensureSession();
    await _invokeJson('delete-dishes', <String, Object?>{'dishIds': dishIds});
  }

  @override
  Future<void> updateDish({
    required String clientMutationId,
    required String dishId,
    required Map<String, Object?> patch,
  }) async {
    await _ensureSession();
    await _invokeJson('updateDish', <String, Object?>{
      'clientMutationId': clientMutationId,
      'dishId': dishId,
      'patch': patch,
    });
  }

  @override
  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  }) async {
    await _ensureSession();

    final Map<String, Object?> data = await _invokeJson(
      'sync-pull',
      <String, Object?>{'afterCursor': afterCursor, 'limit': limit},
    );

    return ApiSyncPull(
      cursor: apiIntValue(data, 'cursor'),
      hasMore: apiBoolValue(data, 'hasMore'),
      requiresBootstrap: apiBoolValue(data, 'requiresBootstrap'),
      events: apiListValue(
        data,
        'events',
      ).map(apiSyncEventFromJson).toList(growable: false),
    );
  }

  @override
  Future<List<ApiCapture>> getCaptures(List<String> ids) async {
    if (ids.isEmpty) {
      return const <ApiCapture>[];
    }
    await _ensureSession();

    final Map<String, Object?> data = await _invokeJson(
      'get-captures',
      <String, Object?>{'ids': ids},
    );
    return apiListValue(
      data,
      'items',
    ).map(apiCaptureFromJson).toList(growable: false);
  }

  @override
  Future<List<ApiDish>> getDishes(List<String> ids) async {
    if (ids.isEmpty) {
      return const <ApiDish>[];
    }
    await _ensureSession();

    final Map<String, Object?> data = await _invokeJson(
      'get-dishes',
      <String, Object?>{'ids': ids},
    );
    return apiListValue(
      data,
      'items',
    ).map(apiDishFromJson).toList(growable: false);
  }

  @override
  Future<List<ApiReviewItem>> getReviewItems(List<String> ids) async {
    if (ids.isEmpty) {
      return const <ApiReviewItem>[];
    }
    await _ensureSession();

    final Map<String, Object?> data = await _invokeJson(
      'get-review-items',
      <String, Object?>{'ids': ids},
    );
    return apiListValue(
      data,
      'items',
    ).map(apiReviewItemFromJson).toList(growable: false);
  }

  @override
  Future<void> _ensureSession() async {
    if (_client.auth.currentSession != null) {
      return;
    }
    _logApi('signInAnonymously start');
    await _client.auth.signInAnonymously();
    _logApi('signInAnonymously complete');
  }

  @override
  Future<Map<String, Object?>> _invokeJson(
    String functionName,
    Map<String, Object?> body,
  ) {
    return _invokeSupabaseJson(this, functionName, body);
  }
}
