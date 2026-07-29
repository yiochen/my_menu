part of 'capture_grouping_result.dart';

extension _UnclassifiedResultActions on _CaptureGroupingResultViewState {
  Future<void> _assignUnclassified(CaptureItem item) async {
    final _UnclassifiedDestination? destination =
        await _showUnclassifiedDestinationSheet(context);
    if (!mounted || destination == null) {
      return;
    }
    switch (destination) {
      case _UnclassifiedDestination.existingDish:
        final String? targetDishId = await showCaptureDishSearchSheet(
          context,
          state: widget.state,
          excludedDishIds: const <String>{},
          selectedCount: 1,
        );
        if (targetDishId != null) {
          await widget.state.assignUnclassifiedPhotos(
            batchId: widget.batchId,
            captureIds: <String>[item.id],
            targetDishId: targetDishId,
          );
        }
      case _UnclassifiedDestination.newDish:
        final String? title = await showCaptureNewDishDialog(
          context,
          selectedCount: 1,
        );
        if (title != null) {
          await widget.state.assignUnclassifiedPhotosToNewDish(
            batchId: widget.batchId,
            captureIds: <String>[item.id],
            title: title,
          );
        }
    }
    _refreshUnclassifiedResult();
  }

  Future<void> _confirmDeleteUnclassified(CaptureItem item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete photo?'),
          content: const Text(
            'This removes the photo from Recent Captures. Your dishes do not '
            'change.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const ValueKey<String>('confirm_delete_unclassified'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed ?? false) {
      await widget.state.deleteCapture(item.id);
      _refreshUnclassifiedResult();
    }
  }
}
