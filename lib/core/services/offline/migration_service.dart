import '../logger/app_logger.dart';

class MigrationService {
  static Future<void> checkAndMigrate(int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      AppLogger.i('🔄 Migrating database from v$oldVersion to v$newVersion');
      // Step-by-step schema migration logic
    }
  }
}
