part of 'my_menu_state.dart';

extension MyMenuStateAi on MyMenuState {
  Future<AiJob?> scheduleAiJob({
    required AiJobType type,
    required String subjectId,
    required String inputHash,
    required String inputVersion,
  }) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return null;
    }
    final AiJob job = await repositories.aiJobRepository.schedule(
      type: type,
      subjectId: subjectId,
      inputHash: inputHash,
      inputVersion: inputVersion,
    );
    await _reloadFromRepositories();
    _startCaptureSyncPollingWindow();
    unawaited(refreshFromServer());
    return job;
  }

  Future<void> retryAiJob(String jobId) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return;
    }
    await repositories.aiJobRepository.requestRetry(jobId);
    await _reloadFromRepositories();
    _startCaptureSyncPollingWindow();
    await refreshFromServer();
  }

  Future<void> cancelAiJob(String jobId) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return;
    }
    await repositories.aiJobRepository.requestCancel(jobId);
    await _reloadFromRepositories();
    await refreshFromServer();
  }

  Future<void> dismissAiJob(String jobId) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return;
    }
    await repositories.aiJobRepository.dismiss(jobId);
    await _reloadFromRepositories();
  }
}
