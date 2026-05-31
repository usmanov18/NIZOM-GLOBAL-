import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logger/app_logger.dart';

class RemoteWipeService {
  static Future<void> wipeAllData() async {
    AppLogger.e('☢️ INITIALIZING NUCLEAR WIPE');

    // 1. Birinchi navbatda Audit Logni serverga yuborishga urinish (Placeholder)
    // await TelemetryService.trackImmediate('WIPE_TRIGGERED');

    // 2. Ma'lumotlarni o'chirish
    await Hive.deleteFromDisk();
    const storage = FlutterSecureStorage();
    await storage.deleteAll();

    AppLogger.i('✅ ALL DATA PURGED.');
  }
}
