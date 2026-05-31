import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// ADMIN LOCAL DATASOURCE - Admin offline cache
// ============================================================

abstract class AdminLocalDataSource {
  // Dashboard
  Future<void> cacheDashboard(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedDashboard();

  // System Settings
  Future<void> cacheSettings(Map<String, dynamic> settings);
  Future<Map<String, dynamic>?> getCachedSettings();

  // Agents
  Future<void> cacheAgents(List<Map<String, dynamic>> agents);
  Future<List<Map<String, dynamic>>> getCachedAgents(
      {String? status, String? search});
  Future<void> saveAgent(Map<String, dynamic> agent);
  Future<Map<String, dynamic>?> getAgent(String agentId);

  // Restrictions
  Future<void> cacheRestrictions(List<Map<String, dynamic>> restrictions);
  Future<List<Map<String, dynamic>>> getCachedRestrictions();
  Future<void> saveRestriction(Map<String, dynamic> restriction);
  Future<Map<String, dynamic>?> getRestriction(String agentId);

  // Discount Policy
  Future<void> cacheDiscountPolicy(Map<String, dynamic> policy);
  Future<Map<String, dynamic>?> getCachedDiscountPolicy();

  // Alerts
  Future<void> cacheAlerts(List<Map<String, dynamic>> alerts);
  Future<List<Map<String, dynamic>>> getCachedAlerts();

  // Audit Log
  Future<void> cacheAuditLog(List<Map<String, dynamic>> logs);
  Future<List<Map<String, dynamic>>> getCachedAuditLog();

  // Sync
  Future<DateTime?> getLastSyncTime();
  Future<void> saveLastSyncTime();

  // Clear
  Future<void> clearAll();
}

class AdminLocalDataSourceImpl implements AdminLocalDataSource {
  static const String _dashboardBox = 'admin_dashboard';
  static const String _settingsBox = 'admin_settings';
  static const String _agentsBox = 'admin_agents';
  static const String _restrictionsBox = 'admin_restrictions';
  static const String _discountsBox = 'admin_discounts';
  static const String _alertsBox = 'admin_alerts';
  static const String _auditBox = 'admin_audit';

  // ============ DASHBOARD ============

  @override
  Future<void> cacheDashboard(Map<String, dynamic> data) async {
    try {
      final box = await Hive.openBox(_dashboardBox);
      await box.put('dashboard', jsonEncode(data));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Dashboard saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedDashboard() async {
    try {
      final box = await Hive.openBox(_dashboardBox);
      final data = box.get('dashboard');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ SETTINGS ============

  @override
  Future<void> cacheSettings(Map<String, dynamic> settings) async {
    try {
      final box = await Hive.openBox(_settingsBox);
      await box.put('settings', jsonEncode(settings));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Sozlamalarni saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedSettings() async {
    try {
      final box = await Hive.openBox(_settingsBox);
      final data = box.get('settings');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ AGENTS ============

  @override
  Future<void> cacheAgents(List<Map<String, dynamic>> agents) async {
    try {
      final box = await Hive.openBox(_agentsBox);
      await box.put('agents_list', jsonEncode(agents));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Agentlarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedAgents(
      {String? status, String? search}) async {
    try {
      final box = await Hive.openBox(_agentsBox);
      final data = box.get('agents_list');
      if (data != null) {
        var agents = List<Map<String, dynamic>>.from(jsonDecode(data));
        if (status != null && status != 'all') {
          agents = agents.where((a) => a['status'] == status).toList();
        }
        if (search != null && search.isNotEmpty) {
          final query = search.toLowerCase();
          agents = agents
              .where((a) =>
                  a['name'].toString().toLowerCase().contains(query) ||
                  a['code'].toString().toLowerCase().contains(query) ||
                  (a['phone'] ?? '').toString().contains(query))
              .toList();
        }
        return agents;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveAgent(Map<String, dynamic> agent) async {
    try {
      final box = await Hive.openBox(_agentsBox);
      await box.put('agent_${agent['id']}', jsonEncode(agent));
    } catch (e) {
      throw CacheException(message: 'Agentni saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getAgent(String agentId) async {
    try {
      final box = await Hive.openBox(_agentsBox);
      final data = box.get('agent_$agentId');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ RESTRICTIONS ============

  @override
  Future<void> cacheRestrictions(
      List<Map<String, dynamic>> restrictions) async {
    try {
      final box = await Hive.openBox(_restrictionsBox);
      await box.put('restrictions_list', jsonEncode(restrictions));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Cheklovlarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedRestrictions() async {
    try {
      final box = await Hive.openBox(_restrictionsBox);
      final data = box.get('restrictions_list');
      if (data != null)
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveRestriction(Map<String, dynamic> restriction) async {
    try {
      final box = await Hive.openBox(_restrictionsBox);
      await box.put(
          'restriction_${restriction['agent_id']}', jsonEncode(restriction));
    } catch (e) {
      throw CacheException(message: 'Cheklovni saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getRestriction(String agentId) async {
    try {
      final box = await Hive.openBox(_restrictionsBox);
      final data = box.get('restriction_$agentId');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ DISCOUNT POLICY ============

  @override
  Future<void> cacheDiscountPolicy(Map<String, dynamic> policy) async {
    try {
      final box = await Hive.openBox(_discountsBox);
      await box.put('policy', jsonEncode(policy));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Siyosatni saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedDiscountPolicy() async {
    try {
      final box = await Hive.openBox(_discountsBox);
      final data = box.get('policy');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ ALERTS ============

  @override
  Future<void> cacheAlerts(List<Map<String, dynamic>> alerts) async {
    try {
      final box = await Hive.openBox(_alertsBox);
      await box.put('alerts_list', jsonEncode(alerts));
    } catch (e) {
      throw CacheException(message: 'Ogohlantirishlarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedAlerts() async {
    try {
      final box = await Hive.openBox(_alertsBox);
      final data = box.get('alerts_list');
      if (data != null)
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============ AUDIT LOG ============

  @override
  Future<void> cacheAuditLog(List<Map<String, dynamic>> logs) async {
    try {
      final box = await Hive.openBox(_auditBox);
      await box.put('audit_log', jsonEncode(logs));
    } catch (e) {
      throw CacheException(message: 'Audit logni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedAuditLog() async {
    try {
      final box = await Hive.openBox(_auditBox);
      final data = box.get('audit_log');
      if (data != null)
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============ SYNC ============

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final box = await Hive.openBox(_dashboardBox);
      final time = box.get('cached_at');
      if (time != null) return DateTime.parse(time);
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveLastSyncTime() async {
    try {
      final box = await Hive.openBox(_dashboardBox);
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      // Silent fail
    }
  }

  // ============ CLEAR ============

  @override
  Future<void> clearAll() async {
    try {
      await Hive.openBox(_dashboardBox).then((b) => b.clear());
      await Hive.openBox(_settingsBox).then((b) => b.clear());
      await Hive.openBox(_agentsBox).then((b) => b.clear());
      await Hive.openBox(_restrictionsBox).then((b) => b.clear());
      await Hive.openBox(_discountsBox).then((b) => b.clear());
      await Hive.openBox(_alertsBox).then((b) => b.clear());
      await Hive.openBox(_auditBox).then((b) => b.clear());
    } catch (e) {
      throw CacheException(message: 'Tozalashda xatolik');
    }
  }
}
