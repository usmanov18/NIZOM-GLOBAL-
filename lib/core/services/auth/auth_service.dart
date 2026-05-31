import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../errors/exceptions.dart';
import '../../../features/auth/domain/entities/auth_entities.dart';

// ============================================================
// AUTH SERVICE - To'liq autentifikatsiya
// ============================================================

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _userRoleKey = 'user_role';
  static const String _sapTokenKey = 'sap_token';
  static const String _oneCTokenKey = '1c_token';

  AuthUser? _currentUser;
  AuthUser? get currentUser => _currentUser;

  // ============ LOGIN/PASSWORD ============

  Future<AuthUser> loginWithCredentials(String login, String password) async {
    try {
      final response = await Dio().post(
        'https://api.nizomglobal.uz/api/v1/auth/login',
        data: {'login': login, 'password': password},
      );

      final data = response.data;

      // Tokenlarni saqlash
      await _storage.write(key: _tokenKey, value: data['access_token']);
      await _storage.write(key: _refreshTokenKey, value: data['refresh_token']);

      // 1C va SAP tokenlari
      if (data['one_c_token'] != null) {
        await _storage.write(key: _oneCTokenKey, value: data['one_c_token']);
      }
      if (data['sap_token'] != null) {
        await _storage.write(key: _sapTokenKey, value: data['sap_token']);
      }

      // Foydalanuvchi ma'lumotlari
      _currentUser = AuthUser.fromJson(data['user']);
      await _storage.write(key: _userDataKey, value: jsonEncode(data['user']));
      await _storage.write(key: _userRoleKey, value: data['user']['role']);

      return _currentUser!;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Login yoki parol noto\'g\'ri');
      }
      throw AuthException(message: 'Tizimga kirishda xatolik: ${e.message}');
    }
  }

  // ============ PHONE/OTP ============

  Future<bool> sendOTP(String phone) async {
    try {
      final response = await Dio().post(
        'https://api.nizomglobal.uz/api/v1/auth/phone/send-otp',
        data: {'phone': phone},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw AuthException(message: 'SMS kod yuborishda xatolik');
    }
  }

  Future<AuthUser> verifyOTP(String phone, String otp) async {
    try {
      final response = await Dio().post(
        'https://api.nizomglobal.uz/api/v1/auth/phone/verify',
        data: {'phone': phone, 'otp': otp},
      );

      final data = response.data;
      await _saveAuthData(data);

      _currentUser = AuthUser.fromJson(data['user']);
      return _currentUser!;
    } catch (e) {
      throw AuthException(message: 'Kod noto\'g\'ri yoki muddati o\'tgan');
    }
  }

  // ============ SSO ============

  Future<void> loginWithSSO() async {
    // SSO hali backend va deep-link bilan ulanmagan.
    // Runtime crash bo‘lmasligi uchun aniq AuthException qaytaramiz.
    throw AuthException(message: 'SSO hozircha yoqilmagan');
  }

  Future<AuthUser> handleSSOCallback(String code) async {
    try {
      final response = await Dio().post(
        'https://api.nizomglobal.uz/api/v1/auth/sso/callback',
        data: {'code': code},
      );

      final data = response.data;
      await _saveAuthData(data);

      _currentUser = AuthUser.fromJson(data['user']);
      return _currentUser!;
    } catch (e) {
      throw AuthException(message: 'SSO kirishda xatolik');
    }
  }

  // ============ BIOMETRIC ============

  Future<AuthUser?> loginWithBiometric() async {
    // Local dan user ma'lumotlarini olish
    final userData = await _storage.read(key: _userDataKey);
    if (userData == null) throw AuthException(message: 'Avval tizimga kiring');

    _currentUser = AuthUser.fromJson(jsonDecode(userData));
    return _currentUser!;
  }

  // ============ TOKEN MANAGEMENT ============

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<String?> getSapToken() async {
    return await _storage.read(key: _sapTokenKey);
  }

  Future<String?> getOneCToken() async {
    return await _storage.read(key: _oneCTokenKey);
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        'https://api.nizomglobal.uz/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data;
      await _storage.write(key: _tokenKey, value: data['access_token']);
      if (data['refresh_token'] != null) {
        await _storage.write(
            key: _refreshTokenKey, value: data['refresh_token']);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============ USER DATA ============

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  Future<AuthUser?> loadCurrentUser() async {
    try {
      final userData = await _storage.read(key: _userDataKey);
      if (userData != null) {
        _currentUser = AuthUser.fromJson(jsonDecode(userData));
        return _currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _userDataKey);
    if (data != null) return jsonDecode(data);
    return null;
  }

  // ============ PASSWORD ============

  Future<bool> resetPassword(String phone) async {
    try {
      await Dio().post(
        'https://api.nizomglobal.uz/api/v1/auth/password/reset',
        data: {'phone': phone},
      );
      return true;
    } catch (e) {
      throw AuthException(message: 'Parolni tiklashda xatolik');
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final token = await getAccessToken();
      await Dio().post(
        'https://api.nizomglobal.uz/api/v1/auth/password/change',
        data: {'old_password': oldPassword, 'new_password': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } catch (e) {
      throw AuthException(message: 'Parolni o\'zgartirishda xatolik');
    }
  }

  // ============ LOGOUT ============

  Future<void> logout() async {
    try {
      final token = await getAccessToken();
      if (token != null) {
        await Dio().post(
          'https://api.nizomglobal.uz/api/v1/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (e) {
      // Logout xatosi e'tiborsiz
    } finally {
      await _clearAuthData();
      _currentUser = null;
    }
  }

  // ============ HELPERS ============

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    await _storage.write(key: _tokenKey, value: data['access_token']);
    await _storage.write(key: _refreshTokenKey, value: data['refresh_token']);
    await _storage.write(key: _userDataKey, value: jsonEncode(data['user']));
    await _storage.write(key: _userRoleKey, value: data['user']['role']);

    if (data['one_c_token'] != null) {
      await _storage.write(key: _oneCTokenKey, value: data['one_c_token']);
    }
    if (data['sap_token'] != null) {
      await _storage.write(key: _sapTokenKey, value: data['sap_token']);
    }
  }

  Future<void> _clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _sapTokenKey);
    await _storage.delete(key: _oneCTokenKey);
  }
}
