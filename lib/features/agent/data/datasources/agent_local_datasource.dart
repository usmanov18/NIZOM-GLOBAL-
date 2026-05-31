import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// AGENT LOCAL DATASOURCE - Offline ma'lumotlar saqlash
// ============================================================

abstract class AgentLocalDataSource {
  // Dashboard
  Future<void> cacheDashboard(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedDashboard();

  // Orders
  Future<void> cacheOrders(List<Map<String, dynamic>> orders);
  Future<List<Map<String, dynamic>>> getCachedOrders({String? status});
  Future<void> saveOrder(Map<String, dynamic> order);
  Future<Map<String, dynamic>?> getOrder(String orderId);
  Future<void> deleteOrder(String orderId);
  Future<List<Map<String, dynamic>>> getPendingOrders();

  // Customers
  Future<void> cacheCustomers(List<Map<String, dynamic>> customers);
  Future<List<Map<String, dynamic>>> getCachedCustomers({String? search});

  // Visits
  Future<void> cacheVisits(List<Map<String, dynamic>> visits);
  Future<List<Map<String, dynamic>>> getCachedVisits({DateTime? date});

  // KPI
  Future<void> cacheKPI(Map<String, dynamic> data, String period);
  Future<Map<String, dynamic>?> getCachedKPI(String period);

  // Daily Report
  Future<void> cacheDailyReport(Map<String, dynamic> data, String date);
  Future<Map<String, dynamic>?> getCachedDailyReport(String date);

  // Sync
  Future<DateTime?> getLastSyncTime();
  Future<void> saveLastSyncTime();

  // Clear
  Future<void> clearAll();
}

class AgentLocalDataSourceImpl implements AgentLocalDataSource {
  static const String _dashboardBox = 'agent_dashboard';
  static const String _ordersBox = 'agent_orders';
  static const String _customersBox = 'agent_customers';
  static const String _visitsBox = 'agent_visits';
  static const String _kpiBox = 'agent_kpi';
  static const String _reportsBox = 'agent_reports';

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
      if (data != null) {
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ ORDERS ============

  @override
  Future<void> cacheOrders(List<Map<String, dynamic>> orders) async {
    try {
      final box = await Hive.openBox(_ordersBox);
      await box.put('orders_list', jsonEncode(orders));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Buyurtmalarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedOrders({String? status}) async {
    try {
      final box = await Hive.openBox(_ordersBox);
      final data = box.get('orders_list');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        var orders = decoded.cast<Map<String, dynamic>>();

        if (status != null) {
          orders = orders.where((o) => o['status'] == status).toList();
        }

        return orders;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveOrder(Map<String, dynamic> order) async {
    try {
      final box = await Hive.openBox(_ordersBox);
      await box.put('order_${order['id']}', jsonEncode(order));
    } catch (e) {
      throw CacheException(message: 'Buyurtma saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final box = await Hive.openBox(_ordersBox);
      final data = box.get('order_$orderId');
      if (data != null) {
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    try {
      final box = await Hive.openBox(_ordersBox);
      await box.delete('order_$orderId');
    } catch (e) {
      throw CacheException(message: 'Buyurtmani o\'chirishda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    try {
      final box = await Hive.openBox(_ordersBox);
      final orders = <Map<String, dynamic>>[];

      for (var i = 0; i < box.length; i++) {
        final key = box.keyAt(i);
        if (key.toString().startsWith('order_')) {
          final data = box.get(key);
          if (data != null) {
            final order = jsonDecode(data);
            if (order['status'] == 'draft' || order['status'] == 'pending') {
              orders.add(order);
            }
          }
        }
      }

      return orders;
    } catch (e) {
      return [];
    }
  }

  // ============ CUSTOMERS ============

  @override
  Future<void> cacheCustomers(List<Map<String, dynamic>> customers) async {
    try {
      final box = await Hive.openBox(_customersBox);
      await box.put('customers_list', jsonEncode(customers));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Mijozlarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedCustomers(
      {String? search}) async {
    try {
      final box = await Hive.openBox(_customersBox);
      final data = box.get('customers_list');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        var customers = decoded.cast<Map<String, dynamic>>();

        if (search != null && search.isNotEmpty) {
          customers = customers
              .where((c) =>
                  c['name']
                      .toString()
                      .toLowerCase()
                      .contains(search.toLowerCase()) ||
                  c['code']
                      .toString()
                      .toLowerCase()
                      .contains(search.toLowerCase()))
              .toList();
        }

        return customers;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============ VISITS ============

  @override
  Future<void> cacheVisits(List<Map<String, dynamic>> visits) async {
    try {
      final box = await Hive.openBox(_visitsBox);
      await box.put('visits_list', jsonEncode(visits));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Tashriflarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedVisits({DateTime? date}) async {
    try {
      final box = await Hive.openBox(_visitsBox);
      final data = box.get('visits_list');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        var visits = decoded.cast<Map<String, dynamic>>();

        if (date != null) {
          final dateStr = date.toIso8601String().substring(0, 10);
          visits = visits
              .where((v) => v['scheduled_date'].toString().startsWith(dateStr))
              .toList();
        }

        return visits;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============ KPI ============

  @override
  Future<void> cacheKPI(Map<String, dynamic> data, String period) async {
    try {
      final box = await Hive.openBox(_kpiBox);
      await box.put('kpi_$period', jsonEncode(data));
    } catch (e) {
      throw CacheException(message: 'KPI saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedKPI(String period) async {
    try {
      final box = await Hive.openBox(_kpiBox);
      final data = box.get('kpi_$period');
      if (data != null) {
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ DAILY REPORT ============

  @override
  Future<void> cacheDailyReport(Map<String, dynamic> data, String date) async {
    try {
      final box = await Hive.openBox(_reportsBox);
      await box.put('report_$date', jsonEncode(data));
    } catch (e) {
      throw CacheException(message: 'Hisobotni saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedDailyReport(String date) async {
    try {
      final box = await Hive.openBox(_reportsBox);
      final data = box.get('report_$date');
      if (data != null) {
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ SYNC ============

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final box = await Hive.openBox(_dashboardBox);
      final time = box.get('cached_at');
      if (time != null) {
        return DateTime.parse(time);
      }
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
      await Hive.openBox(_ordersBox).then((b) => b.clear());
      await Hive.openBox(_customersBox).then((b) => b.clear());
      await Hive.openBox(_visitsBox).then((b) => b.clear());
      await Hive.openBox(_kpiBox).then((b) => b.clear());
      await Hive.openBox(_reportsBox).then((b) => b.clear());
    } catch (e) {
      throw CacheException(message: 'Tozalashda xatolik');
    }
  }
}
