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
    return AppImage(
      imageRef: dish.heroImageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
    );
  }
}
