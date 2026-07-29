part of 'capture_feed_sheet.dart';

class _CaptureBatchCard extends StatelessWidget {
  const _CaptureBatchCard({
    required this.batch,
    required this.state,
    required this.groupingJob,
  });

  final CaptureBatch batch;
  final MyMenuState state;
  final AiJob? groupingJob;

  @override
  Widget build(BuildContext context) {
    final bool canRetryAi = batch.status == CaptureBatchStatus.failed &&
        groupingJob?.status == AiJobStatus.failed;
    final bool canRetryUpload = batch.failedItemCount > 0 ||
        (batch.status == CaptureBatchStatus.failed && !canRetryAi);
    final bool canRetry = canRetryAi || canRetryUpload;
    final bool canRemove = batch.status != CaptureBatchStatus.applied &&
        batch.status != CaptureBatchStatus.discarded;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: batch.status == CaptureBatchStatus.applied
            ? () => _openBatchResult(context, state, batch)
            : null,
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
                  onPressed: canRetryAi
                      ? () => state.retryAiJob(groupingJob!.id)
                      : () => state.retryCaptureBatch(batch.id),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    canRetryAi
                        ? 'Retry organization'
                        : batch.failedItemCount == 0
                            ? 'Retry batch'
                            : batch.failedItemCount == 1
                                ? 'Retry failed photo'
                                : 'Retry failed photos',
                  ),
                ),
              ],
              if (canRemove) ...<Widget>[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: ValueKey<String>('remove_batch_${batch.id}'),
                    onPressed: () => _removeBatch(context),
                    style: TextButton.styleFrom(
                      foregroundColor: MyMenuColors.red,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Remove upload'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeBatch(BuildContext context) async {
    if (!await confirmCaptureBatchRemoval(context, batch) || !context.mounted) {
      return;
    }
    await state.deleteCaptureBatch(batch.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pending upload removed')),
    );
  }

  String _batchTitle(CaptureBatch batch) {
    final int count = batch.items.length;
    return '$count ${count == 1 ? 'photo' : 'photos'}';
  }

  String _progressLabel(CaptureBatch batch) {
    if (batch.status == CaptureBatchStatus.applied) {
      final int dishCount = batch.items
          .map((CaptureItem item) => item.appliedDishId)
          .whereType<String>()
          .toSet()
          .length;
      return dishCount == 1
          ? 'Added as 1 cooking occasion'
          : 'Added as $dishCount cooking occasions';
    }
    if (batch.status == CaptureBatchStatus.processing) {
      return '${batch.items.length} of ${batch.items.length} uploaded · '
          'organizing in the background';
    }
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
