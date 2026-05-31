import 'package:hive/hive.dart';

class MetadataCache {
  static const String _boxName = 'odata_metadata';

  static Future<void> saveMetadata(String key, String xml) async {
    final box = await Hive.openBox(_boxName);
    await box.put(key, xml);
  }

  static Future<String?> getMetadata(String key) async {
    final box = await Hive.openBox(_boxName);
    return box.get(key);
  }
}
