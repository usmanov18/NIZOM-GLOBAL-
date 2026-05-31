import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'order_flow_entities.g.dart';

@HiveType(typeId: 10)
class OrderCustomer extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String code;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String legalName;
  @HiveField(4)
  final String inn;
  @HiveField(5)
  final String address;
  @HiveField(6)
  final String phone;
  @HiveField(7)
  final String? email;
  @HiveField(8)
  final String? contactPerson;
  @HiveField(9)
  final double? latitude;
  @HiveField(10)
  final double? longitude;
  @HiveField(11)
  final String agentId;
  @HiveField(12)
  final String priceGroupId;
  @HiveField(13)
  final String paymentTerms;
  @HiveField(14)
  final double creditLimit;
  @HiveField(15)
  final double currentDebt;
  @HiveField(16)
  final double availableCredit;
  @HiveField(17)
  final int paymentDelayDays;
  @HiveField(18)
  final bool isActive;
  @HiveField(19)
  final bool isBlocked;
  @HiveField(20)
  final String? blockReason;
  @HiveField(21)
  final DateTime? lastOrderDate;
  @HiveField(22)
  final double lastOrderAmount;
  @HiveField(23)
  final String? notes;

  const OrderCustomer({
    required this.id,
    required this.code,
    required this.name,
    this.legalName = '',
    this.inn = '',
    this.address = '',
    this.phone = '',
    this.email,
    this.contactPerson,
    this.latitude,
    this.longitude,
    this.agentId = '',
    this.priceGroupId = '',
    this.paymentTerms = '',
    this.creditLimit = 0,
    this.currentDebt = 0,
    double? availableCredit,
    this.paymentDelayDays = 0,
    this.isActive = true,
    this.isBlocked = false,
    this.blockReason,
    this.lastOrderDate,
    this.lastOrderAmount = 0,
    this.notes,
  }) : availableCredit = availableCredit ?? (creditLimit - currentDebt);

  factory OrderCustomer.fromJson(Map<String, dynamic> json) => OrderCustomer(
        id: (json['id'] ?? json['Ref_Key'] ?? '').toString(),
        code: (json['code'] ?? json['Code'] ?? '').toString(),
        name: (json['name'] ?? json['Description'] ?? '').toString(),
        legalName: (json['legalName'] ?? json['LegalName'] ?? '').toString(),
        inn: (json['inn'] ?? json['INN'] ?? '').toString(),
        address: (json['address'] ?? json['Address'] ?? '').toString(),
        phone: (json['phone'] ?? json['Phone'] ?? '').toString(),
        email: json['email']?.toString(),
        contactPerson: json['contactPerson']?.toString(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        agentId: (json['agentId'] ?? json['Agent_Key'] ?? '').toString(),
        priceGroupId:
            (json['priceGroupId'] ?? json['PriceGroup_Key'] ?? '').toString(),
        paymentTerms:
            (json['paymentTerms'] ?? json['PaymentTerms'] ?? '').toString(),
        creditLimit:
            (json['creditLimit'] ?? json['CreditLimit'] ?? 0).toDouble(),
        currentDebt:
            (json['currentDebt'] ?? json['CurrentDebt'] ?? 0).toDouble(),
        availableCredit:
            (json['availableCredit'] ?? json['AvailableCredit'] ?? 0)
                .toDouble(),
        paymentDelayDays:
            (json['paymentDelayDays'] ?? json['PaymentDelayDays'] ?? 0) as int,
        isActive: json['isActive'] ?? json['IsActive'] ?? true,
        isBlocked: json['isBlocked'] ?? json['IsBlocked'] ?? false,
        blockReason: json['blockReason']?.toString(),
        lastOrderDate: json['lastOrderDate'] == null
            ? null
            : DateTime.tryParse(json['lastOrderDate'].toString()),
        lastOrderAmount:
            (json['lastOrderAmount'] ?? json['LastOrderAmount'] ?? 0)
                .toDouble(),
        notes: json['notes']?.toString(),
      );

  bool get canOrder => isActive && !isBlocked;
  bool get hasDebt => currentDebt > 0;
  bool canAfford(double amount) => amount <= availableCredit;

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        isActive,
        isBlocked,
        availableCredit,
      ];
}

@HiveType(typeId: 11)
class OrderItem extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String productId;
  @HiveField(2)
  final String productCode;
  @HiveField(3)
  final String productName;
  @HiveField(4)
  final String productSku;
  @HiveField(5)
  final String? productImage;
  @HiveField(6)
  final int quantity;
  @HiveField(7)
  final String unitOfMeasure;
  @HiveField(8)
  final double unitPrice;
  @HiveField(9)
  final double discountPercent;
  @HiveField(10)
  final double discountAmount;
  @HiveField(11)
  final double totalPrice;
  @HiveField(12)
  final double totalWithDiscount;
  @HiveField(13)
  final double weight;
  @HiveField(14)
  final double volume;
  @HiveField(15)
  final double? availableStock;
  @HiveField(16)
  final bool isStockSufficient;
  @HiveField(17)
  final String? notes;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productCode,
    required this.productName,
    this.productSku = '',
    this.productImage,
    required this.quantity,
    this.unitOfMeasure = 'dona',
    required this.unitPrice,
    this.discountPercent = 0,
    this.discountAmount = 0,
    double? totalPrice,
    double? totalWithDiscount,
    this.weight = 0,
    this.volume = 0,
    this.availableStock,
    this.isStockSufficient = true,
    this.notes,
  })  : totalPrice = totalPrice ?? unitPrice * quantity,
        totalWithDiscount =
            totalWithDiscount ?? ((unitPrice * quantity) - discountAmount);

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: (json['id'] ?? '').toString(),
        productId: (json['productId'] ?? '').toString(),
        productCode: (json['productCode'] ?? '').toString(),
        productName: (json['productName'] ?? '').toString(),
        productSku: (json['productSku'] ?? '').toString(),
        productImage: json['productImage']?.toString(),
        quantity: json['quantity'] ?? 0,
        unitOfMeasure: (json['unitOfMeasure'] ?? 'dona').toString(),
        unitPrice: (json['unitPrice'] ?? 0).toDouble(),
        discountPercent: (json['discountPercent'] ?? 0).toDouble(),
        discountAmount: (json['discountAmount'] ?? 0).toDouble(),
        totalPrice: (json['totalPrice'] ?? 0).toDouble(),
        totalWithDiscount: (json['totalWithDiscount'] ?? 0).toDouble(),
        weight: (json['weight'] ?? 0).toDouble(),
        volume: (json['volume'] ?? 0).toDouble(),
        availableStock: (json['availableStock'] as num?)?.toDouble(),
        isStockSufficient: json['isStockSufficient'] ?? true,
        notes: json['notes']?.toString(),
      );

  factory OrderItem.fromProductAndPrice({
    required OrderProduct product,
    required ProductPrice price,
    required ProductStock stock,
    required int quantity,
    String? notes,
  }) {
    final subtotal = price.finalPrice * quantity;
    final discount = price.discountAmount * quantity;
    return OrderItem(
      id: '${product.id}_${DateTime.now().microsecondsSinceEpoch}',
      productId: product.id,
      productCode: product.code,
      productName: product.name,
      productSku: product.sku,
      productImage: product.imageUrl,
      quantity: quantity,
      unitOfMeasure: product.unitOfMeasure,
      unitPrice: price.finalPrice,
      discountPercent: price.discountPercent,
      discountAmount: discount,
      totalPrice: subtotal,
      totalWithDiscount: subtotal,
      weight: product.weight * quantity,
      volume: product.volume * quantity,
      availableStock: stock.actualQuantity,
      isStockSufficient: stock.actualQuantity >= quantity,
      notes: notes,
    );
  }

  OrderItem copyWith({
    String? id,
    String? productId,
    String? productCode,
    String? productName,
    String? productSku,
    String? productImage,
    int? quantity,
    String? unitOfMeasure,
    double? unitPrice,
    double? discountPercent,
    double? discountAmount,
    double? totalPrice,
    double? totalWithDiscount,
    double? weight,
    double? volume,
    double? availableStock,
    bool? isStockSufficient,
    String? notes,
  }) =>
      OrderItem(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        productCode: productCode ?? this.productCode,
        productName: productName ?? this.productName,
        productSku: productSku ?? this.productSku,
        productImage: productImage ?? this.productImage,
        quantity: quantity ?? this.quantity,
        unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
        unitPrice: unitPrice ?? this.unitPrice,
        discountPercent: discountPercent ?? this.discountPercent,
        discountAmount: discountAmount ?? this.discountAmount,
        totalPrice: totalPrice ?? this.totalPrice,
        totalWithDiscount: totalWithDiscount ?? this.totalWithDiscount,
        weight: weight ?? this.weight,
        volume: volume ?? this.volume,
        availableStock: availableStock ?? this.availableStock,
        isStockSufficient: isStockSufficient ?? this.isStockSufficient,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [
        id,
        productId,
        quantity,
        unitPrice,
        totalWithDiscount,
      ];
}

@HiveType(typeId: 12)
enum OrderStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  pending,
  @HiveField(2)
  submitted,
  @HiveField(3)
  syncedTo1C,
  @HiveField(4)
  syncedToSAP,
  @HiveField(5)
  syncFailed,
  @HiveField(6)
  confirmed,
  @HiveField(7)
  processing,
  @HiveField(8)
  shipped,
  @HiveField(9)
  delivering,
  @HiveField(10)
  delivered,
  @HiveField(11)
  cancelled,
  @HiveField(12)
  returned;

  static OrderStatus fromJson(String? value) => OrderStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => OrderStatus.draft,
      );
}

@HiveType(typeId: 13)
enum PaymentStatus {
  @HiveField(0)
  unpaid,
  @HiveField(1)
  pending,
  @HiveField(2)
  partial,
  @HiveField(3)
  paid,
  @HiveField(4)
  overdue,
  @HiveField(5)
  refunded,
  @HiveField(6)
  failed;

  static PaymentStatus fromJson(String? value) => PaymentStatus.values
      .firstWhere((e) => e.name == value, orElse: () => PaymentStatus.unpaid);
}

@HiveType(typeId: 14)
class Order extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String orderNumber;
  @HiveField(2)
  final String idempotencyKey;
  @HiveField(3)
  final String? externalId1C;
  @HiveField(4)
  final String? externalIdSAP;
  @HiveField(5)
  final String? documentNumber1C;
  @HiveField(6)
  final String? documentNumberSAP;
  @HiveField(7)
  final String customerId;
  @HiveField(8)
  final String customerCode;
  @HiveField(9)
  final String customerName;
  @HiveField(10)
  final String customerAddress;
  @HiveField(11)
  final String customerPhone;
  @HiveField(12)
  final double? customerLatitude;
  @HiveField(13)
  final double? customerLongitude;
  @HiveField(14)
  final String priceGroupId;
  @HiveField(15)
  final String agentId;
  @HiveField(16)
  final String agentName;
  @HiveField(17)
  final String agentCode;
  @HiveField(18)
  final String regionId;
  @HiveField(19)
  final String warehouseId;
  @HiveField(20)
  final List<OrderItem> items;
  @HiveField(21)
  final double subtotal;
  @HiveField(22)
  final double totalDiscount;
  @HiveField(23)
  final double totalAmount;
  @HiveField(24)
  final double paidAmount;
  @HiveField(25)
  final double remainingAmount;
  @HiveField(26)
  final String currency;
  @HiveField(27)
  final String paymentMethod;
  @HiveField(28)
  final int paymentTermDays;
  @HiveField(29)
  final DateTime? paymentDueDate;
  @HiveField(30)
  final DateTime? deliveryDate;
  @HiveField(31)
  final String? deliveryTimeSlot;
  @HiveField(32)
  final String? deliveryAddress;
  @HiveField(33)
  final double? deliveryLatitude;
  @HiveField(34)
  final double? deliveryLongitude;
  @HiveField(35)
  final OrderStatus status;
  @HiveField(36)
  final PaymentStatus paymentStatus;
  @HiveField(37)
  final DateTime createdAt;
  @HiveField(38)
  final DateTime? submittedAt;
  @HiveField(39)
  final DateTime? confirmedAt;
  @HiveField(40)
  final DateTime? syncedTo1CAt;
  @HiveField(41)
  final DateTime? syncedToSAPAt;
  @HiveField(42)
  final String? syncError;
  @HiveField(43)
  final int syncRetryCount;
  @HiveField(44)
  final String? notes;
  @HiveField(45)
  final String? cancelReason;
  @HiveField(46)
  final Map<String, dynamic>? metadata;

  const Order({
    required this.id,
    required this.orderNumber,
    this.idempotencyKey = '',
    this.externalId1C,
    this.externalIdSAP,
    this.documentNumber1C,
    this.documentNumberSAP,
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    this.customerAddress = '',
    this.customerPhone = '',
    this.customerLatitude,
    this.customerLongitude,
    this.priceGroupId = '',
    required this.agentId,
    this.agentName = '',
    required this.agentCode,
    this.regionId = '',
    this.warehouseId = '',
    required this.items,
    double? subtotal,
    this.totalDiscount = 0,
    required this.totalAmount,
    this.paidAmount = 0,
    double? remainingAmount,
    this.currency = 'UZS',
    this.paymentMethod = 'cash',
    this.paymentTermDays = 0,
    this.paymentDueDate,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.status,
    this.paymentStatus = PaymentStatus.unpaid,
    required this.createdAt,
    this.submittedAt,
    this.confirmedAt,
    this.syncedTo1CAt,
    this.syncedToSAPAt,
    this.syncError,
    this.syncRetryCount = 0,
    this.notes,
    this.cancelReason,
    this.metadata,
  })  : subtotal = subtotal ?? totalAmount,
        remainingAmount = remainingAmount ?? (totalAmount - paidAmount);

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: (json['id'] ?? '').toString(),
        orderNumber: (json['orderNumber'] ?? '').toString(),
        idempotencyKey: (json['idempotencyKey'] ?? '').toString(),
        externalId1C: json['externalId1C']?.toString(),
        externalIdSAP: json['externalIdSAP']?.toString(),
        documentNumber1C: json['documentNumber1C']?.toString(),
        documentNumberSAP: json['documentNumberSAP']?.toString(),
        customerId: (json['customerId'] ?? '').toString(),
        customerCode: (json['customerCode'] ?? '').toString(),
        customerName: (json['customerName'] ?? '').toString(),
        customerAddress: (json['customerAddress'] ?? '').toString(),
        customerPhone: (json['customerPhone'] ?? '').toString(),
        customerLatitude: (json['customerLatitude'] as num?)?.toDouble(),
        customerLongitude: (json['customerLongitude'] as num?)?.toDouble(),
        priceGroupId: (json['priceGroupId'] ?? '').toString(),
        agentId: (json['agentId'] ?? '').toString(),
        agentName: (json['agentName'] ?? '').toString(),
        agentCode: (json['agentCode'] ?? '').toString(),
        regionId: (json['regionId'] ?? '').toString(),
        warehouseId: (json['warehouseId'] ?? '').toString(),
        items: (json['items'] as List? ?? [])
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        subtotal: (json['subtotal'] ?? json['totalAmount'] ?? 0).toDouble(),
        totalDiscount: (json['totalDiscount'] ?? 0).toDouble(),
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        paidAmount: (json['paidAmount'] ?? 0).toDouble(),
        remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
        currency: (json['currency'] ?? 'UZS').toString(),
        paymentMethod: (json['paymentMethod'] ?? 'cash').toString(),
        paymentTermDays: json['paymentTermDays'] ?? 0,
        paymentDueDate: json['paymentDueDate'] == null
            ? null
            : DateTime.tryParse(json['paymentDueDate'].toString()),
        deliveryDate: json['deliveryDate'] == null
            ? null
            : DateTime.tryParse(json['deliveryDate'].toString()),
        deliveryTimeSlot: json['deliveryTimeSlot']?.toString(),
        deliveryAddress: json['deliveryAddress']?.toString(),
        deliveryLatitude: (json['deliveryLatitude'] as num?)?.toDouble(),
        deliveryLongitude: (json['deliveryLongitude'] as num?)?.toDouble(),
        status: OrderStatus.fromJson(json['status']?.toString()),
        paymentStatus:
            PaymentStatus.fromJson(json['paymentStatus']?.toString()),
        createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
            DateTime.now(),
        submittedAt: json['submittedAt'] == null
            ? null
            : DateTime.tryParse(json['submittedAt'].toString()),
        confirmedAt: json['confirmedAt'] == null
            ? null
            : DateTime.tryParse(json['confirmedAt'].toString()),
        syncedTo1CAt: json['syncedTo1CAt'] == null
            ? null
            : DateTime.tryParse(json['syncedTo1CAt'].toString()),
        syncedToSAPAt: json['syncedToSAPAt'] == null
            ? null
            : DateTime.tryParse(json['syncedToSAPAt'].toString()),
        syncError: json['syncError']?.toString(),
        syncRetryCount: json['syncRetryCount'] ?? 0,
        notes: json['notes']?.toString(),
        cancelReason: json['cancelReason']?.toString(),
        metadata: json['metadata'] is Map
            ? Map<String, dynamic>.from(json['metadata'])
            : null,
      );

  Order copyWith({
    String? id,
    String? orderNumber,
    String? idempotencyKey,
    String? externalId1C,
    String? externalIdSAP,
    String? documentNumber1C,
    String? documentNumberSAP,
    String? customerId,
    String? customerCode,
    String? customerName,
    String? customerAddress,
    String? customerPhone,
    double? customerLatitude,
    double? customerLongitude,
    String? priceGroupId,
    String? agentId,
    String? agentName,
    String? agentCode,
    String? regionId,
    String? warehouseId,
    List<OrderItem>? items,
    double? subtotal,
    double? totalDiscount,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    String? currency,
    String? paymentMethod,
    int? paymentTermDays,
    DateTime? paymentDueDate,
    DateTime? deliveryDate,
    String? deliveryTimeSlot,
    String? deliveryAddress,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? submittedAt,
    DateTime? confirmedAt,
    DateTime? syncedTo1CAt,
    DateTime? syncedToSAPAt,
    String? syncError,
    int? syncRetryCount,
    String? notes,
    String? cancelReason,
    Map<String, dynamic>? metadata,
  }) =>
      Order(
        id: id ?? this.id,
        orderNumber: orderNumber ?? this.orderNumber,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        externalId1C: externalId1C ?? this.externalId1C,
        externalIdSAP: externalIdSAP ?? this.externalIdSAP,
        documentNumber1C: documentNumber1C ?? this.documentNumber1C,
        documentNumberSAP: documentNumberSAP ?? this.documentNumberSAP,
        customerId: customerId ?? this.customerId,
        customerCode: customerCode ?? this.customerCode,
        customerName: customerName ?? this.customerName,
        customerAddress: customerAddress ?? this.customerAddress,
        customerPhone: customerPhone ?? this.customerPhone,
        customerLatitude: customerLatitude,
        customerLongitude: customerLongitude,
        priceGroupId: priceGroupId ?? this.priceGroupId,
        agentId: agentId ?? this.agentId,
        agentName: agentName ?? this.agentName,
        agentCode: agentCode ?? this.agentCode,
        regionId: regionId ?? this.regionId,
        warehouseId: warehouseId ?? this.warehouseId,
        items: items ?? this.items,
        subtotal: subtotal ?? this.subtotal,
        totalDiscount: totalDiscount ?? this.totalDiscount,
        totalAmount: totalAmount ?? this.totalAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        currency: currency ?? this.currency,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentTermDays: paymentTermDays ?? this.paymentTermDays,
        paymentDueDate: paymentDueDate ?? this.paymentDueDate,
        deliveryDate: deliveryDate ?? this.deliveryDate,
        deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
        deliveryAddress: deliveryAddress ?? this.deliveryAddress,
        deliveryLatitude: deliveryLatitude,
        deliveryLongitude: deliveryLongitude,
        status: status ?? this.status,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        createdAt: createdAt ?? this.createdAt,
        submittedAt: submittedAt ?? this.submittedAt,
        confirmedAt: confirmedAt ?? this.confirmedAt,
        syncedTo1CAt: syncedTo1CAt ?? this.syncedTo1CAt,
        syncedToSAPAt: syncedToSAPAt ?? this.syncedToSAPAt,
        syncError: syncError ?? this.syncError,
        syncRetryCount: syncRetryCount ?? this.syncRetryCount,
        notes: notes ?? this.notes,
        cancelReason: cancelReason ?? this.cancelReason,
        metadata: metadata ?? this.metadata,
      );

  bool get isSyncedTo1C =>
      externalId1C != null ||
      syncedTo1CAt != null ||
      status == OrderStatus.syncedTo1C;
  bool get isSyncedToSAP =>
      externalIdSAP != null ||
      syncedToSAPAt != null ||
      status == OrderStatus.syncedToSAP;
  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        status,
        paymentStatus,
        totalAmount,
      ];
}

class OrderProduct extends Equatable {
  final String id;
  final String code;
  final String name;
  final String sku;
  final String categoryId;
  final String categoryName;
  final String unitOfMeasure;
  final double weight;
  final double volume;
  final bool isActive;
  final bool isAvailable;
  final String? imageUrl;
  final String? brand;
  final String? barcode;
  final String? description;

  const OrderProduct({
    required this.id,
    required this.code,
    required this.name,
    this.sku = '',
    this.categoryId = '',
    this.categoryName = '',
    this.unitOfMeasure = 'dona',
    this.weight = 0,
    this.volume = 0,
    this.isActive = true,
    this.isAvailable = true,
    this.imageUrl,
    this.brand,
    this.barcode,
    this.description,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) => OrderProduct(
        id: (json['id'] ?? json['Ref_Key'] ?? '').toString(),
        code: (json['code'] ?? json['Code'] ?? '').toString(),
        name: (json['name'] ?? json['Description'] ?? '').toString(),
        sku: (json['sku'] ?? json['SKU'] ?? '').toString(),
        categoryId:
            (json['categoryId'] ?? json['Category_Key'] ?? '').toString(),
        categoryName:
            (json['categoryName'] ?? json['Category_Description'] ?? '')
                .toString(),
        unitOfMeasure:
            (json['unitOfMeasure'] ?? json['UnitOfMeasure'] ?? 'dona')
                .toString(),
        weight: (json['weight'] ?? json['Weight'] ?? 0).toDouble(),
        volume: (json['volume'] ?? json['Volume'] ?? 0).toDouble(),
        isActive: json['isActive'] ?? json['IsActive'] ?? true,
        isAvailable: json['isAvailable'] ?? json['IsAvailable'] ?? true,
        imageUrl: json['imageUrl']?.toString(),
        brand: json['brand']?.toString(),
        barcode: json['barcode']?.toString() ?? json['Barcode']?.toString(),
        description: json['description']?.toString() ??
            json['DescriptionFull']?.toString(),
      );

  @override
  List<Object?> get props => [id, code, name, categoryId];
}

class ProductPrice extends Equatable {
  final String productId;
  final String productCode;
  final String productName;
  final String priceGroupId;
  final double basePrice;
  final double discountPercent;
  final double discountAmount;
  final double finalPrice;
  final String currency;
  final bool hasPromotion;
  final String? promotionName;

  const ProductPrice({
    required this.productId,
    this.productCode = '',
    this.productName = '',
    this.priceGroupId = '',
    required this.basePrice,
    this.discountPercent = 0,
    this.discountAmount = 0,
    double? finalPrice,
    this.currency = 'UZS',
    this.hasPromotion = false,
    this.promotionName,
  }) : finalPrice = finalPrice ?? (basePrice - discountAmount);

  @override
  List<Object?> get props => [productId, priceGroupId, finalPrice, currency];
}

class ProductStock extends Equatable {
  final String productId;
  final String productCode;
  final String warehouseId;
  final String warehouseName;
  final double availableQuantity;
  final double reservedQuantity;
  final double orderedQuantity;
  final double actualQuantity;
  final String unitOfMeasure;
  final DateTime? lastUpdated;

  const ProductStock({
    required this.productId,
    this.productCode = '',
    this.warehouseId = '',
    this.warehouseName = '',
    double? availableQuantity,
    this.reservedQuantity = 0,
    this.orderedQuantity = 0,
    double? actualQuantity,
    this.unitOfMeasure = 'dona',
    this.lastUpdated,
  })  : availableQuantity = availableQuantity ?? (actualQuantity ?? 0),
        actualQuantity =
            actualQuantity ?? ((availableQuantity ?? 0) - reservedQuantity);

  bool get isAvailableForSale => actualQuantity > 0;
  bool canReserve(int quantity) => actualQuantity >= quantity;

  @override
  List<Object?> get props => [productId, warehouseId, actualQuantity];
}

class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String? parentId;
  final String? imageUrl;
  final int sortOrder;
  final int productCount;

  const ProductCategory({
    required this.id,
    required this.name,
    this.parentId,
    this.imageUrl,
    this.sortOrder = 0,
    this.productCount = 0,
  });

  @override
  List<Object?> get props => [id, name];
}

class SyncResult extends Equatable {
  final int total;
  final int success;
  final int failed;
  final List<SyncError> errors;

  const SyncResult({
    required this.total,
    required this.success,
    required this.failed,
    required this.errors,
  });

  bool get allSuccess => failed == 0;
  bool get hasErrors => failed > 0;

  @override
  List<Object?> get props => [total, success, failed];
}

class SyncError extends Equatable {
  final String orderId;
  final String orderNumber;
  final String system;
  final String errorMessage;
  final int errorCode;

  const SyncError({
    required this.orderId,
    required this.orderNumber,
    required this.system,
    required this.errorMessage,
    required this.errorCode,
  });

  @override
  List<Object?> get props => [orderId, system, errorCode];
}
