import 'package:equatable/equatable.dart';

/// Yetkazib berish model
class DeliveryModel extends Equatable {
  final String id;
  final String deliveryNumber;
  final String orderId;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double? latitude;
  final double? longitude;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber;
  final String agentId;
  final String agentName;
  final DateTime createdAt;
  final DateTime scheduledDate;
  final String scheduledTimeSlot;
  final String status;
  final List<DeliveryItemModel> items;
  final double totalAmount;
  final double collectedAmount;
  final double remainingAmount;
  final String paymentMethod;
  final List<String> photoUrls;
  final String? signatureUrl;
  final String? recipientName;
  final String? recipientPhone;
  final String? notes;
  final String? failureReason;
  final String? syncError;

  const DeliveryModel({
    required this.id,
    required this.deliveryNumber,
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.latitude,
    this.longitude,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    required this.agentId,
    required this.agentName,
    required this.createdAt,
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.collectedAmount,
    required this.remainingAmount,
    required this.paymentMethod,
    this.photoUrls = const [],
    this.signatureUrl,
    this.recipientName,
    this.recipientPhone,
    this.notes,
    this.failureReason,
    this.syncError,
  });

  bool get isDelivered => status == 'delivered';
  bool get isFailed => status == 'failed';
  bool get hasPhotos => photoUrls.isNotEmpty;
  bool get hasSignature => signatureUrl != null;

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] ?? '',
      deliveryNumber: json['delivery_number'] ?? '',
      orderId: json['order_id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      driverId: json['driver_id'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      vehicleNumber: json['vehicle_number'],
      agentId: json['agent_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      scheduledDate: DateTime.parse(
          json['scheduled_date'] ?? DateTime.now().toIso8601String()),
      scheduledTimeSlot: json['scheduled_time_slot'] ?? '',
      status: json['status'] ?? 'pending',
      items: (json['items'] as List? ?? [])
          .map((i) => DeliveryItemModel.fromJson(i))
          .toList(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      collectedAmount: (json['collected_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'cash',
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
      signatureUrl: json['signature_url'],
      recipientName: json['recipient_name'],
      recipientPhone: json['recipient_phone'],
      notes: json['notes'],
      failureReason: json['failure_reason'],
      syncError: json['sync_error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery_number': deliveryNumber,
      'order_id': orderId,
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      'latitude': latitude,
      'longitude': longitude,
      'driver_id': driverId,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'vehicle_number': vehicleNumber,
      'agent_id': agentId,
      'agent_name': agentName,
      'created_at': createdAt.toIso8601String(),
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_time_slot': scheduledTimeSlot,
      'status': status,
      'items': items.map((i) => i.toJson()).toList(),
      'total_amount': totalAmount,
      'collected_amount': collectedAmount,
      'remaining_amount': remainingAmount,
      'payment_method': paymentMethod,
      'photo_urls': photoUrls,
      'signature_url': signatureUrl,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'notes': notes,
      'failure_reason': failureReason,
      'sync_error': syncError,
    };
  }

  @override
  List<Object?> get props => [id, deliveryNumber, status];
}

/// Yetkazish elementi model
class DeliveryItemModel extends Equatable {
  final String id;
  final String productId;
  final String productCode;
  final String productName;
  final int orderedQuantity;
  final int deliveredQuantity;
  final int returnedQuantity;
  final String unitOfMeasure;
  final double unitPrice;
  final double totalPrice;

  const DeliveryItemModel({
    required this.id,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.orderedQuantity,
    required this.deliveredQuantity,
    required this.returnedQuantity,
    required this.unitOfMeasure,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory DeliveryItemModel.fromJson(Map<String, dynamic> json) {
    return DeliveryItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productCode: json['product_code'] ?? '',
      productName: json['product_name'] ?? '',
      orderedQuantity: json['ordered_quantity'] ?? 0,
      deliveredQuantity: json['delivered_quantity'] ?? 0,
      returnedQuantity: json['returned_quantity'] ?? 0,
      unitOfMeasure: json['unit_of_measure'] ?? 'dona',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_code': productCode,
      'product_name': productName,
      'ordered_quantity': orderedQuantity,
      'delivered_quantity': deliveredQuantity,
      'returned_quantity': returnedQuantity,
      'unit_of_measure': unitOfMeasure,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  @override
  List<Object?> get props => [id, productId, orderedQuantity];
}
