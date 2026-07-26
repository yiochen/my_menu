part of 'my_menu_api_client.dart';

mixin AiJobApiDefaults {
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
  }) {
    throw UnimplementedError('AI job scheduling is not implemented.');
  }

  Future<List<ApiAiJob>> getAiJobs(List<String> ids) async {
    return const <ApiAiJob>[];
  }

  Future<ApiAiJob> retryAiJob({required String jobId}) {
    throw UnimplementedError('AI job retry is not implemented.');
  }

  Future<ApiAiJob> cancelAiJob({required String jobId}) {
    throw UnimplementedError('AI job cancellation is not implemented.');
  }
}
