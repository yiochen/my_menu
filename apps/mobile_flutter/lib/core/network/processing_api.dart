part of 'my_menu_api_client.dart';

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
  final String operation;
  final String idempotencyKey;
  final String status;
  final DateTime expiresAt;
  final String inputSchemaVersion;
  final String resultSchemaVersion;
  final List<ApiProcessingUploadTarget> uploadTargets;
  final String? errorCode;
}
