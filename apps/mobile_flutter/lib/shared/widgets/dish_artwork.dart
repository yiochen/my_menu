import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/food_cover_placeholder.dart';

class DishArtwork extends StatelessWidget {
  const DishArtwork({
    required this.dish,
    this.fit = BoxFit.cover,
    this.resizeForDisplay = false,
    super.key,
  });

  final Dish dish;
  final BoxFit fit;
  final bool resizeForDisplay;

  @override
  Widget build(BuildContext context) {
    final String imageRef =
        resizeForDisplay ? dish.cardImageUrl : dish.heroImageUrl;
    if (imageRef.trim().isEmpty) {
      return const DishArtworkPlaceholder();
    }
    return AppImage(
      imageRef: imageRef,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
      resizeForDisplay: resizeForDisplay,
      placeholderImageRef: resizeForDisplay ? dish.cardPlaceholderUrl : null,
    );
  }
}

class DishArtworkPlaceholder extends StatelessWidget {
  const DishArtworkPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const FoodCoverPlaceholder(
      key: ValueKey<String>('dish_artwork_placeholder'),
    );
  }
}
