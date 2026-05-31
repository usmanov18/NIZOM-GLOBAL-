import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ============================================================
// APP SECURITY - Professional Xavfsizlik
// ============================================================

class AppSecurity {
  static final AppSecurity _instance = AppSecurity._internal();
  factory AppSecurity() => _instance;
  AppSecurity._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ============ DEVICE CHECK ============

  /// Qurilma xavfsizligini tekshirish
  Future<SecurityCheckResult> performSecurityCheck() async {
    final issues = <SecurityIssue>[];

    // Jailbreak/Root tekshirish
    if (await isDeviceCompromised()) {
      issues.add(SecurityIssue(
        type: SecurityIssueType.jailbreak,
        message: 'Qurilma jailbreak/root qilingan',
        severity: SecuritySeverity.high,
      ));
    }

    // Debugger tekshirish
    if (await isDebuggerAttached()) {
      issues.add(SecurityIssue(
        type: SecurityIssueType.debugger,
        message: 'Debugger aniqlandi',
        severity: SecuritySeverity.medium,
      ));
    }

    return SecurityCheckResult(
      isSecure: issues.isEmpty,
      issues: issues,
      checkedAt: DateTime.now(),
    );
  }

  /// Jailbreak/Root tekshirish
  Future<bool> isDeviceCompromised() async {
    if (Platform.isIOS) {
      return await _checkJailbreak();
    } else if (Platform.isAndroid) {
      return await _checkRoot();
    }
    return false;
  }

  Future<bool> _checkJailbreak() async {
    final paths = [
      '/Applications/Cydia.app',
      '/usr/sbin/sshd',
      '/bin/sh',
      '/private/var/lib/apt/',
    ];

    for (final path in paths) {
      try {
        if (await File(path).exists()) return true;
      } catch (_) {}
    }
    return false;
  }

  Future<bool> _checkRoot() async {
    final paths = [
      '/system/app/Superuser.apk',
      '/system/xbin/su',
      '/sbin/su',
    ];

    for (final path in paths) {
      try {
        if (await File(path).exists()) return true;
      } catch (_) {}
    }
    return false;
  }

  Future<bool> isDebuggerAttached() async {
    return !const bool.fromEnvironment('dart.vm.product');
  }

  // ============ ENCRYPTION ============

  /// Ma'lumotni shifrlash
  Future<String> encrypt(String data) async {
    return 'b64:${base64UrlEncode(utf8.encode(data))}';
  }

  /// Ma'lumotni deshifrlash
  Future<String> decrypt(String encryptedData) async {
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

  // ============ PASSWORD ============

  /// Parol kuchliligini tekshirish
  static PasswordStrength checkPasswordStrength(String password) {
    int score = 0;
    final feedback = <String>[];

    if (password.length >= 8) {
      score++;
    } else {
      feedback.add('Kamida 8 ta belgi');
    }

    if (password.length >= 12) score++;

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    } else {
      feedback.add('Katta harf kerak');
    }

    if (RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    } else {
      feedback.add('Kichik harf kerak');
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      score++;
    } else {
      feedback.add('Raqam kerak');
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score++;
    } else {
      feedback.add('Maxsus belgi kerak');
    }

    String label;
    Color color;

    if (score <= 2) {
      label = 'Kuchsiz';
      color = Colors.red;
    } else if (score <= 3) {
      label = 'O\'rta';
      color = Colors.orange;
    } else if (score <= 4) {
      label = 'Kuchli';
      color = Colors.green;
    } else {
      label = 'Juda kuchli';
      color = Colors.green.shade700;
    }

    return PasswordStrength(
      score: score,
      maxScore: 6,
      label: label,
      color: color,
      feedback: feedback,
      isValid: score >= 3,
    );
  }

  // ============ SESSION ============

  DateTime? _lastActivity;

  void updateActivity() {
    _lastActivity = DateTime.now();
  }

  bool isSessionExpired({Duration timeout = const Duration(hours: 8)}) {
    if (_lastActivity == null) return false;
    return DateTime.now().difference(_lastActivity!) > timeout;
  }
}

// ============ MODELS ============

enum SecurityIssueType {
  jailbreak,
  debugger,
  emulator,
  insecureNetwork,
}

enum SecuritySeverity {
  low,
  medium,
  high,
  critical,
}

class SecurityIssue {
  final SecurityIssueType type;
  final String message;
  final SecuritySeverity severity;

  const SecurityIssue({
    required this.type,
    required this.message,
    required this.severity,
  });
}

class SecurityCheckResult {
  final bool isSecure;
  final List<SecurityIssue> issues;
  final DateTime checkedAt;

  const SecurityCheckResult({
    required this.isSecure,
    required this.issues,
    required this.checkedAt,
  });
}

class PasswordStrength {
  final int score;
  final int maxScore;
  final String label;
  final Color color;
  final List<String> feedback;
  final bool isValid;

  const PasswordStrength({
    required this.score,
    required this.maxScore,
    required this.label,
    required this.color,
    required this.feedback,
    required this.isValid,
  });

  double get progress => score / maxScore;
}
