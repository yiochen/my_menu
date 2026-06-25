import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mymenu/core/network/my_menu_api_models.dart';
import 'package:mymenu/core/network/my_menu_api_parsers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:mymenu/core/network/my_menu_api_models.dart';

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

  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  });

  Future<List<ApiCapture>> getCaptures(List<String> ids);

  Future<List<ApiDish>> getDishes(List<String> ids);

  Future<List<ApiReviewItem>> getReviewItems(List<String> ids);
}

class FakeMyMenuApiClient implements MyMenuApiClient {
  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String localMediaRef,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return 'fake://captures/$captureId';
  }

  @override
  Future<ApiClassificationStart> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return ApiClassificationStart(
      captureId: captureId,
      status: 'classifying',
    );
  }

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

    await _client.storage.from('menu-media').uploadBinaryToSignedUrl(
          storagePath,
          token,
          bytes,
          FileOptions(contentType: contentType, upsert: true),
        );

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
    return apiStringValue(image, 'mediaRef');
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
    await _client.auth.signInAnonymously();
  }

  Future<Map<String, Object?>> _invokeJson(
    String functionName,
    Map<String, Object?> body,
  ) async {
    final FunctionResponse response = await _client.functions.invoke(
      functionName,
      body: body,
    );
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
