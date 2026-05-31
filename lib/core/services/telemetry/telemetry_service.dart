import 'dart:math';
import '../logger/app_logger.dart';

class TelemetryService {
  static final _random = Random();

  static void trackEvent(String eventName,
      {Map<String, dynamic>? properties, bool isError = false}) {
    // 2026 Sampling: Track 100% of errors, but only 10% of successful events
    if (isError || _random.nextDouble() < 0.1) {
      AppLogger.i('📡 TELEMETRY (Sampled): $eventName | $properties');
    }
  }
}
