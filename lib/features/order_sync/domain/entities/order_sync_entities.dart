import 'package:equatable/equatable.dart';

// ============================================================
// ORDER SYNC ENTITIES
// Buyurtma va qaytarish sinxronlash uchun
// ============================================================

// ============ BUYURTMA SINXRONLASH SO'ROVI ============

class OrderSyncRequest extends Equatable {
  factory OrderSyncRequest.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String orderId; // Local order ID
  final String orderNumber; // Order number
  final DateTime orderDate; // Order date

  // Customer
  final String customerId; // 1C Ref_Key / SAP Customer
  final String customerCode; // Code
  final String customerName; // Name
  final String priceGroupId; // Price group
  final String customerGroupId; // Customer group

  // Agent
  final String agentId; // Agent ID
  final String agentCode; // Agent code
  final String agentName; // Agent name

  // Warehouse
  final String warehouseId; // Warehouse ID
  final String warehouseCode; // Warehouse code
  final String warehouseName; // Warehouse name
  final String regionId; // Region

  // Items
  final List<OrderSyncItem> items; // Order items

  // Amounts
  final double totalAmount; // Total amount
  final String currency; // Currency (UZS)

  // Payment
  final String paymentMethod; // cash, card, transfer, credit
  final String paymentTerms; // NET30, etc.
  final int paymentDays; // Payment delay days

  // Delivery
  final DateTime? deliveryDate; // Delivery date
  final String? deliveryTimeSlot; // Time slot
  final String? deliveryAddress; // Address
  final double? deliveryLatitude; // Latitude
  final double? deliveryLongitude; // Longitude

  // Notes
  final String? notes; // Comment

  const OrderSyncRequest({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.priceGroupId,
    required this.customerGroupId,
    required this.agentId,
    required this.agentCode,
    required this.agentName,
    required this.warehouseId,
    required this.warehouseCode,
    required this.warehouseName,
    required this.regionId,
    required this.items,
    required this.totalAmount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentTerms,
    required this.paymentDays,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.notes,
  });

  @override
  List<Object?> get props => [orderId, orderNumber];
}

/// Buyurtma elementi
class OrderSyncItem extends Equatable {
  factory OrderSyncItem.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String productId; // Product ID
  final String productCode; // Product code (1C/SAP)
  final String productName; // Product name
  final String? characteristicId; // Characteristic (color, size)
  final int quantity; // Quantity
  final String unitId; // Unit ID
  final String unitName; // Unit name
  final double unitFactor; // Unit factor
  final double unitPrice; // Unit price
  final double amount; // Amount (qty * price)
  final double discountPercent; // Discount %
  final double discountAmount; // Discount amount
  final double amountWithDiscount; // Amount with discount
  final double taxRate; // Tax rate %
  final double taxAmount; // Tax amount
  final double totalAmount; // Total (with tax)
  final bool isGift; // Is gift
  final String? promotionId; // Promotion ID
  final String? notes; // Notes

  const OrderSyncItem({
    required this.productId,
    required this.productCode,
    required this.productName,
    this.characteristicId,
    required this.quantity,
    required this.unitId,
    required this.unitName,
    required this.unitFactor,
    required this.unitPrice,
    required this.amount,
    required this.discountPercent,
    required this.discountAmount,
    required this.amountWithDiscount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.isGift,
    this.promotionId,
    this.notes,
  });

  @override
  List<Object?> get props => [productId, quantity, unitPrice];
}

// ============ BUYURTMA SINXRONLASH NATIJASI ============

class OrderSyncResult extends Equatable {
  factory OrderSyncResult.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String orderId;
  final String? oneCRefKey;
  final String? oneCNumber;
  final String? sapSalesOrder;
  final String? error1C;
  final String? errorSAP;
  final bool isSyncedTo1C;
  final bool isSyncedToSAP;
  final DateTime submittedAt;
  final DateTime completedAt;
  final Duration duration;

  const OrderSyncResult({
    required this.orderId,
    this.oneCRefKey,
    this.oneCNumber,
    this.sapSalesOrder,
    this.error1C,
    this.errorSAP,
    required this.isSyncedTo1C,
    required this.isSyncedToSAP,
    required this.submittedAt,
    required this.completedAt,
    required this.duration,
  });

  bool get isSuccess => isSyncedTo1C || isSyncedToSAP;
  bool get isPartialSuccess =>
      (isSyncedTo1C && !isSyncedToSAP) || (!isSyncedTo1C && isSyncedToSAP);
  bool get isFailure => !isSyncedTo1C && !isSyncedToSAP;

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'oneCRefKey': oneCRefKey,
        'oneCNumber': oneCNumber,
        'sapSalesOrder': sapSalesOrder,
        'error1C': error1C,
        'errorSAP': errorSAP,
        'isSyncedTo1C': isSyncedTo1C,
        'isSyncedToSAP': isSyncedToSAP,
      };

  @override
  List<Object?> get props => [orderId, oneCRefKey, sapSalesOrder];
}

// ============ QAYTARISH SINXRONLASH SO'ROVI ============

class ReturnSyncRequest extends Equatable {
  factory ReturnSyncRequest.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String returnId; // Local return ID
  final String returnNumber; // Return number
  final DateTime returnDate; // Return date
  final String orderId; // Original order ID
  final String orderNumber; // Original order number
  final String? originalOrderId; // 1C original order key
  final String? originalOrderNumber; // 1C original order number
  final String? sapOriginalOrder; // SAP original order

  // Customer
  final String customerId;
  final String customerCode;
  final String customerName;

  // Agent
  final String agentId;

  // Warehouse
  final String warehouseId;
  final String warehouseCode;

  // Items
  final List<ReturnSyncItem> items;

  // Amounts
  final double totalAmount;
  final String currency;

  // Return reason
  final String returnReason; // defective, expired, wrong_item, customer_request
  final String returnReasonDescription;

  // Notes
  final String? notes;
  final List<String> photoUrls;
  final String? signatureUrl;

  const ReturnSyncRequest({
    required this.returnId,
    required this.returnNumber,
    required this.returnDate,
    required this.orderId,
    required this.orderNumber,
    this.originalOrderId,
    this.originalOrderNumber,
    this.sapOriginalOrder,
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.agentId,
    required this.warehouseId,
    required this.warehouseCode,
    required this.items,
    required this.totalAmount,
    required this.currency,
    required this.returnReason,
    required this.returnReasonDescription,
    this.notes,
    this.photoUrls = const [],
    this.signatureUrl,
  });

  @override
  List<Object?> get props => [returnId, orderId];
}

/// Qaytarish elementi
class ReturnSyncItem extends Equatable {
  factory ReturnSyncItem.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String productId;
  final String productCode;
  final String productName;
  final int quantity;
  final String unitId;
  final String unitName;
  final double unitPrice;
  final double amount;
  final String returnReason; // defective, expired, wrong_item, overstock
  final String condition; // good, damaged, expired, opened
  final String? batchNumber;
  final String? notes;

  const ReturnSyncItem({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.unitId,
    required this.unitName,
    required this.unitPrice,
    required this.amount,
    required this.returnReason,
    required this.condition,
    this.batchNumber,
    this.notes,
  });

  @override
  List<Object?> get props => [productId, quantity, returnReason];
}

// ============ QAYTARISH SINXRONLASH NATIJASI ============

class ReturnSyncResult extends Equatable {
  factory ReturnSyncResult.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String orderId;
  final String returnId;
  final String? oneCRefKey;
  final String? sapReturnOrder;
  final String? error1C;
  final String? errorSAP;
  final bool isSyncedTo1C;
  final bool isSyncedToSAP;
  final DateTime submittedAt;
  final DateTime completedAt;

  const ReturnSyncResult({
    required this.orderId,
    required this.returnId,
    this.oneCRefKey,
    this.sapReturnOrder,
    this.error1C,
    this.errorSAP,
    required this.isSyncedTo1C,
    required this.isSyncedToSAP,
    required this.submittedAt,
    required this.completedAt,
  });

  bool get isSuccess => isSyncedTo1C || isSyncedToSAP;

  @override
  List<Object?> get props => [returnId, oneCRefKey, sapReturnOrder];
}

// ============ BUYURTMA KUZATISH NATIJASI ============

class OrderTrackingResult extends Equatable {
  factory OrderTrackingResult.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final dynamic oneCStatus; // OneCOrderStatus
  final dynamic sapStatus; // SAPOrderTracking
  final String? error1C;
  final String? errorSAP;
  final DateTime trackedAt;

  const OrderTrackingResult({
    this.oneCStatus,
    this.sapStatus,
    this.error1C,
    this.errorSAP,
    required this.trackedAt,
  });

  bool get has1CStatus => oneCStatus != null;
  bool get hasSAPStatus => sapStatus != null;

  bool get isCompleted {
    if (oneCStatus != null && oneCStatus.posted == true) return true;
    if (sapStatus != null && sapStatus.isCompletelyProcessed) return true;
    return false;
  }

  String get statusText {
    if (sapStatus != null) return sapStatus.statusText;
    if (oneCStatus != null) return oneCStatus.statusDescription;
    return 'Noma\'lum';
  }

  @override
  List<Object?> get props => [oneCStatus, sapStatus, trackedAt];
}

// ============ SINXRONLASH VOQEALARI ============

enum SyncEventType {
  orderSubmitting, // Buyurtma yuborilmoqda
  syncingTo1C, // 1C ga yuborilmoqda
  syncingToSAP, // SAP ga yuborilmoqda
  sync1CCompleted, // 1C ga yuborildi
  syncSAPCompleted, // SAP ga yuborildi
  sync1CFailed, // 1C xatolik
  syncSAPFailed, // SAP xatolik
  orderSubmitted, // Buyurtma yuborildi
  orderSubmitFailed, // Buyurtma yuborish xatolik
  returnSubmitting, // Qaytarish yuborilmoqda
  return1CCompleted, // 1C ga qaytarish yuborildi
  returnSAPCompleted, // SAP ga qaytarish yuborildi
  statusUpdated, // Holat yangilandi
}

class SyncEvent extends Equatable {
  factory SyncEvent.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String orderId;
  final SyncEventType type;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  SyncEvent({
    required this.orderId,
    required this.type,
    required this.message,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [orderId, type, timestamp];
}

// ============ QAYTARISH SABABLARI ============

class ReturnReason {
  factory ReturnReason.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String code;
  final String name;
  final String description;
  final String icon;

  const ReturnReason({
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
  });

  static const List<ReturnReason> reasons = [
    ReturnReason(
      code: 'defective',
      name: 'Nosoz mahsulot',
      description: 'Mahsulot sifatsiz yoki buzilgan',
      icon: '🔧',
    ),
    ReturnReason(
      code: 'expired',
      name: 'Muddati o\'tgan',
      description: 'Yaroqlilik muddati tugagan',
      icon: '⏰',
    ),
    ReturnReason(
      code: 'wrong_item',
      name: 'Noto\'g\'ri mahsulot',
      description: 'Boshqa mahsulot yuborilgan',
      icon: '❌',
    ),
    ReturnReason(
      code: 'overstock',
      name: 'Ortiqcha qoldiq',
      description: 'Mijozga kerak emas',
      icon: '📦',
    ),
    ReturnReason(
      code: 'customer_request',
      name: 'Mijoz so\'rovi',
      description: 'Mijoz o\'zi qaytarmoqchi',
      icon: '👤',
    ),
    ReturnReason(
      code: 'damaged_transport',
      name: 'Transportda shikastlangan',
      description: 'Yetkazish davomida shikastlangan',
      icon: '🚚',
    ),
  ];
}

// ============ TO'LOV USULLARI ============

class PaymentMethod {
  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String code;
  final String name;
  final String icon;

  const PaymentMethod({
    required this.code,
    required this.name,
    required this.icon,
  });

  static const List<PaymentMethod> methods = [
    PaymentMethod(code: 'cash', name: 'Naqd pul', icon: '💵'),
    PaymentMethod(code: 'card', name: 'Plastik karta', icon: '💳'),
    PaymentMethod(code: 'transfer', name: 'Bank o\'tkazmasi', icon: '🏦'),
    PaymentMethod(code: 'credit', name: 'Kredit (muddatli)', icon: '📅'),
  ];
}
