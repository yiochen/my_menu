import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/improve_cover/improve_cover_dialog.dart';
import 'package:mymenu/features/plan/plan_dish_dialog.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

part 'dish_detail_editors.dart';
part 'dish_detail_sections.dart';
part 'dish_detail_sources.dart';

class DishDetailScreen extends StatelessWidget {
  const DishDetailScreen({required this.dishId, super.key});

  final String dishId;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish dish = state.dishById(dishId);
    final GlobalKey notesKey = GlobalKey();
    final GlobalKey recipeKey = GlobalKey();
    final GlobalKey ingredientsKey = GlobalKey();
    final GlobalKey sourcesKey = GlobalKey();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: state.refreshFromServer,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            _DishHero(dish: dish),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _DishSummary(dish: dish),
                    const SizedBox(height: 16),
                    _DishActions(dishId: dish.id),
                    const SizedBox(height: 20),
                    _JumpLinks(
                      onNotes: () => _scrollTo(notesKey),
                      onRecipe: () => _scrollTo(recipeKey),
                      onIngredients: () => _scrollTo(ingredientsKey),
                      onSources: () => _scrollTo(sourcesKey),
                    ),
                    const SizedBox(height: 28),
                    _NotesSection(key: notesKey, dish: dish),
                    const SizedBox(height: 26),
                    _RecipeSection(key: recipeKey, dish: dish),
                    const SizedBox(height: 26),
                    _IngredientsSection(key: ingredientsKey, dish: dish),
                    const SizedBox(height: 26),
                    _SourcesSection(key: sourcesKey, photos: dish.sourcePhotos),
                    const SizedBox(height: 30),
                    _CookAgainAction(dishId: dish.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollTo(GlobalKey key) {
    final BuildContext? context = key.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }
}

class _DishHero extends StatelessWidget {
  const _DishHero({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 340,
      actions: <Widget>[
        IconButton(
          tooltip: 'Favorite',
          onPressed: () => state.toggleFavorite(dish.id),
          icon: Icon(dish.isFavorite ? Icons.favorite : Icons.favorite_border),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AppImage(imageRef: dish.heroImageUrl, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.68),
                    Colors.black.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: FilledButton.icon(
                onPressed: () => showImproveCoverDialog(context, state, dish.id),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Improve Cover'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DishSummary extends StatelessWidget {
  const _DishSummary({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(dish.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(dish.description),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            Chip(label: Text('${dish.prepMinutes} min')),
            Chip(label: Text(dish.category)),
            Chip(label: Text(dish.difficulty)),
            Chip(label: Text('Made ${dish.madeCount}')),
            Chip(label: Text('Last made ${dish.lastMadeLabel}')),
          ],
        ),
      ],
    );
  }
}

class _DishActions extends StatelessWidget {
  const _DishActions({required this.dishId});

  final String dishId;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return OutlinedButton.icon(
      onPressed: () => showPlanDishDialog(
        context,
        state,
        initialDayKey: dayKeyForDate(state.remainingPlanDates().first),
        initialDishId: dishId,
      ),
      icon: const Icon(Icons.calendar_month),
      label: const Text('Plan Dish'),
    );
  }
}
