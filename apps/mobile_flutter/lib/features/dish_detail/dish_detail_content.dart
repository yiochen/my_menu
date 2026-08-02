import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/dish_detail/dish_history_content.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class DishDetailContent extends StatelessWidget {
  const DishDetailContent({
    required this.dish,
    required this.tab,
    required this.onAddPhoto,
    required this.onAddNote,
    required this.onEditIngredients,
    required this.onEditSteps,
    super.key,
  });

  final Dish dish;
  final DishDetailTab tab;
  final VoidCallback onAddPhoto;
  final VoidCallback onAddNote;
  final VoidCallback onEditIngredients;
  final VoidCallback onEditSteps;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      DishDetailTab.journal => DishHistoryContent(
          dish: dish,
          onAddPhoto: onAddPhoto,
          onAddNote: onAddNote,
        ),
      DishDetailTab.recipe => _RecipeContent(
          dish: dish,
          onEditIngredients: onEditIngredients,
          onEditSteps: onEditSteps,
        ),
    };
  }
}

class _RecipeContent extends StatelessWidget {
  const _RecipeContent({
    required this.dish,
    required this.onEditIngredients,
    required this.onEditSteps,
  });

  final Dish dish;
  final VoidCallback onEditIngredients;
  final VoidCallback onEditSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionHeading(
          title: 'Ingredients',
          action: 'Edit',
          onPressed: onEditIngredients,
        ),
        const SizedBox(height: 10),
        for (final String ingredient in dish.ingredients) ...<Widget>[
          _IngredientRow(value: ingredient),
          const SizedBox(height: 9),
        ],
        const SizedBox(height: 9),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.auto_awesome,
              size: 15,
              color: MyMenuColors.orange,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'AI-assisted recipe. Review ingredients and cooking safety '
                'before use.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionHeading(
          title: 'Steps',
          action: 'Edit',
          onPressed: onEditSteps,
        ),
        const SizedBox(height: 10),
        for (int index = 0; index < dish.recipeSteps.length; index += 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: MyMenuColors.orangeSoft,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: MyMenuColors.orangeDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dish.recipeSteps[index],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: MyMenuColors.ink,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onPressed,
  });

  final String title;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            action,
            style: const TextStyle(color: MyMenuColors.orangeDark),
          ),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final List<String> parts = value.split('|');
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: MyMenuColors.oat,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              parts.first.toLowerCase().contains('salmon')
                  ? Icons.set_meal_outlined
                  : Icons.restaurant_outlined,
              size: 17,
              color: MyMenuColors.muted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  parts.first,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (parts.length > 1)
                  Text(parts[1], style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> showAddNoteSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _AddNoteSheet(),
  );
}

class _AddNoteSheet extends StatefulWidget {
  const _AddNoteSheet();

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        10,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SheetTopBar(
            title: 'Add note',
            closeOnLeft: true,
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey<String>('dish_note_input'),
            controller: _controller,
            autofocus: true,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'What should you remember next time?',
            ),
          ),
          const SizedBox(height: 14),
          PrimaryPillButton(
            label: 'Save',
            onPressed: () => Navigator.pop(context, _controller.text.trim()),
          ),
        ],
      ),
    );
  }
}
