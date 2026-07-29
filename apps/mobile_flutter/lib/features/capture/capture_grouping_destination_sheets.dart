import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

Future<String?> showCaptureDishSearchSheet(
  BuildContext context, {
  required MyMenuState state,
  required Set<String> excludedDishIds,
  required int selectedCount,
}) {
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) => _CaptureDishSearchSheet(
      state: state,
      excludedDishIds: excludedDishIds,
      selectedCount: selectedCount,
    ),
  );
}

Future<String?> showCaptureNewDishDialog(
  BuildContext context, {
  required int selectedCount,
}) async {
  final TextEditingController controller =
      TextEditingController(text: 'Captured Dish');
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Make a new dish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$selectedCount selected '
              '${selectedCount == 1 ? 'photo' : 'photos'} will start one history.',
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey<String>('new_capture_dish_name'),
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Dish name'),
              onSubmitted: (_) => _submitNewDish(context, controller),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey<String>('create_capture_dish'),
            onPressed: () => _submitNewDish(context, controller),
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
  controller.dispose();
  return result;
}

void _submitNewDish(
  BuildContext context,
  TextEditingController controller,
) {
  final String title = controller.text.trim();
  if (title.isNotEmpty) {
    Navigator.pop(context, title);
  }
}

class _CaptureDishSearchSheet extends StatefulWidget {
  const _CaptureDishSearchSheet({
    required this.state,
    required this.excludedDishIds,
    required this.selectedCount,
  });

  final MyMenuState state;
  final Set<String> excludedDishIds;
  final int selectedCount;

  @override
  State<_CaptureDishSearchSheet> createState() =>
      _CaptureDishSearchSheetState();
}

class _CaptureDishSearchSheetState extends State<_CaptureDishSearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final List<Dish> dishes = widget.state
        .filterDishes(_query)
        .where((Dish dish) => !widget.excludedDishIds.contains(dish.id))
        .toList(growable: false);
    return FractionallySizedBox(
      heightFactor: 0.82,
      child: WarmPage(
        includeBottomChromeSpace: false,
        topPadding: 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Move to another dish',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.selectedCount} selected '
              '${widget.selectedCount == 1 ? 'photo moves' : 'photos move'} together.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            TextField(
              key: const ValueKey<String>('capture_dish_search'),
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search your dishes',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (String value) => setState(() => _query = value),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: dishes.isEmpty
                  ? const Center(child: Text('No other dishes found.'))
                  : ListView.separated(
                      itemCount: dishes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        return _DishDestinationTile(dish: dishes[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DishDestinationTile extends StatelessWidget {
  const _DishDestinationTile({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return WarmCard(
      padding: EdgeInsets.zero,
      shadow: false,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          key: ValueKey<String>('capture_destination_${dish.id}'),
          minTileHeight: 72,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 48,
              height: 48,
              child: DishArtwork(dish: dish),
            ),
          ),
          title: Text(dish.title),
          subtitle: Text(
            '${dish.madeCount} ${dish.madeCount == 1 ? 'cook' : 'cooks'}',
          ),
          trailing: const Icon(
            Icons.arrow_forward_rounded,
            color: MyMenuColors.orangeDark,
          ),
          onTap: () => Navigator.pop(context, dish.id),
        ),
      ),
    );
  }
}
