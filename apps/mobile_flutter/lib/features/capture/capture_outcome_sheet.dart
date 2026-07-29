import 'package:flutter/material.dart';

import 'package:mymenu/domain/ai/ai_job.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
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
            CaptureOutcomeStep.created => _createdView(),
            CaptureOutcomeStep.failed => CaptureFailedView(
                failureReason: _batch()?.failureReason,
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
      if (batch.id == widget.batchId) {
        if (batch.isWaitingForConnection) {
          return CaptureOutcomeStep.offline;
        }
        if (batch.status == CaptureBatchStatus.applied) {
          return CaptureOutcomeStep.created;
        }
        if (batch.status == CaptureBatchStatus.failed) {
          return CaptureOutcomeStep.failed;
        }
      }
    }
    return _step;
  }

  Widget _createdView() {
    final String? batchId = widget.batchId;
    if (batchId != null &&
        (_resultDishes().isNotEmpty || _rejectedCount() > 0)) {
      return CaptureGroupingResultView(
        state: widget.state,
        batchId: batchId,
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
    final CaptureBatch? batch = _batch();
    if (batch == null) {
      return const <Dish>[];
    }
    final Set<String> dishIds = batch.items
        .map((item) => item.appliedDishId)
        .whereType<String>()
        .toSet();
    return widget.state.dishes
        .where((Dish dish) => dishIds.contains(dish.id))
        .toList(growable: false);
  }

  int _rejectedCount() =>
      _batch()
          ?.items
          .where(
              (CaptureItem item) => item.status == CaptureItemStatus.discarded)
          .length ??
      0;

  CaptureBatch? _batch() => widget.state.captureBatches
      .where((CaptureBatch item) => item.id == widget.batchId)
      .firstOrNull;

  Future<void> _retry() async {
    final String? batchId = widget.batchId;
    if (batchId == null) {
      return;
    }
    final AiJob? groupingJob = widget.state.aiJobs
        .where(
          (AiJob job) =>
              job.type == AiJobType.batchGrouping &&
              job.subjectId == batchId &&
              job.status.canRetry,
        )
        .firstOrNull;
    setState(() => _step = CaptureOutcomeStep.saved);
    if (groupingJob != null) {
      await widget.state.retryAiJob(groupingJob.id);
    } else {
      await widget.state.retryCaptureBatch(batchId);
    }
  }

  void _close() => Navigator.pop(context);
}
