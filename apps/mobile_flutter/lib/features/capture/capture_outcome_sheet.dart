import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_outcome_recovery.dart';
import 'package:mymenu/features/capture/capture_outcome_success.dart';

enum CaptureOutcomeStep { saved, matched, created, offline, permission }

Future<void> showCaptureOutcomeSheet(
  BuildContext context, {
  required MyMenuState state,
  required CaptureOutcomeStep initialStep,
  required CaptureOutcomeStep organizedStep,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => CaptureOutcomeSheet(
      state: state,
      initialStep: initialStep,
      organizedStep: organizedStep,
    ),
  );
}

class CaptureOutcomeSheet extends StatefulWidget {
  const CaptureOutcomeSheet({
    required this.state,
    required this.initialStep,
    required this.organizedStep,
    super.key,
  });

  final MyMenuState state;
  final CaptureOutcomeStep initialStep;
  final CaptureOutcomeStep organizedStep;

  @override
  State<CaptureOutcomeSheet> createState() => _CaptureOutcomeSheetState();
}

class _CaptureOutcomeSheetState extends State<CaptureOutcomeSheet> {
  late CaptureOutcomeStep _step;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    if (_step == CaptureOutcomeStep.saved) {
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 900), () {
          if (mounted && _step == CaptureOutcomeStep.saved) {
            setState(() => _step = widget.organizedStep);
          }
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: switch (_step) {
        CaptureOutcomeStep.saved => CaptureSavedView(onClose: _close),
        CaptureOutcomeStep.matched => CaptureMatchedView(
            dish: widget.state.dishById('dish_salmon'),
            onClose: _close,
          ),
        CaptureOutcomeStep.created => CaptureCreatedView(onClose: _close),
        CaptureOutcomeStep.offline => CaptureOfflineView(onClose: _close),
        CaptureOutcomeStep.permission => CapturePermissionView(
            state: widget.state,
            onClose: _close,
          ),
      },
    );
  }

  void _close() => Navigator.pop(context);
}
