import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';

class MenuGridCard extends StatelessWidget {
  const MenuGridCard({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    final double titleLineHeight =
        MediaQuery.textScalerOf(context).scale(titleStyle.fontSize!) *
            titleStyle.height!;
    final double titleSlotHeight = (titleLineHeight * 2).ceilToDouble();

    return Material(
      key: ValueKey<String>('menu_dish_${dish.id}'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DishDetailScreen(dishId: dish.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  DishArtwork(dish: dish),
                  if (dish.isFavorite)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: GestureDetector(
                        onTap: () =>
                            MyMenuScope.read(context).toggleFavorite(dish.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xEFFFFFFF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.favorite, size: 10),
                              SizedBox(width: 3),
                              Text(
                                'Favorite',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: titleSlotHeight,
                    child: Text(
                      key: ValueKey<String>('menu_dish_title_${dish.id}'),
                      dish.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                  ),
                  Text(
                    '${dish.madeCount} ${dish.madeCount == 1 ? 'cook' : 'cooks'}'
                    ' · ${dish.sourcePhotos.length} photos',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 7),
                  _MemoryCue(dish: dish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCue extends StatelessWidget {
  const _MemoryCue({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          _usesNoteCue(dish) ? Icons.edit_outlined : Icons.history_rounded,
          size: 11,
          color: const Color(0xFF796E64),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _memoryCue(dish),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF796E64),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

String _memoryCue(Dish dish) {
  if (dish.id == 'dish_salmon') {
    return '“Broil for 2 minutes…”';
  }
  if (dish.id == 'dish_katsu') {
    return 'Crispier crumbs next time';
  }
  if (dish.id == 'dish_pho') {
    return 'Evolving since 2024';
  }
  return 'Last made ${dish.lastMadeLabel}';
}

bool _usesNoteCue(Dish dish) =>
    dish.id == 'dish_salmon' || dish.id == 'dish_katsu';
