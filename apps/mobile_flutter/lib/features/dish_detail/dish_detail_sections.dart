part of 'dish_detail_screen.dart';

class _JumpLinks extends StatelessWidget {
  const _JumpLinks({
    required this.onNotes,
    required this.onRecipe,
    required this.onIngredients,
    required this.onSources,
  });

  final VoidCallback onNotes;
  final VoidCallback onRecipe;
  final VoidCallback onIngredients;
  final VoidCallback onSources;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _JumpChip(label: 'Notes', icon: Icons.sticky_note_2, onTap: onNotes),
          _JumpChip(label: 'Recipe', icon: Icons.list_alt, onTap: onRecipe),
          _JumpChip(
            label: 'Ingredients',
            icon: Icons.shopping_basket,
            onTap: onIngredients,
          ),
          _JumpChip(
            label: 'Sources',
            icon: Icons.photo_library,
            onTap: onSources,
          ),
        ],
      ),
    );
  }
}

class _JumpChip extends StatelessWidget {
  const _JumpChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return _SectionChrome(
      title: 'Notes',
      trailing: FilledButton.icon(
        onPressed: () => _showNoteEditor(context, dishId: dish.id),
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: dish.notes.map((DishNote note) {
          return _NoteCard(
            note: note,
            onEdit: () => _showNoteEditor(
              context,
              dishId: dish.id,
              note: note,
            ),
            onDelete: () => state.deleteDishNote(note.id),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final DishNote note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3B8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5C75C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(note.body),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                tooltip: 'Edit note',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_note),
              ),
              IconButton(
                tooltip: 'Delete note',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeSection extends StatelessWidget {
  const _RecipeSection({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return _SectionChrome(
      title: 'Recipe',
      trailing: IconButton(
        tooltip: 'Edit recipe',
        onPressed: () => _showListEditor(
          context,
          title: 'Recipe',
          initialItems: dish.recipeSteps,
          onSave: (MyMenuState state, List<String> items) {
            state.updateDishSections(dish.id, recipeSteps: items);
          },
        ),
        icon: const Icon(Icons.edit),
      ),
      child: Column(
        children: dish.recipeSteps.asMap().entries.map((
          MapEntry<int, String> entry,
        ) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 14,
              child: Text('${entry.key + 1}'),
            ),
            title: Text(entry.value),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return _SectionChrome(
      title: 'Ingredients',
      trailing: IconButton(
        tooltip: 'Edit ingredients',
        onPressed: () => _showListEditor(
          context,
          title: 'Ingredients',
          initialItems: dish.ingredients,
          onSave: (MyMenuState state, List<String> items) {
            state.updateDishSections(dish.id, ingredients: items);
          },
        ),
        icon: const Icon(Icons.edit),
      ),
      child: Column(
        children: dish.ingredients.map((String item) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(item),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.photos, super.key});

  final List<SourcePhoto> photos;

  @override
  Widget build(BuildContext context) {
    return _SectionChrome(
      title: 'Sources',
      child: _SourcePhotoStrip(photos: photos),
    );
  }
}

class _CookAgainAction extends StatelessWidget {
  const _CookAgainAction({required this.dishId});

  final String dishId;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => showPlanDishDialog(
          context,
          state,
          initialDayKey: dayKeyForDate(state.remainingPlanDates().first),
          initialDishId: dishId,
        ),
        icon: const Icon(Icons.restaurant_menu),
        label: const Text('Cook Again'),
      ),
    );
  }
}

class _SectionChrome extends StatelessWidget {
  const _SectionChrome({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
