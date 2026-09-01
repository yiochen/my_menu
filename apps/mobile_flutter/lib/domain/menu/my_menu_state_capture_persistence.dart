part of 'my_menu_state.dart';

extension MyMenuStateCapturePersistence on MyMenuState {
  Future<CaptureIngest?> addPhotoCaptures(
    List<Object> capturedMedia, {
    String? targetDishId,
  }) {
    return _createPhotoCaptures(capturedMedia, targetDishId: targetDishId);
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
        status: CaptureItemStatus.localOnly,
        createdAt: item.createdAt,
        ingestId: item.ingestId,
        ordinal: item.ordinal,
        localMediaRef: item.localMediaRef,
        localPreviewRef: item.localPreviewRef,
        localThumbnailRef: item.localThumbnailRef,
        localPlaceholderRef: item.localPlaceholderRef,
        text: item.text,
        capturedAt: item.capturedAt,
        capturedLocalDate: item.capturedLocalDate,
        captureDateSource: item.captureDateSource,
        appliedDishId: item.appliedDishId,
        failureReason: item.failureReason,
      );
    }).toList(growable: false);
    _reviewItems = _reviewItems
        .where((ReviewItem item) => item.captureId != captureId)
        .toList(growable: false);
    _notifyChanged();
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
  }

  Future<void> deleteCaptureIngest(String ingestId) async {
    final AppRepositories? repositories = _repositories;
    final Set<String> captureIds = _captureItems
        .where((CaptureItem item) => item.ingestId == ingestId)
        .map((CaptureItem item) => item.id)
        .toSet();
    if (repositories == null) {
      _captureIngests = _captureIngests
          .where((CaptureIngest ingest) => ingest.id != ingestId)
          .toList(growable: false);
      _captureItems = _captureItems
          .where((CaptureItem item) => !captureIds.contains(item.id))
          .toList(growable: false);
      _reviewItems = _reviewItems
          .where((ReviewItem item) => !captureIds.contains(item.captureId))
          .toList(growable: false);
      _captureCorrections = _captureCorrections
          .where(
              (CaptureCorrection correction) => correction.ingestId != ingestId)
          .toList(growable: false);
      _notifyChanged();
      _updateProcessingResumePolling();
      return;
    }
    await repositories.captureRepository.deleteIngest(ingestId);
    await _reloadFromRepositories();
    _updateProcessingResumePolling();
  }

  Future<void> _bootstrapRepositories() async {
    final AppRepositories repositories = _repositories!;
    await repositories.prepareLocalData();
    await repositories.captureRepository.adoptDeclinedPhotoCapturesLocally();
    await _reloadFromRepositories();
    unawaited(_resumeLegacyMediaContraction());
    _updateProcessingResumePolling();
    if (_hasProcessingWorkToResume()) {
      unawaited(resumeProcessing());
    }
  }

  Future<void> _resumeLegacyMediaContraction() async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) return;
    try {
      if (await repositories.database.resumeLegacyMediaContraction()) {
        await _reloadFromRepositories();
      }
    } on Object {
      developer.log(
        'Legacy media localization will retry later.',
        name: 'mymenu.media.migration',
      );
    }
  }

  Future<CaptureIngest?> _createPhotoCaptures(
    List<Object> capturedMedia, {
    String? targetDishId,
  }) async {
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

    final bool firstSourcesForDish = targetDishId != null &&
        _dishes.any(
          (Dish dish) => dish.id == targetDishId && dish.sourcePhotos.isEmpty,
        );
    final CaptureIngest? ingest =
        await repositories.captureRepository.createPhotoIngest(
      capturedMedia,
      targetDishId: targetDishId,
    );
    if (ingest == null) {
      return null;
    }
    if (targetDishId == null) {
      _startProcessingResumeWindow();
    }
    await _reloadFromRepositories();
    if (targetDishId == null) {
      unawaited(resumeProcessing());
    } else if (firstSourcesForDish) {
      final Set<String> captureIds =
          ingest.items.map((CaptureItem item) => item.id).toSet();
      final Dish dish = dishById(targetDishId);
      final bool enqueued =
          await repositories.coverRepository.enqueueAutomaticCover(
        dishId: targetDishId,
        sourceIds: dish.sourcePhotos
            .where(
              (SourcePhoto source) => captureIds.contains(source.captureId),
            )
            .map((SourcePhoto source) => source.id)
            .whereType<String>()
            .take(3)
            .toList(growable: false),
        now: ingest.createdAt,
      );
      if (enqueued) {
        await _reloadFromRepositories();
        _startProcessingResumeWindow();
      }
    }
    return ingest;
  }

  Future<void> _reloadFromRepositories() async {
    final AppRepositories repositories = _repositories!;
    _processingConsentDecision =
        await repositories.processingConsentRepository.currentDecision();
    final Set<String> pendingDishIds = _pendingDishDeletionIds;
    final Set<String> pendingCaptureIds = _pendingDishCaptureIds;
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
    _captureIngests = (await repositories.captureRepository.listIngests())
        .map(
          (CaptureIngest ingest) => CaptureIngest(
            id: ingest.id,
            status: ingest.status,
            createdAt: ingest.createdAt,
            updatedAt: ingest.updatedAt,
            items: ingest.items
                .where(
                  (CaptureItem item) =>
                      !pendingCaptureIds.contains(item.id) &&
                      !pendingDishIds.contains(item.appliedDishId),
                )
                .toList(growable: false),
            failureReason: ingest.failureReason,
          ),
        )
        .where((CaptureIngest ingest) => ingest.items.isNotEmpty)
        .toList(growable: false);
    _reviewItems = (await repositories.captureRepository.listReviewItems())
        .where(
          (ReviewItem item) => !pendingCaptureIds.contains(item.captureId),
        )
        .map(
          (ReviewItem item) => item.copyWith(
            suggestedDishIds: item.suggestedDishIds
                .where(repositoryDishIds.contains)
                .toList(growable: false),
          ),
        )
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
    _processingRequests =
        await repositories.processingOutboxRepository.listRequests();
    _generatedCovers = await repositories.coverRepository.listAll();
    _notifyChanged();
  }

  Future<void> retryCaptureIngest(String ingestId) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return;
    }
    await repositories.captureRepository.retryIngest(ingestId);
    await _reloadFromRepositories();
    await resumeProcessing();
  }
}
