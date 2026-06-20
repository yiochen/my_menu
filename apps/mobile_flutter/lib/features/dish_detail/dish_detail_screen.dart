import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/improve_cover/improve_cover_dialog.dart';
import 'package:mymenu/features/plan/plan_dish_dialog.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/info_section.dart';

class DishDetailScreen extends StatelessWidget {
  const DishDetailScreen({required this.dishId, super.key});

  final String dishId;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish dish = state.dishById(dishId);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _DishHero(dish: dish),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _DishSummary(dish: dish),
                  const SizedBox(height: 20),
                  _DishActions(dishId: dish.id),
                  const SizedBox(height: 28),
                  InfoSection(
                    title: 'Ingredients',
                    child: Column(
                      children: dish.ingredients.map((String item) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(item),
                        );
                      }).toList(growable: false),
                    ),
                  ),
                  InfoSection(
                    title: 'Recipe',
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
                  ),
                  InfoSection(
                    title: 'Notes',
                    child: Column(
                      children: dish.notes.map((String note) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.sticky_note_2_outlined),
                          title: Text(note),
                        );
                      }).toList(growable: false),
                    ),
                  ),
                  InfoSection(
                    title: 'Sources',
                    child: _SourcePhotoStrip(photos: dish.sourcePhotos),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
      expandedHeight: 300,
      actions: <Widget>[
        IconButton(
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
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
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

    return Row(
      children: <Widget>[
        FilledButton.icon(
          onPressed: () => showImproveCoverDialog(context, state, dishId),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Improve Cover'),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () => showPlanDishDialog(
            context,
            state,
            initialDayKey: dayKeyForDate(state.remainingPlanDates().first),
            initialDishId: dishId,
          ),
          icon: const Icon(Icons.calendar_month),
          label: const Text('Plan Dish'),
        ),
      ],
    );
  }
}

class _SourcePhotoStrip extends StatelessWidget {
  const _SourcePhotoStrip({required this.photos});

  final List<SourcePhoto> photos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          return _SourcePhotoCard(photo: photos[index]);
        },
      ),
    );
  }
}

class _SourcePhotoCard extends StatelessWidget {
  const _SourcePhotoCard({required this.photo});

  final SourcePhoto photo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AppImage(imageRef: photo.url, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    photo.capturedLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (photo.note != null)
                    Text(
                      photo.note!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
