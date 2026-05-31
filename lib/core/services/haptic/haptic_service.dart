import 'package:flutter/services.dart';

// ============================================================
// HAPTIC SERVICE - Tebranish feedback
// ============================================================

class HapticService {
  static final HapticService _instance = HapticService._();
  factory HapticService() => _instance;
  HapticService._();

  bool _enabled = true;

  bool get isEnabled => _enabled;
  void setEnabled(bool value) => _enabled = value;

  /// Yengil tebranish (tugma bosish)
  Future<void> lightImpact() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// O'rtacha tebranish (toggle, checkbox)
  Future<void> mediumImpact() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Kuchli tebranish (xatolik, ogohlantirish)
  Future<void> heavyImpact() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Yengil vibaratsiya (selection)
  Future<void> selectionClick() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Muvaffaqiyat vibaratsiya
  Future<void> success() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Xatolik vibaratsiya
  Future<void> error() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Ogohlantirish vibaratsiya
  Future<void> warning() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
  }
}
