import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF0D47A1);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFFF6F00);
  static const danger = Color(0xFFC62828);
  static const teal = Color(0xFF00897B);
  static const purple = Color(0xFF6A1B9A);
  static const surface = Colors.white;
  static const background = Color(0xFFF5F7FA);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);

  static Color portfolio(String id) {
    switch (id) {
      case 'pf_beverages':
        return primary;
      case 'pf_snacks':
        return teal;
      case 'pf_energy_premium':
        return purple;
      default:
        return textSecondary;
    }
  }
}

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppRadius {
  AppRadius._();
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

class AppShadows {
  AppShadows._();
  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

class AppGradients {
  AppGradients._();
  static const primary =
      LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]);
  static const success =
      LinearGradient(colors: [AppColors.success, Color(0xFF1B5E20)]);
}
