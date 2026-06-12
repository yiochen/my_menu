import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get data {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF208AEF)),
      scaffoldBackgroundColor: const Color(0xFFF7F5F1),
      useMaterial3: true,
    );
  }
}
