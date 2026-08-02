import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';

class MenuMemoryCue extends StatelessWidget {
  const MenuMemoryCue({required this.dish, super.key});

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
