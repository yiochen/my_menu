import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/dish_detail/dish_history_content.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class DishDetailContent extends StatelessWidget {
  const DishDetailContent({
    required this.dish,
    required this.state,
    required this.tab,
    required this.onChanged,
    super.key,
  });

  final Dish dish;
  final MyMenuState state;
  final DishDetailTab tab;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      DishDetailTab.recipe => _RecipeContent(dish: dish),
      DishDetailTab.notes => _NotesContent(
          dish: dish,
          state: state,
          onChanged: onChanged,
        ),
      DishDetailTab.history => DishHistoryContent(dish: dish),
    };
  }
}

class _RecipeContent extends StatelessWidget {
  const _RecipeContent({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeading(title: 'Ingredients', action: 'Edit'),
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
        const _SectionHeading(title: 'Steps', action: 'Edit'),
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
  const _SectionHeading({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        TextButton(
          onPressed: () {},
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
            child: Text(
                parts.first.toLowerCase().contains('salmon') ? '🐟' : '🥣'),
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

class _NotesContent extends StatelessWidget {
  const _NotesContent({
    required this.dish,
    required this.state,
    required this.onChanged,
  });

  final Dish dish;
  final MyMenuState state;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionHeadingWithButton(
          title: 'Notes',
          label: 'Add Note',
          onPressed: () async {
            final String? note = await showAddNoteSheet(context);
            if (note != null && context.mounted) {
              state.addDishNote(dish.id, note);
              onChanged();
            }
          },
        ),
        const SizedBox(height: 10),
        for (int index = 0; index < dish.notes.length; index += 1) ...<Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: MyMenuColors.note,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x148F6B10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  index == 0 ? 'JUL 18' : 'MAY 9',
                  style: const TextStyle(
                    color: Color(0xFF8B7547),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  dish.notes[index].body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MyMenuColors.ink,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SectionHeadingWithButton extends StatelessWidget {
  const _SectionHeadingWithButton({
    required this.title,
    required this.label,
    required this.onPressed,
  });

  final String title;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        TextButton(onPressed: onPressed, child: Text(label)),
      ],
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
