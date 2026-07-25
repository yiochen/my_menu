import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/improve_cover/improve_cover_dialog.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class DishDetailHero extends StatelessWidget {
  const DishDetailHero({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).width <= 380 ? 300 : 330;
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DishArtwork(dish: dish),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Colors.transparent, Color(0x991A130D)],
                  stops: <double>[0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: _HeroActions(dish: dish),
            ),
            Positioned(
              right: 12,
              top: 70,
              child: WarmPill(
                key: const ValueKey<String>('improve_cover_button'),
                label: 'Improve cover',
                icon: Icons.auto_awesome,
                compact: true,
                onPressed: () => showImproveCoverDialog(
                  context,
                  MyMenuScope.read(context),
                  dish.id,
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: _HeroCaption(dish: dish),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          size: 40,
          radius: 14,
          semanticLabel: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        CircleIconButton(
          icon: dish.isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 40,
          radius: 14,
          semanticLabel: 'Favorite',
          onPressed: () => MyMenuScope.read(context).toggleFavorite(dish.id),
        ),
        const SizedBox(width: 8),
        CircleIconButton(
          icon: Icons.more_horiz_rounded,
          size: 40,
          radius: 14,
          semanticLabel: 'More actions',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _HeroCaption extends StatelessWidget {
  const _HeroCaption({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xD9FFFFFF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Cover image',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          dish.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontSize: 31,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          dish.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }
}
