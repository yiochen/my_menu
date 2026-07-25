import 'package:flutter/material.dart';

abstract final class MyMenuColors {
  static const Color cream = Color(0xFFFDFBF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color oat = Color(0xFFF3EFE9);
  static const Color oat2 = Color(0xFFEEE8DF);
  static const Color ink = Color(0xFF22201E);
  static const Color muted = Color(0xFF77736F);
  static const Color softInk = Color(0xFF9B9690);
  static const Color line = Color(0x14362D25);
  static const Color orange = Color(0xFFFF710A);
  static const Color orangeAction = Color(0xFFC94B00);
  static const Color orangeDark = Color(0xFFB84200);
  static const Color orangeSoft = Color(0xFFFFF0E3);
  static const Color green = Color(0xFF4F785E);
  static const Color greenSoft = Color(0xFFE9F1E8);
  static const Color red = Color(0xFFC75045);
  static const Color redSoft = Color(0xFFFAE9E6);
  static const Color note = Color(0xFFFFF7DC);
}

abstract final class MyMenuUnits {
  // Mock CSS pixels map 1:1 to Flutter logical pixels at 390 logical pixels.
  static const double referenceWidth = 390;
  static const double pageGutter = 18;
  static const double compactPageGutter = 14;
  static const double pageTop = 24;
  static const double pageBottom = 116;
  static const double cardRadius = 22;
  static const double controlRadius = 18;
  static const double bottomBarHeight = 76;
  static const double bottomBarBottom = 12;
  static const double bottomBarInset = 16;
  static const double captureButtonSize = 62;

  static double pageHorizontal(BuildContext context) {
    return MediaQuery.sizeOf(context).width <= 380
        ? compactPageGutter
        : pageGutter;
  }
}

const List<BoxShadow> myMenuCardShadow = <BoxShadow>[
  BoxShadow(
    color: Color(0x0F302318),
    blurRadius: 32,
    offset: Offset(0, 12),
  ),
];

const List<BoxShadow> myMenuFloatingShadow = <BoxShadow>[
  BoxShadow(
    color: Color(0x24302318),
    blurRadius: 42,
    offset: Offset(0, 18),
  ),
];
