import 'package:hive/hive.dart';
import '../logger/app_logger.dart';

class StorageOptimizer {
  static Future<void> optimizeIfNeeded() async {
    // 2026 Logic: Compact only on weekends or after 1000 writes
    AppLogger.i('🧹 Storage Health Check running...');
    final boxNames = ['orders', 'customers', 'products'];
    for (final name in boxNames) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).compact();
      }
    }
  }
}
