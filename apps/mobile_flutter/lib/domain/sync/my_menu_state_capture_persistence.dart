part of 'my_menu_state.dart';

extension MyMenuStateCapturePersistence on MyMenuState {
  Future<CaptureBatch?> addPhotoCaptures(List<Object> capturedMedia) {
    return _createPhotoCaptures(capturedMedia);
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
        capturedAt: item.capturedAt,
        capturedLocalDate: item.capturedLocalDate,
        captureDateSource: item.captureDateSource,
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

  Future<void> deleteCapture(String captureId) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      _captureItems = _captureItems
          .where((CaptureItem item) => item.id != captureId)
          .toList(growable: false);
      _notifyChanged();
      return;
    }
    await repositories.captureRepository.deleteCapture(captureId);
    await _reloadFromRepositories();
    unawaited(_syncCaptureCorrections());
  }

  Future<void> deleteCaptureBatch(String batchId) async {
    final AppRepositories? repositories = _repositories;
    final Set<String> captureIds = _captureItems
        .where((CaptureItem item) => item.batchId == batchId)
        .map((CaptureItem item) => item.id)
        .toSet();
    if (repositories == null) {
      _captureBatches = _captureBatches
          .where((CaptureBatch batch) => batch.id != batchId)
          .toList(growable: false);
      _captureItems = _captureItems
          .where((CaptureItem item) => !captureIds.contains(item.id))
          .toList(growable: false);
      _aiJobs = _aiJobs
          .where((AiJob job) => job.subjectId != batchId)
          .toList(growable: false);
      _reviewItems = _reviewItems
          .where((ReviewItem item) => !captureIds.contains(item.captureId))
          .toList(growable: false);
      _captureCorrections = _captureCorrections
          .where(
              (CaptureCorrection correction) => correction.batchId != batchId)
          .toList(growable: false);
      _notifyChanged();
      _updateCaptureSyncPolling();
      return;
    }
    await repositories.captureRepository.deleteBatch(batchId);
    await _reloadFromRepositories();
    _updateCaptureSyncPolling();
    unawaited(repositories.syncRepository.processPendingOperations());
  }

  Future<void> _bootstrapRepositories() async {
    final AppRepositories repositories = _repositories!;
    await repositories.seedIfNeeded();
    await _reloadFromRepositories();
    _updateCaptureSyncPolling();
    unawaited(refreshFromServer());
  }

  Future<CaptureBatch?> _createPhotoCaptures(
    List<Object> capturedMedia,
  ) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      final List<ReviewItem> nextReviewItems = _reviewItemsWithPhotoCaptures(
        capturedMedia
            .map(
              (Object media) =>
                  media is CapturedMedia ? media.path : media.toString(),
            )
            .toList(growable: false),
        _reviewItems,
      );
      if (!identical(nextReviewItems, _reviewItems)) {
        _reviewItems = nextReviewItems;
        _notifyChanged();
      }
      return null;
    }

    final CaptureBatch? batch =
        await repositories.captureRepository.createPhotoBatch(capturedMedia);
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
    final Set<String> pendingDishIds = _pendingDishDeletionIds;
    final Set<String> pendingCaptureIds = _pendingDishCaptureIds;
    final Set<String> pendingBatchIds = _pendingDishBatchIds;
    final List<Dish> repositoryDishes =
        await repositories.dishRepository.listDishes();
    final Set<String> repositoryDishIds =
        repositoryDishes.map((Dish dish) => dish.id).toSet();
    _dishes = repositoryDishes
        .where((Dish dish) => !pendingDishIds.contains(dish.id))
        .toList(growable: false);
    _plan = (await repositories.planRepository.listMeals(
      validDishIds: repositoryDishIds,
    ))
        .where((PlannedMeal meal) => !pendingDishIds.contains(meal.dishId))
        .toList(growable: false);
    _captureItems = (await repositories.captureRepository.listFeedItems())
        .where(
          (CaptureItem item) =>
              !pendingCaptureIds.contains(item.id) &&
              !pendingDishIds.contains(item.appliedDishId),
        )
        .toList(growable: false);
    _captureBatches = (await repositories.captureRepository.listBatches())
        .map(
          (CaptureBatch batch) => CaptureBatch(
            id: batch.id,
            status: batch.status,
            createdAt: batch.createdAt,
            updatedAt: batch.updatedAt,
            items: batch.items
                .where(
                  (CaptureItem item) =>
                      !pendingCaptureIds.contains(item.id) &&
                      !pendingDishIds.contains(item.appliedDishId),
                )
                .toList(growable: false),
            failureReason: batch.failureReason,
          ),
        )
        .where((CaptureBatch batch) => batch.items.isNotEmpty)
        .toList(growable: false);
    _captureCorrections =
        (await repositories.captureCorrectionRepository.listCorrections())
            .where(
              (CaptureCorrection correction) =>
                  !pendingDishIds.contains(correction.targetDishId) &&
                  !pendingDishIds.contains(correction.createdDishId) &&
                  !correction.captureIds.any(pendingCaptureIds.contains) &&
                  !correction.previousDishIds.values
                      .any(pendingDishIds.contains),
            )
            .toList(growable: false);
    _aiJobs = (await repositories.aiJobRepository.listJobs())
        .where(
          (AiJob job) =>
              !pendingDishIds.contains(job.subjectId) &&
              !pendingBatchIds.contains(job.subjectId),
        )
        .toList(growable: false);
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
