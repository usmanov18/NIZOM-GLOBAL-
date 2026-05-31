import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/logger/app_logger.dart';

class IsolateManager {
  static Future<T> computeWithTimeout<T>(FutureOr<T> Function() task,
      {Duration timeout = const Duration(seconds: 30)}) async {
    try {
      return await compute((_) => task(), null).timeout(timeout, onTimeout: () {
        AppLogger.e('🚨 Isolate Task Timed Out!');
        throw TimeoutException('Isolate task took too long');
      });
    } catch (e) {
      AppLogger.e('❌ Isolate Error: $e');
      rethrow;
    }
  }
}
