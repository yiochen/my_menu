import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

class DishArtwork extends StatelessWidget {
  const DishArtwork({
    required this.dish,
    this.fit = BoxFit.cover,
    this.improved = false,
    super.key,
  });

  final Dish dish;
  final BoxFit fit;
  final bool improved;

  @override
  Widget build(BuildContext context) {
    final String? asset = _assetFor(dish, improved: improved);
    if (asset != null) {
      return SvgPicture.asset(
        asset,
        width: double.infinity,
        height: double.infinity,
        fit: fit,
      );
    }
    return AppImage(
      imageRef: dish.heroImageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
    );
  }
}

String? dishArtworkAsset(Dish dish, {bool improved = false}) {
  return _assetFor(dish, improved: improved);
}

String? _assetFor(Dish dish, {required bool improved}) {
  final String key = '${dish.id} ${dish.title}'.toLowerCase();
  if (key.contains('salmon')) {
    return improved || dish.heroImageUrl.contains('miso-salmon-improved')
        ? 'assets/dish_art/miso-salmon-improved.svg'
        : 'assets/dish_art/miso-salmon.svg';
  }
  if (key.contains('linguine') || key.contains('noodle')) {
    return 'assets/dish_art/linguine.svg';
  }
  if (key.contains('katsu') || key.contains('curry')) {
    return 'assets/dish_art/katsu.svg';
  }
  if (key.contains('pho')) {
    return 'assets/dish_art/pho.svg';
  }
  return null;
}
