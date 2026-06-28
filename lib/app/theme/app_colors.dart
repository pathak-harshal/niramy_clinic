import 'package:flutter/material.dart';

class AppColors {
  // Primary Teal (Consistent across themes for brand identity)
  static const Color primaryTeal = Color(0xFF007A87);
  static const Color primaryLight = Color(0xFF4DA3AF);
  static const Color primaryDark = Color(0xFF004E5A);

  // Secondary / Accent Accent
  static const Color accentOrange = Color(0xFFFF8A65);

  // Status Tones (Slightly altered vibrancies for readability on dark surfaces)
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color successGreenDark = Color(0xFF81C784);

  static const Color warningAmber = Color(0xFFEF6C00);
  static const Color warningAmberDark = Color(0xFFFFB74D);

  static const Color errorRed = Color(0xFFC62828);
  static const Color errorRedDark = Color(0xFFE57373);

  // --- Light Theme Specifics ---
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMutedLight = Color(0xFF64748B);

  // --- Dark Theme Specifics ---
  static const Color bgDark = Color(0xFF0F172A); // Deep Slate/Navy background
  static const Color surfaceDark = Color(
    0xFF1E293B,
  ); // Lighter Slate card color
  static const Color textLight = Color(0xFFF8FAFC); // High contrast white text
  static const Color textMutedDark = Color(0xFF94A3B8); // Subdued text
}
