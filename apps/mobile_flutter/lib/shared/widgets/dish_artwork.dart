import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/cover_generation_effect.dart';
import 'package:mymenu/shared/widgets/food_cover_placeholder.dart';

String dishArtworkHeroTag(String dishId) => 'dish_artwork_$dishId';

Widget dishArtworkFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero fromHero = fromHeroContext.widget as Hero;
  final Hero toHero = toHeroContext.widget as Hero;
  final Widget artwork = flightDirection == HeroFlightDirection.push
      ? toHero.child
      : fromHero.child;

  return AnimatedBuilder(
    animation: animation,
    child: artwork,
    builder: (BuildContext context, Widget? child) {
      return ClipRRect(
        key: const ValueKey<String>('dish_artwork_hero_flight_clip'),
        borderRadius: BorderRadius.circular(
          20 + (8 * animation.value),
        ),
        child: SizedBox.expand(child: child),
      );
    },
  );
}

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
