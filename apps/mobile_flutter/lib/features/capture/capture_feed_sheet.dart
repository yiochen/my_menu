import 'package:flutter/material.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_batch_removal_dialog.dart';
import 'package:mymenu/features/capture/capture_outcome_sheet.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/food_cover_placeholder.dart';

part 'capture_feed_batch_card.dart';

Future<void> showCaptureFeedSheet(
  BuildContext context,
  MyMenuState state,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.82,
        child: AnimatedBuilder(
          animation: state,
          builder: (BuildContext context, _) {
            final List<CaptureBatch> batches = state.captureBatches;
            return RefreshIndicator(
              onRefresh: state.resumeProcessing,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: <Widget>[
                  Text(
                    'Recent Captures',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Photos stay in the order you took or selected them. '
                    'Open an organized result to correct its grouping.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (batches.isNotEmpty) ...<Widget>[
                    Text(
                      'Capture results',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    for (final CaptureBatch batch in batches) ...<Widget>[
                      _CaptureBatchCard(
                        batch: batch,
                        state: state,
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 4),
                  ],
                  if (batches.isEmpty) const Text('No captures yet.')
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> _openBatchResult(
  BuildContext context,
  MyMenuState state,
  CaptureBatch batch,
) {
  return showCaptureOutcomeSheet(
    context,
    state: state,
    initialStep: CaptureOutcomeStep.created,
    organizedStep: CaptureOutcomeStep.created,
    photoCount: batch.items.length,
    batchId: batch.id,
  );
}
