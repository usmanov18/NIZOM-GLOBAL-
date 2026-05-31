import 'dart:math';
import '../services/logger/app_logger.dart';

class ChaosMonkey {
  static final _random = Random();

  static void injectChaos() {
    // 2026 Resilience Test: 5% chance of injecting a resilience fault
    if (_random.nextDouble() < 0.05) {
      AppLogger.e('🐵 CHAOS MONKEY: Injecting random network drop!');
      // Trigger a network exception or database lock scenario
    }
  }
}
