import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

class DishArtwork extends StatelessWidget {
  const DishArtwork({
    required this.dish,
    this.fit = BoxFit.cover,
    super.key,
  });

  final Dish dish;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (dish.heroImageUrl.trim().isEmpty) {
      return const DishArtworkPlaceholder();
    }
    return AppImage(
      imageRef: dish.heroImageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
    );
  }
}

class DishArtworkPlaceholder extends StatelessWidget {
  const DishArtworkPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      key: ValueKey<String>('dish_artwork_placeholder'),
      color: Color(0xFFD9C5AB),
      child: Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 44,
          color: Color(0xFF6F5540),
        ),
      ),
    );
  }
}
