import 'package:flutter/material.dart';

// ============================================================
// NAVIGATION SERVICE - Professional navigatsiya
// ============================================================

class NavigationService {
  static final NavigationService _instance = NavigationService._();
  factory NavigationService() => _instance;
  NavigationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentContext;

  // ============ NAVIGATION ============

  /// Sahifaga o'tish
  Future<T?> push<T>(Widget page) async {
    return navigatorKey.currentState?.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Sahifaga o'tish (nom bilan)
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) async {
    return navigatorKey.currentState
        ?.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Sahifaga o'tish va oldingisini o'chirish
  Future<T?> pushReplacement<T>(Widget page) async {
    return navigatorKey.currentState?.pushReplacement<T, void>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Sahifaga o'tish va barchasini o'chirish
  Future<T?> pushAndRemoveAll<T>(Widget page) async {
    return navigatorKey.currentState?.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  /// Orqaga qaytish
  void pop<T>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  /// Barchasiga qaytish
  void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
  }

  /// Dialog ko'rsatish
  Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  /// Bottom sheet ko'rsatish
  Future<T?> showBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context!,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: builder,
    );
  }

  /// SnackBar ko'rsatish
  void showSnackBar(String message,
      {Color? backgroundColor, SnackBarAction? action}) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Muvaffaqiyat SnackBar
  void showSuccess(String message) {
    showSnackBar(message, backgroundColor: const Color(0xFF2E7D32));
  }

  /// Xatolik SnackBar
  void showError(String message) {
    showSnackBar(message, backgroundColor: const Color(0xFFC62828));
  }

  /// Ogohlantirish SnackBar
  void showWarning(String message) {
    showSnackBar(message, backgroundColor: const Color(0xFFFF6F00));
  }
}
