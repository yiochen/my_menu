import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mymenu/core/network/processing_api_parsers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'fake_processing_api_client.dart';
part 'fake_processing_api.dart';
part 'processing_api_config.dart';
part 'processing_api_models.dart';
part 'supabase_processing_api.dart';
part 'supabase_processing_api_helpers.dart';

/// The only network boundary retained by the local-first client.
abstract class ProcessingApiClient {
  Future<ApiProcessingAllowances> getProcessingAllowances() {
    throw UnimplementedError('Processing allowances are not implemented.');
  }

  Future<ApiProcessingJob> createProcessingJob({
    required ApiProcessingContract contract,
    required String idempotencyKey,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) {
    throw UnimplementedError('Processing job creation is not implemented.');
  }

  Future<void> uploadProcessingAsset({
    required ApiProcessingUploadTarget target,
    required String localPath,
  }) {
    throw UnimplementedError('Processing upload is not implemented.');
  }

  Future<ApiProcessingJob> submitProcessingJob({
    required String jobId,
    required ApiProcessingInput input,
  }) {
    throw UnimplementedError('Processing submission is not implemented.');
  }

  Future<ApiProcessingJob> getProcessingJob({required String jobId}) {
    throw UnimplementedError('Processing status is not implemented.');
  }

  Future<ApiProcessingResult> downloadProcessingResult({
    required String jobId,
  }) {
    throw UnimplementedError('Processing result download is not implemented.');
  }

  Future<void> acknowledgeProcessingJob({required String jobId}) {
    throw UnimplementedError(
      'Processing acknowledgement is not implemented.',
    );
  }

  Future<void> cancelProcessingJob({required String jobId}) {
    throw UnimplementedError('Processing cancellation is not implemented.');
  }
}

class SupabaseProcessingApiClient extends ProcessingApiClient
    with SupabaseProcessingApi {
  SupabaseProcessingApiClient({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  final SupabaseClient _client;

  @override
  Future<void> _ensureSession() async {
    if (_client.auth.currentSession != null) return;
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
