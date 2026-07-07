part of 'dish_detail_screen.dart';

class _JumpLinks extends StatelessWidget {
  const _JumpLinks({
    required this.activeSection,
    required this.onNotes,
    required this.onRecipe,
    required this.onIngredients,
    required this.onSources,
  });

  final _DishDetailSection activeSection;
  final VoidCallback onNotes;
  final VoidCallback onRecipe;
  final VoidCallback onIngredients;
  final VoidCallback onSources;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9DECE)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _JumpChip(
              label: 'Notes',
              icon: Icons.sticky_note_2_outlined,
              selected: activeSection == _DishDetailSection.notes,
              onTap: onNotes,
            ),
          ),
          Expanded(
            child: _JumpChip(
              label: 'Recipe',
              icon: Icons.list_alt,
              selected: activeSection == _DishDetailSection.recipe,
              onTap: onRecipe,
            ),
          ),
          Expanded(
            child: _JumpChip(
              label: 'Ingredients',
              icon: Icons.eco_outlined,
              selected: activeSection == _DishDetailSection.ingredients,
              onTap: onIngredients,
            ),
          ),
          Expanded(
            child: _JumpChip(
              label: 'Sources',
              icon: Icons.photo_outlined,
              selected: activeSection == _DishDetailSection.sources,
              onTap: onSources,
            ),
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
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? Colors.white : _detailMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Jump to $label',
      child: Material(
        color: selected ? _detailInk : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 19, color: foreground),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
      trailing: TextButton(
        onPressed: () => _showListEditor(
          context,
          title: 'Recipe',
          initialItems: dish.recipeSteps,
          onSave: (MyMenuState state, List<String> items) {
            state.updateDishSections(dish.id, recipeSteps: items);
          },
        ),
        style: TextButton.styleFrom(
          foregroundColor: _detailGold,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
        child: const Text('Edit'),
      ),
      child: Column(
        children: dish.recipeSteps.asMap().entries.map((
          MapEntry<int, String> entry,
        ) {
          return _RecipeStep(number: entry.key + 1, text: entry.value);
        }).toList(growable: false),
      ),
    );
  }
}

class _RecipeStep extends StatelessWidget {
  const _RecipeStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFECE2D4))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFF0EADF),
            child: Text(
              '$number',
              style: const TextStyle(
                color: _detailMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF293630),
                    fontSize: 14,
                    height: 1.35,
                  ),
            ),
          ),
        ],
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
      trailing: TextButton(
        onPressed: () => _showListEditor(
          context,
          title: 'Ingredients',
          initialItems: dish.ingredients,
          onSave: (MyMenuState state, List<String> items) {
            state.updateDishSections(dish.id, ingredients: items);
          },
        ),
        style: TextButton.styleFrom(
          foregroundColor: _detailGold,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
        child: const Text('Edit'),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool twoColumns = constraints.maxWidth >= 360;
          final double itemWidth = twoColumns
              ? (constraints.maxWidth - 18) / 2
              : constraints.maxWidth;

          return Wrap(
            spacing: 18,
            runSpacing: 10,
            children: dish.ingredients.map((String item) {
              return SizedBox(width: itemWidth, child: _IngredientItem(item));
            }).toList(growable: false),
          );
        },
      ),
    );
  }
}

class _IngredientItem extends StatelessWidget {
  const _IngredientItem(this.item);

  final String item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(Icons.circle, size: 5, color: _detailGold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF293630),
                  fontSize: 14,
                  height: 1.32,
                ),
          ),
        ),
      ],
    );
  }
}

class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.photos, super.key});

  final List<SourcePhoto> photos;

  @override
  Widget build(BuildContext context) {
    return _SectionChrome(
      title: 'Source Photos',
      trailing: TextButton(
        onPressed:
            photos.isEmpty ? null : () => _showSourceGallery(context, photos),
        style: TextButton.styleFrom(
          foregroundColor: _detailGold,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
        child: Text('See all (${photos.length})'),
      ),
      child: _SourcePhotoStrip(photos: photos),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: FilledButton.icon(
            onPressed: () => showPlanDishDialog(
              context,
              state,
              initialDayKey: dayKeyForDate(state.remainingPlanDates().first),
              initialDishId: dish.id,
            ),
            icon: const Icon(Icons.calendar_month),
            label: const Text('Cook Again'),
            style: FilledButton.styleFrom(
              backgroundColor: _detailInk,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        IconButton.filledTonal(
          tooltip: 'Favorite',
          onPressed: () => state.toggleFavorite(dish.id),
          icon: Icon(dish.isFavorite ? Icons.bookmark : Icons.bookmark_border),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF4EFE7),
            foregroundColor: _detailInk,
            fixedSize: const Size.square(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _detailInk,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
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
