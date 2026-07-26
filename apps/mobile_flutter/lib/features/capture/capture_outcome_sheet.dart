import 'package:flutter/material.dart';

import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_outcome_recovery.dart';
import 'package:mymenu/features/capture/capture_outcome_success.dart';

enum CaptureOutcomeStep { saved, matched, created, offline, permission }

Future<void> showCaptureOutcomeSheet(
  BuildContext context, {
  required MyMenuState state,
  required CaptureOutcomeStep initialStep,
  required CaptureOutcomeStep organizedStep,
  required int photoCount,
  String? batchId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => CaptureOutcomeSheet(
      state: state,
      initialStep: initialStep,
      organizedStep: organizedStep,
      photoCount: photoCount,
      batchId: batchId,
    ),
  );
}

class CaptureOutcomeSheet extends StatefulWidget {
  const CaptureOutcomeSheet({
    required this.state,
    required this.initialStep,
    required this.organizedStep,
    required this.photoCount,
    this.batchId,
    super.key,
  });

  final MyMenuState state;
  final CaptureOutcomeStep initialStep;
  final CaptureOutcomeStep organizedStep;
  final int photoCount;
  final String? batchId;

  @override
  State<CaptureOutcomeSheet> createState() => _CaptureOutcomeSheetState();
}

class _CaptureOutcomeSheetState extends State<CaptureOutcomeSheet> {
  late CaptureOutcomeStep _step;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (BuildContext context, _) {
        final CaptureOutcomeStep displayStep = _displayStep();
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: switch (displayStep) {
            CaptureOutcomeStep.saved => CaptureSavedView(
                onClose: _close,
                photoCount: widget.photoCount,
              ),
            CaptureOutcomeStep.matched => CaptureMatchedView(
                dish: widget.state.dishById('dish_salmon'),
                onClose: _close,
              ),
            CaptureOutcomeStep.created => CaptureCreatedView(onClose: _close),
            CaptureOutcomeStep.offline => CaptureOfflineView(
                onClose: _close,
                photoCount: widget.photoCount,
              ),
            CaptureOutcomeStep.permission => CapturePermissionView(
                state: widget.state,
                onClose: _close,
              ),
          },
        );
      },
    );
  }

  CaptureOutcomeStep _displayStep() {
    if (_step != CaptureOutcomeStep.saved || widget.batchId == null) {
      return _step;
    }
    for (final CaptureBatch batch in widget.state.captureBatches) {
      if (batch.id == widget.batchId && batch.isWaitingForConnection) {
        return CaptureOutcomeStep.offline;
      }
    }
    return _step;
  }

  void _close() => Navigator.pop(context);
}
