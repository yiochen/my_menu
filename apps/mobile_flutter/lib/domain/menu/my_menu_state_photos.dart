part of 'my_menu_state.dart';

extension MyMenuStatePhotos on MyMenuState {
  Future<List<CaptureCorrection>> organizePhotos({
    required Iterable<String> captureIds,
    required String dishId,
  }) async {
    return organizePhotoAssignments(<String, String>{
      for (final String captureId in captureIds.toSet()) captureId: dishId,
    });
  }

  Future<List<CaptureCorrection>> organizePhotoAssignments(
    Map<String, String> dishIdByCaptureId,
  ) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return const <CaptureCorrection>[];
    }
    final List<CaptureCorrection> corrections = await repositories
        .captureCorrectionRepository
        .applyAssignments(dishIdByCaptureId);
    await _reloadFromRepositories();
    return corrections;
  }

  Future<List<CaptureCorrection>> undoPhotoCorrections(
    Iterable<String> correctionIds,
  ) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return const <CaptureCorrection>[];
    }
    final List<CaptureCorrection> corrections = await repositories
        .captureCorrectionRepository
        .undoCorrections(correctionIds);
    await _reloadFromRepositories();
    _startProcessingResumeWindow();
    return corrections;
  }

  Future<String?> organizePhotosIntoNewDish({
    required Iterable<String> captureIds,
    required String title,
  }) async {
    final List<String> ids = captureIds.toSet().toList(growable: false);
    if (ids.isEmpty) {
      return null;
    }
    final CaptureItem first = captureItems.firstWhere(
      (CaptureItem item) => item.id == ids.first,
    );
    final String? batchId = first.batchId;
    if (batchId == null) {
      return null;
    }
    final CaptureCorrection? created = first.appliedDishId == null
        ? await assignUnclassifiedPhotosToNewDish(
            batchId: batchId,
            captureIds: <String>[first.id],
            title: title,
          )
        : await splitCapturePhotos(
            batchId: batchId,
            captureIds: <String>[first.id],
            title: title,
          );
    final String? dishId = created?.createdDishId;
    if (dishId == null) {
      return null;
    }
    await organizePhotos(
      captureIds: ids.where((String id) => id != first.id),
      dishId: dishId,
    );
    return dishId;
  }

  Future<void> dismissPhotoSuggestion(String captureId) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      _reviewItems = _reviewItems
          .where((ReviewItem item) => item.captureId != captureId)
          .toList(growable: false);
      _notifyChanged();
      return;
    }
    await repositories.captureRepository.dismissSuggestion(captureId);
    await _reloadFromRepositories();
  }
}
