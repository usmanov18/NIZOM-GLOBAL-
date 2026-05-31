import 'dart:convert';
import 'package:hive/hive.dart';

// ============================================================
// ORDER LOCAL STORAGE SERVICE
// Agent buyurtmalarini 1 oy saqlash va kuzatish
// ============================================================

class OrderLocalStorageService {
  static const String _boxName = 'agent_orders';
  static const String _syncLogBox = 'sync_logs';
  static const int _retentionDays = 30; // 1 oy

  // ============ BUYURTMA SAQLASH ============

  /// Buyurtmani local ga saqlash
  Future<void> saveOrder(Map<String, dynamic> order) async {
    final box = await Hive.openBox(_boxName);
    final orderId = order['id'];

    // Mavjud buyurtmani olish
    final existing = box.get(orderId);

    if (existing != null) {
      // Yangilash - eski versiyani saqlash
      final existingData = jsonDecode(existing);
      final versions = List<Map<String, dynamic>>.from(
        existingData['versions'] ?? [existingData],
      );

      // Farq yaratish
      final diff = _createDiff(existingData, order);

      versions.add({
        ...order,
        'savedAt': DateTime.now().toIso8601String(),
        'diff': diff,
      });

      await box.put(
          orderId,
          jsonEncode({
            ...order,
            'versions': versions,
            'lastModified': DateTime.now().toIso8601String(),
            'version': versions.length,
          }));
    } else {
      // Yangi buyurtma
      await box.put(
          orderId,
          jsonEncode({
            ...order,
            'versions': [order],
            'savedAt': DateTime.now().toIso8601String(),
            'lastModified': DateTime.now().toIso8601String(),
            'version': 1,
            'source': 'local', // local, 1c, sap
          }));
    }
  }

  /// Buyurtmani olish
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    final box = await Hive.openBox(_boxName);
    final data = box.get(orderId);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  /// Barcha buyurtmalarni olish
  Future<List<Map<String, dynamic>>> getAllOrders({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? customerId,
  }) async {
    final box = await Hive.openBox(_boxName);
    final orders = <Map<String, dynamic>>[];

    for (var i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null) {
        final order = jsonDecode(data);

        // Filtr
        if (status != null && order['status'] != status) continue;
        if (customerId != null && order['customerId'] != customerId) continue;
        if (fromDate != null) {
          final orderDate = DateTime.parse(order['createdAt']);
          if (orderDate.isBefore(fromDate)) continue;
        }
        if (toDate != null) {
          final orderDate = DateTime.parse(order['createdAt']);
          if (orderDate.isAfter(toDate)) continue;
        }

        orders.add(order);
      }
    }

    // Sana bo'yicha saralash (yangi birinchi)
    orders.sort((a, b) => DateTime.parse(b['createdAt'])
        .compareTo(DateTime.parse(a['createdAt'])));

    return orders;
  }

  /// Agent buyurtmalari (oxirgi 1 oy)
  Future<List<Map<String, dynamic>>> getAgentOrders(String agentId) async {
    final oneMonthAgo =
        DateTime.now().subtract(const Duration(days: _retentionDays));
    return getAllOrders(fromDate: oneMonthAgo);
  }

  /// Sinxronlanmagan buyurtmalar
  Future<List<Map<String, dynamic>>> getUnsyncedOrders() async {
    final box = await Hive.openBox(_boxName);
    final orders = <Map<String, dynamic>>[];

    for (var i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null) {
        final order = jsonDecode(data);
        final isSyncedTo1C = order['externalId1C'] != null &&
            (order['externalId1C'] as String).isNotEmpty;
        final isSyncedToSAP = order['externalIdSAP'] != null &&
            (order['externalIdSAP'] as String).isNotEmpty;

        if (!isSyncedTo1C || !isSyncedToSAP) {
          orders.add(order);
        }
      }
    }

    return orders;
  }

  // ============ O'ZGARISHLARNI KUZATISH ============

  /// 1C/SAP dan kelgan ma'lumotni solishtirish
  Future<OrderComparisonResult> compareWithExternal({
    required String orderId,
    required Map<String, dynamic> externalData,
    required String source, // '1c' yoki 'sap'
  }) async {
    final localOrder = await getOrder(orderId);

    if (localOrder == null) {
      return OrderComparisonResult(
        orderId: orderId,
        source: source,
        hasLocal: false,
        hasExternal: true,
        hasDifferences: true,
        differences: ['Buyurtma local da topilmadi'],
        externalData: externalData,
        localData: null,
      );
    }

    // Farqlarni topish
    final differences = _findDifferences(localOrder, externalData);

    return OrderComparisonResult(
      orderId: orderId,
      source: source,
      hasLocal: true,
      hasExternal: true,
      hasDifferences: differences.isNotEmpty,
      differences: differences,
      externalData: externalData,
      localData: localOrder,
    );
  }

  /// Farqlarni topish
  List<String> _findDifferences(
    Map<String, dynamic> local,
    Map<String, dynamic> external,
  ) {
    final differences = <String>[];

    // Status farqi
    if (local['status'] != external['status']) {
      differences.add(
        'Holat: ${local['status']} → ${external['status']}',
      );
    }

    // Summa farqi
    final localAmount = (local['totalAmount'] ?? 0).toDouble();
    final externalAmount = (external['totalAmount'] ?? 0).toDouble();
    if ((localAmount - externalAmount).abs() > 0.01) {
      differences.add(
        'Summa: $localAmount → $externalAmount',
      );
    }

    // Elementlar soni farqi
    final localItems = (local['items'] as List?)?.length ?? 0;
    final externalItems = (external['items'] as List?)?.length ?? 0;
    if (localItems != externalItems) {
      differences.add(
        'Mahsulotlar soni: $localItems → $externalItems',
      );
    }

    // Har bir elementni solishtirish
    final localItemsList = local['items'] as List? ?? [];
    final externalItemsList = external['items'] as List? ?? [];

    for (int i = 0;
        i < localItemsList.length && i < externalItemsList.length;
        i++) {
      final localItem = localItemsList[i];
      final externalItem = externalItemsList[i];

      // Miqdor farqi
      final localQty = (localItem['quantity'] ?? 0).toDouble();
      final externalQty = (externalItem['quantity'] ?? 0).toDouble();
      if ((localQty - externalQty).abs() > 0.01) {
        differences.add(
          'Element ${i + 1} miqdori: $localQty → $externalQty',
        );
      }

      // Narx farqi
      final localPrice = (localItem['unitPrice'] ?? 0).toDouble();
      final externalPrice = (externalItem['unitPrice'] ?? 0).toDouble();
      if ((localPrice - externalPrice).abs() > 0.01) {
        differences.add(
          'Element ${i + 1} narxi: $localPrice → $externalPrice',
        );
      }

      // Chegirma farqi
      final localDiscount = (localItem['discountPercent'] ?? 0).toDouble();
      final externalDiscount =
          (externalItem['discountPercent'] ?? 0).toDouble();
      if ((localDiscount - externalDiscount).abs() > 0.01) {
        differences.add(
          'Element ${i + 1} chegirma: $localDiscount% → $externalDiscount%',
        );
      }
    }

    return differences;
  }

  /// Farq yaratish (versiyalar uchun)
  Map<String, dynamic> _createDiff(
    Map<String, dynamic> old,
    Map<String, dynamic> newOrder,
  ) {
    final diff = <String, dynamic>{};

    if (old['status'] != newOrder['status']) {
      diff['status'] = {'old': old['status'], 'new': newOrder['status']};
    }
    if (old['totalAmount'] != newOrder['totalAmount']) {
      diff['totalAmount'] = {
        'old': old['totalAmount'],
        'new': newOrder['totalAmount']
      };
    }
    if (old['paidAmount'] != newOrder['paidAmount']) {
      diff['paidAmount'] = {
        'old': old['paidAmount'],
        'new': newOrder['paidAmount']
      };
    }

    return diff;
  }

  // ============ SINXRONLASH LOGI ============

  /// Sinxronlash logini saqlash
  Future<void> saveSyncLog(Map<String, dynamic> log) async {
    final box = await Hive.openBox(_syncLogBox);
    final logs = List<Map<String, dynamic>>.from(
      (box.get('logs') as List?)?.map((l) => jsonDecode(l)) ?? [],
    );

    logs.insert(0, {
      ...log,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Oxirgi 1000 ta log saqlash
    if (logs.length > 1000) {
      logs.removeRange(1000, logs.length);
    }

    await box.put('logs', jsonEncode(logs));
  }

  /// Sinxronlash loglarini olish
  Future<List<Map<String, dynamic>>> getSyncLogs({
    String? orderId,
    String? source,
    int limit = 50,
  }) async {
    final box = await Hive.openBox(_syncLogBox);
    final logs = List<Map<String, dynamic>>.from(
      (box.get('logs') as List?)?.map((l) => jsonDecode(l)) ?? [],
    );

    var filtered = logs;
    if (orderId != null) {
      filtered = filtered.where((l) => l['orderId'] == orderId).toList();
    }
    if (source != null) {
      filtered = filtered.where((l) => l['source'] == source).toList();
    }

    return filtered.take(limit).toList();
  }

  // ============ TOZALASH ============

  /// Eski buyurtmalarni tozalash (1 oydan eski)
  Future<int> cleanOldOrders() async {
    final box = await Hive.openBox(_boxName);
    final cutoffDate =
        DateTime.now().subtract(const Duration(days: _retentionDays));
    int deletedCount = 0;

    final keysToDelete = <dynamic>[];

    for (var i = 0; i < box.length; i++) {
      final key = box.keyAt(i);
      final data = box.get(key);
      if (data != null) {
        final order = jsonDecode(data);
        final createdAt = DateTime.parse(order['createdAt']);
        if (createdAt.isBefore(cutoffDate)) {
          keysToDelete.add(key);
        }
      }
    }

    for (final key in keysToDelete) {
      await box.delete(key);
      deletedCount++;
    }

    return deletedCount;
  }

  /// Barcha ma'lumotlarni tozalash
  Future<void> clearAll() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}

// ============ SOLISHTIRISH NATIJASI ============

class OrderComparisonResult {
  final String orderId;
  final String source;
  final bool hasLocal;
  final bool hasExternal;
  final bool hasDifferences;
  final List<String> differences;
  final Map<String, dynamic>? externalData;
  final Map<String, dynamic>? localData;

  const OrderComparisonResult({
    required this.orderId,
    required this.source,
    required this.hasLocal,
    required this.hasExternal,
    required this.hasDifferences,
    required this.differences,
    this.externalData,
    this.localData,
  });

  bool get isOnlyLocal => hasLocal && !hasExternal;
  bool get isOnlyExternal => !hasLocal && hasExternal;
  bool get isInSync => hasLocal && hasExternal && !hasDifferences;
}
