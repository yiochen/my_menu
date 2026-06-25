import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
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

    final Map<String, Object?> upload = _mapValue(prepare, 'upload');
    final String storagePath = _stringValue(prepare, 'storagePath');
    final String token = _stringValue(upload, 'token');

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
    final Map<String, Object?> image = _mapValue(created, 'image');
    final String mediaRef = _stringValue(image, 'mediaRef');
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
      captureId: _stringValue(data, 'captureId'),
      status: _stringValue(data, 'status'),
    );
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
