import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'clinic_colors.dart';

class AppTheme {
  AppTheme._();

  // Shared button properties across themes
  static final _buttonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  // ==================== LIGHT THEME ====================
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryTeal,
      secondary: AppColors.accentOrange,
      onSurface: AppColors.textDark,
      error: AppColors.errorRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceWhite,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textDark),
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceWhite,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _buttonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(AppColors.primaryTeal),
        foregroundColor: WidgetStateProperty.all(AppColors.surfaceWhite),
      ),
    ),
    inputDecorationTheme: _inputTheme(
      borderColor: AppColors.textMutedLight,
      fillColor: AppColors.surfaceWhite,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      ClinicColors(
        confirmedStatus: AppColors.successGreen,
        pendingStatus: AppColors.warningAmber,
        cancelledStatus: AppColors.errorRed,
      ),
    ],
  );

  // ==================== DARK THEME ====================
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors
          .primaryLight, // Slightly brighter teal for better visibility
      onPrimary: AppColors.bgDark,
      secondary: AppColors.accentOrange,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textLight,
      error: AppColors.errorRedDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textLight),
      titleTextStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _buttonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(AppColors.primaryLight),
        foregroundColor: WidgetStateProperty.all(AppColors.bgDark),
      ),
    ),
    inputDecorationTheme: _inputTheme(
      borderColor: AppColors.textMutedDark,
      fillColor: AppColors.surfaceDark,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      ClinicColors(
        confirmedStatus: AppColors.successGreenDark,
        pendingStatus: AppColors.warningAmberDark,
        cancelledStatus: AppColors.errorRedDark,
      ),
    ],
  );

  // Helper method for generating form inputs styling
  static InputDecorationTheme _inputTheme({
    required Color borderColor,
    required Color fillColor,
  }) => InputDecorationTheme(
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor.withValues(alpha: 0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
    ),
  );
}
