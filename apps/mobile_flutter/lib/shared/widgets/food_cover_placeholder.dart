import 'package:flutter/material.dart';

class FoodCoverPlaceholder extends StatelessWidget {
  const FoodCoverPlaceholder({
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  static const String assetPath = 'assets/placeholders/food-cover.png';

  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      excludeFromSemantics: true,
    );
  }
}
