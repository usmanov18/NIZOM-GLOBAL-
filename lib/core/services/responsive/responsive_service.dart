import 'package:flutter/material.dart';

// ============================================================
// RESPONSIVE SERVICE - Ekran o'lchamlariga moslashish
// ============================================================

class ResponsiveService {
  static final ResponsiveService _instance = ResponsiveService._();
  factory ResponsiveService() => _instance;
  ResponsiveService._();

  // Ekran turlari
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Ekran turini aniqlash
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  /// Mobil ekran
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  /// Planshet ekran
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  /// Desktop ekran
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }

  /// Ekran kengligi
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Ekran balandligi
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Padding o'lchami
  static double padding(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 24;
    return 32;
  }

  /// Grid ustunlari soni
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  /// Font o'lchami
  static double fontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) return baseSize;
    if (isTablet(context)) return baseSize * 1.1;
    return baseSize * 1.2;
  }
}

enum ScreenType { mobile, tablet, desktop }

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveService.getScreenType(context);

    switch (screenType) {
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
        return mobile;
    }
  }
}
