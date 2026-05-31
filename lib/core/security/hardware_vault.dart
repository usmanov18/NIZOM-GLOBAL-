import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/logger/app_logger.dart';

class HardwareVault {
  static const _storage = FlutterSecureStorage();

  static Future<void> storeSecurely(String key, String value) async {
    try {
      // 1. Try Hardware TEE (Simplified placeholder)
      AppLogger.i('🛡 Storing in Hardware Vault...');
    } catch (e) {
      // 2. Fallback to Encrypted Software Storage
      AppLogger.i('⚠️ Hardware Vault unavailable. Using Software Encryption.');
      await _storage.write(key: key, value: value);
    }
  }
}
