import 'dart:async';
import 'package:hive/hive.dart';
import '../logger/app_logger.dart';

class BoxManager {
  static final Map<String, Box> _openBoxes = {};
  static final Map<String, Future<Box>> _inFlight = {};

  static Future<Box<T>> getBox<T>(String name) async {
    // 1. Agar box allaqachon ochiq bo'lsa
    if (_openBoxes.containsKey(name)) return _openBoxes[name] as Box<T>;

    // 2. Agar box hozir ochilayotgan bo'lsa (in-flight)
    if (_inFlight.containsKey(name)) {
      final box = await _inFlight[name]!;
      return box as Box<T>;
    }

    // 3. Yangi ochish jarayoni
    final Future<Box<T>> openFuture = Hive.openBox<T>(name);
    _inFlight[name] = openFuture;

    try {
      final box = await openFuture;
      _openBoxes[name] = box;
      AppLogger.i('📦 Box opened & cached: $name');
      return box;
    } catch (e) {
      AppLogger.e('🚨 Failed to open box $name: $e');
      rethrow;
    } finally {
      _inFlight.remove(name);
    }
  }

  static Future<void> closeUnused() async {
    AppLogger.i('🧹 Lifecycle: Releasing unused Hive resources.');
    // Keep core boxes, close others logic...
  }
}
