import 'package:flutter/material.dart';

import 'package:mymenu/domain/capture/capture_ingest.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_grouping_result.dart';
import 'package:mymenu/features/capture/capture_outcome_recovery.dart';
import 'package:mymenu/features/capture/capture_outcome_success.dart';

enum CaptureOutcomeStep { saved, matched, created, failed, offline, permission }

Future<void> showCaptureOutcomeSheet(
  BuildContext context, {
  required MyMenuState state,
  required CaptureOutcomeStep initialStep,
  required CaptureOutcomeStep organizedStep,
  required int photoCount,
  String? ingestId,
}) {
  if (initialStep == CaptureOutcomeStep.created) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          body: CaptureOutcomeSheet(
            state: state,
            initialStep: initialStep,
            organizedStep: organizedStep,
            photoCount: photoCount,
            ingestId: ingestId,
            fullScreen: true,
          ),
        ),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => CaptureOutcomeSheet(
      state: state,
      initialStep: initialStep,
      organizedStep: organizedStep,
      photoCount: photoCount,
      ingestId: ingestId,
    ),
  );
}

class CaptureOutcomeSheet extends StatefulWidget {
  const CaptureOutcomeSheet({
    required this.state,
    required this.initialStep,
    required this.organizedStep,
    required this.photoCount,
    this.ingestId,
    this.fullScreen = false,
    super.key,
  });

  final MyMenuState state;
  final CaptureOutcomeStep initialStep;
  final CaptureOutcomeStep organizedStep;
  final int photoCount;
  final String? ingestId;
  final bool fullScreen;

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
        final Widget content = switch (displayStep) {
          CaptureOutcomeStep.saved => CaptureSavedView(
              onClose: _close,
              photoCount: widget.photoCount,
            ),
          CaptureOutcomeStep.matched => CaptureMatchedView(
              dish: widget.state.dishById('dish_salmon'),
              onClose: _close,
            ),
          CaptureOutcomeStep.created => _createdView(),
          CaptureOutcomeStep.failed => CaptureFailedView(
              failureReason: _ingest()?.failureReason,
              onRetry: _retry,
              onClose: _close,
            ),
          CaptureOutcomeStep.offline => CaptureOfflineView(
              onClose: _close,
              photoCount: widget.photoCount,
            ),
          CaptureOutcomeStep.permission => CapturePermissionView(
              state: widget.state,
              onClose: _close,
            ),
        };
        return widget.fullScreen
            ? SafeArea(bottom: false, child: content)
            : FractionallySizedBox(heightFactor: 0.9, child: content);
      },
    );
  }

  CaptureOutcomeStep _displayStep() {
    if (_step != CaptureOutcomeStep.saved || widget.ingestId == null) {
      return _step;
    }
    for (final CaptureIngest ingest in widget.state.captureIngests) {
      if (ingest.id == widget.ingestId) {
        if (ingest.isWaitingForConnection) {
          return CaptureOutcomeStep.offline;
        }
        if (ingest.status == CaptureIngestStatus.applied) {
          return CaptureOutcomeStep.created;
        }
        if (ingest.status == CaptureIngestStatus.failed) {
          return CaptureOutcomeStep.failed;
        }
      }
    }
    return _step;
  }

  Widget _createdView() {
    final String? ingestId = widget.ingestId;
    if (ingestId != null &&
        (_resultDishes().isNotEmpty || _rejectedCount() > 0)) {
      return CaptureGroupingResultView(
        state: widget.state,
        ingestId: ingestId,
        onClose: _close,
      );
    }
    return CaptureCreatedView(
      dishes: _resultDishes(),
      rejectedCount: _rejectedCount(),
      onClose: _close,
    );
  }

  List<Dish> _resultDishes() {
    final CaptureIngest? ingest = _ingest();
    if (ingest == null) {
      return const <Dish>[];
    }
    final Set<String> dishIds = ingest.items
        .map((item) => item.appliedDishId)
        .whereType<String>()
        .toSet();
    return widget.state.dishes
        .where((Dish dish) => dishIds.contains(dish.id))
        .toList(growable: false);
  }

  int _rejectedCount() =>
      _ingest()
          ?.items
          .where(
              (CaptureItem item) => item.status == CaptureItemStatus.discarded)
          .length ??
      0;

  CaptureIngest? _ingest() => widget.state.captureIngests
      .where((CaptureIngest item) => item.id == widget.ingestId)
      .firstOrNull;

  Future<void> _retry() async {
    final String? ingestId = widget.ingestId;
    if (ingestId == null) {
      return;
    }
    setState(() => _step = CaptureOutcomeStep.saved);
    await widget.state.retryCaptureIngest(ingestId);
  }

  void _close() => Navigator.pop(context);
}
