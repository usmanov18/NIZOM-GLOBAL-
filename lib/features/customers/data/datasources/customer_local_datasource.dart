import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// CUSTOMER LOCAL DATASOURCE - Offline mijozlar saqlash
// ============================================================

abstract class CustomerLocalDataSource {
  // Customers
  Future<void> cacheCustomers(List<Map<String, dynamic>> customers);
  Future<List<Map<String, dynamic>>> getCachedCustomers({
    String? search,
    String? agentId,
  });
  Future<void> saveCustomer(Map<String, dynamic> customer);
  Future<Map<String, dynamic>?> getCustomer(String customerId);

  // Agent Profile
  Future<void> cacheAgentProfile(Map<String, dynamic> profile);
  Future<Map<String, dynamic>?> getCachedAgentProfile();

  // Orders & Payments
  Future<void> cacheCustomerOrders(
    String customerId,
    List<Map<String, dynamic>> orders,
  );
  Future<List<Map<String, dynamic>>> getCachedCustomerOrders(String customerId);

  Future<void> cacheCustomerPayments(
    String customerId,
    List<Map<String, dynamic>> payments,
  );
  Future<List<Map<String, dynamic>>> getCachedCustomerPayments(
      String customerId);

  // Sync
  Future<DateTime?> getLastSyncTime();
  Future<void> saveLastSyncTime();

  // Clear
  Future<void> clearAll();
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  static const String _customersBox = 'customers';
  static const String _agentBox = 'agent_profile';
  static const String _ordersBox = 'customer_orders';
  static const String _paymentsBox = 'customer_payments';

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
  Future<List<Map<String, dynamic>>> getCachedCustomers({
    String? search,
    String? agentId,
  }) async {
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
                      .contains(search.toLowerCase()) ||
                  (c['phone'] ?? '').toString().contains(search))
              .toList();
        }

        if (agentId != null) {
          customers = customers.where((c) => c['agent_id'] == agentId).toList();
        }

        return customers;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveCustomer(Map<String, dynamic> customer) async {
    try {
      final box = await Hive.openBox(_customersBox);
      await box.put('customer_${customer['id']}', jsonEncode(customer));
    } catch (e) {
      throw CacheException(message: 'Mijozni saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCustomer(String customerId) async {
    try {
      final box = await Hive.openBox(_customersBox);
      final data = box.get('customer_$customerId');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheAgentProfile(Map<String, dynamic> profile) async {
    try {
      final box = await Hive.openBox(_agentBox);
      await box.put('profile', jsonEncode(profile));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Agent profilini saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedAgentProfile() async {
    try {
      final box = await Hive.openBox(_agentBox);
      final data = box.get('profile');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheCustomerOrders(
    String customerId,
    List<Map<String, dynamic>> orders,
  ) async {
    try {
      final box = await Hive.openBox(_ordersBox);
      await box.put('orders_$customerId', jsonEncode(orders));
    } catch (e) {
      throw CacheException(message: 'Buyurtmalarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedCustomerOrders(
      String customerId) async {
    try {
      final box = await Hive.openBox(_ordersBox);
      final data = box.get('orders_$customerId');
      if (data != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheCustomerPayments(
    String customerId,
    List<Map<String, dynamic>> payments,
  ) async {
    try {
      final box = await Hive.openBox(_paymentsBox);
      await box.put('payments_$customerId', jsonEncode(payments));
    } catch (e) {
      throw CacheException(message: 'To\'lovlarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedCustomerPayments(
      String customerId) async {
    try {
      final box = await Hive.openBox(_paymentsBox);
      final data = box.get('payments_$customerId');
      if (data != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final box = await Hive.openBox(_customersBox);
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
      final box = await Hive.openBox(_customersBox);
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await Hive.openBox(_customersBox).then((b) => b.clear());
      await Hive.openBox(_agentBox).then((b) => b.clear());
      await Hive.openBox(_ordersBox).then((b) => b.clear());
      await Hive.openBox(_paymentsBox).then((b) => b.clear());
    } catch (e) {
      throw CacheException(message: 'Tozalashda xatolik');
    }
  }
}
