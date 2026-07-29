part of 'capture_grouping_result.dart';

class _CorrectionTopBar extends StatelessWidget {
  const _CorrectionTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Back',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Text(
            'Correct grouping',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _OutcomeDishGroup extends StatelessWidget {
  const _OutcomeDishGroup({required this.dish, required this.items});

  final Dish dish;
  final List<CaptureItem> items;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${dish.title}, ${items.length} source ${items.length == 1 ? 'photo' : 'photos'}',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MyMenuColors.surface,
          borderRadius: BorderRadius.circular(MyMenuUnits.cardRadius),
          border: Border.all(color: MyMenuColors.line),
          boxShadow: myMenuCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    dish.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${items.length} ${items.length == 1 ? 'photo' : 'photos'}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: MyMenuColors.muted,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final CaptureItem item in items)
                  _OutcomeCapturePhoto(item: item),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeCapturePhoto extends StatelessWidget {
  const _OutcomeCapturePhoto({required this.item});

  final CaptureItem item;

  @override
  Widget build(BuildContext context) {
    final String? imageRef = item.localMediaRef ?? item.remoteMediaRef;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: MyMenuColors.oat,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyMenuColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageRef == null
          ? const Icon(Icons.photo_outlined)
          : AppImage(
              imageRef: imageRef,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
    );
  }
}

class _DraggableCapturePhoto extends StatelessWidget {
  const _DraggableCapturePhoto({
    required this.item,
    required this.selected,
    required this.selectedItems,
    required this.onToggleSelected,
  });

  final CaptureItem item;
  final bool selected;
  final List<CaptureItem> selectedItems;
  final ValueChanged<String> onToggleSelected;

  @override
  Widget build(BuildContext context) {
    final List<CaptureItem> draggedItems = selected && selectedItems.isNotEmpty
        ? selectedItems
        : <CaptureItem>[item];
    final _CaptureDragPayload payload = _CaptureDragPayload(
      items: draggedItems,
      itemIds: draggedItems.map((CaptureItem capture) => capture.id).toList(),
      sourceGroupIds: draggedItems
          .map((CaptureItem capture) => capture.appliedDishId!)
          .toList(),
    );
    return LongPressDraggable<_CaptureDragPayload>(
      data: payload,
      maxSimultaneousDrags: 1,
      feedback: _CaptureDragFeedback(items: draggedItems),
      childWhenDragging: Opacity(opacity: 0.3, child: _photo(context)),
      child: _photo(context),
    );
  }

  Widget _photo(BuildContext context) {
    final String? imageRef = item.localMediaRef ?? item.remoteMediaRef;
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? 'Selected capture photo' : 'Select capture photo',
      child: GestureDetector(
        onTap: () => onToggleSelected(item.id),
        child: Stack(
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      selected ? MyMenuColors.orangeAction : MyMenuColors.line,
                  width: selected ? 3 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageRef == null
                  ? const ColoredBox(
                      color: MyMenuColors.oat,
                      child: Icon(Icons.photo_outlined),
                    )
                  : AppImage(
                      imageRef: imageRef,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
            ),
            if (selected)
              const Positioned(
                right: 5,
                top: 5,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: MyMenuColors.orangeAction,
                  child: Icon(Icons.check, size: 13, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CaptureDragFeedback extends StatelessWidget {
  const _CaptureDragFeedback({required this.items});

  final List<CaptureItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: MyMenuColors.ink,
          borderRadius: BorderRadius.circular(18),
          boxShadow: myMenuCardShadow,
        ),
        child: Text(
          '${items.length} ${items.length == 1 ? 'photo' : 'photos'}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({
    required this.selectedCount,
    required this.onClear,
  });

  final int selectedCount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            '$selectedCount ${selectedCount == 1 ? 'photo' : 'photos'} selected',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        TextButton(onPressed: onClear, child: const Text('Clear')),
      ],
    );
  }
}

class _DestinationDropZone extends StatelessWidget {
  const _DestinationDropZone({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onDrop,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ValueChanged<List<String>> onDrop;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_CaptureDragPayload>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (_CaptureDragPayloadDetails details) {
        onDrop(details.data.itemIds);
      },
      builder: (
        BuildContext context,
        List<_CaptureDragPayload?> candidates,
        List<dynamic> rejected,
      ) {
        final bool active = candidates.isNotEmpty;
        return Material(
          color: active ? MyMenuColors.orangeSoft : MyMenuColors.surface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              constraints: const BoxConstraints(minHeight: 74),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? MyMenuColors.orangeAction : MyMenuColors.line,
                  width: active ? 2 : 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(icon, color: MyMenuColors.orangeDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          active ? 'Drop here' : title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CorrectionStatus extends StatelessWidget {
  const _CorrectionStatus({
    required this.correction,
    required this.onUndo,
  });

  final CaptureCorrection correction;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final (IconData, String, Color, Color) display =
        switch (correction.status) {
      CaptureCorrectionStatus.pending => (
          Icons.sync_rounded,
          'Saved here · syncing',
          MyMenuColors.orangeDark,
          MyMenuColors.orangeSoft,
        ),
      CaptureCorrectionStatus.synced => (
          Icons.cloud_done_outlined,
          'Correction synced',
          MyMenuColors.green,
          MyMenuColors.greenSoft,
        ),
      CaptureCorrectionStatus.failed => (
          Icons.error_outline,
          'Could not save · grouping restored',
          MyMenuColors.red,
          MyMenuColors.redSoft,
        ),
      CaptureCorrectionStatus.undone => (
          Icons.undo_rounded,
          'Correction undone',
          MyMenuColors.muted,
          MyMenuColors.oat,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: display.$4,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Icon(display.$1, color: display.$3),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              display.$2,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: display.$3,
                  ),
            ),
          ),
          if (onUndo != null)
            TextButton(
              key: const ValueKey<String>('undo_capture_correction'),
              onPressed: onUndo,
              child: const Text('Undo'),
            ),
        ],
      ),
    );
  }
}
