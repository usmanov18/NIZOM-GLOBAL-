import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// SUPERVISOR LOCAL DATASOURCE
// ============================================================

abstract class SupervisorLocalDataSource {
  Future<void> cacheDashboard(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedDashboard();
  Future<void> cacheAgents(List<Map<String, dynamic>> agents);
  Future<List<Map<String, dynamic>>> getCachedAgents();
  Future<void> cacheTasks(List<Map<String, dynamic>> tasks);
  Future<List<Map<String, dynamic>>> getCachedTasks();
  Future<void> cacheSchedule(Map<String, dynamic> schedule, String agentId);
  Future<Map<String, dynamic>?> getCachedSchedule(String agentId);
  Future<DateTime?> getLastSyncTime();
  Future<void> saveLastSyncTime();
  Future<void> clearAll();
}

class SupervisorLocalDataSourceImpl implements SupervisorLocalDataSource {
  static const String _dashboardBox = 'supervisor_dashboard';
  static const String _agentsBox = 'supervisor_agents';
  static const String _tasksBox = 'supervisor_tasks';
  static const String _scheduleBox = 'supervisor_schedule';

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

  @override
  Future<void> cacheAgents(List<Map<String, dynamic>> agents) async {
    try {
      final box = await Hive.openBox(_agentsBox);
      await box.put('agents_list', jsonEncode(agents));
    } catch (e) {
      throw CacheException(message: 'Agentlarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedAgents() async {
    try {
      final box = await Hive.openBox(_agentsBox);
      final data = box.get('agents_list');
      if (data != null)
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheTasks(List<Map<String, dynamic>> tasks) async {
    try {
      final box = await Hive.openBox(_tasksBox);
      await box.put('tasks_list', jsonEncode(tasks));
    } catch (e) {
      throw CacheException(message: 'Vazifalarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedTasks() async {
    try {
      final box = await Hive.openBox(_tasksBox);
      final data = box.get('tasks_list');
      if (data != null)
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheSchedule(
      Map<String, dynamic> schedule, String agentId) async {
    try {
      final box = await Hive.openBox(_scheduleBox);
      await box.put('schedule_$agentId', jsonEncode(schedule));
    } catch (e) {
      throw CacheException(message: 'Jadvalni saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedSchedule(String agentId) async {
    try {
      final box = await Hive.openBox(_scheduleBox);
      final data = box.get('schedule_$agentId');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

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

  @override
  Future<void> clearAll() async {
    try {
      await Hive.openBox(_dashboardBox).then((b) => b.clear());
      await Hive.openBox(_agentsBox).then((b) => b.clear());
      await Hive.openBox(_tasksBox).then((b) => b.clear());
      await Hive.openBox(_scheduleBox).then((b) => b.clear());
    } catch (e) {
      throw CacheException(message: 'Tozalashda xatolik');
    }
  }
}
