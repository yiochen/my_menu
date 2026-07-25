import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/cook_again_sheet.dart';
import 'package:mymenu/features/dish_detail/dish_detail_content.dart';
import 'package:mymenu/features/dish_detail/dish_detail_hero.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

enum DishDetailTab { recipe, notes, history }

class DishDetailScreen extends StatefulWidget {
  const DishDetailScreen({required this.dishId, super.key});

  final String dishId;

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  DishDetailTab _tab = DishDetailTab.recipe;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish dish = state.dishById(widget.dishId);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: WarmPage(
          includeBottomChromeSpace: false,
          topPadding: 14,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DishDetailHero(dish: dish),
              const SizedBox(height: 16),
              PrimaryPillButton(
                key: const ValueKey<String>('cook_again_button'),
                label: 'Cook again',
                icon: Icons.play_arrow_rounded,
                onPressed: () => showCookAgainSheet(context, state, dish),
              ),
              const SizedBox(height: 12),
              _Metrics(dish: dish),
              const SizedBox(height: 12),
              _LatestNote(dish: dish),
              const SizedBox(height: 14),
              _DetailTabs(
                selected: _tab,
                notesCount: dish.notes.length,
                historyCount: dish.madeCount,
                onSelect: (DishDetailTab tab) => setState(() => _tab = tab),
              ),
              const SizedBox(height: 16),
              DishDetailContent(
                dish: dish,
                state: state,
                tab: _tab,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child:
                _Metric(value: '${dish.madeCount} cooks', label: 'occasions')),
        const SizedBox(width: 8),
        Expanded(
          child: _Metric(
            value: '${dish.sourcePhotos.length} photos',
            label: 'sources',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _Metric(value: dish.lastMadeLabel, label: 'last made')),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      decoration: BoxDecoration(
        color: MyMenuColors.oat,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 3),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _LatestNote extends StatelessWidget {
  const _LatestNote({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    if (dish.notes.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: MyMenuColors.note,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.edit_outlined, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Eyebrow('Latest note · Jul 18'),
                const SizedBox(height: 3),
                Text(
                  dish.notes.first.body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MyMenuColors.ink,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({
    required this.selected,
    required this.notesCount,
    required this.historyCount,
    required this.onSelect,
  });

  final DishDetailTab selected;
  final int notesCount;
  final int historyCount;
  final ValueChanged<DishDetailTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: MyMenuColors.oat,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: <Widget>[
          _TabButton(
            label: 'Recipe',
            selected: selected == DishDetailTab.recipe,
            onTap: () => onSelect(DishDetailTab.recipe),
          ),
          _TabButton(
            label: 'Notes · $notesCount',
            selected: selected == DishDetailTab.notes,
            onTap: () => onSelect(DishDetailTab.notes),
          ),
          _TabButton(
            label: 'History · $historyCount',
            selected: selected == DishDetailTab.history,
            onTap: () => onSelect(DishDetailTab.history),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 36,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
