import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseApiConfig {
  const SupabaseApiConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

class ApiCaptureResult {
  const ApiCaptureResult({
    required this.captureId,
    required this.dishId,
    required this.title,
    required this.description,
    required this.mediaRef,
    required this.category,
  });

  final String captureId;
  final String dishId;
  final String title;
  final String description;
  final String mediaRef;
  final String category;
}

abstract class MyMenuApiClient {
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String localMediaRef,
  });

  Future<ApiCaptureResult> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  });
}

class FakeMyMenuApiClient implements MyMenuApiClient {
  FakeMyMenuApiClient({Random? random}) : _random = random ?? Random(7);

  final Random _random;

  static const List<String> _dishNames = <String>[
    'Golden Garlic Noodles',
    'Miso Market Bowl',
    'Sunday Pepper Chicken',
    'Bright Herb Rice',
    'Sesame Garden Pasta',
    'Tomato Butter Beans',
  ];

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String localMediaRef,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return 'fake://captures/$captureId';
  }

  @override
  Future<ApiCaptureResult> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final String title = ideaText == null || ideaText.trim().isEmpty
        ? _dishNames[_random.nextInt(_dishNames.length)]
        : _titleCase(ideaText);
    return ApiCaptureResult(
      captureId: captureId,
      dishId: 'dish_$captureId',
      title: title,
      description: 'Created from a synced capture.',
      mediaRef: remoteMediaRef ?? '',
      category: 'Mains',
    );
  }

  String _titleCase(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
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
      <String, Object?>{
        'route': 'capture.preparePhotoUpload',
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
      <String, Object?>{
        'route': 'capture.createPhoto',
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
  Future<ApiCaptureResult> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  }) async {
    await _ensureSession();

    final Map<String, Object?> data = await _invokeJson(
      <String, Object?>{
        'route': 'capture.classify',
        'captureId': captureId,
        if (remoteMediaRef != null) 'remoteMediaRef': remoteMediaRef,
        if (ideaText != null) 'ideaText': ideaText,
      },
    );

    return ApiCaptureResult(
      captureId: _stringValue(data, 'captureId'),
      dishId: _stringValue(data, 'dishId'),
      title: _stringValue(data, 'title'),
      description: _stringValue(data, 'description'),
      mediaRef: _optionalStringValue(data, 'mediaRef') ?? '',
      category: _optionalStringValue(data, 'category') ?? 'Mains',
    );
  }

  Future<void> _ensureSession() async {
    if (_client.auth.currentSession != null) {
      return;
    }
    await _client.auth.signInAnonymously();
  }

  Future<Map<String, Object?>> _invokeJson(Map<String, Object?> body) async {
    final FunctionResponse response = await _client.functions.invoke(
      'api',
      body: body,
    );
    if (response.status < 200 || response.status >= 300) {
      throw StateError('Supabase function failed: ${response.status}');
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
