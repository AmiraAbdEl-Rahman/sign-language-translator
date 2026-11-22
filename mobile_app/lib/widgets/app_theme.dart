import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF1F3A5F);
  static const teal = Color(0xFF0E7C86);
  static const ok = Color(0xFF2E9E6B);
  static const bad = Color(0xFFD64545);
}

ThemeData buildTheme(bool dark) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: AppColors.teal,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? const Color(0xFF0E1621) : const Color(0xFFEEF2F6),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.navy, foregroundColor: Colors.white),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
