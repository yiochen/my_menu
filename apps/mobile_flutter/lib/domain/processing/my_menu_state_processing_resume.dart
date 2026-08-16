part of '../menu/my_menu_state.dart';

extension MyMenuStateProcessingResume on MyMenuState {
  void _handleNetworkStatusChange() {
    unawaited(_resumeLegacyMediaContraction());
    if (_hasProcessingWorkToResume()) {
      _startProcessingResumeWindow();
      unawaited(resumeProcessing());
    }
  }

  /// Resumes only remote processing requests already represented in the local
  /// outbox. Menu, plan, capture, and correction rows remain local authority.
  Future<void> resumeProcessing() async {
    final Future<void>? active = _activeProcessingResume;
    if (active != null) {
      await active;
      return;
    }
    final AppRepositories? repositories = _repositories;
    if (repositories == null) return;

    final Future<void> resume = _runProcessingResume(repositories);
    _activeProcessingResume = resume;
    try {
      await resume;
    } finally {
      if (identical(_activeProcessingResume, resume)) {
        _activeProcessingResume = null;
      }
    }
  }

  Future<void> _runProcessingResume(AppRepositories repositories) async {
    try {
      await repositories.processingCoordinator.processPendingCaptures();
      await repositories.processingCoordinator.processPendingCovers();
      await _reloadFromRepositories();
    } on Object {
      developer.log(
        'Processing resume stopped before completion.',
        name: 'mymenu.processing',
      );
      await _reloadFromRepositories();
    } finally {
      _updateProcessingResumePolling();
    }
  }

  void _startProcessingResumeWindow() {
    _processingResumeDeadline = DateTime.now().add(
      MyMenuState._processingResumeWindow,
    );
    _updateProcessingResumePolling();
  }

  void _updateProcessingResumePolling() {
    if (_repositories == null) return;
    final bool hasCancellation = _hasServerCancellationWaiting();
    if (_processingConsentDecision != ProcessingConsentDecision.accepted &&
        !hasCancellation) {
      _stopProcessingResumePolling();
      return;
    }
    if (!_hasProcessingWorkToResume()) {
      _stopProcessingResumePolling();
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime deadline = _processingResumeDeadline ??
        now.add(MyMenuState._processingResumeWindow);
    _processingResumeDeadline = deadline;
    if (!now.isBefore(deadline)) {
      _stopProcessingResumePolling();
      return;
    }
    if (_processingResumeTimer != null) return;

    _processingResumeTimer = Timer.periodic(
      MyMenuState._processingResumeInterval,
      (_) {
        if (!_hasProcessingWorkToResume() ||
            !DateTime.now().isBefore(_processingResumeDeadline!)) {
          _stopProcessingResumePolling();
          return;
        }
        unawaited(resumeProcessing());
      },
    );
  }

  void _stopProcessingResumePolling() {
    _processingResumeTimer?.cancel();
    _processingResumeTimer = null;
    _processingResumeDeadline = null;
  }

  bool _hasProcessingWorkToResume() {
    if (_hasServerCancellationWaiting()) return true;
    if (_processingConsentDecision != ProcessingConsentDecision.accepted) {
      return false;
    }
    return _hasLocalCapturesWaitingForUpload() ||
        _processingRequests.any(
          (ProcessingOutboxRequest request) =>
              <ProcessingDeliveryState>{
                ProcessingDeliveryState.pendingUpload,
                ProcessingDeliveryState.uploading,
                ProcessingDeliveryState.submitted,
              }.contains(request.deliveryState) ||
              (request.deliveryState == ProcessingDeliveryState.acknowledged &&
                  request.adoptionState ==
                      ProcessingAdoptionState.readyForAdoption),
        );
  }

  bool _hasLocalCapturesWaitingForUpload() => _captureItems.any(
        (CaptureItem item) =>
            item.status == CaptureItemStatus.pendingUpload ||
            item.status == CaptureItemStatus.uploading,
      );

  bool _hasServerCancellationWaiting() => _processingRequests.any(
        (ProcessingOutboxRequest request) =>
            request.deliveryState == ProcessingDeliveryState.canceled &&
            request.serverJobId != null,
      );
}
