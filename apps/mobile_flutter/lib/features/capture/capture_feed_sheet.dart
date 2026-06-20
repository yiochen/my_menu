import 'package:flutter/material.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
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
            final List<CaptureItem> items = state.captureItems;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: <Widget>[
                Text(
                  'Capture Feed',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Text('No captures yet.')
                else
                  for (final CaptureItem item in items) ...<Widget>[
                    _CaptureFeedCard(item: item, state: state),
                    const SizedBox(height: 12),
                  ],
              ],
            );
          },
        ),
      );
    },
  );
}

class _CaptureFeedCard extends StatelessWidget {
  const _CaptureFeedCard({
    required this.item,
    required this.state,
  });

  final CaptureItem item;
  final MyMenuState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _CapturePreview(item: item),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.kind == CaptureItemKind.photo ? 'Photo' : 'Idea',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(_statusLabel(item.status)),
                  if (item.appliedDishId != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                        'Added to ${state.dishById(item.appliedDishId!).title}'),
                  ],
                  if (_canDiscard(item)) ...<Widget>[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => state.discardCapture(item.id),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Discard'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canDiscard(CaptureItem item) {
    return item.status != CaptureItemStatus.applied &&
        item.status != CaptureItemStatus.discarded;
  }

  String _statusLabel(CaptureItemStatus status) {
    return switch (status) {
      CaptureItemStatus.localOnly => 'Saved locally',
      CaptureItemStatus.pendingUpload => 'Waiting to upload',
      CaptureItemStatus.uploaded => 'Uploaded',
      CaptureItemStatus.classifying => 'Organizing with fake API',
      CaptureItemStatus.applied => 'Applied to menu',
      CaptureItemStatus.discarded => 'Discarded',
      CaptureItemStatus.failed => 'Failed',
    };
  }
}

class _CapturePreview extends StatelessWidget {
  const _CapturePreview({required this.item});

  final CaptureItem item;

  @override
  Widget build(BuildContext context) {
    final String? imageRef = item.localMediaRef ?? item.remoteMediaRef;
    if (imageRef == null) {
      return Container(
        width: 74,
        height: 74,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F2E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.edit_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AppImage(
        imageRef: imageRef,
        width: 74,
        height: 74,
        fit: BoxFit.cover,
      ),
    );
  }
}
