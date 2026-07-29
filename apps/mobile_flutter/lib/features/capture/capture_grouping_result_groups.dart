part of 'capture_grouping_result.dart';

class _OutcomeHeading extends StatelessWidget {
  const _OutcomeHeading({
    required this.photoCount,
    required this.dishCount,
    required this.unclassifiedCount,
  });

  final int photoCount;
  final int dishCount;
  final int unclassifiedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          '$photoCount ${photoCount == 1 ? 'photo' : 'photos'} organized into '
          '$dishCount ${dishCount == 1 ? 'dish' : 'dishes'}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          unclassifiedCount == 0
              ? 'Every photo is shown under the dish where it was organized.'
              : '$unclassifiedCount '
                  '${unclassifiedCount == 1 ? 'photo was' : 'photos were'} '
                  'left unclassified and shown below.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _CorrectionHeading extends StatelessWidget {
  const _CorrectionHeading({required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'Select, then drag',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          selectedCount == 0
              ? 'Tap photos to select one or more. Drag them onto another dish.'
              : '$selectedCount selected · drag them together or tap a destination.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DishDropGroup extends StatelessWidget {
  const _DishDropGroup({
    required this.dish,
    required this.items,
    required this.selectedIds,
    required this.allSelectedItems,
    required this.onToggleSelected,
    required this.onDrop,
    required this.onTapDestination,
  });

  final Dish dish;
  final List<CaptureItem> items;
  final Set<String> selectedIds;
  final List<CaptureItem> allSelectedItems;
  final ValueChanged<String> onToggleSelected;
  final ValueChanged<List<String>> onDrop;
  final VoidCallback? onTapDestination;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_CaptureDragPayload>(
      onWillAcceptWithDetails: (_CaptureDragPayloadDetails details) =>
          details.data.sourceGroupIds.any(
        (String sourceDishId) => sourceDishId != dish.id,
      ),
      onAcceptWithDetails: (_CaptureDragPayloadDetails details) {
        onDrop(details.data.itemIds);
      },
      builder: (
        BuildContext context,
        List<_CaptureDragPayload?> candidates,
        List<dynamic> rejected,
      ) {
        final bool active = candidates.isNotEmpty;
        return Semantics(
          button: onTapDestination != null,
          label: 'Move selected photos to ${dish.title}',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTapDestination,
              borderRadius: BorderRadius.circular(MyMenuUnits.cardRadius),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      active ? MyMenuColors.orangeSoft : MyMenuColors.surface,
                  borderRadius: BorderRadius.circular(MyMenuUnits.cardRadius),
                  border: Border.all(
                    color:
                        active ? MyMenuColors.orangeAction : MyMenuColors.line,
                    width: active ? 2 : 1,
                  ),
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
                          active
                              ? 'Drop here'
                              : '${items.length} ${items.length == 1 ? 'photo' : 'photos'}',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: active
                                        ? MyMenuColors.orangeDark
                                        : MyMenuColors.muted,
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
                          _DraggableCapturePhoto(
                            item: item,
                            selected: selectedIds.contains(item.id),
                            selectedItems: allSelectedItems,
                            onToggleSelected: onToggleSelected,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
