part of 'my_menu_state.dart';

extension MyMenuStatePhotos on MyMenuState {
  Future<List<CaptureCorrection>> organizePhotos({
    required Iterable<String> captureIds,
    required String dishId,
  }) async {
    final Set<String> requested = captureIds.toSet();
    final List<CaptureItem> selected = captureItems
        .where((CaptureItem item) => requested.contains(item.id))
        .toList(growable: false);
    final Map<(String, bool), List<String>> groups =
        <(String, bool), List<String>>{};
    for (final CaptureItem item in selected) {
      final String? batchId = item.batchId;
      if (batchId == null) {
        continue;
      }
      groups.putIfAbsent(
        (batchId, item.appliedDishId == null),
        () => <String>[],
      ).add(item.id);
    }
    final List<CaptureCorrection> corrections = <CaptureCorrection>[];
    for (final MapEntry<(String, bool), List<String>> group in groups.entries) {
      final CaptureCorrection? correction = group.key.$2
          ? await assignUnclassifiedPhotos(
              batchId: group.key.$1,
              captureIds: group.value,
              targetDishId: dishId,
            )
          : await moveCapturePhotos(
              batchId: group.key.$1,
              captureIds: group.value,
              targetDishId: dishId,
            );
      if (correction != null) {
        corrections.add(correction);
      }
    }
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
