import 'package:flutter/material.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

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
              onRefresh: state.refreshFromServer,
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
                    'Each card is one capture batch. Photos stay in the order '
                    'you took or selected them.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (batches.isEmpty)
                    const Text('No capture batches yet.')
                  else
                    for (final CaptureBatch batch in batches) ...<Widget>[
                      _CaptureBatchCard(batch: batch, state: state),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _CaptureBatchCard extends StatelessWidget {
  const _CaptureBatchCard({required this.batch, required this.state});

  final CaptureBatch batch;
  final MyMenuState state;

  @override
  Widget build(BuildContext context) {
    final bool canRetry =
        batch.failedItemCount > 0 || batch.status == CaptureBatchStatus.failed;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _batchTitle(batch),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _BatchStatusPill(batch: batch),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: batch.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  return _CapturePreview(item: batch.items[index]);
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(_progressLabel(batch)),
            if (canRetry) ...<Widget>[
              const SizedBox(height: 8),
              FilledButton.icon(
                key: ValueKey<String>('retry_batch_${batch.id}'),
                onPressed: () => state.retryCaptureBatch(batch.id),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  batch.failedItemCount == 0
                      ? 'Retry batch'
                      : batch.failedItemCount == 1
                          ? 'Retry failed photo'
                          : 'Retry failed photos',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _batchTitle(CaptureBatch batch) {
    final int count = batch.items.length;
    return '$count ${count == 1 ? 'photo' : 'photos'}';
  }

  String _progressLabel(CaptureBatch batch) {
    if (batch.isWaitingForConnection) {
      return 'Saved on this device · ${batch.uploadedItemCount} of '
          '${batch.items.length} uploaded';
    }
    if (batch.failedItemCount > 0) {
      return '${batch.uploadedItemCount} of ${batch.items.length} uploaded · '
          '${batch.failedItemCount} failed';
    }
    return '${batch.uploadedItemCount} of ${batch.items.length} uploaded';
  }
}

class _BatchStatusPill extends StatelessWidget {
  const _BatchStatusPill({required this.batch});

  final CaptureBatch batch;

  @override
  Widget build(BuildContext context) {
    final (String, Color, Color) display = batch.isWaitingForConnection
        ? ('Saved offline', MyMenuColors.orangeDark, MyMenuColors.orangeSoft)
        : switch (batch.status) {
            CaptureBatchStatus.local || CaptureBatchStatus.pendingUpload => (
                'Pending',
                MyMenuColors.orangeDark,
                MyMenuColors.orangeSoft
              ),
            CaptureBatchStatus.uploading => (
                'Uploading',
                MyMenuColors.orangeDark,
                MyMenuColors.orangeSoft
              ),
            CaptureBatchStatus.readyForAi => (
                'Uploaded',
                MyMenuColors.green,
                MyMenuColors.greenSoft
              ),
            CaptureBatchStatus.processing => (
                'Processing',
                MyMenuColors.orangeDark,
                MyMenuColors.orangeSoft
              ),
            CaptureBatchStatus.applied => (
                'Added',
                MyMenuColors.green,
                MyMenuColors.greenSoft
              ),
            CaptureBatchStatus.failed => (
                'Needs retry',
                Colors.red.shade800,
                Colors.red.shade50
              ),
            CaptureBatchStatus.discarded => (
                'Discarded',
                MyMenuColors.muted,
                MyMenuColors.oat
              ),
          };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: display.$3,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          display.$1,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: display.$2,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _CapturePreview extends StatelessWidget {
  const _CapturePreview({required this.item});

  final CaptureItem item;

  @override
  Widget build(BuildContext context) {
    final String? imageRef = item.localMediaRef ?? item.remoteMediaRef;
    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageRef == null
              ? Container(
                  width: 82,
                  height: 82,
                  color: MyMenuColors.oat,
                  child: const Icon(Icons.edit_outlined),
                )
              : AppImage(
                  imageRef: imageRef,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          left: 6,
          top: 6,
          child: CircleAvatar(
            radius: 11,
            backgroundColor: MyMenuColors.ink.withValues(alpha: 0.75),
            child: Text(
              '${item.ordinal + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (item.status == CaptureItemStatus.failed)
          const Positioned(
            right: 5,
            bottom: 5,
            child: CircleAvatar(
              radius: 11,
              backgroundColor: Colors.red,
              child: Icon(Icons.error_outline, size: 15, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
