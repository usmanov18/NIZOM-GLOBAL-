import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// AUTH LOCAL DATASOURCE - Local ma'lumotlar saqlash
// ============================================================

abstract class AuthLocalDataSource {
  // Token operations
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearTokens();

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> clearUserData();

  // Role
  Future<void> saveUserRole(String role);
  Future<String?> getUserRole();

  // 1C/SAP tokens
  Future<void> saveOneCToken(String token);
  Future<String?> getOneCToken();
  Future<void> saveSapToken(String token);
  Future<String?> getSapToken();

  // Settings
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
  Future<void> setLanguage(String code);
  Future<String?> getLanguage();

  // Cache
  Future<void> cacheUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>?> getCachedUser();

  // Clear all
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  static const String _userBox = 'user_cache';

  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  // ============ TOKEN OPERATIONS ============

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: 'access_token', value: token);
    } catch (e) {
      throw CacheException(message: 'Token saqlashda xatolik');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: 'access_token');
    } catch (e) {
      throw CacheException(message: 'Token o\'qishda xatolik');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: 'refresh_token', value: token);
    } catch (e) {
      throw CacheException(message: 'Refresh token saqlashda xatolik');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: 'refresh_token');
    } catch (e) {
      throw CacheException(message: 'Refresh token o\'qishda xatolik');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
    } catch (e) {
      throw CacheException(message: 'Tokenlarni tozalashda xatolik');
    }
  }

  // ============ USER DATA ============

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _secureStorage.write(
        key: 'user_data',
        value: jsonEncode(userData),
      );
    } catch (e) {
      throw CacheException(
          message: 'Foydalanuvchi ma\'lumotlarini saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final data = await _secureStorage.read(key: 'user_data');
      if (data != null) {
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      throw CacheException(
          message: 'Foydalanuvchi ma\'lumotlarini o\'qishda xatolik');
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await _secureStorage.delete(key: 'user_data');
    } catch (e) {
      throw CacheException(message: 'Ma\'lumotlarni tozalashda xatolik');
    }
  }

  // ============ ROLE ============

  @override
  Future<void> saveUserRole(String role) async {
    try {
      await _secureStorage.write(key: 'user_role', value: role);
    } catch (e) {
      throw CacheException(message: 'Rol saqlashda xatolik');
    }
  }

  @override
  Future<String?> getUserRole() async {
    try {
      return await _secureStorage.read(key: 'user_role');
    } catch (e) {
      return null;
    }
  }

  // ============ 1C/SAP TOKENS ============

  @override
  Future<void> saveOneCToken(String token) async {
    await _secureStorage.write(key: 'one_c_token', value: token);
  }

  @override
  Future<String?> getOneCToken() async {
    return await _secureStorage.read(key: 'one_c_token');
  }

  @override
  Future<void> saveSapToken(String token) async {
    await _secureStorage.write(key: 'sap_token', value: token);
  }

  @override
  Future<String?> getSapToken() async {
    return await _secureStorage.read(key: 'sap_token');
  }

  // ============ SETTINGS ============

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
        key: 'biometric_enabled', value: enabled.toString());
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  @override
  Future<void> setLanguage(String code) async {
    await _secureStorage.write(key: 'language', value: code);
  }

  @override
  Future<String?> getLanguage() async {
    return await _secureStorage.read(key: 'language');
  }

  // ============ CACHE ============

  @override
  Future<void> cacheUser(Map<String, dynamic> user) async {
    try {
      final box = await Hive.openBox(_userBox);
      await box.put('current_user', jsonEncode(user));
      await box.put('cache_time', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Keshlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedUser() async {
    try {
      final box = await Hive.openBox(_userBox);
      final data = box.get('current_user');
      if (data != null) {
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ CLEAR ALL ============

  @override
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      final box = await Hive.openBox(_userBox);
      await box.clear();
    } catch (e) {
      throw CacheException(message: 'Tozalashda xatolik');
    }
  }
}
