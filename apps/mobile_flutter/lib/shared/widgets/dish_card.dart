import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';

class DishCard extends StatelessWidget {
  const DishCard({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                DishDetailScreen(dishId: dish.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(dish.heroImageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton.filledTonal(
                    onPressed: () => state.toggleFavorite(dish.id),
                    icon: Icon(
                      dish.isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    dish.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dish.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${dish.prepMinutes} min · ${dish.category} · Made ${dish.madeCount} times',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
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
