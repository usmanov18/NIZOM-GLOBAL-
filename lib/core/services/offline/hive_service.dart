import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

// ============================================================
// HIVE SERVICE - Offline ma'lumotlar saqlash
// ============================================================

class HiveService {
  static const String _settingsBox = 'settings';
  static const String _cacheBox = 'cache';
  static const String _syncBox = 'sync';

  // ============ INIT ============

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_cacheBox);
    await Hive.openBox(_syncBox);
  }

  // ============ SETTINGS ============

  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBox);
    await box.put(key, jsonEncode(value));
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    final box = Hive.box(_settingsBox);
    final data = box.get(key);
    if (data != null) return jsonDecode(data);
    return defaultValue;
  }

  Future<void> deleteSetting(String key) async {
    final box = Hive.box(_settingsBox);
    await box.delete(key);
  }

  // ============ CACHE ============

  Future<void> cacheData(String key, dynamic data, {Duration? ttl}) async {
    final box = Hive.box(_cacheBox);
    final entry = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'ttl': ttl?.inSeconds,
    };
    await box.put(key, jsonEncode(entry));
  }

  dynamic getCachedData(String key) {
    final box = Hive.box(_cacheBox);
    final data = box.get(key);
    if (data != null) {
      final entry = jsonDecode(data);
      final timestamp = DateTime.parse(entry['timestamp']);
      final ttl = entry['ttl'] as int?;

      if (ttl != null) {
        final expiry = timestamp.add(Duration(seconds: ttl));
        if (DateTime.now().isAfter(expiry)) {
          box.delete(key);
          return null;
        }
      }
      return entry['data'];
    }
    return null;
  }

  Future<void> deleteCachedData(String key) async {
    final box = Hive.box(_cacheBox);
    await box.delete(key);
  }

  Future<void> clearCache() async {
    final box = Hive.box(_cacheBox);
    await box.clear();
  }

  // ============ SYNC ============

  Future<void> saveSyncTime(String key) async {
    final box = Hive.box(_syncBox);
    await box.put(key, DateTime.now().toIso8601String());
  }

  DateTime? getLastSyncTime(String key) {
    final box = Hive.box(_syncBox);
    final data = box.get(key);
    if (data != null) return DateTime.parse(data);
    return null;
  }

  bool needsSync(String key, {Duration maxAge = const Duration(hours: 1)}) {
    final lastSync = getLastSyncTime(key);
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) > maxAge;
  }

  // ============ GENERIC ============

  Future<void> save(String boxName, String key, dynamic data) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, jsonEncode(data));
  }

  dynamic get(String boxName, String key) {
    final box = Hive.box(boxName);
    final data = box.get(key);
    if (data != null) return jsonDecode(data);
    return null;
  }

  Future<void> delete(String boxName, String key) async {
    final box = await Hive.openBox(boxName);
    await box.delete(key);
  }

  Future<void> clearBox(String boxName) async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }

  // ============ CLEAR ALL ============

  Future<void> clearAll() async {
    await Hive.box(_settingsBox).clear();
    await Hive.box(_cacheBox).clear();
    await Hive.box(_syncBox).clear();
  }
}
