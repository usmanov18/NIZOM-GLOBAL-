import 'package:flutter/foundation.dart';
import '../../config/env_config.dart';
import 'log_sanitizer.dart';

class AppLogger {
  static void d(String message) {
    if (EnvConfig.environment == AppEnvironment.dev) {
      debugPrint('🔵 [DEBUG] ${LogSanitizer.sanitize(message)}');
    }
  }

  static void e(String message, [dynamic error, StackTrace? stack]) {
    final cleanMsg = LogSanitizer.sanitize(message);
    final cleanErr =
        error != null ? LogSanitizer.sanitize(error.toString()) : '';
    debugPrint('🔴 [ERROR] $cleanMsg | Error: $cleanErr');
  }

  static void i(String message) {
    if (EnvConfig.environment != AppEnvironment.prod) {
      debugPrint('🟢 [INFO] ${LogSanitizer.sanitize(message)}');
    }
  }
}
