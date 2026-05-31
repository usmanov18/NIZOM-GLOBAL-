import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/one_c/one_c_api_client.dart';
import '../../../../core/network/one_c/models/one_c_document_models.dart';
import '../../../../core/network/sap/sap_api_client.dart';

// ============================================================
// ORDER CREATION LOGIC
// To'lov turiga qarab 1C/SAP da hujjat yaratish
// ============================================================
//
// 1C LOGIKASI:
// ├── Bank/Kredit to'lov → ЗаказКлиента (Buyurtma) yaratiladi
// │   └── Keyin РеализацияТоваров ga aylantiriladi
// └── Naqd/Plastik to'lov → РеализацияТоваров (Sotuv) to'g'ridan-to'g'ri yaratiladi
//
// SAP LOGIKASI:
// ├── Bank/Kredit to'lov → Sales Order (OR/ZOR) yaratiladi
// │   └── Keyin Delivery/Invoice yaratiladi
// └── Naqd/Plastik to'lov → Sales Order + Immediate Delivery + Invoice
//
// HOLAT KUZATISH:
// └── РеализацияТоваров dan holat olinadi (Проведен/НеПроведен)
// ============================================================

class OrderCreationLogic {
  final OneCAPIClient oneCClient;
  final SAPAPIClient sapClient;

  OrderCreationLogic({
    required this.oneCClient,
    required this.sapClient,
  });

  // ============ ASOSIY LOGIKA ============

  /// Buyurtma yaratish - to'lov turiga qarab
  Future<Either<Failure, OrderCreationResult>> createOrder({
    required OrderCreationRequest request,
  }) async {
    try {
      // 1. To'lov turini aniqlash
      final paymentType = _determinePaymentType(request.paymentMethod);

      // 2. 1C da yaratish
      final result1C = await _createIn1C(request, paymentType);

      // 3. SAP da yaratish
      final resultSAP = await _createInSAP(request, paymentType);

      // 4. Natijalarni birlashtirish
      return Right(OrderCreationResult(
        orderId: request.orderId,
        paymentType: paymentType,
        result1C: result1C,
        resultSAP: resultSAP,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Buyurtma yaratishda xatolik: $e'));
    }
  }

  /// To'lov turini aniqlash
  OneCPaymentType _determinePaymentType(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return OneCPaymentType.cash;
      case 'card':
        return OneCPaymentType.card;
      case 'transfer':
      case 'bank':
        return OneCPaymentType.transfer;
      case 'credit':
      case 'muddatli':
        return OneCPaymentType.credit;
      default:
        return OneCPaymentType.cash;
    }
  }

  // ============ 1C DA YARATISH ============

  /// 1C da hujjat yaratish
  Future<OneCOrderCreationResult> _createIn1C(
    OrderCreationRequest request,
    OneCPaymentType paymentType,
  ) async {
    switch (paymentType) {
      case OneCPaymentType.cash:
      case OneCPaymentType.card:
        // Naqd/Plastik → РеализацияТоваровУслуг
        return await _createSaleDocument(request);

      case OneCPaymentType.transfer:
      case OneCPaymentType.credit:
        // Bank/Kredit → ЗаказКлиента
        return await _createClientOrder(request);
    }
  }

  /// ЗаказКлиента yaratish (Bank/Kredit uchun)
  Future<OneCOrderCreationResult> _createClientOrder(
    OrderCreationRequest request,
  ) async {
    final orderData = {
      'Date': request.orderDate.toIso8601String(),
      'Number': request.orderNumber,
      'Status': 'Новый',

      // Контрагент
      'Контрагент_Key': request.customerId,
      'Контрагент_Code': request.customerCode,
      'Контрагент_Description': request.customerName,

      // Организация
      'Организация_Key': request.organizationId,

      // Склад
      'Склад_Key': request.warehouseId,
      'Склад_Code': request.warehouseCode,

      // Ответственный
      'Ответственный_Key': request.agentId,
      'Ответственный_Code': request.agentCode,

      // Табличная часть
      'ТабличнаяЧасть': request.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return {
          'НомерСтроки': index + 1,
          'Номенклатура_Key': item.productId,
          'Номенклатура_Code': item.productCode,
          'Номенклатура_Description': item.productName,
          'Характеристика_Key': item.characteristicId ?? '',
          'Количество': item.quantity,
          'ЕдиницаИзмерения_Key': item.unitId,
          'ЕдиницаИзмерения_Description': item.unitName,
          'Коэффициент': item.unitFactor,
          'Цена': item.unitPrice,
          'Сумма': item.amount,
          'ПроцентСкидки': item.discountPercent,
          'СуммаСкидки': item.discountAmount,
          'СуммаСоСкидкой': item.amountWithDiscount,
          'СтавкаНДС': item.taxRate,
          'СуммаНДС': item.taxAmount,
          'Всего': item.totalAmount,
          'Склад_Key': request.warehouseId,
          'Комментарий': '',
          'Подарок': item.isGift,
          if (item.promotionId != null) 'Акция_Key': item.promotionId,
        };
      }).toList(),

      // Суммы
      'СуммаДокумента': request.totalAmount,
      'СуммаСкидки': request.totalDiscount,
      'СуммаНДС': request.totalTax,
      'Валюта': request.currency,

      // Оплата
      'СпособОплаты': request.paymentMethod,
      'УсловияОплаты': request.paymentTerms,
      'Отсрочка': request.paymentDays,
      'ДатаПлатежа': request.paymentDueDate?.toIso8601String(),

      // Доставка
      'ДатаДоставки': request.deliveryDate?.toIso8601String(),
      'ВремяДоставки': request.deliveryTimeSlot,
      'АдресДоставки': request.deliveryAddress,

      // Прочее
      'Комментарий': request.notes ?? '',
    };

    final result = await oneCClient.createOrder(orderData);

    return result.fold(
      (failure) => OneCOrderCreationResult(
        documentType: OneCDocumentType.order,
        documentRefKey: '',
        documentNumber: '',
        documentDate: '',
        status: 'Error',
        amount: 0,
        posted: false,
        errorMessage: failure.message,
      ),
      (data) => OneCOrderCreationResult.fromJson({
        ...data,
        'DocumentType': 'ЗаказКлиента',
      }),
    );
  }

  /// РеализацияТоваровУслуг yaratish (Naqd/Plastik uchun)
  Future<OneCOrderCreationResult> _createSaleDocument(
    OrderCreationRequest request,
  ) async {
    final saleData = {
      'Date': request.orderDate.toIso8601String(),
      'Number': '${request.orderNumber}-S',
      'Status': 'Новый',
      'ВидОперации': 'Реализация',

      // Контрагент
      'Контрагент_Key': request.customerId,
      'Контрагент_Code': request.customerCode,
      'Контрагент_Description': request.customerName,

      // Организация
      'Организация_Key': request.organizationId,

      // Склад
      'Склад_Key': request.warehouseId,
      'Склад_Code': request.warehouseCode,

      // Ответственный
      'Ответственный_Key': request.agentId,
      'Ответственный_Code': request.agentCode,

      // Договор
      'Договор_Key': request.contractId,
      'Договор_Nomer': request.contractNumber,

      // Табличная часть
      'ТабличнаяЧасть': request.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return {
          'НомерСтроки': index + 1,
          'Номенклатура_Key': item.productId,
          'Номенклатура_Code': item.productCode,
          'Номенклатура_Description': item.productName,
          'Характеристика_Key': item.characteristicId ?? '',
          'Количество': item.quantity,
          'ЕдиницаИзмерения_Key': item.unitId,
          'ЕдиницаИзмерения_Description': item.unitName,
          'Коэффициент': item.unitFactor,
          'Цена': item.unitPrice,
          'Сумма': item.amount,
          'ПроцентСкидки': item.discountPercent,
          'СуммаСкидки': item.discountAmount,
          'СуммаСоСкидкой': item.amountWithDiscount,
          'СтавкаНДС': item.taxRate,
          'СуммаНДС': item.taxAmount,
          'Всего': item.totalAmount,
          'Склад_Key': request.warehouseId,
          'Комментарий': '',
          'Подарок': item.isGift,
          if (item.promotionId != null) 'Акция_Key': item.promotionId,
        };
      }).toList(),

      // Суммы
      'СуммаДокумента': request.totalAmount,
      'СуммаСкидки': request.totalDiscount,
      'СуммаНДС': request.totalTax,
      'Валюта': request.currency,

      // Оплата
      'СпособОплаты': request.paymentMethod,
      'Оплачено': request.paidAmount,
      'Остаток': request.totalAmount - request.paidAmount,

      // Доставка
      'АдресДоставки': request.deliveryAddress,

      // Прочее
      'Комментарий': request.notes ?? '',
    };

    final result = await oneCClient.createOrder(saleData);

    return result.fold(
      (failure) => OneCOrderCreationResult(
        documentType: OneCDocumentType.sale,
        documentRefKey: '',
        documentNumber: '',
        documentDate: '',
        status: 'Error',
        amount: 0,
        posted: false,
        errorMessage: failure.message,
      ),
      (data) => OneCOrderCreationResult.fromJson({
        ...data,
        'DocumentType': 'РеализацияТоваровУслуг',
      }),
    );
  }

  // ============ SAP DA YARATISH ============

  /// SAP da hujjat yaratish
  Future<SAPOrderCreationResult> _createInSAP(
    OrderCreationRequest request,
    OneCPaymentType paymentType,
  ) async {
    final orderData = {
      'SalesOrderType': 'ZOR',
      'SalesOrganization': '1000',
      'DistributionChannel': '10',
      'Division': '00',
      'SoldToParty': request.customerCode,
      'ShipToParty': request.customerCode,
      'PurchaseOrderNumber': request.orderNumber,
      'RequestedDeliveryDate':
          request.deliveryDate?.toIso8601String().substring(0, 10) ?? '',
      'PricingDate': request.orderDate.toIso8601String().substring(0, 10),
      'PaymentTerms': request.paymentTerms,
      'TransactionCurrency': request.currency,
      'SalesPerson': request.agentCode,

      // Naqd bo'lsa, darhol yetkazish
      if (paymentType == OneCPaymentType.cash ||
          paymentType == OneCPaymentType.card)
        'DeliveryBlock': ''
      else
        'DeliveryBlock': '01', // Bank kutish

      'TotalNetAmount': request.totalAmount.toString(),
      'CustomerReference': request.orderNumber,
      'HeaderText': request.notes ?? '',

      'to_Item': request.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return {
          'SalesOrderItem': ((index + 1) * 10).toString().padLeft(6, '0'),
          'Material': item.productCode,
          'MaterialDescription': item.productName,
          'RequestedQuantity': item.quantity.toString(),
          'SalesUnit': item.unitName,
          'Plant': request.warehouseCode,
          'ItemCategory': 'TAN',
          'NetAmount': item.amountWithDiscount.toString(),
          'to_PricingElement': [
            {
              'ConditionType': 'ZPRC',
              'ConditionRateAmount': item.unitPrice.toString(),
              'ConditionCurrency': request.currency,
            },
            if (item.discountPercent > 0)
              {
                'ConditionType': 'ZDIS',
                'ConditionRateAmount': item.discountPercent.toString(),
              },
          ],
        };
      }).toList(),

      'to_Partner': [
        {'PartnerFunction': 'SP', 'Customer': request.customerCode},
        {'PartnerFunction': 'SH', 'Customer': request.customerCode},
      ],
    };

    final result = await sapClient.createOrder(orderData);

    return result.fold(
      (failure) => SAPOrderCreationResult(
        salesOrder: '',
        salesOrderType: '',
        status: 'Error',
        amount: 0,
        isSuccess: false,
        errorMessage: failure.message,
      ),
      (data) => SAPOrderCreationResult.fromJson(data),
    );
  }

  // ============ HOLATNI KUZATISH ============

  /// 1C da Реализация holatini olish (Проведен/НеПроведен)
  Future<Either<Failure, OneCSaleDocumentStatus>> getSaleDocumentStatus({
    required String saleDocumentKey,
  }) async {
    try {
      final result = await oneCClient.getOrderDetails(saleDocumentKey);

      return result.fold(
        (failure) => Left(failure),
        (data) => Right(OneCSaleDocumentStatus.fromJson(data)),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Holat olishda xatolik: $e'));
    }
  }

  /// Заказ holatini olish va Реализация ga bog'lash
  Future<Either<Failure, OrderStatusResult>> getOrderStatus({
    required String orderKey,
  }) async {
    try {
      // 1. Заказ holatini olish
      final orderResult = await oneCClient.getOrderDetails(orderKey);

      return orderResult.fold(
        (failure) => Left(failure),
        (orderData) async {
          final order = OneCClientOrder.fromJson(orderData);

          // 2. Agar Реализация mavjud bo'lsa, uning holatini ham olish
          OneCSaleDocumentStatus? saleStatus;

          if (order.hasSaleDocument) {
            final saleResult = await getSaleDocumentStatus(
              saleDocumentKey: order.saleDocumentKey!,
            );
            saleResult.fold(
              (_) {},
              (status) => saleStatus = status,
            );
          }

          return Right(OrderStatusResult(
            orderStatus: order,
            saleStatus: saleStatus,
            checkedAt: DateTime.now(),
          ));
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Holat olishda xatolik: $e'));
    }
  }

  /// Real vaqt holat kuzatish (polling)
  Stream<OrderStatusResult> trackOrderStatus({
    required String orderKey,
    Duration interval = const Duration(seconds: 30),
  }) async* {
    while (true) {
      await Future.delayed(interval);
      final result = await getOrderStatus(orderKey: orderKey);
      yield* result.fold(
        (failure) => const Stream.empty(),
        (status) async* {
          yield status;
          // Agar tugallangan bo'lsa, to'xtatish
          if (status.isCompleted) return;
        },
      );
    }
  }
}

// ============ YORDAMCHI SINFLAR ============

/// Buyurtma yaratish so'rovi
class OrderCreationRequest {
  final String orderId;
  final String orderNumber;
  final DateTime orderDate;

  // Customer
  final String customerId;
  final String customerCode;
  final String customerName;
  final String customerGroupId;
  final String priceGroupId;

  // Agent
  final String agentId;
  final String agentCode;
  final String agentName;

  // Organization
  final String organizationId;

  // Contract
  final String contractId;
  final String contractNumber;

  // Warehouse
  final String warehouseId;
  final String warehouseCode;
  final String warehouseName;

  // Items
  final List<OrderCreationItem> items;

  // Amounts
  final double totalAmount;
  final double totalDiscount;
  final double totalTax;
  final String currency;

  // Payment
  final String paymentMethod; // cash, card, transfer, credit
  final String paymentTerms; // NET30
  final int paymentDays;
  final double paidAmount;
  final DateTime? paymentDueDate;

  // Delivery
  final DateTime? deliveryDate;
  final String? deliveryTimeSlot;
  final String? deliveryAddress;

  // Notes
  final String? notes;

  const OrderCreationRequest({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.customerGroupId,
    required this.priceGroupId,
    required this.agentId,
    required this.agentCode,
    required this.agentName,
    required this.organizationId,
    required this.contractId,
    required this.contractNumber,
    required this.warehouseId,
    required this.warehouseCode,
    required this.warehouseName,
    required this.items,
    required this.totalAmount,
    required this.totalDiscount,
    required this.totalTax,
    required this.currency,
    required this.paymentMethod,
    required this.paymentTerms,
    required this.paymentDays,
    required this.paidAmount,
    this.paymentDueDate,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.deliveryAddress,
    this.notes,
  });
}

/// Buyurtma elementi
class OrderCreationItem {
  final String productId;
  final String productCode;
  final String productName;
  final String? characteristicId;
  final int quantity;
  final String unitId;
  final String unitName;
  final double unitFactor;
  final double unitPrice;
  final double amount;
  final double discountPercent;
  final double discountAmount;
  final double amountWithDiscount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final bool isGift;
  final String? promotionId;

  const OrderCreationItem({
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
  });
}

/// Buyurtma yaratish natijasi
class OrderCreationResult {
  final String orderId;
  final OneCPaymentType paymentType;
  final OneCOrderCreationResult? result1C;
  final SAPOrderCreationResult? resultSAP;
  final DateTime createdAt;

  const OrderCreationResult({
    required this.orderId,
    required this.paymentType,
    this.result1C,
    this.resultSAP,
    required this.createdAt,
  });

  bool get isSyncedTo1C => result1C?.isSuccess ?? false;
  bool get isSyncedToSAP => resultSAP?.isSuccess ?? false;
  bool get isSuccess => isSyncedTo1C || isSyncedToSAP;

  String? get oneCDocumentType =>
      result1C?.documentType == OneCDocumentType.order
          ? 'ЗаказКлиента'
          : result1C?.documentType == OneCDocumentType.sale
              ? 'РеализацияТоваровУслуг'
              : null;
}

/// SAP yaratish natijasi
class SAPOrderCreationResult {
  final String salesOrder;
  final String salesOrderType;
  final String status;
  final double amount;
  final bool isSuccess;
  final String? errorMessage;

  const SAPOrderCreationResult({
    required this.salesOrder,
    required this.salesOrderType,
    required this.status,
    required this.amount,
    required this.isSuccess,
    this.errorMessage,
  });

  factory SAPOrderCreationResult.fromJson(Map<String, dynamic> json) {
    return SAPOrderCreationResult(
      salesOrder: json['SalesOrder'] ?? '',
      salesOrderType: json['SalesOrderType'] ?? '',
      status: json['OverallOrderStatus'] ?? '',
      amount: double.tryParse(json['TotalNetAmount'] ?? '0') ?? 0,
      isSuccess: (json['SalesOrder'] ?? '').isNotEmpty,
      errorMessage: json['SalesOrderErrorMessage'],
    );
  }
}

/// Buyurtma holati natijasi
class OrderStatusResult {
  final OneCClientOrder orderStatus;
  final OneCSaleDocumentStatus? saleStatus;
  final DateTime checkedAt;

  const OrderStatusResult({
    required this.orderStatus,
    this.saleStatus,
    required this.checkedAt,
  });

  bool get isCompleted {
    // Заказ tugallangan
    if (orderStatus.status == 'Выполнен') return true;

    // Реализация Проведен bo'lsa
    if (saleStatus != null && saleStatus!.posted) return true;

    return false;
  }

  bool get hasSaleDocument => saleStatus != null;

  bool get isFullyPaid {
    if (saleStatus != null) return saleStatus!.isFullyPaid;
    return orderStatus.isPaid;
  }

  String get statusText {
    if (saleStatus != null && saleStatus!.posted) {
      return 'Sotuv o\'tkazildi (${saleStatus!.number})';
    }
    if (orderStatus.hasSaleDocument) {
      return 'Sotuv hujjati yaratildi';
    }
    if (orderStatus.status == 'Выполнен') {
      return 'Buyurtma tugallangan';
    }
    if (orderStatus.status == 'ВРаботе') {
      return 'Ish jarayonida';
    }
    return orderStatus.status;
  }
}
