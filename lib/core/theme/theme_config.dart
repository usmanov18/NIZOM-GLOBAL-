import 'package:flutter/material.dart';

class ThemeConfig {
  static String brandName = "NIZOM GLOBAL";
  static Color primaryColor = const Color(0xFF1565C0);
  static Color accentColor = const Color(0xFFFF6F00);

  static void switchBrand(String name, Color primary, Color accent) {
    brandName = name;
    primaryColor = primary;
    accentColor = accent;
  }
}
