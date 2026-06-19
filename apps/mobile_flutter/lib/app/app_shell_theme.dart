import 'package:flutter/material.dart';

class AppShellThemeTokens extends ThemeExtension<AppShellThemeTokens> {
  const AppShellThemeTokens({
    this.screenHorizontalPadding = 18,
    this.fabSize = 58,
    this.fabHeight = 56,
    this.fabRightOffset = 22,
    this.fabBottomOffset = 28,
    this.fabIconSize = 28,
    this.bottomChromeBottomOffset = 20,
    this.bottomChromeHeight = 120,
    this.bottomBarWidth = 378,
    this.bottomBarHeight = 64,
    this.bottomBarRadius = 32,
    this.bottomNavItemPadding = 4,
    this.bottomNavItemRadius = 28,
    this.bottomNavSelectedHeight = 52,
    this.bottomNavIconSize = 22,
    this.bottomNavLabelSpacing = 4,
    this.bottomNavLabelFontSize = 8,
  });

  final double screenHorizontalPadding;
  final double fabSize;
  final double fabHeight;
  final double fabRightOffset;
  final double fabBottomOffset;
  final double fabIconSize;
  final double bottomChromeBottomOffset;
  final double bottomChromeHeight;
  final double bottomBarWidth;
  final double bottomBarHeight;
  final double bottomBarRadius;
  final double bottomNavItemPadding;
  final double bottomNavItemRadius;
  final double bottomNavSelectedHeight;
  final double bottomNavIconSize;
  final double bottomNavLabelSpacing;
  final double bottomNavLabelFontSize;

  @override
  AppShellThemeTokens copyWith() => this;

  @override
  AppShellThemeTokens lerp(
    covariant ThemeExtension<AppShellThemeTokens>? other,
    double t,
  ) {
    if (other is! AppShellThemeTokens) {
      return this;
    }

    return t < 0.5 ? this : other;
  }
}

extension AppShellThemeBuildContext on BuildContext {
  AppShellThemeTokens get appShellTheme =>
      Theme.of(this).extension<AppShellThemeTokens>()!;
}
