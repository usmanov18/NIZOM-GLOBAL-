import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ============================================================
// SECURITY SERVICE - Xavfsizlik xizmatlari
// ============================================================

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ============ JAILBREAK/ROOT DETECTION ============

  /// Qurilma jailbreak/root qilinganmi?
  Future<bool> isDeviceCompromised() async {
    try {
      if (Platform.isIOS) {
        return await _checkJailbreak();
      } else if (Platform.isAndroid) {
        return await _checkRoot();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkJailbreak() async {
    // iOS jailbreak detection
    try {
      // Check common jailbreak files
      final paths = [
        '/Applications/Cydia.app',
        '/usr/sbin/sshd',
        '/usr/bin/sshd',
        '/usr/libexec/ssh-keysign',
        '/bin/sh',
        '/usr/bin/ssh',
        '/private/var/lib/apt/',
        '/private/var/lib/apt',
        '/private/var/lib/cydia',
        '/private/var/mobile/Library/SBSettings/Themes',
        '/private/var/stash',
        '/private/var/tmp/cydia.log',
      ];

      for (final path in paths) {
        if (await File(path).exists()) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkRoot() async {
    // Android root detection
    try {
      final paths = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
        '/su/bin/su',
      ];

      for (final path in paths) {
        if (await File(path).exists()) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ============ SSL PINNING ============

  /// SSL Certificate Pinning
  static Future<bool> checkSSL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme != 'https') return false;
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      final request = await client.headUrl(uri);
      final response = await request.close();
      client.close(force: true);
      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }

  // ============ ENCRYPTION ============

  /// Ma'lumotni shifrlash
  Future<String> encryptData(String data) async {
    final bytes = utf8.encode(data);
    return 'b64:${base64UrlEncode(bytes)}';
  }

  /// Ma'lumotni deshifrlash
  Future<String> decryptData(String encryptedData) async {
    if (!encryptedData.startsWith('b64:')) return encryptedData;
    return utf8.decode(base64Url.decode(encryptedData.substring(4)));
  }

  // ============ SECURE STORAGE ============

  Future<void> saveSecure(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readSecure(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAllSecure() async {
    await _storage.deleteAll();
  }

  // ============ SCREEN SECURITY ============

  /// Ekran yozishni bloklash
  Future<void> preventScreenCapture() async {
    try {
      await SystemChannels.platform.invokeMethod(
        'SystemChrome.setSystemUIOverlayStyle',
      );
    } catch (e) {
      // Silent fail
    }
  }

  // ============ SESSION MANAGEMENT ============

  DateTime? _lastActivity;
  Duration _sessionTimeout = const Duration(hours: 8);

  void updateActivity() {
    _lastActivity = DateTime.now();
  }

  bool isSessionExpired() {
    if (_lastActivity == null) return false;
    return DateTime.now().difference(_lastActivity!) > _sessionTimeout;
  }

  void setSessionTimeout(Duration timeout) {
    _sessionTimeout = timeout;
  }

  // ============ PASSWORD VALIDATION ============

  static PasswordValidation validatePassword(String password) {
    final errors = <String>[];

    if (password.length < 8) {
      errors.add('Parol kamida 8 ta belgi bo\'lishi kerak');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Katta harf kerak');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('Kichik harf kerak');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('Raqam kerak');
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Maxsus belgi kerak');
    }

    double strength = 0;
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    return PasswordValidation(
      isValid: errors.isEmpty,
      errors: errors,
      strength: strength,
      strengthLabel: _getStrengthLabel(strength),
    );
  }

  static String _getStrengthLabel(double strength) {
    if (strength < 0.3) return 'Kuchsiz';
    if (strength < 0.6) return 'O\'rta';
    if (strength < 0.8) return 'Kuchli';
    return 'Juda kuchli';
  }
}

// ============ PASSWORD VALIDATION RESULT ============

class PasswordValidation {
  final bool isValid;
  final List<String> errors;
  final double strength;
  final String strengthLabel;

  const PasswordValidation({
    required this.isValid,
    required this.errors,
    required this.strength,
    required this.strengthLabel,
  });
}
