import 'dart:async';
import 'one_c_api_client.dart';
import '../sap/sap_api_client.dart';

// ============================================================
// 1C & SAP SYNC SERVICE - Professional sinxronlash
// ============================================================

class OneCSAPSyncService {
  final OneCAPIClient oneCClient;
  final SAPAPIClient sapClient;

  final StreamController<SyncProgress> _progressController =
      StreamController<SyncProgress>.broadcast();

  Stream<SyncProgress> get progressStream => _progressController.stream;

  OneCSAPSyncService({
    required this.oneCClient,
    required this.sapClient,
  });

  // ============ FULL SYNC ============

  /// Barcha ma'lumotlarni sinxronlash
  Future<SyncResult> syncAll({
    required String agentCode,
    DateTime? sinceDate,
  }) async {
    final startTime = DateTime.now();
    final errors = <String>[];
    int totalSynced = 0;

    try {
      // 1. Mijozlar
      _emitProgress('Mijozlar yuklanmoqda...', 0.1);
      final customersResult = await _syncCustomers(agentCode, sinceDate);
      totalSynced += customersResult.item1;
      errors.addAll(customersResult.item2);

      // 2. Mahsulotlar
      _emitProgress('Mahsulotlar yuklanmoqda...', 0.25);
      final productsResult = await _syncProducts(sinceDate);
      totalSynced += productsResult.item1;
      errors.addAll(productsResult.item2);

      // 3. Kategoriyalar
      _emitProgress('Kategoriyalar yuklanmoqda...', 0.35);
      final categoriesResult = await _syncCategories();
      totalSynced += categoriesResult.item1;
      errors.addAll(categoriesResult.item2);

      // 4. Narxlar
      _emitProgress('Narxlar yuklanmoqda...', 0.5);
      final pricesResult = await _syncPrices();
      totalSynced += pricesResult.item1;
      errors.addAll(pricesResult.item2);

      // 5. Ombor qoldiqlari
      _emitProgress('Ombor qoldiqlari yuklanmoqda...', 0.65);
      final stockResult = await _syncStock();
      totalSynced += stockResult.item1;
      errors.addAll(stockResult.item2);

      // 6. Chegirmalar
      _emitProgress('Chegirmalar yuklanmoqda...', 0.8);
      final discountsResult = await _syncDiscounts();
      totalSynced += discountsResult.item1;
      errors.addAll(discountsResult.item2);

      // 7. Promolar
      _emitProgress('Promolar yuklanmoqda...', 0.9);
      final promotionsResult = await _syncPromotions();
      totalSynced += promotionsResult.item1;
      errors.addAll(promotionsResult.item2);

      _emitProgress('Sinxronlash tugadi!', 1.0);

      return SyncResult(
        success: errors.isEmpty,
        totalSynced: totalSynced,
        errors: errors,
        duration: DateTime.now().difference(startTime),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SyncResult(
        success: false,
        totalSynced: totalSynced,
        errors: [...errors, 'Umumiy xatolik: $e'],
        duration: DateTime.now().difference(startTime),
        timestamp: DateTime.now(),
      );
    }
  }

  // ============ CUSTOMERS SYNC ============

  Future<SyncTuple> _syncCustomers(
      String agentCode, DateTime? sinceDate) async {
    int count = 0;
    final errors = <String>[];

    try {
      // 1C dan mijozlar
      final customers1C = await oneCClient.getAgentCustomers(
        agentCode: agentCode,
        sinceDate: sinceDate,
      );
      customers1C.fold((failure) => errors.add(failure.message),
          (items) => count += items.length);
    } catch (e) {
      errors.add('1C mijozlar: $e');
    }

    try {
      // SAP dan mijozlar
      final customersSAP = await sapClient.getAgentCustomers(
        salesPerson: agentCode,
        sinceDate: sinceDate,
      );
      customersSAP.fold((failure) => errors.add(failure.message),
          (items) => count += items.length);
    } catch (e) {
      errors.add('SAP mijozlar: $e');
    }

    return SyncTuple(count, errors);
  }

  // ============ PRODUCTS SYNC ============

  Future<SyncTuple> _syncProducts(DateTime? sinceDate) async {
    int count = 0;
    final errors = <String>[];

    try {
      final products1C = await oneCClient.getProducts();
      products1C.fold((failure) => errors.add(failure.message),
          (items) => count += items.length);
    } catch (e) {
      errors.add('1C mahsulotlar: $e');
    }

    try {
      final productsSAP = await sapClient.getProducts();
      productsSAP.fold((failure) => errors.add(failure.message),
          (items) => count += items.length);
    } catch (e) {
      errors.add('SAP mahsulotlar: $e');
    }

    return SyncTuple(count, errors);
  }

  // ============ CATEGORIES SYNC ============

  Future<SyncTuple> _syncCategories() async {
    int count = 0;
    final errors = <String>[];
    final categories = <String>{};

    try {
      final products1C = await oneCClient.getProducts();
      products1C.fold(
        (failure) => errors.add(failure.message),
        (items) => categories.addAll(items
            .map((item) =>
                (item['category'] ?? item['category_name'] ?? '').toString())
            .where((value) => value.isNotEmpty)),
      );
    } catch (e) {
      errors.add('1C kategoriyalar: $e');
    }

    try {
      final productsSAP = await sapClient.getProducts();
      productsSAP.fold(
        (failure) => errors.add(failure.message),
        (items) => categories.addAll(items
            .map((item) =>
                (item['MaterialGroup'] ?? item['category'] ?? '').toString())
            .where((value) => value.isNotEmpty)),
      );
    } catch (e) {
      errors.add('SAP kategoriyalar: $e');
    }

    count = categories.length;
    return SyncTuple(count, errors);
  }

  // ============ PRICES SYNC ============

  Future<SyncTuple> _syncPrices() async {
    int count = 0;
    final errors = <String>[];

    try {
      final specialPrices = await oneCClient.getSpecialPrices();
      specialPrices.fold((failure) => errors.add(failure.message),
          (items) => count += items.length);
    } catch (e) {
      errors.add('1C narxlar: $e');
    }

    try {
      final sapPrices = await sapClient.getPriceList(
          salesOrganization: '1000', distributionChannel: '10');
      sapPrices.fold((failure) => errors.add(failure.message),
          (items) => count += items.length);
    } catch (e) {
      errors.add('SAP narxlar: $e');
    }

    return SyncTuple(count, errors);
  }

  // ============ STOCK SYNC ============

  Future<SyncTuple> _syncStock() async {
    int count = 0;
    final errors = <String>[];

    try {
      final stock1C =
          await oneCClient.getStockBalance(warehouseRefKey: 'warehouse_1');
      stock1C.fold((failure) => errors.add(failure.message),
          (items) => count += items.length);
    } catch (e) {
      errors.add('1C ombor: $e');
    }

    try {
      final stockSAP = await sapClient.getStockBalance(plant: '1000');
      stockSAP.fold((failure) => errors.add(failure.message),
          (items) => count += items.length);
    } catch (e) {
      errors.add('SAP ombor: $e');
    }

    return SyncTuple(count, errors);
  }

  // ============ DISCOUNTS SYNC ============

  Future<SyncTuple> _syncDiscounts() async {
    int count = 0;
    final errors = <String>[];

    try {
      final discounts = await oneCClient.getActiveDiscounts();
      discounts.fold((failure) => errors.add(failure.message),
          (items) => count += items.length);
    } catch (e) {
      errors.add('1C chegirmalar: $e');
    }

    return SyncTuple(count, errors);
  }

  // ============ PROMOTIONS SYNC ============

  Future<SyncTuple> _syncPromotions() async {
    int count = 0;
    final errors = <String>[];

    try {
      final promotions = await oneCClient.getActivePromotions();
      promotions.fold((failure) => errors.add(failure.message),
          (items) => count += items.length);
    } catch (e) {
      errors.add('1C promolar: $e');
    }

    return SyncTuple(count, errors);
  }

  // ============ HELPERS ============

  void _emitProgress(String message, double progress) {
    _progressController.add(SyncProgress(
      message: message,
      progress: progress,
      timestamp: DateTime.now(),
    ));
  }

  void dispose() {
    _progressController.close();
  }
}

// ============ MODELS ============

class SyncProgress {
  final String message;
  final double progress;
  final DateTime timestamp;

  SyncProgress({
    required this.message,
    required this.progress,
    required this.timestamp,
  });
}

class SyncResult {
  final bool success;
  final int totalSynced;
  final List<String> errors;
  final Duration duration;
  final DateTime timestamp;

  const SyncResult({
    required this.success,
    required this.totalSynced,
    required this.errors,
    required this.duration,
    required this.timestamp,
  });
}

class SyncTuple {
  final int item1;
  final List<String> item2;
  const SyncTuple(this.item1, this.item2);
}
