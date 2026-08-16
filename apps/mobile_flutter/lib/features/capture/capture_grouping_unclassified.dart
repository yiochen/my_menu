part of 'capture_grouping_result.dart';

enum _UnclassifiedDestination { existingDish, newDish }

Future<_UnclassifiedDestination?> _showUnclassifiedDestinationSheet(
  BuildContext context,
) {
  return showModalBottomSheet<_UnclassifiedDestination>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Assign photo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'You decide where this photo belongs.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              ListTile(
                key: const ValueKey<String>('assign_to_existing_dish'),
                leading: const Icon(Icons.search_rounded),
                title: const Text('Choose a dish'),
                subtitle: const Text('Search your Menu'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(
                  context,
                  _UnclassifiedDestination.existingDish,
                ),
              ),
              ListTile(
                key: const ValueKey<String>('assign_to_new_dish'),
                leading: const Icon(Icons.add_rounded),
                title: const Text('Make a new dish'),
                subtitle: const Text('Start a new history with this photo'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(
                  context,
                  _UnclassifiedDestination.newDish,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _UnclassifiedSection extends StatelessWidget {
  const _UnclassifiedSection({
    required this.items,
    required this.onAssign,
    required this.onDelete,
  });

  final List<CaptureItem> items;
  final ValueChanged<CaptureItem> onAssign;
  final ValueChanged<CaptureItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('unclassified_capture_section'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MyMenuColors.oat,
        borderRadius: BorderRadius.circular(MyMenuUnits.cardRadius),
        border: Border.all(color: MyMenuColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.photo_library_outlined,
                color: MyMenuColors.orangeDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unclassified photos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${items.length}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'These did not look like dishes. Assign one manually or delete it.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (int index = 0; index < items.length; index += 1) ...<Widget>[
            _UnclassifiedPhotoRow(
              item: items[index],
              onAssign: () => onAssign(items[index]),
              onDelete: () => onDelete(items[index]),
            ),
            if (index != items.length - 1) const Divider(height: 22),
          ],
        ],
      ),
    );
  }
}

class _UnclassifiedPhotoRow extends StatelessWidget {
  const _UnclassifiedPhotoRow({
    required this.item,
    required this.onAssign,
    required this.onDelete,
  });

  final CaptureItem item;
  final VoidCallback onAssign;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String? imageRef = item.localMediaRef;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: MyMenuColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MyMenuColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageRef == null
              ? const FoodCoverPlaceholder(width: 82, height: 82)
              : AppImage(
                  imageRef: imageRef,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.failureReason ?? 'No dish was recognized in this photo.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  TextButton.icon(
                    key: ValueKey<String>('assign_unclassified_${item.id}'),
                    onPressed: onAssign,
                    icon: const Icon(Icons.drive_file_move_outline, size: 18),
                    label: const Text('Assign'),
                  ),
                  IconButton(
                    key: ValueKey<String>('delete_unclassified_${item.id}'),
                    tooltip: 'Delete photo',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
