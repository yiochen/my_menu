import 'package:flutter/material.dart';

import 'package:mymenu/shared/theme/my_menu_theme.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get data {
    const TextTheme base = Typography.blackCupertino;
    final TextTheme textTheme = base.copyWith(
      displaySmall: const TextStyle(
        fontSize: 29,
        height: 1.08,
        letterSpacing: -1.02,
        fontWeight: FontWeight.w800,
        color: MyMenuColors.ink,
      ),
      headlineSmall: const TextStyle(
        fontSize: 19,
        height: 1.2,
        letterSpacing: -0.38,
        fontWeight: FontWeight.w800,
        color: MyMenuColors.ink,
      ),
      titleMedium: const TextStyle(
        fontSize: 15,
        height: 1.25,
        fontWeight: FontWeight.w800,
        color: MyMenuColors.ink,
      ),
      bodyLarge: const TextStyle(
        fontSize: 14,
        height: 1.45,
        color: MyMenuColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontSize: 13,
        height: 1.4,
        color: MyMenuColors.muted,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        height: 1.35,
        color: MyMenuColors.muted,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: MyMenuColors.ink,
      ),
      labelMedium: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: MyMenuColors.orangeDark,
      ),
      labelSmall: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: MyMenuColors.muted,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MyMenuColors.orange,
        primary: MyMenuColors.orangeAction,
        surface: MyMenuColors.surface,
      ),
      scaffoldBackgroundColor: MyMenuColors.cream,
      fontFamily: '.SF Pro Rounded',
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      dividerColor: MyMenuColors.line,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MyMenuColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        hintStyle: textTheme.bodyLarge?.copyWith(color: MyMenuColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: MyMenuColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: MyMenuColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: MyMenuColors.orange, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MyMenuColors.cream,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: MyMenuColors.cream,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
    );
  }
}
