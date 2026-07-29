enum AiJobType {
  batchGrouping('batch_grouping', 'Organizing captures'),
  existingDishMatch('existing_dish_match', 'Matching a dish'),
  recipeEnrichment('recipe_enrichment', 'Enriching recipe'),
  coverGeneration('cover_generation', 'Improving cover');

  const AiJobType(this.apiValue, this.displayLabel);

  final String apiValue;
  final String displayLabel;

  static AiJobType fromApiValue(String value) {
    return values.firstWhere((AiJobType type) => type.apiValue == value);
  }
}

enum AiJobStatus {
  pendingOffline,
  queued,
  running,
  retrying,
  succeeded,
  failed,
  canceled;

  bool get isActive =>
      this == pendingOffline ||
      this == queued ||
      this == running ||
      this == retrying;

  bool get canCancel =>
      this == pendingOffline || this == queued || this == retrying;

  bool get canRetry => this == failed;

  bool get canDismiss =>
      this == succeeded || this == failed || this == canceled;

  static AiJobStatus fromDatabase(String value) {
    return switch (value) {
      'pending_offline' => pendingOffline,
      _ => values.byName(value),
    };
  }

  String get databaseValue => switch (this) {
        pendingOffline => 'pending_offline',
        _ => name,
      };
}

class AiJob {
  const AiJob({
    required this.id,
    required this.type,
    required this.subjectId,
    required this.status,
    required this.idempotencyKey,
    required this.inputHash,
    required this.inputVersion,
    required this.attemptCount,
    required this.maxAttempts,
    required this.promptVersion,
    required this.modelVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
    this.nextRetryAt,
    this.normalizedResult,
    this.normalizedError,
    this.startedAt,
    this.completedAt,
    this.pendingAction,
  });

  final String id;
  final AiJobType type;
  final String subjectId;
  final AiJobStatus status;
  final String idempotencyKey;
  final String inputHash;
  final String inputVersion;
  final int attemptCount;
  final int maxAttempts;
  final String promptVersion;
  final String modelVersion;
  final String schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextRetryAt;
  final Map<String, Object?>? normalizedResult;
  final Map<String, Object?>? normalizedError;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? pendingAction;

  String? get errorMessage {
    final Object? message = normalizedError?['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    final Object? code = normalizedError?['code'];
    return code is String && code.trim().isNotEmpty ? code : null;
  }

  String get runtimeLabel {
    final Object? provenance = normalizedResult?['provenance'];
    final Object? provider =
        provenance is Map<String, Object?> ? provenance['provider'] : null;
    final Object? model =
        provenance is Map<String, Object?> ? provenance['model'] : null;
    final String resolvedModel =
        model is String && model.trim().isNotEmpty ? model : modelVersion;
    return provider is String && provider.trim().isNotEmpty
        ? '${provider.trim()} · $resolvedModel'
        : resolvedModel;
  }
}
