part of 'my_menu_state.dart';

extension MyMenuStateSync on MyMenuState {
  void _handleNetworkStatusChange() {
    if (!_hasLocalCapturesWaitingForUpload()) {
      return;
    }
    debugPrint('mymenu.sync: network changed; retry window restarted');
    _startCaptureSyncPollingWindow();
    unawaited(refreshFromServer());
  }

  Future<void> refreshFromServer() async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null || _isSyncingCaptures) {
      return;
    }
    if (_hasLocalCapturesWaitingForUpload()) {
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
      await repositories.syncRepository.processPendingCaptures();
      await _reloadFromRepositories();
      if (!_hasLocalCapturesWaitingForUpload()) {
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
      await repositories.syncRepository.pullCaptureSync();
      await _reloadFromRepositories();
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
    final bool hasUnresolvedCaptures = _hasUnresolvedCaptures();
    if (!hasUnresolvedCaptures) {
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
        if (!_hasUnresolvedCaptures()) {
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

  bool _hasUnresolvedCaptures() {
    return _captureItems.any((CaptureItem item) {
      return switch (item.status) {
        CaptureItemStatus.localOnly ||
        CaptureItemStatus.pendingUpload ||
        CaptureItemStatus.uploading ||
        CaptureItemStatus.uploaded ||
        CaptureItemStatus.classifying ||
        CaptureItemStatus.needsReview =>
          true,
        CaptureItemStatus.applied ||
        CaptureItemStatus.discarded ||
        CaptureItemStatus.failed =>
          false,
      };
    });
  }
}
