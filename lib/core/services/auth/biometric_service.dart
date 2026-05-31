import 'dart:async';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ============================================================
// BIOMETRIC SERVICE - Professional Biometrik Avtentifikatsiya
// ============================================================

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ============ MAVJUDLIGINI TEKSHIRISH ============

  /// Biometrik mavjudligini tekshirish
  Future<bool> isAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Mavjud biometrik turlarini olish
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Biometrik turini aniqlash
  Future<String> getBiometricTypeName() async {
    final types = await getAvailableBiometrics();
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Barmoq izi';
    if (types.contains(BiometricType.iris)) return 'Iris';
    return 'Biometrik';
  }

  // ============ AUTENTIFIKATSIYA ============

  /// Biometrik autentifikatsiya
  Future<BiometricResult> authenticate({
    String reason = 'Iltimos, shaxsingizni tasdiqlang',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        return BiometricResult(
          success: false,
          errorMessage: 'Biometrik autentifikatsiya mavjud emas',
          errorType: BiometricErrorType.notAvailable,
        );
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          useErrorDialogs: useErrorDialogs,
          biometricOnly: false,
        ),
      );

      if (isAuthenticated) {
        return BiometricResult(
          success: true,
          authenticatedAt: DateTime.now(),
        );
      }

      return BiometricResult(
        success: false,
        errorMessage: 'Autentifikatsiya bekor qilindi',
        errorType: BiometricErrorType.cancelled,
      );
    } on PlatformException catch (e) {
      return BiometricResult(
        success: false,
        errorMessage: _getErrorMessage(e.code),
        errorType: _getErrorType(e.code),
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        errorMessage: 'Noma\'lum xatolik: $e',
        errorType: BiometricErrorType.unknown,
      );
    }
  }

  // ============ SOZLAMALAR ============

  /// Biometrikni yoqish/o'chirish
  Future<void> setEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  /// Biometrik yoqilganmi?
  Future<bool> isEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  /// Oxirgi autentifikatsiya vaqti
  Future<void> saveLastAuthTime() async {
    await _storage.write(
      key: 'last_biometric_auth',
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Oxirgi autentifikatsiya vaqtini olish
  Future<DateTime?> getLastAuthTime() async {
    final value = await _storage.read(key: 'last_biometric_auth');
    if (value != null) return DateTime.parse(value);
    return null;
  }

  /// Sessiya hali faolmi?
  Future<bool> isSessionValid(
      {Duration maxAge = const Duration(hours: 8)}) async {
    final lastAuth = await getLastAuthTime();
    if (lastAuth == null) return false;
    return DateTime.now().difference(lastAuth) < maxAge;
  }

  // ============ YORDAMCHI ============

  String _getErrorMessage(String code) {
    switch (code) {
      case 'NotAvailable':
        return 'Biometrik autentifikatsiya mavjud emas';
      case 'NotEnrolled':
        return 'Biometrik ma\'lumotlar kiritilmagan';
      case 'LockedOut':
        return 'Juda ko\'p urinish. Keyinroq qayta urinib ko\'ring';
      case 'PermanentlyLockedOut':
        return 'Biometrik bloklandi. Parol bilan kiring';
      case 'BiometricOnlyNotSupported':
        return 'Faqat biometrik qo\'llab-quvvatlanmaydi';
      default:
        return 'Biometrik xatolik: $code';
    }
  }

  BiometricErrorType _getErrorType(String code) {
    switch (code) {
      case 'NotAvailable':
        return BiometricErrorType.notAvailable;
      case 'NotEnrolled':
        return BiometricErrorType.notEnrolled;
      case 'LockedOut':
        return BiometricErrorType.lockedOut;
      case 'PermanentlyLockedOut':
        return BiometricErrorType.permanentlyLockedOut;
      case 'BiometricOnlyNotSupported':
        return BiometricErrorType.biometricOnlyNotSupported;
      default:
        return BiometricErrorType.unknown;
    }
  }
}

// ============ MODELS ============

enum BiometricErrorType {
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  biometricOnlyNotSupported,
  cancelled,
  unknown,
}

class BiometricResult {
  final bool success;
  final String? errorMessage;
  final BiometricErrorType? errorType;
  final DateTime? authenticatedAt;

  const BiometricResult({
    required this.success,
    this.errorMessage,
    this.errorType,
    this.authenticatedAt,
  });
}
