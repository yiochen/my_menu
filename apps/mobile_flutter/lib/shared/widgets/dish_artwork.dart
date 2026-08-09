import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/cover_generation_effect.dart';
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
    final Widget artwork = imageRef.trim().isEmpty
        ? const DishArtworkPlaceholder()
        : AppImage(
            imageRef: imageRef,
            width: double.infinity,
            height: double.infinity,
            fit: fit,
            resizeForDisplay: resizeForDisplay,
            placeholderImageRef:
                resizeForDisplay ? dish.cardPlaceholderUrl : null,
          );
    final bool isGenerating =
        MyMenuScope.maybeOf(context)?.isCoverGenerationActiveForDish(dish.id) ??
            false;
    return isGenerating ? CoverGenerationEffect(child: artwork) : artwork;
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
