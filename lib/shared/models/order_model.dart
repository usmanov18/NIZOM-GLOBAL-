import 'package:equatable/equatable.dart';

/// Buyurtma model
class OrderModel extends Equatable {
  final String id;
  final String orderNumber;
  final String? externalId1C;
  final String? externalIdSAP;
  final String customerId;
  final String customerCode;
  final String customerName;
  final String agentId;
  final String agentCode;
  final String agentName;
  final List<OrderItemModel> items;
  final double subtotal;
  final double totalDiscount;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? deliveryDate;
  final String? notes;
  final String? syncError;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    this.externalId1C,
    this.externalIdSAP,
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.agentId,
    required this.agentCode,
    required this.agentName,
    required this.items,
    required this.subtotal,
    required this.totalDiscount,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.deliveryDate,
    this.notes,
    this.syncError,
  });

  bool get isDraft => status == 'draft';
  bool get isConfirmed => status == 'confirmed';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isSyncedTo1C => externalId1C != null;
  bool get isSyncedToSAP => externalIdSAP != null;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      externalId1C: json['external_id_1c'],
      externalIdSAP: json['external_id_sap'],
      customerId: json['customer_id'] ?? '',
      customerCode: json['customer_code'] ?? '',
      customerName: json['customer_name'] ?? '',
      agentId: json['agent_id'] ?? '',
      agentCode: json['agent_code'] ?? '',
      agentName: json['agent_name'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((i) => OrderItemModel.fromJson(i))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      totalDiscount: (json['total_discount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UZS',
      paymentMethod: json['payment_method'] ?? 'cash',
      status: json['status'] ?? 'draft',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'])
          : null,
      notes: json['notes'],
      syncError: json['sync_error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'external_id_1c': externalId1C,
      'external_id_sap': externalIdSAP,
      'customer_id': customerId,
      'customer_code': customerCode,
      'customer_name': customerName,
      'agent_id': agentId,
      'agent_code': agentCode,
      'agent_name': agentName,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'total_discount': totalDiscount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'currency': currency,
      'payment_method': paymentMethod,
      'status': status,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'notes': notes,
      'sync_error': syncError,
    };
  }

  @override
  List<Object?> get props => [id, orderNumber, status];
}

/// Buyurtma elementi model
class OrderItemModel extends Equatable {
  final String id;
  final String productId;
  final String productCode;
  final String productName;
  final int quantity;
  final String unitOfMeasure;
  final double unitPrice;
  final double discountPercent;
  final double discountAmount;
  final double totalPrice;
  final double totalWithDiscount;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.unitOfMeasure,
    required this.unitPrice,
    required this.discountPercent,
    required this.discountAmount,
    required this.totalPrice,
    required this.totalWithDiscount,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productCode: json['product_code'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitOfMeasure: json['unit_of_measure'] ?? 'dona',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      discountPercent: (json['discount_percent'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      totalWithDiscount: (json['total_with_discount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_code': productCode,
      'product_name': productName,
      'quantity': quantity,
      'unit_of_measure': unitOfMeasure,
      'unit_price': unitPrice,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'total_price': totalPrice,
      'total_with_discount': totalWithDiscount,
    };
  }

  @override
  List<Object?> get props => [id, productId, quantity];
}
