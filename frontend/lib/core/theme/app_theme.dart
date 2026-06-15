import 'package:flutter/material.dart';

abstract class SedixColors {
  static const bg = Color(0xFFE8E2D9);
  static const surface = Color(0xFFF2EDE4);
  static const surfaceHigh = Color(0xFFFAF6F0);
  static const shadowDark = Color(0xFFC8C2B8);
  static const accent = Color(0xFFFF8A3D);
  static const accentLight = Color(0xFFFFF0E4);
  static const success = Color(0xFF4CAF82);
  static const successLight = Color(0xFFE4F5EE);
  static const textPrimary = Color(0xFF18151F);
  static const textSecondary = Color(0xFF9B96A8);
  static const navy = Color(0xFF1A1825);
}

BoxDecoration clayBox({
  Color color = SedixColors.surface,
  double radius = 28,
}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.88),
          offset: const Offset(-8, -8),
          blurRadius: 20,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: SedixColors.shadowDark.withOpacity(0.65),
          offset: const Offset(8, 8),
          blurRadius: 20,
          spreadRadius: 1,
        ),
      ],
    );

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: SedixColors.bg,
        fontFamily: 'Iosevka Charon',
        colorScheme: const ColorScheme.light(
          surface: SedixColors.bg,
          primary: SedixColors.accent,
          secondary: SedixColors.success,
          onSurface: SedixColors.textPrimary,
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: SedixColors.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: SedixColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            fontFamily: 'Iosevka Charon',
          ),
          iconTheme: IconThemeData(color: SedixColors.textPrimary),
        ),
      );

  static ThemeData get dark => light;
}
