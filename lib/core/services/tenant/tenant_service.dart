import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ============================================================
// TENANT SERVICE - Multi-Tenant boshqaruvi
// ============================================================

class TenantService {
  static final TenantService _instance = TenantService._internal();
  factory TenantService() => _instance;
  TenantService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _tenantId;
  String? _tenantName;
  Map<String, dynamic>? _tenantConfig;

  String? get tenantId => _tenantId;
  String? get tenantName => _tenantName;
  Map<String, dynamic>? get tenantConfig => _tenantConfig;

  // ============ INIT ============

  Future<void> initialize() async {
    _tenantId = await _storage.read(key: 'tenant_id');
    _tenantName = await _storage.read(key: 'tenant_name');

    final configStr = await _storage.read(key: 'tenant_config');
    if (configStr != null) {
      _tenantConfig = Map<String, dynamic>.from(
        // jsonDecode(configStr)
        {},
      );
    }
  }

  // ============ TENANT OPERATIONS ============

  Future<void> setTenant({
    required String tenantId,
    required String tenantName,
    required Map<String, dynamic> config,
  }) async {
    _tenantId = tenantId;
    _tenantName = tenantName;
    _tenantConfig = config;

    await _storage.write(key: 'tenant_id', value: tenantId);
    await _storage.write(key: 'tenant_name', value: tenantName);
    await _storage.write(key: 'tenant_config', value: config.toString());
  }

  Future<void> clearTenant() async {
    _tenantId = null;
    _tenantName = null;
    _tenantConfig = null;

    await _storage.delete(key: 'tenant_id');
    await _storage.delete(key: 'tenant_name');
    await _storage.delete(key: 'tenant_config');
  }

  // ============ CONFIG HELPERS ============

  String getBaseUrl() {
    return _tenantConfig?['base_url'] ?? 'https://api.nizomglobal.uz';
  }

  String getOneCUrl() {
    return _tenantConfig?['one_c_url'] ?? 'https://1c.nizomglobal.uz';
  }

  String getSAPUrl() {
    return _tenantConfig?['sap_url'] ?? 'https://sap.nizomglobal.uz';
  }

  String getCurrency() {
    return _tenantConfig?['currency'] ?? 'UZS';
  }

  String getTimezone() {
    return _tenantConfig?['timezone'] ?? 'Asia/Tashkent';
  }

  String getLanguage() {
    return _tenantConfig?['language'] ?? 'uz';
  }

  bool isFeatureEnabled(String feature) {
    final features = _tenantConfig?['features'] as Map<String, dynamic>?;
    return features?[feature] ?? false;
  }
}
