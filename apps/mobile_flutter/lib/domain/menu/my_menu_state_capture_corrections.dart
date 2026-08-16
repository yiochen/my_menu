part of 'my_menu_state.dart';

extension MyMenuStateCaptureCorrections on MyMenuState {
  CaptureCorrection? latestCaptureCorrection(String batchId) {
    final List<CaptureCorrection> matches = _captureCorrections
        .where(
          (CaptureCorrection correction) => correction.batchId == batchId,
        )
        .toList(growable: false)
      ..sort(
        (CaptureCorrection left, CaptureCorrection right) =>
            right.createdAt.compareTo(left.createdAt),
      );
    return matches.firstOrNull;
  }

  CaptureCorrection? latestCaptureCorrectionForPhoto(String captureId) {
    final List<CaptureCorrection> matches = _captureCorrections
        .where(
          (CaptureCorrection correction) =>
              correction.captureIds.contains(captureId) && correction.canUndo,
        )
        .toList(growable: false)
      ..sort(
        (CaptureCorrection left, CaptureCorrection right) =>
            right.createdAt.compareTo(left.createdAt),
      );
    return matches.firstOrNull;
  }

  Future<CaptureCorrection?> moveCapturePhotos({
    required String batchId,
    required List<String> captureIds,
    required String targetDishId,
  }) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return null;
    }
    final CaptureCorrection? correction =
        await repositories.captureCorrectionRepository.moveCaptures(
      batchId: batchId,
      captureIds: captureIds,
      targetDishId: targetDishId,
    );
    await _reloadFromRepositories();
    _startProcessingResumeWindow();
    return correction;
  }

  Future<CaptureCorrection?> splitCapturePhotos({
    required String batchId,
    required List<String> captureIds,
    required String title,
  }) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return null;
    }
    final CaptureCorrection? correction =
        await repositories.captureCorrectionRepository.splitCaptures(
      batchId: batchId,
      captureIds: captureIds,
      title: title,
    );
    await _reloadFromRepositories();
    return correction;
  }

  Future<CaptureCorrection?> assignUnclassifiedPhotos({
    required String batchId,
    required List<String> captureIds,
    required String targetDishId,
  }) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return null;
    }
    final CaptureCorrection? correction =
        await repositories.captureCorrectionRepository.assignCaptures(
      batchId: batchId,
      captureIds: captureIds,
      targetDishId: targetDishId,
    );
    await _reloadFromRepositories();
    return correction;
  }

  Future<CaptureCorrection?> assignUnclassifiedPhotosToNewDish({
    required String batchId,
    required List<String> captureIds,
    required String title,
  }) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return null;
    }
    final CaptureCorrection? correction =
        await repositories.captureCorrectionRepository.assignCapturesToNewDish(
      batchId: batchId,
      captureIds: captureIds,
      title: title,
    );
    await _reloadFromRepositories();
    return correction;
  }

  Future<CaptureCorrection?> undoLatestCaptureCorrection(
    String batchId, {
    String? captureId,
  }) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return null;
    }
    final CaptureCorrection? correction =
        await repositories.captureCorrectionRepository.undoLatest(
      batchId,
      captureId: captureId,
    );
    await _reloadFromRepositories();
    return correction;
  }
}
