import 'package:flutter/material.dart';

class AppColors {
  // Core brand — Unacademy-inspired
  static const Color primary       = Color(0xFF08BD80); // Unacademy green
  static const Color primaryDark   = Color(0xFF06A870);
  static const Color primarySoft   = Color(0xFFE8FBF4);

  static const Color accent        = Color(0xFF5A4FCF); // purple accent
  static const Color accentSoft    = Color(0xFFEEEDFB);

  static const Color live          = Color(0xFFE53935); // red LIVE badge
  static const Color liveSoft      = Color(0xFFFFEBEE);

  // Backgrounds
  static const Color background    = Color(0xFFF7F8FA);
  static const Color surface       = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A4A68);
  static const Color textMuted     = Color(0xFF9899A6);

  // Border
  static const Color border        = Color(0xFFECECF0);

  // Status
  static const Color success       = Color(0xFF08BD80);
  static const Color warning       = Color(0xFFFFC107);
  static const Color error         = Color(0xFFE53935);
  static const Color info          = Color(0xFF2979FF);

  static const Color surfaceEl = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF08BD80), Color(0xFF04A574)],
  );

  static const LinearGradient liveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE53935), Color(0xFFFF5252)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5A4FCF), Color(0xFF7B6EE8)],
  );
  static const LinearGradient cardGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF7F8FA),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -1),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.8),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5),
        headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.6),
        bodyMedium:    TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5),
        labelLarge:    TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.border,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    );
  }
}
