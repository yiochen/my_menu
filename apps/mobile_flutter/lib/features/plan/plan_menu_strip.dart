import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/plan/plan_theme.dart';

class PlanMenuStrip extends StatelessWidget {
  const PlanMenuStrip({
    required this.horizontalPadding,
    super.key,
  });

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final List<Dish> dishes = state.dishes.take(4).toList(growable: false);
    final PlanThemeTokens tokens = context.planTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: <Widget>[
              Text(
                'From your menu',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: tokens.menuHeadingFontSize,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: null,
                child: Text(
                  'See all',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF174B2A),
                      ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.menuHeaderToListSpacing),
        SizedBox(
          height: tokens.menuCardHeight,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            scrollDirection: Axis.horizontal,
            itemCount: dishes.length,
            separatorBuilder: (_, __) => SizedBox(width: tokens.menuCardGap),
            itemBuilder: (BuildContext context, int index) {
              return _MenuDishCard(dish: dishes[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _MenuDishCard extends StatelessWidget {
  const _MenuDishCard({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;

    return SizedBox(
      width: tokens.menuCardWidth,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.menuCardRadius),
          side: const BorderSide(color: Color(0xFFE8DFD2)),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  DishDetailScreen(dishId: dish.id),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.network(
                dish.heroImageUrl,
                fit: BoxFit.cover,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0x00000000),
                      Color(0x33000000),
                      Color(0xB3000000),
                    ],
                    stops: <double>[0.35, 0.7, 1],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: tokens.menuTitlePadding,
                  child: Text(
                    dish.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: tokens.menuCardTitleFontSize,
                          height: 1.2,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
