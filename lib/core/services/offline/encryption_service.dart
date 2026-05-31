import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class EncryptionService {
  static const String _keyName = 'hive_encryption_key';

  static Future<HiveCipher> getEncryptionKey() async {
    const storage = FlutterSecureStorage();
    var key = await storage.read(key: _keyName);
    if (key == null) {
      final newKey = Hive.generateSecureKey();
      await storage.write(key: _keyName, value: base64UrlEncode(newKey));
      return HiveAesCipher(newKey);
    }
    return HiveAesCipher(base64Url.decode(key));
  }
}
