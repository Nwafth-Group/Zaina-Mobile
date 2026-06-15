import 'package:flutter/material.dart';

const String _urbanist = 'Urbanist';

class ZienaColors {
  // Primary
  static const Color primary = Color(0xFFF45B8C);
  static const Color primaryDark = Color(0xFFD94A78);
  static const Color primaryLight = Color(0xFFFF8FA3);

  // Backgrounds
  static const Color bg1 = Color(0xFFFFF6F8);
  static const Color bg2 = Color(0xFFFFECEF);
  static const Color bg3 = Color(0xFFFFDAE0);
  static const Color bg4 = Color(0xFFFFBEC8);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A2E);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyBorder = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF1A0A0E);
  static const Color textSecondary = Color(0xFF434343);
  static const Color textHint = Color(0xFFBDBDBD);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [primary, primaryLight],
  );
}

class ZienaTheme {
  static TextTheme get _textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontFamily: _urbanist,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: ZienaColors.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: _urbanist,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: ZienaColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: _urbanist,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: ZienaColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: _urbanist,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: ZienaColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: _urbanist,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ZienaColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: _urbanist,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ZienaColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _urbanist,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ZienaColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: _urbanist,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ZienaColors.textPrimary,
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: _urbanist,
    textTheme: _textTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ZienaColors.primary,
      primary: ZienaColors.primary,
      secondary: ZienaColors.primaryLight,
      surface: ZienaColors.bg1,
      error: ZienaColors.error,
    ),
    scaffoldBackgroundColor: ZienaColors.bg1,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ZienaColors.textPrimary),
      titleTextStyle: TextStyle(
        fontFamily: _urbanist,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ZienaColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ZienaColors.primary,
        foregroundColor: ZienaColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: _urbanist,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ZienaColors.textPrimary,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: ZienaColors.greyBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontFamily: _urbanist,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ZienaColors.bg1,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ZienaColors.greyBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ZienaColors.greyBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ZienaColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ZienaColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        fontFamily: _urbanist,
        color: ZienaColors.textHint,
        fontSize: 14,
      ),
    ),
  );
}
