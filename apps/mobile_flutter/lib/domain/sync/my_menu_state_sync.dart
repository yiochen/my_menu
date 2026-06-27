part of 'my_menu_state.dart';

extension MyMenuStateSync on MyMenuState {
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
      await repositories.syncRepository.pullCaptureSync();
      await _reloadFromRepositories();
    } on Object catch (error, stackTrace) {
      _logState('_syncCaptures failed', error, stackTrace);
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
    } on Object catch (error, stackTrace) {
      _logState('_pullCaptureSync failed', error, stackTrace);
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
        unawaited(_pullCaptureSync());
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
      (CaptureItem item) => item.status == CaptureItemStatus.pendingUpload,
    );
  }

  bool _hasUnresolvedCaptures() {
    return _captureItems.any((CaptureItem item) {
      return switch (item.status) {
        CaptureItemStatus.localOnly ||
        CaptureItemStatus.pendingUpload ||
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

void _logState(String message, [Object? error, StackTrace? stackTrace]) {
  developer.log(
    message,
    name: 'mymenu.state',
    error: error,
    stackTrace: stackTrace,
  );
  debugPrint('mymenu.state: $message${error == null ? '' : ' error=$error'}');
  if (stackTrace != null) {
    debugPrintStack(label: 'mymenu.state stack', stackTrace: stackTrace);
  }
}
