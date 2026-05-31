import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/order_flow_entities.dart';

// ============================================================
// ORDER LOCAL DATASOURCE - Hive cache
// Offline ma'lumotlarni saqlash
// ============================================================

class OrderLocalDataSource {
  static const String _ordersBox = 'orders';
  static const String _customersBox = 'customers';
  static const String _productsBox = 'products';
  static const String _syncQueueBox = 'sync_queue';

  // ============ ORDERS ============

  Future<void> saveOrder(Order order) async {
    final box = await Hive.openBox(_ordersBox);
    await box.put(order.id, jsonEncode(_orderToJson(order)));
  }

  Future<Order?> getOrder(String orderId) async {
    final box = await Hive.openBox(_ordersBox);
    final data = box.get(orderId);
    if (data != null) {
      return _orderFromJson(jsonDecode(data));
    }
    return null;
  }

  Future<List<Order>> getAllOrders() async {
    final box = await Hive.openBox(_ordersBox);
    final orders = <Order>[];
    for (var i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null) {
        orders.add(_orderFromJson(jsonDecode(data)));
      }
    }
    return orders;
  }

  Future<List<Order>> getPendingOrders() async {
    final box = await Hive.openBox(_ordersBox);
    final orders = <Order>[];
    for (var i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null) {
        final order = _orderFromJson(jsonDecode(data));
        if (order.status == OrderStatus.draft ||
            order.status == OrderStatus.syncFailed) {
          orders.add(order);
        }
      }
    }
    return orders;
  }

  Future<void> deleteOrder(String orderId) async {
    final box = await Hive.openBox(_ordersBox);
    await box.delete(orderId);
  }

  Future<void> clearOrders() async {
    final box = await Hive.openBox(_ordersBox);
    await box.clear();
  }

  // ============ CUSTOMERS ============

  Future<void> cacheCustomers(List<Map<String, dynamic>> customers) async {
    final box = await Hive.openBox(_customersBox);
    await box.put('customers_list', jsonEncode(customers));
    await box.put('last_sync', DateTime.now().toIso8601String());
  }

  Future<List<Map<String, dynamic>>> getCachedCustomers() async {
    final box = await Hive.openBox(_customersBox);
    final data = box.get('customers_list');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  DateTime? getLastCustomerSync() {
    if (!Hive.isBoxOpen(_customersBox)) return null;
    final value = Hive.box(_customersBox).get('last_sync');
    return value == null ? null : DateTime.tryParse(value.toString());
  }

  // ============ SYNC QUEUE ============

  Future<void> addToSyncQueue(String orderId) async {
    final box = await Hive.openBox(_syncQueueBox);
    final queue = List<String>.from(box.get('queue') ?? []);
    if (!queue.contains(orderId)) {
      queue.add(orderId);
      await box.put('queue', queue);
    }
  }

  Future<List<String>> getSyncQueue() async {
    final box = await Hive.openBox(_syncQueueBox);
    return List<String>.from(box.get('queue') ?? []);
  }

  Future<void> removeFromSyncQueue(String orderId) async {
    final box = await Hive.openBox(_syncQueueBox);
    final queue = List<String>.from(box.get('queue') ?? []);
    queue.remove(orderId);
    await box.put('queue', queue);
  }

  // ============ CONVERSION ============

  Map<String, dynamic> _orderToJson(Order order) {
    return {
      'id': order.id,
      'orderNumber': order.orderNumber,
      'externalId1C': order.externalId1C,
      'externalIdSAP': order.externalIdSAP,
      'documentNumber1C': order.documentNumber1C,
      'documentNumberSAP': order.documentNumberSAP,
      'customerId': order.customerId,
      'customerCode': order.customerCode,
      'customerName': order.customerName,
      'customerAddress': order.customerAddress,
      'customerPhone': order.customerPhone,
      'priceGroupId': order.priceGroupId,
      'agentId': order.agentId,
      'agentName': order.agentName,
      'agentCode': order.agentCode,
      'regionId': order.regionId,
      'warehouseId': order.warehouseId,
      'items': order.items
          .map((item) => {
                'id': item.id,
                'productId': item.productId,
                'productCode': item.productCode,
                'productName': item.productName,
                'productSku': item.productSku,
                'quantity': item.quantity,
                'unitOfMeasure': item.unitOfMeasure,
                'unitPrice': item.unitPrice,
                'discountPercent': item.discountPercent,
                'discountAmount': item.discountAmount,
                'totalPrice': item.totalPrice,
                'totalWithDiscount': item.totalWithDiscount,
                'weight': item.weight,
                'volume': item.volume,
                'isStockSufficient': item.isStockSufficient,
              })
          .toList(),
      'subtotal': order.subtotal,
      'totalDiscount': order.totalDiscount,
      'totalAmount': order.totalAmount,
      'paidAmount': order.paidAmount,
      'remainingAmount': order.remainingAmount,
      'currency': order.currency,
      'paymentMethod': order.paymentMethod,
      'paymentTermDays': order.paymentTermDays,
      'paymentDueDate': order.paymentDueDate?.toIso8601String(),
      'deliveryDate': order.deliveryDate?.toIso8601String(),
      'deliveryTimeSlot': order.deliveryTimeSlot,
      'status': order.status.name,
      'paymentStatus': order.paymentStatus.name,
      'createdAt': order.createdAt.toIso8601String(),
      'submittedAt': order.submittedAt?.toIso8601String(),
      'confirmedAt': order.confirmedAt?.toIso8601String(),
      'syncedTo1CAt': order.syncedTo1CAt?.toIso8601String(),
      'syncedToSAPAt': order.syncedToSAPAt?.toIso8601String(),
      'syncError': order.syncError,
      'syncRetryCount': order.syncRetryCount,
      'notes': order.notes,
      'metadata': order.metadata,
    };
  }

  Order _orderFromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      externalId1C: json['externalId1C'],
      externalIdSAP: json['externalIdSAP'],
      documentNumber1C: json['documentNumber1C'],
      documentNumberSAP: json['documentNumberSAP'],
      customerId: json['customerId'] ?? '',
      customerCode: json['customerCode'] ?? '',
      customerName: json['customerName'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      priceGroupId: json['priceGroupId'] ?? '',
      agentId: json['agentId'] ?? '',
      agentName: json['agentName'] ?? '',
      agentCode: json['agentCode'] ?? '',
      regionId: json['regionId'] ?? '',
      warehouseId: json['warehouseId'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem(
                id: item['id'] ?? '',
                productId: item['productId'] ?? '',
                productCode: item['productCode'] ?? '',
                productName: item['productName'] ?? '',
                productSku: item['productSku'] ?? '',
                quantity: item['quantity'] ?? 0,
                unitOfMeasure: item['unitOfMeasure'] ?? 'dona',
                unitPrice: (item['unitPrice'] ?? 0).toDouble(),
                discountPercent: (item['discountPercent'] ?? 0).toDouble(),
                discountAmount: (item['discountAmount'] ?? 0).toDouble(),
                totalPrice: (item['totalPrice'] ?? 0).toDouble(),
                totalWithDiscount: (item['totalWithDiscount'] ?? 0).toDouble(),
                weight: (item['weight'] ?? 0).toDouble(),
                volume: (item['volume'] ?? 0).toDouble(),
                isStockSufficient: item['isStockSufficient'] ?? true,
              ))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      totalDiscount: (json['totalDiscount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UZS',
      paymentMethod: json['paymentMethod'] ?? 'cash',
      paymentTermDays: json['paymentTermDays'] ?? 30,
      paymentDueDate: json['paymentDueDate'] != null
          ? DateTime.parse(json['paymentDueDate'])
          : null,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      deliveryTimeSlot: json['deliveryTimeSlot'],
      status: _parseStatus(json['status']),
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      createdAt: DateTime.parse(json['createdAt']),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      syncedTo1CAt: json['syncedTo1CAt'] != null
          ? DateTime.parse(json['syncedTo1CAt'])
          : null,
      syncedToSAPAt: json['syncedToSAPAt'] != null
          ? DateTime.parse(json['syncedToSAPAt'])
          : null,
      syncError: json['syncError'],
      syncRetryCount: json['syncRetryCount'] ?? 0,
      notes: json['notes'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'draft':
        return OrderStatus.draft;
      case 'pending':
        return OrderStatus.pending;
      case 'submitted':
        return OrderStatus.submitted;
      case 'syncedTo1C':
        return OrderStatus.syncedTo1C;
      case 'syncedToSAP':
        return OrderStatus.syncedToSAP;
      case 'syncFailed':
        return OrderStatus.syncFailed;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivering':
        return OrderStatus.delivering;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'returned':
        return OrderStatus.returned;
      default:
        return OrderStatus.draft;
    }
  }

  PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'unpaid':
        return PaymentStatus.unpaid;
      case 'partial':
        return PaymentStatus.partial;
      case 'paid':
        return PaymentStatus.paid;
      case 'overdue':
        return PaymentStatus.overdue;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.unpaid;
    }
  }
}
