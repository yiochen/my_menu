part of 'my_menu_state.dart';

extension MyMenuStateProcessing on MyMenuState {
  Future<ProcessingConsentDecision> requestProcessingConsent({
    required ProcessingConsentTrigger trigger,
  }) async {
    await _repositoryBootstrap;
    if (_processingConsentDecision != ProcessingConsentDecision.notDecided) {
      return _processingConsentDecision;
    }
    final Completer<ProcessingConsentDecision>? active =
        _processingConsentCompleter;
    if (active != null) {
      return active.future;
    }

    final Completer<ProcessingConsentDecision> completer =
        Completer<ProcessingConsentDecision>();
    _processingConsentCompleter = completer;
    _pendingProcessingConsentRequest = ProcessingConsentRequest(
      id: _nextProcessingConsentRequestId,
      trigger: trigger,
    );
    _nextProcessingConsentRequestId += 1;
    _notifyChanged();
    return completer.future;
  }

  Future<void> resolveProcessingConsent(
    ProcessingConsentDecision decision,
  ) async {
    if (decision == ProcessingConsentDecision.notDecided ||
        _pendingProcessingConsentRequest == null) {
      return;
    }
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      if (decision == ProcessingConsentDecision.accepted) {
        await repositories.processingConsentRepository.acceptCurrentNotice();
      } else {
        await repositories.processingConsentRepository.declineCurrentNotice();
      }
    }

    final Completer<ProcessingConsentDecision>? completer =
        _processingConsentCompleter;
    _processingConsentDecision = decision;
    _processingConsentCompleter = null;
    _pendingProcessingConsentRequest = null;
    _notifyChanged();
    completer?.complete(decision);

    if (decision == ProcessingConsentDecision.accepted &&
        repositories != null) {
      _startCaptureSyncPollingWindow();
      unawaited(_syncCaptures());
    }
  }

  Future<void> disableAiProcessing() async {
    await _repositoryBootstrap;
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      await repositories.processingConsentRepository.disableAiProcessing();
    }
    _processingConsentDecision = ProcessingConsentDecision.declined;
    _notifyChanged();
  }

  Future<void> resetProcessingConsent() async {
    await _repositoryBootstrap;
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      await repositories.processingConsentRepository.resetCurrentNotice();
    }
    _processingConsentDecision = ProcessingConsentDecision.notDecided;
    _stopCaptureSyncPolling();
    _notifyChanged();
  }
}
