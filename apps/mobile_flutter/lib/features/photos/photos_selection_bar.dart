import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mymenu/domain/capture/capture_correction.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

class PhotoSelectionBar extends StatelessWidget {
  const PhotoSelectionBar({
    required this.count,
    required this.onAssign,
    required this.onCreate,
    required this.onDelete,
    super.key,
  });

  final int count;
  final VoidCallback onAssign;
  final VoidCallback onCreate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        elevation: 10,
        color: MyMenuColors.ink,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$count selected',
                    style: const TextStyle(color: Colors.white)),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Add selected photos to a dish',
                onPressed: onAssign,
                color: Colors.white,
                icon: const Icon(Icons.restaurant_menu_rounded),
              ),
              IconButton(
                tooltip: 'Split selected photos across dishes',
                onPressed: count > 1 ? onCreate : null,
                color: Colors.white,
                icon: const Icon(Icons.call_split_rounded),
              ),
              IconButton(
                tooltip: 'Delete selected photos',
                onPressed: onDelete,
                color: Colors.white,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showPhotoUndoSnackBar(
  BuildContext context,
  MyMenuState state,
  String? batchId,
  String message,
) {
  if (batchId == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => unawaited(
          state.undoLatestCaptureCorrection(batchId),
        ),
      ),
    ),
  );
}

void showPhotoBulkUndoSnackBar(
  BuildContext context,
  MyMenuState state,
  List<CaptureCorrection> corrections,
  String message,
) {
  if (corrections.isEmpty) return;
  final List<String> ids = corrections
      .map((CaptureCorrection correction) => correction.id)
      .toList(growable: false);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => unawaited(state.undoPhotoCorrections(ids)),
      ),
    ),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showPhotoDeletionUndo(
  BuildContext context,
  Set<String> ids, {
  required Duration duration,
  required VoidCallback onUndo,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration,
      content: Text(
        ids.length == 1 ? 'Photo removed' : '${ids.length} photos removed',
      ),
      action: SnackBarAction(label: 'Undo', onPressed: onUndo),
    ),
  );
}
