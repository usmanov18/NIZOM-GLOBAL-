import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../logger/app_logger.dart';

class AuditService {
  static const String _boxName = 'audit_logs';

  Future<void> logAction({
    required String userId,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'userId': userId,
      'action': action,
      'metadata': metadata,
    };

    if (kDebugMode) {
      AppLogger.d('📝 AUDIT: $entry');
    }

    final box = await Hive.openBox(_boxName);
    await box.add(entry);
  }
}
