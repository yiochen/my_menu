part of 'my_menu_state.dart';

extension MyMenuStateCapturePersistence on MyMenuState {
  Future<CaptureBatch?> addPhotoCaptures(List<String> imageRefs) {
    return _createPhotoCaptures(imageRefs);
  }

  void discardCapture(String captureId) {
    final AppRepositories? repositories = _repositories;
    _captureItems = _captureItems.map((CaptureItem item) {
      if (item.id != captureId) {
        return item;
      }
      return CaptureItem(
        id: item.id,
        kind: item.kind,
        status: CaptureItemStatus.discarded,
        createdAt: item.createdAt,
        batchId: item.batchId,
        ordinal: item.ordinal,
        localMediaRef: item.localMediaRef,
        remoteMediaRef: item.remoteMediaRef,
        text: item.text,
        appliedDishId: item.appliedDishId,
        failureReason: item.failureReason,
      );
    }).toList(growable: false);
    _notifyChanged();
    _updateCaptureSyncPolling();
    if (repositories != null) {
      unawaited(repositories.captureRepository.discardCapture(captureId));
    }
  }

  Future<void> _bootstrapRepositories() async {
    final AppRepositories repositories = _repositories!;
    await repositories.seedIfNeeded();
    await _reloadFromRepositories();
    _updateCaptureSyncPolling();
    if (_hasLocalCapturesWaitingForUpload()) {
      unawaited(refreshFromServer());
    }
  }

  Future<CaptureBatch?> _createPhotoCaptures(List<String> imageRefs) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      final List<ReviewItem> nextReviewItems = _reviewItemsWithPhotoCaptures(
        imageRefs,
        _reviewItems,
      );
      if (!identical(nextReviewItems, _reviewItems)) {
        _reviewItems = nextReviewItems;
        _notifyChanged();
      }
      return null;
    }

    final CaptureBatch? batch =
        await repositories.captureRepository.createPhotoBatch(imageRefs);
    if (batch == null) {
      return null;
    }
    _startCaptureSyncPollingWindow();
    await _reloadFromRepositories();
    unawaited(_syncCaptures());
    return batch;
  }

  Future<void> _createIdeaCapture(String text) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return;
    }
    await repositories.captureRepository.createIdeaCapture(text);
    _startCaptureSyncPollingWindow();
    await _reloadFromRepositories();
    await _syncCaptures();
  }

  Future<void> _reloadFromRepositories() async {
    final AppRepositories repositories = _repositories!;
    _dishes = await repositories.dishRepository.listDishes();
    _captureBatches = await repositories.captureRepository.listBatches();
    _captureItems = await repositories.captureRepository.listFeedItems();
    _notifyChanged();
  }

  Future<void> retryCaptureBatch(String batchId) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return;
    }
    await repositories.captureRepository.retryBatch(batchId);
    await _reloadFromRepositories();
    await _syncCaptures();
  }
}
