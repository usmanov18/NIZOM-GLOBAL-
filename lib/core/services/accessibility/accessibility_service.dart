import 'package:flutter/material.dart';

// ============================================================
// ACCESSIBILITY SERVICE - Ekran o'qish qo'llab-quvvatlash
// ============================================================

class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._();
  factory AccessibilityService() => _instance;
  AccessibilityService._();

  /// Ekran o'qish yoqilganmi?
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Yuqori kontrast rejimi
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Kattalashtirish koeffitsienti
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Animatsiyalar yoqilganmi?
  static bool areAnimationsEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations == false;
  }

  /// Semantik label yaratish
  static Widget semanticLabel({
    required Widget child,
    required String label,
    String? hint,
    bool isButton = false,
    bool isHeader = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      header: isHeader,
      child: child,
    );
  }
}

/// Accessibility wrapper
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;
  final bool excludeFromSemantics;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (semanticLabel != null) {
      result = Semantics(label: semanticLabel, child: result);
    }

    if (tooltip != null) {
      result = Tooltip(message: tooltip!, child: result);
    }

    if (excludeFromSemantics) {
      result = ExcludeSemantics(child: result);
    }

    return result;
  }
}
