part of 'processing_api_client.dart';

enum ApiProcessingOperation {
  captureGrouping('capture_grouping'),
  coverGeneration('cover_generation');

  const ApiProcessingOperation(this.apiValue);

  final String apiValue;

  static ApiProcessingOperation fromApi(String value) => values.firstWhere(
        (ApiProcessingOperation operation) => operation.apiValue == value,
      );
}

enum ApiProcessingJobStatus {
  created,
  submitted,
  processing,
  succeeded,
  acknowledged,
  failed,
  expired,
  canceled;

  static ApiProcessingJobStatus fromApi(String value) => switch (value) {
        // Supabase persists worker-oriented names while the client exposes
        // delivery-oriented names for its local outbox state machine.
        'queued' => ApiProcessingJobStatus.submitted,
        'running' => ApiProcessingJobStatus.processing,
        _ => values.firstWhere(
            (ApiProcessingJobStatus status) => status.name == value,
          ),
      };
}

class ApiProcessingContract {
  const ApiProcessingContract({
    required this.operation,
    required this.inputSchemaVersion,
    required this.resultSchemaVersion,
  });

  static const ApiProcessingContract captureGroupingV2 = ApiProcessingContract(
    operation: ApiProcessingOperation.captureGrouping,
    inputSchemaVersion: 'capture-grouping-input-v2',
    resultSchemaVersion: 'capture-grouping-result-v2',
  );
  static const ApiProcessingContract coverGenerationV1 = ApiProcessingContract(
    operation: ApiProcessingOperation.coverGeneration,
    inputSchemaVersion: 'cover-generation-input-v1',
    resultSchemaVersion: 'cover-generation-result-v1',
  );

  final ApiProcessingOperation operation;
  final String inputSchemaVersion;
  final String resultSchemaVersion;
}

sealed class ApiProcessingInput {
  const ApiProcessingInput(this.payload);

  final Map<String, Object?> payload;
}

class ApiCaptureGroupingInput extends ApiProcessingInput {
  const ApiCaptureGroupingInput(super.payload);
}

class ApiCoverGenerationInput extends ApiProcessingInput {
  const ApiCoverGenerationInput(super.payload);
}

sealed class ApiProcessingResult {
  const ApiProcessingResult({
    required this.schemaVersion,
    required this.payload,
  });

  final String schemaVersion;
  final Map<String, Object?> payload;
}

class ApiCaptureGroupingResult extends ApiProcessingResult {
  const ApiCaptureGroupingResult({
    required super.schemaVersion,
    required super.payload,
  });
}

class ApiCoverGenerationResult extends ApiProcessingResult {
  const ApiCoverGenerationResult({
    required super.schemaVersion,
    required super.payload,
  });
}

class ApiProcessingAllowances {
  const ApiProcessingAllowances({
    required this.organizationRemaining,
    required this.coverRemaining,
  });

  final int organizationRemaining;
  final int coverRemaining;
}

class ApiProcessingAssetManifest {
  const ApiProcessingAssetManifest({
    required this.assetId,
    required this.contentType,
    required this.byteSize,
  });

  final String assetId;
  final String contentType;
  final int byteSize;

  Map<String, Object?> toJson() => <String, Object?>{
        'assetId': assetId,
        'contentType': contentType,
        'byteSize': byteSize,
      };
}

class ApiProcessingUploadTarget {
  const ApiProcessingUploadTarget({
    required this.assetId,
    required this.storagePath,
    required this.token,
    required this.contentType,
  });

  final String assetId;
  final String storagePath;
  final String token;
  final String contentType;
}

class ApiProcessingJob {
  const ApiProcessingJob({
    required this.id,
    required this.operation,
    required this.idempotencyKey,
    required this.status,
    required this.expiresAt,
    required this.inputSchemaVersion,
    required this.resultSchemaVersion,
    this.uploadTargets = const <ApiProcessingUploadTarget>[],
    this.errorCode,
  });

  final String id;
  final ApiProcessingOperation operation;
  final String idempotencyKey;
  final ApiProcessingJobStatus status;
  final DateTime expiresAt;
  final String inputSchemaVersion;
  final String resultSchemaVersion;
  final List<ApiProcessingUploadTarget> uploadTargets;
  final String? errorCode;
}
