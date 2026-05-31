import 'dart:async';
import '../logger/app_logger.dart';

class ServerTimeService {
  static Duration _offset = Duration.zero;
  static bool _isSyncing = false;

  static Future<void> syncWithServer(
      DateTime serverTime, DateTime requestStartTime) async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final now = DateTime.now();
      final rtt = now.difference(requestStartTime);
      final adjustedServerTime =
          serverTime.add(Duration(milliseconds: rtt.inMilliseconds ~/ 2));
      _offset = adjustedServerTime.difference(now);
      AppLogger.i('🕒 Time Synced with RTT compensation.');
    } finally {
      _isSyncing = false;
    }
  }

  // Timeout bilan sinxronlash uchun yordamchi
  static Future<void> safeSync(Future<DateTime> Function() fetcher) async {
    try {
      final startTime = DateTime.now();
      final serverTime = await fetcher().timeout(const Duration(seconds: 5));
      await syncWithServer(serverTime, startTime);
    } catch (e) {
      AppLogger.e(
          '🕒 Time sync timed out or failed. Using local clock fallback.');
    }
  }

  static DateTime get now => DateTime.now().add(_offset);
}
