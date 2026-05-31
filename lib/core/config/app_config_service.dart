import 'dart:convert';
import 'package:hive/hive.dart';

/// App konfiguratsiya xizmati
class AppConfigService {
  static AppConfigService? _instance;
  late Box _box;

  static Future<AppConfigService> getInstance() async {
    if (_instance == null) {
      _instance = AppConfigService._();
      _instance!._box = await Hive.openBox('app_config');
    }
    return _instance!;
  }

  AppConfigService._();

  // Umumiy
  String get appName => _get('app_name', 'NIZOM GLOBAL');
  String get companyCode => _get('company_code', 'NG001');
  String get currency => _get('currency', 'UZS');
  String get timezone => _get('timezone', 'Asia/Tashkent');
  String get language => _get('language', 'uz');
  String get theme => _get('theme', 'light');

  // Auth
  bool get loginPasswordEnabled => _get('auth.login_password', true);
  bool get phoneOtpEnabled => _get('auth.phone_otp', true);
  bool get ssoEnabled => _get('auth.sso', false);
  bool get biometricEnabled => _get('auth.biometric', true);
  int get maxLoginAttempts => _get('auth.max_attempts', 5);
  int get sessionTimeout => _get('auth.session_timeout', 480);

  // Orders
  bool get ordersEnabled => _get('orders.enabled', true);
  int get maxItemsPerOrder => _get('orders.max_items', 50);
  double get maxOrderAmount => _get('orders.max_amount', 50000000);
  bool get cashEnabled => _get('orders.payment.cash', true);
  bool get cardEnabled => _get('orders.payment.card', true);
  bool get transferEnabled => _get('orders.payment.transfer', true);
  bool get creditEnabled => _get('orders.payment.credit', true);

  // Delivery
  bool get deliveryEnabled => _get('delivery.enabled', true);
  bool get gpsTracking => _get('delivery.gps', true);
  int get gpsInterval => _get('delivery.gps_interval', 30);
  bool get requirePhoto => _get('delivery.require_photo', true);
  int get minPhotos => _get('delivery.min_photos', 3);
  bool get requireSignature => _get('delivery.require_signature', true);

  // Notifications
  bool get pushEnabled => _get('notifications.push', true);
  bool get soundEnabled => _get('notifications.sound', true);
  bool get vibrationEnabled => _get('notifications.vibration', true);

  // Integrations
  bool get oneCEnabled => _get('integrations.one_c', true);
  bool get sapEnabled => _get('integrations.sap', true);
  bool get firebaseEnabled => _get('integrations.firebase', true);
  bool get mapsEnabled => _get('integrations.maps', true);

  String get oneCBaseUrl =>
      _get('integrations.one_c_url', 'https://1c.nizomglobal.uz');
  String get sapBaseUrl =>
      _get('integrations.sap_url', 'https://sap.nizomglobal.uz');

  // Sozlamalarni o'zgartirish
  Future<void> updateSetting(String key, dynamic value) async {
    await _box.put(key, jsonEncode(value));
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    for (final entry in settings.entries) {
      await _box.put(entry.key, jsonEncode(entry.value));
    }
  }

  Map<String, dynamic> getAllSettings() {
    final settings = <String, dynamic>{};
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value != null) {
        try {
          settings[key] = jsonDecode(value);
        } catch (e) {
          settings[key] = value;
        }
      }
    }
    return settings;
  }

  Future<void> resetToDefaults() async {
    await _box.clear();
  }

  dynamic _get(String key, dynamic defaultValue) {
    final value = _box.get(key);
    if (value == null) return defaultValue;
    try {
      return jsonDecode(value);
    } catch (e) {
      return value;
    }
  }
}
