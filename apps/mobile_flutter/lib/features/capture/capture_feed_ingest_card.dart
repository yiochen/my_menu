part of 'capture_feed_sheet.dart';

class _CaptureIngestCard extends StatelessWidget {
  const _CaptureIngestCard({
    required this.ingest,
    required this.state,
  });

  final CaptureIngest ingest;
  final MyMenuState state;

  @override
  Widget build(BuildContext context) {
    final bool canRetry = ingest.failedItemCount > 0 ||
        ingest.status == CaptureIngestStatus.failed;
    final bool canRemove = ingest.status != CaptureIngestStatus.applied &&
        ingest.status != CaptureIngestStatus.discarded;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: ingest.status == CaptureIngestStatus.applied
            ? () => _openIngestResult(context, state, ingest)
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
                      _ingestTitle(ingest),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _IngestStatusPill(ingest: ingest),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 82,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ingest.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int index) {
                    return _CapturePreview(item: ingest.items[index]);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(_progressLabel(ingest)),
              if (canRetry) ...<Widget>[
                const SizedBox(height: 8),
                FilledButton.icon(
                  key: ValueKey<String>('retry_ingest_${ingest.id}'),
                  onPressed: () => state.retryCaptureIngest(ingest.id),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    ingest.failedItemCount == 0
                        ? 'Retry organization'
                        : ingest.failedItemCount == 1
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
                    key: ValueKey<String>('remove_ingest_${ingest.id}'),
                    onPressed: () => _removeIngest(context),
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

  Future<void> _removeIngest(BuildContext context) async {
    if (!await confirmCaptureIngestRemoval(context, ingest) ||
        !context.mounted) {
      return;
    }
    await state.deleteCaptureIngest(ingest.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pending upload removed')),
    );
  }

  String _ingestTitle(CaptureIngest ingest) {
    final int count = ingest.items.length;
    return '$count ${count == 1 ? 'photo' : 'photos'}';
  }

  String _progressLabel(CaptureIngest ingest) {
    if (ingest.status == CaptureIngestStatus.applied) {
      final int dishCount = ingest.items
          .map((CaptureItem item) => item.appliedDishId)
          .whereType<String>()
          .toSet()
          .length;
      return dishCount == 1 ? 'Added to 1 dish' : 'Added to $dishCount dishes';
    }
    if (ingest.status == CaptureIngestStatus.processing) {
      return '${ingest.items.length} of ${ingest.items.length} uploaded · '
          'organizing in the background';
    }
    if (ingest.isWaitingForConnection) {
      return 'Saved on this device · ${ingest.uploadedItemCount} of '
          '${ingest.items.length} uploaded';
    }
    if (ingest.failedItemCount > 0) {
      return '${ingest.uploadedItemCount} of ${ingest.items.length} uploaded · '
          '${ingest.failedItemCount} failed';
    }
    return '${ingest.uploadedItemCount} of ${ingest.items.length} uploaded';
  }
}

class _IngestStatusPill extends StatelessWidget {
  const _IngestStatusPill({required this.ingest});

  final CaptureIngest ingest;

  @override
  Widget build(BuildContext context) {
    final (String, Color, Color) display = ingest.isWaitingForConnection
        ? (
            'Saved on this device',
            MyMenuColors.orangeDark,
            MyMenuColors.orangeSoft,
          )
        : switch (ingest.status) {
            CaptureIngestStatus.local || CaptureIngestStatus.pendingUpload => (
                'Saved',
                MyMenuColors.orangeDark,
                MyMenuColors.orangeSoft
              ),
            CaptureIngestStatus.uploading => (
                'Sending',
                MyMenuColors.orangeDark,
                MyMenuColors.orangeSoft
              ),
            CaptureIngestStatus.readyForAi => (
                'Waiting',
                MyMenuColors.green,
                MyMenuColors.greenSoft
              ),
            CaptureIngestStatus.processing => (
                'Organizing',
                MyMenuColors.orangeDark,
                MyMenuColors.orangeSoft
              ),
            CaptureIngestStatus.applied => (
                'Added',
                MyMenuColors.green,
                MyMenuColors.greenSoft
              ),
            CaptureIngestStatus.failed => (
                'Needs retry',
                Colors.red.shade800,
                Colors.red.shade50
              ),
            CaptureIngestStatus.discarded => (
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
    final String? imageRef = item.localMediaRef;
    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageRef == null
              ? const FoodCoverPlaceholder(width: 82, height: 82)
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
