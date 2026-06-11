import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/widgets/dish_card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({
    required this.query,
    required this.onQueryChanged,
    super.key,
  });

  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final List<Dish> favorites = state.dishes
        .where((Dish dish) => dish.isFavorite)
        .toList(growable: false);
    final List<Dish> visibleDishes = state.filterDishes(query);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: <Widget>[
        Text('My Menu', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        TextField(
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search dishes, notes, and categories',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (favorites.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          Text('Favorites', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 240,
                  child: DishCard(dish: favorites[index]),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text('All Dishes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final Dish dish in visibleDishes) ...<Widget>[
          DishCard(dish: dish),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
