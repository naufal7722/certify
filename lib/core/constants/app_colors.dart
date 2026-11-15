import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors from design document
  static const Color primary = Color(0xFF7663E8);
  static const Color primaryDark = Color(0xFF5B49D1);
  static const Color primaryLight = Color(0xFFEBE8FD);
  static const Color secondary = Color(0xFFA99BFF);
  
  // Neutral & background colors
  static const Color background = Color(0xFFF4F3FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF22213A);
  static const Color textSecondary = Color(0xFF7A7893);
  static const Color textMuted = Color(0xFFA5A3B8);
  
  // Borders & Dividers
  static const Color border = Color(0xFFE6E5F2);
  static const Color divider = Color(0xFFEEEEF6);
  
  // Status & Accents
  static const Color success = Color(0xFF38A169);
  static const Color successLight = Color(0xFFE6FFFA);
  static const Color warning = Color(0xFFED8936);
  static const Color warningLight = Color(0xFFFEEBC8);
  static const Color danger = Color(0xFFE53E3E);
  static const Color dangerLight = Color(0xFFFED7D7);
  static const Color info = Color(0xFF3182CE);
  static const Color infoLight = Color(0xFFEBF8FF);
  static const Color gold = Color(0xFFD69E2E);
  static const Color favorite = Color(0xFFE53E3E);

  // Category specific accent colors
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'workshop':
        return const Color(0xFF7663E8);
      case 'competition':
        return const Color(0xFF3182CE);
      case 'webinar':
        return const Color(0xFFED8936);
      case 'certification':
        return const Color(0xFF38A169);
      case 'academic':
        return const Color(0xFF805AD5);
      case 'organization':
        return const Color(0xFF319795);
      default:
        return const Color(0xFF718096);
    }
  }

  static Color getCategoryLightColor(String category) {
    switch (category.toLowerCase()) {
      case 'workshop':
        return const Color(0xFFF0EDFF);
      case 'competition':
        return const Color(0xFFEBF8FF);
      case 'webinar':
        return const Color(0xFFFEEBC8);
      case 'certification':
        return const Color(0xFFE6FFFA);
      case 'academic':
        return const Color(0xFFFAF5FF);
      case 'organization':
        return const Color(0xFFE6FFFA);
      default:
        return const Color(0xFFEDF2F7);
    }
  }
}
