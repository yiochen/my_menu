import 'package:flutter/material.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

Future<({String dishId, bool includeBatch})?> showPhotoDishPicker(
  BuildContext context, {
  required List<Dish> dishes,
  int batchSiblingCount = 0,
}) {
  return showModalBottomSheet<({String dishId, bool includeBatch})>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: MyMenuColors.cream,
    builder: (BuildContext context) => _DishPicker(
      dishes: dishes,
      batchSiblingCount: batchSiblingCount,
    ),
  );
}

Future<String?> showNewPhotoDishDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Create a dish'),
      content: TextField(
        key: const ValueKey<String>('photo_new_dish_name'),
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Dish name'),
        onSubmitted: (String value) {
          if (value.trim().isNotEmpty) Navigator.pop(context, value.trim());
        },
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

class _DishPicker extends StatefulWidget {
  const _DishPicker({required this.dishes, required this.batchSiblingCount});

  final List<Dish> dishes;
  final int batchSiblingCount;

  @override
  State<_DishPicker> createState() => _DishPickerState();
}

class _DishPickerState extends State<_DishPicker> {
  bool _includeBatch = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: MyMenuColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text('Choose a dish',
              style: Theme.of(context).textTheme.headlineSmall),
          if (widget.batchSiblingCount > 0)
            SwitchListTile.adaptive(
              key: const ValueKey<String>('photo_include_batch'),
              contentPadding: EdgeInsets.zero,
              value: _includeBatch,
              onChanged: (bool value) => setState(() => _includeBatch = value),
              title: Text(
                  'Also organize ${widget.batchSiblingCount} nearby photos'),
              subtitle: const Text(
                  'Photos captured together usually belong together.'),
            ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.dishes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final Dish dish = widget.dishes[index];
                return ListTile(
                  key: ValueKey<String>('photo_dish_${dish.id}'),
                  leading: const Icon(Icons.restaurant_rounded),
                  title: Text(dish.title),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pop(
                    context,
                    (dishId: dish.id, includeBatch: _includeBatch),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
