import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

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

class ApiClassificationStart {
  const ApiClassificationStart({
    required this.captureId,
    required this.status,
  });

  final String captureId;
  final String status;
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
  Future<void> createDishNote({
    required String noteId,
    required String dishId,
    required String body,
    required int position,
  }) async {}

  @override
  Future<void> updateDishNote({
    required String noteId,
    required String body,
    required int? position,
  }) async {}

  @override
  Future<void> deleteDishNote({required String noteId}) async {}

  @override
  Future<void> updateDish({
    required String clientMutationId,
    required String dishId,
    required Map<String, Object?> patch,
  }) async {}
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
      'preparePhotoUpload',
      <String, Object?>{
        'captureId': captureId,
        'contentType': contentType,
        'byteSize': bytes.length,
      },
    );

    final Map<String, Object?> upload = _mapValue(prepare, 'upload');
    final String storagePath = _stringValue(prepare, 'storagePath');
    final String token = _stringValue(upload, 'token');

    await _client.storage.from('menu-media').uploadBinaryToSignedUrl(
          storagePath,
          token,
          bytes,
          FileOptions(contentType: contentType, upsert: true),
        );

    final Map<String, Object?> created = await _invokeJson(
      'createPhoto',
      <String, Object?>{
        'captureId': captureId,
        'storagePath': storagePath,
        'contentType': contentType,
        'byteSize': bytes.length,
        'capturedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
    final Map<String, Object?> image = _mapValue(created, 'image');
    return _stringValue(image, 'mediaRef');
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
      captureId: _stringValue(data, 'captureId'),
      status: _stringValue(data, 'status'),
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

  Map<String, Object?> _mapValue(Map<String, Object?> data, String key) {
    final Object? value = data[key];
    if (value is Map<String, dynamic>) {
      return Map<String, Object?>.from(value);
    }
    if (value is Map<String, Object?>) {
      return value;
    }
    throw StateError('Expected JSON object at "$key".');
  }

  String _stringValue(Map<String, Object?> data, String key) {
    final String? value = _optionalStringValue(data, key);
    if (value == null) {
      throw StateError('Expected string at "$key".');
    }
    return value;
  }

  String? _optionalStringValue(Map<String, Object?> data, String key) {
    final Object? value = data[key];
    return value is String ? value : null;
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
