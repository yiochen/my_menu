import 'package:flutter/material.dart';

import 'package:mymenu/app/app_shell_theme.dart';
import 'package:mymenu/features/plan/plan_theme.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get data {
    const Color primaryGreen = Color(0xFF174B2A);
    const TextTheme baseTextTheme = Typography.blackMountainView;

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF208AEF)),
      scaffoldBackgroundColor: const Color(0xFFF7F5F1),
      textTheme: baseTextTheme.copyWith(
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: primaryGreen,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 12,
          height: 1.3,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 10,
          height: 1.2,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppShellThemeTokens(),
        PlanThemeTokens(),
      ],
      useMaterial3: true,
    );
  }
}
