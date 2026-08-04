part of 'my_menu_state.dart';

extension MyMenuStateSync on MyMenuState {
  void _handleNetworkStatusChange() {
    if (_hasLocalWorkWaitingForSync()) {
      debugPrint('mymenu.sync: network changed; retry window restarted');
      _startCaptureSyncPollingWindow();
    }
    unawaited(refreshFromServer());
  }

  Future<void> refreshFromServer() async {
    final Future<void>? activeRefresh = _activeCaptureRefresh;
    if (activeRefresh != null) {
      await activeRefresh;
      return;
    }

    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return;
    }

    final Future<void> refresh = _refreshFromServer();
    _activeCaptureRefresh = refresh;
    try {
      await refresh;
    } finally {
      if (identical(_activeCaptureRefresh, refresh)) {
        _activeCaptureRefresh = null;
      }
    }
  }

  Future<void> _refreshFromServer() async {
    if (_hasLocalWorkWaitingForSync()) {
      await _syncCaptures();
      return;
    }
    await _pullCaptureSync();
  }

  Future<void> _syncCaptures() async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null || _isSyncingCaptures) {
      return;
    }
    _isSyncingCaptures = true;
    try {
      await repositories.syncRepository.processPendingOperations();
      await repositories.syncRepository.processPendingAiJobs();
      await repositories.syncRepository.processPendingCaptures();
      await repositories.syncRepository.processPendingCovers();
      await _reloadFromRepositories();
      if (!_hasLocalWorkWaitingForSync()) {
        try {
          await repositories.syncRepository.pullCaptureSync();
        } on Object catch (error, stackTrace) {
          developer.log(
            'Capture pull unavailable after local sync.',
            name: 'mymenu.sync',
            error: error,
            stackTrace: stackTrace,
          );
        }
        await _reloadFromRepositories();
      }
    } on Object catch (error, stackTrace) {
      developer.log(
        'Capture sync failed before completion.',
        name: 'mymenu.sync',
        error: error,
        stackTrace: stackTrace,
      );
      await _reloadFromRepositories();
    } finally {
      _isSyncingCaptures = false;
      _updateCaptureSyncPolling();
    }
  }

  Future<void> _pullCaptureSync() async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null || _isSyncingCaptures) {
      return;
    }
    _isSyncingCaptures = true;
    try {
      await repositories.syncRepository.processPendingOperations();
      await repositories.syncRepository.pullCaptureSync();
      await _reloadFromRepositories();
    } on Object catch (error, stackTrace) {
      developer.log(
        'Capture pull unavailable.',
        name: 'mymenu.sync',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isSyncingCaptures = false;
      _updateCaptureSyncPolling();
    }
  }

  void _startCaptureSyncPollingWindow() {
    _captureSyncPollingDeadline = DateTime.now().add(
      MyMenuState._captureSyncPollWindow,
    );
    _updateCaptureSyncPolling();
  }

  void _updateCaptureSyncPolling() {
    if (_repositories == null) {
      return;
    }
    if (_processingConsentDecision != ProcessingConsentDecision.accepted) {
      _stopCaptureSyncPolling();
      return;
    }
    final bool hasUnresolvedWork = _hasUnresolvedCaptures() ||
        _aiJobs.any((AiJob job) => job.status.isActive);
    if (!hasUnresolvedWork) {
      _stopCaptureSyncPolling();
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime deadline = _captureSyncPollingDeadline ??
        now.add(MyMenuState._captureSyncPollWindow);
    _captureSyncPollingDeadline = deadline;
    if (!now.isBefore(deadline)) {
      _stopCaptureSyncPolling();
      return;
    }

    if (_captureSyncTimer != null) {
      return;
    }
    _captureSyncTimer = Timer.periodic(
      MyMenuState._captureSyncPollInterval,
      (_) {
        if (!_hasUnresolvedCaptures() &&
            !_aiJobs.any((AiJob job) => job.status.isActive) &&
            !_hasActiveProcessingRequest()) {
          _stopCaptureSyncPolling();
          return;
        }
        final DateTime? deadline = _captureSyncPollingDeadline;
        if (deadline != null && !DateTime.now().isBefore(deadline)) {
          _stopCaptureSyncPolling();
          return;
        }
        unawaited(refreshFromServer());
      },
    );
  }

  void _stopCaptureSyncPolling() {
    _captureSyncTimer?.cancel();
    _captureSyncTimer = null;
    _captureSyncPollingDeadline = null;
  }

  bool _hasLocalCapturesWaitingForUpload() {
    return _captureItems.any(
      (CaptureItem item) =>
          item.status == CaptureItemStatus.pendingUpload ||
          item.status == CaptureItemStatus.uploading,
    );
  }

  bool _hasLocalWorkWaitingForSync() {
    if (_processingConsentDecision != ProcessingConsentDecision.accepted) {
      return false;
    }
    return _hasLocalCapturesWaitingForUpload() ||
        _processingRequests.any(
          (ProcessingOutboxRequest request) =>
              request.deliveryState == ProcessingDeliveryState.pendingUpload ||
              request.deliveryState == ProcessingDeliveryState.uploading ||
              request.deliveryState == ProcessingDeliveryState.submitted ||
              (request.deliveryState == ProcessingDeliveryState.canceled &&
                  request.serverJobId != null),
        ) ||
        _aiJobs.any((AiJob job) => job.pendingAction != null);
  }

  bool _hasActiveProcessingRequest() => _processingRequests.any(
        (ProcessingOutboxRequest request) => <ProcessingDeliveryState>{
          ProcessingDeliveryState.pendingUpload,
          ProcessingDeliveryState.uploading,
          ProcessingDeliveryState.submitted,
        }.contains(request.deliveryState),
      );

  bool _hasUnresolvedCaptures() {
    return _captureItems.any((CaptureItem item) {
      return switch (item.status) {
        CaptureItemStatus.localOnly ||
        CaptureItemStatus.pendingUpload ||
        CaptureItemStatus.uploading ||
        CaptureItemStatus.uploaded ||
        CaptureItemStatus.classifying ||
        CaptureItemStatus.needsReview ||
        CaptureItemStatus.notADish =>
          true,
        CaptureItemStatus.applied ||
        CaptureItemStatus.discarded ||
        CaptureItemStatus.failed =>
          false,
      };
    });
  }
}
