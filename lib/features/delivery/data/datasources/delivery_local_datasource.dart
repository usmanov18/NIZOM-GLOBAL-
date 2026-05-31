import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// DELIVERY LOCAL DATASOURCE - Offline ma'lumotlar saqlash
// ============================================================

abstract class DeliveryLocalDataSource {
  // Dashboard
  Future<void> cacheDriverStatus(Map<String, dynamic> status);
  Future<Map<String, dynamic>?> getCachedDriverStatus();

  // Deliveries
  Future<void> cacheDeliveries(List<Map<String, dynamic>> deliveries);
  Future<List<Map<String, dynamic>>> getCachedDeliveries({String? status});
  Future<void> saveDelivery(Map<String, dynamic> delivery);
  Future<Map<String, dynamic>?> getDelivery(String deliveryId);
  Future<void> updateDeliveryStatus(String deliveryId, String status);

  // Route
  Future<void> cacheRoute(Map<String, dynamic> route);
  Future<Map<String, dynamic>?> getCachedRoute();

  // GPS Track
  Future<void> saveLocationPoint(Map<String, dynamic> point);
  Future<List<Map<String, dynamic>>> getDailyTrack(DateTime date);
  Future<void> clearOldTracks({int daysOld = 7});

  // Pending actions (offline)
  Future<void> savePendingAction(Map<String, dynamic> action);
  Future<List<Map<String, dynamic>>> getPendingActions();
  Future<void> removePendingAction(String actionId);

  // Sync
  Future<DateTime?> getLastSyncTime();
  Future<void> saveLastSyncTime();

  // Clear
  Future<void> clearAll();
}

class DeliveryLocalDataSourceImpl implements DeliveryLocalDataSource {
  static const String _statusBox = 'delivery_status';
  static const String _deliveriesBox = 'delivery_orders';
  static const String _routeBox = 'delivery_route';
  static const String _trackBox = 'delivery_track';
  static const String _pendingBox = 'delivery_pending';

  // ============ DASHBOARD ============

  @override
  Future<void> cacheDriverStatus(Map<String, dynamic> status) async {
    try {
      final box = await Hive.openBox(_statusBox);
      await box.put('driver_status', jsonEncode(status));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Haydovchi holati saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedDriverStatus() async {
    try {
      final box = await Hive.openBox(_statusBox);
      final data = box.get('driver_status');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ DELIVERIES ============

  @override
  Future<void> cacheDeliveries(List<Map<String, dynamic>> deliveries) async {
    try {
      final box = await Hive.openBox(_deliveriesBox);
      await box.put('deliveries_list', jsonEncode(deliveries));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Yetkazishlarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedDeliveries(
      {String? status}) async {
    try {
      final box = await Hive.openBox(_deliveriesBox);
      final data = box.get('deliveries_list');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        var deliveries = decoded.cast<Map<String, dynamic>>();
        if (status != null) {
          deliveries = deliveries.where((d) => d['status'] == status).toList();
        }
        return deliveries;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveDelivery(Map<String, dynamic> delivery) async {
    try {
      final box = await Hive.openBox(_deliveriesBox);
      await box.put('delivery_${delivery['id']}', jsonEncode(delivery));
    } catch (e) {
      throw CacheException(message: 'Yetkazish saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getDelivery(String deliveryId) async {
    try {
      final box = await Hive.openBox(_deliveriesBox);
      final data = box.get('delivery_$deliveryId');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateDeliveryStatus(String deliveryId, String status) async {
    try {
      final delivery = await getDelivery(deliveryId);
      if (delivery != null) {
        delivery['status'] = status;
        delivery['updated_at'] = DateTime.now().toIso8601String();
        await saveDelivery(delivery);
      }
    } catch (e) {
      throw CacheException(message: 'Holat yangilashda xatolik');
    }
  }

  // ============ ROUTE ============

  @override
  Future<void> cacheRoute(Map<String, dynamic> route) async {
    try {
      final box = await Hive.openBox(_routeBox);
      await box.put('route', jsonEncode(route));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Marshrutni saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedRoute() async {
    try {
      final box = await Hive.openBox(_routeBox);
      final data = box.get('route');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ GPS TRACK ============

  @override
  Future<void> saveLocationPoint(Map<String, dynamic> point) async {
    try {
      final box = await Hive.openBox(_trackBox);
      final dateKey = point['timestamp'].toString().substring(0, 10);
      final existing = box.get(dateKey);
      final List<dynamic> points = existing != null ? jsonDecode(existing) : [];
      points.add(point);
      await box.put(dateKey, jsonEncode(points));
    } catch (e) {
      // GPS xatoliklari jimjitlik bilan o'tkaziladi
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyTrack(DateTime date) async {
    try {
      final box = await Hive.openBox(_trackBox);
      final dateKey = date.toIso8601String().substring(0, 10);
      final data = box.get(dateKey);
      if (data != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearOldTracks({int daysOld = 7}) async {
    try {
      final box = await Hive.openBox(_trackBox);
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      final keysToDelete = <dynamic>[];
      for (final key in box.keys) {
        if (key is String && key.length == 10) {
          final date = DateTime.tryParse(key);
          if (date != null && date.isBefore(cutoffDate)) {
            keysToDelete.add(key);
          }
        }
      }

      for (final key in keysToDelete) {
        await box.delete(key);
      }
    } catch (e) {
      // Silent fail
    }
  }

  // ============ PENDING ACTIONS ============

  @override
  Future<void> savePendingAction(Map<String, dynamic> action) async {
    try {
      final box = await Hive.openBox(_pendingBox);
      final actions = List<String>.from(box.get('actions') ?? []);
      actions.add(jsonEncode({
        ...action,
        'created_at': DateTime.now().toIso8601String(),
      }));
      await box.put('actions', actions);
    } catch (e) {
      throw CacheException(message: 'Harakat saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingActions() async {
    try {
      final box = await Hive.openBox(_pendingBox);
      final actions = List<String>.from(box.get('actions') ?? []);
      return actions.map((a) => jsonDecode(a) as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> removePendingAction(String actionId) async {
    try {
      final box = await Hive.openBox(_pendingBox);
      final actions = List<String>.from(box.get('actions') ?? []);
      actions.removeWhere((a) {
        final decoded = jsonDecode(a);
        return decoded['id'] == actionId;
      });
      await box.put('actions', actions);
    } catch (e) {
      // Silent fail
    }
  }

  // ============ SYNC ============

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final box = await Hive.openBox(_deliveriesBox);
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
      final box = await Hive.openBox(_deliveriesBox);
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      // Silent fail
    }
  }

  // ============ CLEAR ============

  @override
  Future<void> clearAll() async {
    try {
      await Hive.openBox(_statusBox).then((b) => b.clear());
      await Hive.openBox(_deliveriesBox).then((b) => b.clear());
      await Hive.openBox(_routeBox).then((b) => b.clear());
      await Hive.openBox(_trackBox).then((b) => b.clear());
      await Hive.openBox(_pendingBox).then((b) => b.clear());
    } catch (e) {
      throw CacheException(message: 'Tozalashda xatolik');
    }
  }
}
