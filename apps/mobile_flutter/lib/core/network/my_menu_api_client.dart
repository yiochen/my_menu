import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mymenu/core/network/my_menu_api_models.dart';
import 'package:mymenu/core/network/my_menu_api_parsers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:mymenu/core/network/my_menu_api_models.dart';

part 'fake_my_menu_api_client.dart';

class SupabaseApiConfig {
  const SupabaseApiConfig._();

  static const String apiMode = String.fromEnvironment(
    'MY_MENU_API_MODE',
    defaultValue: 'auto',
  );
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static bool get shouldUseSupabase {
    switch (apiMode) {
      case 'auto':
        return isConfigured;
      case 'fake':
        return false;
      case 'supabase':
        if (!isConfigured) {
          throw StateError(
            'MY_MENU_API_MODE=supabase requires SUPABASE_URL and '
            'SUPABASE_ANON_KEY.',
          );
        }
        return true;
      default:
        throw StateError(
          'Unsupported MY_MENU_API_MODE "$apiMode". Use auto, fake, or '
          'supabase.',
        );
    }
  }
}

abstract class MyMenuApiClient {
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String localMediaRef,
  });

  Future<ApiClassificationStart> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  });

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

  Future<void> updateDish({
    required String clientMutationId,
    required String dishId,
    required Map<String, Object?> patch,
  });

  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  });

  Future<List<ApiCapture>> getCaptures(List<String> ids);

  Future<List<ApiDish>> getDishes(List<String> ids);

  Future<List<ApiReviewItem>> getReviewItems(List<String> ids);
}

class SupabaseMyMenuApiClient implements MyMenuApiClient {
  SupabaseMyMenuApiClient({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String localMediaRef,
  }) async {
    await _ensureSession();

    final Uint8List bytes = await File(localMediaRef).readAsBytes();
    final String contentType = _contentTypeForPath(localMediaRef);
    _logApi(
      'uploadCaptureMedia start captureId=$captureId '
      'contentType=$contentType bytes=${bytes.length}',
    );
    final Map<String, Object?> prepare = await _invokeJson(
      'prepare-photo-upload',
      <String, Object?>{
        'captureId': captureId,
        'contentType': contentType,
        'byteSize': bytes.length,
      },
    );

    final Map<String, Object?> upload = apiMapValue(prepare, 'upload');
    final String storagePath = apiStringValue(prepare, 'storagePath');
    final String token = apiStringValue(upload, 'token');

    _logApi('uploadCaptureMedia storage upload start captureId=$captureId');
    await _client.storage.from('menu-media').uploadBinaryToSignedUrl(
          storagePath,
          token,
          bytes,
          FileOptions(contentType: contentType, upsert: true),
        );
    _logApi('uploadCaptureMedia storage upload complete captureId=$captureId');

    final Map<String, Object?> created = await _invokeJson(
      'create-photo',
      <String, Object?>{
        'captureId': captureId,
        'storagePath': storagePath,
        'contentType': contentType,
        'byteSize': bytes.length,
        'capturedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
    final Map<String, Object?> image = apiMapValue(created, 'image');
    final String mediaRef = apiStringValue(image, 'mediaRef');
    _logApi('uploadCaptureMedia complete captureId=$captureId');
    return mediaRef;
  }

  @override
  Future<ApiClassificationStart> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  }) async {
    await _ensureSession();

    final Map<String, Object?> data = await _invokeJson(
      'classify',
      <String, Object?>{
        'captureId': captureId,
        if (remoteMediaRef != null) 'remoteMediaRef': remoteMediaRef,
        if (ideaText != null) 'ideaText': ideaText,
      },
    );

    return ApiClassificationStart(
      captureId: apiStringValue(data, 'captureId'),
      status: apiStringValue(data, 'status'),
    );
  }

  @override
  Future<void> createDishNote({
    required String noteId,
    required String dishId,
    required String body,
    required int position,
  }) async {
    await _ensureSession();
    await _invokeJson(
      'createDishNote',
      <String, Object?>{
        'noteId': noteId,
        'dishId': dishId,
        'body': body,
        'position': position,
      },
    );
  }

  @override
  Future<void> updateDishNote({
    required String noteId,
    required String body,
    required int? position,
  }) async {
    await _ensureSession();
    await _invokeJson(
      'updateDishNote',
      <String, Object?>{
        'noteId': noteId,
        'body': body,
        if (position != null) 'position': position,
      },
    );
  }

  @override
  Future<void> deleteDishNote({required String noteId}) async {
    await _ensureSession();
    await _invokeJson(
      'deleteDishNote',
      <String, Object?>{'noteId': noteId},
    );
  }

  @override
  Future<void> updateDish({
    required String clientMutationId,
    required String dishId,
    required Map<String, Object?> patch,
  }) async {
    await _ensureSession();
    await _invokeJson(
      'updateDish',
      <String, Object?>{
        'clientMutationId': clientMutationId,
        'dishId': dishId,
        'patch': patch,
      },
    );
  }

  @override
  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  }) async {
    await _ensureSession();

    final Map<String, Object?> data = await _invokeJson(
      'sync-pull',
      <String, Object?>{
        'afterCursor': afterCursor,
        'limit': limit,
      },
    );

    return ApiSyncPull(
      cursor: apiIntValue(data, 'cursor'),
      hasMore: apiBoolValue(data, 'hasMore'),
      requiresBootstrap: apiBoolValue(data, 'requiresBootstrap'),
      events: apiListValue(data, 'events')
          .map(apiSyncEventFromJson)
          .toList(growable: false),
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
    return apiListValue(data, 'items')
        .map(apiCaptureFromJson)
        .toList(growable: false);
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
    return apiListValue(data, 'items')
        .map(apiDishFromJson)
        .toList(growable: false);
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
    return apiListValue(data, 'items')
        .map(apiReviewItemFromJson)
        .toList(growable: false);
  }

  Future<void> _ensureSession() async {
    if (_client.auth.currentSession != null) {
      return;
    }
    _logApi('signInAnonymously start');
    await _client.auth.signInAnonymously();
    _logApi('signInAnonymously complete');
  }

  Future<Map<String, Object?>> _invokeJson(
    String functionName,
    Map<String, Object?> body,
  ) async {
    _logApi('invoke $functionName start');
    final FunctionResponse response;
    try {
      response = await _client.functions.invoke(
        functionName,
        body: body,
      );
    } on Object catch (error, stackTrace) {
      _logApi('invoke $functionName threw', error, stackTrace);
      rethrow;
    }
    _logApi('invoke $functionName status=${response.status}');
    if (response.status < 200 || response.status >= 300) {
      throw StateError(
        'Supabase function failed: ${response.status} ${response.data}',
      );
    }
    final Object? data = response.data;
    if (data is Map<String, dynamic>) {
      return Map<String, Object?>.from(data);
    }
    if (data is Map<String, Object?>) {
      return data;
    }
    throw StateError('Supabase function returned non-object JSON.');
  }

  String _contentTypeForPath(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.heic')) {
      return 'image/heic';
    }
    if (lower.endsWith('.heif')) {
      return 'image/heif';
    }
    return 'image/jpeg';
  }
}

void _logApi(String message, [Object? error, StackTrace? stackTrace]) {
  developer.log(
    message,
    name: 'mymenu.api',
    error: error,
    stackTrace: stackTrace,
  );
  debugPrint('mymenu.api: $message${error == null ? '' : ' error=$error'}');
  if (stackTrace != null) {
    debugPrintStack(label: 'mymenu.api stack', stackTrace: stackTrace);
  }
}
