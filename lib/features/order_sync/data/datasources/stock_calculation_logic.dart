// ============================================================
// STOCK CALCULATION LOGIC - TO'G'RILANGAN
// ============================================================
//
// ASOSIY QOIDA:
// ┌─────────────────────────────────────────────────────────┐
// │  │                                                          │
// │  │  BUYURTMA YARATILDI:                                    │
// │  │  → Ombor actual: O'ZGARMAYDI                            │
// │  │  → Ombor reserved: +miqdor (BAND)                       │
// │  │  → Mavjud = actual - reserved                           │
// │  │                                                          │
// │  │  YETKAZILDI (Проведен):                                 │
// │  │  → Ombor actual: -miqdor (KAMAYDI)                      │
// │  │  → Ombor reserved: -miqdor (BAND BEKOR)                 │
// │  │                                                          │
// │  │  BEKOR QILINDI:                                         │
// │  │  → Ombor actual: O'ZGARMAYDI                            │
// │  │  → Ombor reserved: -miqdor (BAND QAYTARILDI)            │
// │  │                                                          │
// │  │  QAYTARISH YARATILDI (operator):                        │
// │  │  → Ombor actual: O'ZGARMAYDI                            │
// │  │  → Ombor reserved: +miqdor (QAYTARISH BAND)             │
// │  │                                                          │
// │  │  QAYTARISH ПРОВЕДЕН (operator tasdiqladi):              │
// │  │  → Ombor actual: +miqdor (QAYTARILDI)                   │
// │  │  → Ombor reserved: -miqdor (BAND BEKOR)                 │
// │  │                                                          │
// │  └─────────────────────────────────────────────────────────┘
// ============================================================

import 'dart:convert';
import 'package:hive/hive.dart';

class StockCalculationLogic {
  static const String _stockBox = 'stock_data';
  static const String _reservationsBox = 'stock_reservations';

  // ============ ASOSIY FORMULA ============

  /// Mavjud miqdorni hisablash
  ///
  /// MAVJUD = ACTUAL - RESERVED
  ///
  /// ACTUAL = 1C/SAP dan kelgan haqiqiy ombor miqdori
  /// RESERVED = Ochiq buyurtmalar + Qaytarishlar (Проведен bo'lmagan)
  StockCalculation calculateAvailableStock({
    required String productId,
    required String warehouseId,
    required double actualStock, // 1C/SAP dan kelgan
  }) {
    // Barcha band qilishlarni olish
    final allReservations = _getReservations(productId, warehouseId);

    // OCHIQ buyurtmalar band qilishlari (hali yetkazilmagan)
    final orderReservations = allReservations
        .where((r) => r['type'] == 'order' && r['status'] == 'reserved')
        .toList();

    // QAYTARISH band qilishlari (hali Проведен bo'lmagan)
    final returnReservations = allReservations
        .where((r) => r['type'] == 'return' && r['status'] == 'reserved')
        .toList();

    // Buyurtmalar band qilingan miqdor
    final orderReservedQty = orderReservations.fold<double>(
        0, (sum, r) => sum + (r['quantity'] as double));

    // Qaytarishlar band qilingan miqdor
    final returnReservedQty = returnReservations.fold<double>(
        0, (sum, r) => sum + (r['quantity'] as double));

    // JAMI RESERVED
    final totalReserved = orderReservedQty + returnReservedQty;

    // MAVJUD = ACTUAL - RESERVED
    final available = actualStock - totalReserved;

    return StockCalculation(
      productId: productId,
      warehouseId: warehouseId,
      actualStock: actualStock,
      orderReservedQuantity: orderReservedQty,
      returnReservedQuantity: returnReservedQty,
      totalReservedQuantity: totalReserved,
      availableQuantity: available > 0 ? available : 0,
      isAvailable: available > 0,
    );
  }

  // ============ 1. BUYURTMA YARATILDI ============

  /// Buyurtma yaratilganda - BAND QILISH
  ///
  /// Ombor actual: O'ZGARMAYDI
  /// Ombor reserved: +miqdor
  /// Mavjud: actual - (old_reserved + new_reserved) KAMAYADI
  ReservationResult reserveForOrder({
    required String orderId,
    required String productId,
    required String warehouseId,
    required double quantity,
  }) {
    // Mavjud miqdorni tekshirish
    final stock = calculateAvailableStock(
      productId: productId,
      warehouseId: warehouseId,
      actualStock: _getActualStock(productId, warehouseId),
    );

    if (stock.availableQuantity < quantity) {
      return ReservationResult(
        success: false,
        message: 'Mavjud miqdor yetarli emas. '
            'Mavjud: ${stock.availableQuantity}, '
            'Talab: $quantity',
        availableQuantity: stock.availableQuantity,
        requestedQuantity: quantity,
      );
    }

    // Band qilish
    _saveReservation({
      'orderId': orderId,
      'productId': productId,
      'warehouseId': warehouseId,
      'quantity': quantity,
      'type': 'order', // Buyurtma turi
      'status': 'reserved',
      'createdAt': DateTime.now().toIso8601String(),
    });

    return ReservationResult(
      success: true,
      message: '$quantity miqdor buyurtma uchun band qilindi',
      availableQuantity: stock.availableQuantity - quantity,
      requestedQuantity: quantity,
    );
  }

  // ============ 2. YETKAZILDI (ПРОВЕДЕН) ============

  /// Yetkazilganda - OMBORDAN CHIQARISH
  ///
  /// Ombor actual: -miqdor (KAMAYADI)
  /// Ombor reserved: -miqdor (BAND BEKOR)
  ///
  /// SHU YERDA OMBOR KAMAYDI!
  void confirmDelivery({
    required String orderId,
    required String productId,
    required String warehouseId,
    required double deliveredQuantity,
  }) {
    // 1. Band qilishni "delivered" ga o'zgartirish
    _updateReservationStatus(orderId, productId, warehouseId, 'delivered');

    // 2. Ombor actual miqdorini KAMAYTIRISH
    _decreaseActualStock(productId, warehouseId, deliveredQuantity);

    // Bu yerda: actual -= deliveredQuantity
    // reserved -= deliveredQuantity (chunki "delivered" endi "reserved" emas)
  }

  // ============ 3. BUYURTMA BEKOR QILINDI ============

  /// Buyurtma bekor qilinganda - BAND QAYTARISH
  ///
  /// Ombor actual: O'ZGARMAYDI
  /// Ombor reserved: -miqdor (BAND QAYTARILDI)
  /// Mavjud: actual - (reserved - miqdor) OSHADI
  void cancelOrder({
    required String orderId,
    required String productId,
    required String warehouseId,
  }) {
    // Band qilishni "cancelled" ga o'zgartirish
    _updateReservationStatus(orderId, productId, warehouseId, 'cancelled');

    // actual O'ZGARMAYDI!
    // reserved KAMAYDI (chunki "cancelled" endi "reserved" emas)
  }

  // ============ 4. QAYTARISH YARATILDI (OPERATOR) ============

  /// Qaytarish yaratilganda (1C/SAP operatori tomonidan)
  ///
  /// Agent dasturda YOZMAYDI!
  /// Agent SINXRON bosganda KO'RADI
  ///
  /// Ombor actual: O'ZGARMAYDI
  /// Ombor reserved: +miqdor (QAYTARISH BAND)
  /// Mavjud: KAMAYDI (reserved oshdi)
  void createReturnReservation({
    required String returnId,
    required String orderId,
    required String productId,
    required String warehouseId,
    required double quantity,
  }) {
    _saveReservation({
      'returnId': returnId,
      'orderId': orderId,
      'productId': productId,
      'warehouseId': warehouseId,
      'quantity': quantity,
      'type': 'return', // Qaytarish turi
      'status': 'reserved', // Hali Проведен emas
      'createdAt': DateTime.now().toIso8601String(),
      'source': 'operator', // Operator yaratgan
    });
  }

  // ============ 5. QAYTARISH ПРОВЕДЕН (OPERATOR TASDIQLADI) ============

  /// Qaytarish Проведен bo'lganda - OMBORGA QAYTARISH
  ///
  /// Ombor actual: +miqdor (QAYTARILDI)
  /// Ombor reserved: -miqdor (BAND BEKOR)
  ///
  /// SHU YERDA OMBOR OSHDI!
  void confirmReturn({
    required String returnId,
    required String productId,
    required String warehouseId,
    required double returnQuantity,
  }) {
    // 1. Band qilishni "completed" ga o'zgartirish
    _updateReturnReservationStatus(returnId, 'completed');

    // 2. Ombor actual miqdorini OSHIRISH
    _increaseActualStock(productId, warehouseId, returnQuantity);

    // Bu yerda: actual += returnQuantity
    // reserved -= returnQuantity (chunki "completed" endi "reserved" emas)
  }

  // ============ 1C/SAP DAN SINXRONLASH ============

  /// 1C/SAP dan kelgan buyurtmalarni ko'rish
  ///
  /// Agent sinxron bosganda:
  /// - 1C/SAP dagi buyurtmalarni oladi
  /// - Local dagilar bilan solishtiradi
  /// - Farqlarni ko'rsatadi
  Future<List<Map<String, dynamic>>> syncExternalOrders({
    required String agentCode,
  }) async {
    return [
      {
        'source': 'local_cache',
        'agentCode': agentCode,
        'syncedAt': DateTime.now().toIso8601String(),
        'orders': [],
      }
    ];
  }

  /// 1C/SAP dan kelgan qaytarishlarni ko'rish
  Future<List<Map<String, dynamic>>> syncExternalReturns({
    required String agentCode,
  }) async {
    return [
      {
        'source': 'local_cache',
        'agentCode': agentCode,
        'syncedAt': DateTime.now().toIso8601String(),
        'returns': [],
      }
    ];
  }

  // ============ YETKAZISH VAQTIDA QAYTARISH ============

  /// Yetkazish vaqtida qaytarish bo'lsa
  ///
  /// Agent dasturda qaytarishni YOZADI
  /// Keyin 1C/SAP ga yuboradi
  /// Operator Проведен qilganda omborga qaytadi
  DeliveryReturnResult processDeliveryReturn({
    required String orderId,
    required String deliveryId,
    required String productId,
    required String warehouseId,
    required double returnQuantity,
    required String returnReason,
    required String condition, // good, damaged, expired
  }) {
    // 1. Qaytarish band qilish
    createReturnReservation(
      returnId: '${deliveryId}_return_$productId',
      orderId: orderId,
      productId: productId,
      warehouseId: warehouseId,
      quantity: returnQuantity,
    );

    // 2. Asosiy buyurtma band qilishni yangilash
    // (yetkazilgan qismini "delivered", qaytarilganini "returned")
    _updatePartialDelivery(
      orderId,
      productId,
      warehouseId,
      deliveredQuantity: 0, // Qaytarilgan qism
      returnedQuantity: returnQuantity,
    );

    return DeliveryReturnResult(
      success: true,
      message: '$returnQuantity miqdor qaytarish uchun band qilindi',
      returnId: '${deliveryId}_return_$productId',
      needsOperatorConfirmation: true, // Operator Проведен qilishi kerak
    );
  }

  // ============ YORDAMCHI FUNKSIYALAR ============

  double _getActualStock(String productId, String warehouseId) {
    final box = Hive.box(_stockBox);
    final data = box.get('${productId}_$warehouseId');
    if (data != null) {
      return (jsonDecode(data)['actualStock'] ?? 0).toDouble();
    }
    return 0;
  }

  void _decreaseActualStock(
    String productId,
    String warehouseId,
    double quantity,
  ) {
    final box = Hive.box(_stockBox);
    final key = '${productId}_$warehouseId';
    final data = box.get(key);

    if (data != null) {
      final stockData = jsonDecode(data);
      final current = (stockData['actualStock'] ?? 0).toDouble();
      stockData['actualStock'] = current - quantity;
      box.put(key, jsonEncode(stockData));
    }
  }

  void _increaseActualStock(
    String productId,
    String warehouseId,
    double quantity,
  ) {
    final box = Hive.box(_stockBox);
    final key = '${productId}_$warehouseId';
    final data = box.get(key);

    if (data != null) {
      final stockData = jsonDecode(data);
      final current = (stockData['actualStock'] ?? 0).toDouble();
      stockData['actualStock'] = current + quantity;
      box.put(key, jsonEncode(stockData));
    }
  }

  List<Map<String, dynamic>> _getReservations(
    String productId,
    String warehouseId,
  ) {
    final box = Hive.box(_reservationsBox);
    final reservations = <Map<String, dynamic>>[];

    for (var i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null) {
        final r = jsonDecode(data);
        if (r['productId'] == productId && r['warehouseId'] == warehouseId) {
          reservations.add(r);
        }
      }
    }

    return reservations;
  }

  void _saveReservation(Map<String, dynamic> reservation) {
    final box = Hive.box(_reservationsBox);
    box.add(jsonEncode(reservation));
  }

  void _updateReservationStatus(
    String orderId,
    String productId,
    String warehouseId,
    String newStatus,
  ) {
    final box = Hive.box(_reservationsBox);

    for (var i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null) {
        final r = jsonDecode(data);
        if (r['orderId'] == orderId &&
            r['productId'] == productId &&
            r['warehouseId'] == warehouseId &&
            r['type'] == 'order') {
          r['status'] = newStatus;
          r['updatedAt'] = DateTime.now().toIso8601String();
          box.putAt(i, jsonEncode(r));
        }
      }
    }
  }

  void _updateReturnReservationStatus(
    String returnId,
    String newStatus,
  ) {
    final box = Hive.box(_reservationsBox);

    for (var i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null) {
        final r = jsonDecode(data);
        if (r['returnId'] == returnId) {
          r['status'] = newStatus;
          r['updatedAt'] = DateTime.now().toIso8601String();
          box.putAt(i, jsonEncode(r));
        }
      }
    }
  }

  void _updatePartialDelivery(
    String orderId,
    String productId,
    String warehouseId, {
    required double deliveredQuantity,
    required double returnedQuantity,
  }) {
    final box = Hive.box(_reservationsBox);

    for (var i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null) {
        final r = jsonDecode(data);
        if (r['orderId'] == orderId &&
            r['productId'] == productId &&
            r['warehouseId'] == warehouseId &&
            r['type'] == 'order') {
          r['status'] = 'partially_delivered';
          r['deliveredQuantity'] = deliveredQuantity;
          r['returnedQuantity'] = returnedQuantity;
          r['updatedAt'] = DateTime.now().toIso8601String();
          box.putAt(i, jsonEncode(r));
        }
      }
    }
  }
}

// ============ NATIJA SINFLARI ============

class StockCalculation {
  final String productId;
  final String warehouseId;
  final double actualStock; // 1C/SAP dan kelgan
  final double orderReservedQuantity; // Buyurtmalar band
  final double returnReservedQuantity; // Qaytarishlar band
  final double totalReservedQuantity; // Jami band
  final double availableQuantity; // Mavjud = actual - reserved
  final bool isAvailable;

  const StockCalculation({
    required this.productId,
    required this.warehouseId,
    required this.actualStock,
    required this.orderReservedQuantity,
    required this.returnReservedQuantity,
    required this.totalReservedQuantity,
    required this.availableQuantity,
    required this.isAvailable,
  });

  bool canReserve(double quantity) => availableQuantity >= quantity;

  @override
  String toString() => 'Stock(actual: $actualStock, '
      'orderReserved: $orderReservedQuantity, '
      'returnReserved: $returnReservedQuantity, '
      'available: $availableQuantity)';
}

class ReservationResult {
  final bool success;
  final String message;
  final double availableQuantity;
  final double requestedQuantity;
  final String? reservationId;

  const ReservationResult({
    required this.success,
    required this.message,
    required this.availableQuantity,
    required this.requestedQuantity,
    this.reservationId,
  });
}

class DeliveryReturnResult {
  final bool success;
  final String message;
  final String? returnId;
  final bool needsOperatorConfirmation;

  const DeliveryReturnResult({
    required this.success,
    required this.message,
    this.returnId,
    this.needsOperatorConfirmation = false,
  });
}
