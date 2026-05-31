import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/one_c/one_c_api_client.dart';
import '../../../../core/network/one_c/models/one_c_order_models.dart';
import '../../../../core/network/sap/sap_api_client.dart';
import '../../../../core/network/sap/models/sap_order_models.dart';
import '../../domain/entities/order_sync_entities.dart';

// ============================================================
// ORDER SYNC SERVICE
// Buyurtma va qaytarishlarni 1C/SAP ga yuborish va kuzatish
// ============================================================

class OrderSyncService {
  final OneCAPIClient oneCClient;
  final SAPAPIClient sapClient;
  final StreamController<SyncEvent> _eventController =
      StreamController<SyncEvent>.broadcast();

  OrderSyncService({
    required this.oneCClient,
    required this.sapClient,
  });

  /// Real vaqt voqealar oqimi
  Stream<SyncEvent> get syncEvents => _eventController.stream;

  // ============ BUYURTMA YARATISH ============

  /// Buyurtmani 1C va SAP ga parallel yuborish
  Future<Either<Failure, OrderSyncResult>> submitOrder({
    required OrderSyncRequest request,
    bool syncTo1C = true,
    bool syncToSAP = true,
  }) async {
    final startTime = DateTime.now();
    _eventController.add(SyncEvent(
      orderId: request.orderId,
      type: SyncEventType.orderSubmitting,
      message: 'Buyurtma yuborilmoqda...',
    ));

    String? oneCRefKey;
    String? oneCNumber;
    String? sapSalesOrder;
    String? error1C;
    String? errorSAP;

    // 1C ga yuborish
    if (syncTo1C) {
      _eventController.add(SyncEvent(
        orderId: request.orderId,
        type: SyncEventType.syncingTo1C,
        message: '1C ga yuborilmoqda...',
      ));

      final result1C = await _submitTo1C(request);
      result1C.fold(
        (failure) {
          error1C = failure.message;
          _eventController.add(SyncEvent(
            orderId: request.orderId,
            type: SyncEventType.sync1CFailed,
            message: '1C xatolik: ${failure.message}',
          ));
        },
        (response) {
          oneCRefKey = response.refKey;
          oneCNumber = response.number;
          _eventController.add(SyncEvent(
            orderId: request.orderId,
            type: SyncEventType.sync1CCompleted,
            message: '1C ga yuborildi: ${response.number}',
          ));
        },
      );
    }

    // SAP ga yuborish
    if (syncToSAP) {
      _eventController.add(SyncEvent(
        orderId: request.orderId,
        type: SyncEventType.syncingToSAP,
        message: 'SAP ga yuborilmoqda...',
      ));

      final resultSAP = await _submitToSAP(request);
      resultSAP.fold(
        (failure) {
          errorSAP = failure.message;
          _eventController.add(SyncEvent(
            orderId: request.orderId,
            type: SyncEventType.syncSAPFailed,
            message: 'SAP xatolik: ${failure.message}',
          ));
        },
        (response) {
          sapSalesOrder = response.salesOrder;
          _eventController.add(SyncEvent(
            orderId: request.orderId,
            type: SyncEventType.syncSAPCompleted,
            message: 'SAP ga yuborildi: ${response.salesOrder}',
          ));
        },
      );
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    // Natija
    final result = OrderSyncResult(
      orderId: request.orderId,
      oneCRefKey: oneCRefKey,
      oneCNumber: oneCNumber,
      sapSalesOrder: sapSalesOrder,
      error1C: error1C,
      errorSAP: errorSAP,
      isSyncedTo1C: oneCRefKey != null,
      isSyncedToSAP: sapSalesOrder != null,
      submittedAt: startTime,
      completedAt: endTime,
      duration: duration,
    );

    _eventController.add(SyncEvent(
      orderId: request.orderId,
      type: result.isSuccess
          ? SyncEventType.orderSubmitted
          : SyncEventType.orderSubmitFailed,
      message: result.isSuccess
          ? 'Buyurtma muvaffaqiyatli yuborildi'
          : 'Buyurtma yuborishda xatolik',
      data: result.toJson(),
    ));

    return Right(result);
  }

  /// 1C ga yuborish
  Future<Either<Failure, OneCOrderResponse>> _submitTo1C(
    OrderSyncRequest request,
  ) async {
    try {
      final orderData = _build1COrderData(request);
      final result = await oneCClient.createOrder(orderData);

      return result.fold(
        (failure) => Left(failure),
        (data) => Right(OneCOrderResponse.fromJson(data)),
      );
    } catch (e) {
      return Left(ServerFailure(message: '1C ga yuborishda xatolik: $e'));
    }
  }

  /// SAP ga yuborish
  Future<Either<Failure, SAPOrderResponse>> _submitToSAP(
    OrderSyncRequest request,
  ) async {
    try {
      final orderData = _buildSAPOrderData(request);
      final result = await sapClient.createOrder(orderData);

      return result.fold(
        (failure) => Left(failure),
        (data) => Right(SAPOrderResponse.fromJson(data)),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'SAP ga yuborishda xatolik: $e'));
    }
  }

  // ============ QAYTARISH YARATISH ============

  /// Qaytarishni 1C va SAP ga parallel yuborish
  Future<Either<Failure, ReturnSyncResult>> submitReturn({
    required ReturnSyncRequest request,
    bool syncTo1C = true,
    bool syncToSAP = true,
  }) async {
    final startTime = DateTime.now();
    _eventController.add(SyncEvent(
      orderId: request.orderId,
      type: SyncEventType.returnSubmitting,
      message: 'Qaytarish yuborilmoqda...',
    ));

    String? oneCRefKey;
    String? sapReturnOrder;
    String? error1C;
    String? errorSAP;

    // 1C ga yuborish
    if (syncTo1C) {
      final result1C = await _submitReturnTo1C(request);
      result1C.fold(
        (failure) => error1C = failure.message,
        (response) {
          oneCRefKey = response.refKey;
          _eventController.add(SyncEvent(
            orderId: request.orderId,
            type: SyncEventType.return1CCompleted,
            message: '1C ga qaytarish yuborildi',
          ));
        },
      );
    }

    // SAP ga yuborish
    if (syncToSAP) {
      final resultSAP = await _submitReturnToSAP(request);
      resultSAP.fold(
        (failure) => errorSAP = failure.message,
        (response) {
          sapReturnOrder = response.salesOrder;
          _eventController.add(SyncEvent(
            orderId: request.orderId,
            type: SyncEventType.returnSAPCompleted,
            message: 'SAP ga qaytarish yuborildi',
          ));
        },
      );
    }

    final result = ReturnSyncResult(
      orderId: request.orderId,
      returnId: request.returnId,
      oneCRefKey: oneCRefKey,
      sapReturnOrder: sapReturnOrder,
      error1C: error1C,
      errorSAP: errorSAP,
      isSyncedTo1C: oneCRefKey != null,
      isSyncedToSAP: sapReturnOrder != null,
      submittedAt: startTime,
      completedAt: DateTime.now(),
    );

    return Right(result);
  }

  Future<Either<Failure, OneCOrderResponse>> _submitReturnTo1C(
    ReturnSyncRequest request,
  ) async {
    try {
      final data = _build1CReturnData(request);
      final result = await oneCClient.createOrder(data);

      return result.fold(
        (failure) => Left(failure),
        (data) => Right(OneCOrderResponse.fromJson(data)),
      );
    } catch (e) {
      return Left(
          ServerFailure(message: '1C ga qaytarish yuborishda xatolik: $e'));
    }
  }

  Future<Either<Failure, SAPOrderResponse>> _submitReturnToSAP(
    ReturnSyncRequest request,
  ) async {
    try {
      final data = _buildSAPReturnData(request);
      final result = await sapClient.createOrder(data);

      return result.fold(
        (failure) => Left(failure),
        (data) => Right(SAPOrderResponse.fromJson(data)),
      );
    } catch (e) {
      return Left(
          ServerFailure(message: 'SAP ga qaytarish yuborishda xatolik: $e'));
    }
  }

  // ============ HOLATNI KUZATISH ============

  /// Buyurtma holatini 1C dan olish (real vaqt)
  Future<Either<Failure, OneCOrderStatus>> trackOrderIn1C(
    String oneCRefKey,
  ) async {
    try {
      final result = await oneCClient.getOrderDetails(oneCRefKey);

      return result.fold(
        (failure) => Left(failure),
        (data) => Right(OneCOrderStatus.fromJson(data)),
      );
    } catch (e) {
      return Left(ServerFailure(message: '1C dan holat olishda xatolik: $e'));
    }
  }

  /// Buyurtma holatini SAP dan olish (real vaqt)
  Future<Either<Failure, SAPOrderTracking>> trackOrderInSAP(
    String sapSalesOrder,
  ) async {
    try {
      final result = await sapClient.getOrderDetails(sapSalesOrder);

      return result.fold(
        (failure) => Left(failure),
        (data) => Right(SAPOrderTracking.fromJson(data)),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'SAP dan holat olishda xatolik: $e'));
    }
  }

  /// Buyurtma holatini ikkala tizimdan olish
  Future<Either<Failure, OrderTrackingResult>> trackOrder({
    String? oneCRefKey,
    String? sapSalesOrder,
  }) async {
    OneCOrderStatus? status1C;
    SAPOrderTracking? statusSAP;
    String? error1C;
    String? errorSAP;

    if (oneCRefKey != null) {
      final result = await trackOrderIn1C(oneCRefKey);
      result.fold(
        (failure) => error1C = failure.message,
        (status) => status1C = status,
      );
    }

    if (sapSalesOrder != null) {
      final result = await trackOrderInSAP(sapSalesOrder);
      result.fold(
        (failure) => errorSAP = failure.message,
        (status) => statusSAP = status,
      );
    }

    return Right(OrderTrackingResult(
      oneCStatus: status1C,
      sapStatus: statusSAP,
      error1C: error1C,
      errorSAP: errorSAP,
      trackedAt: DateTime.now(),
    ));
  }

  /// Periodik holat yangilash (polling)
  Stream<OrderTrackingResult> trackOrderPeriodically({
    String? oneCRefKey,
    String? sapSalesOrder,
    Duration interval = const Duration(seconds: 30),
  }) async* {
    while (true) {
      await Future.delayed(interval);
      final result = await trackOrder(
        oneCRefKey: oneCRefKey,
        sapSalesOrder: sapSalesOrder,
      );
      yield* result.fold(
        (failure) => const Stream.empty(),
        (tracking) async* {
          yield tracking;

          // Agar buyurtma tugallangan bo'lsa, to'xtatish
          if (tracking.isCompleted) return;
        },
      );
    }
  }

  // ============ 1C FORMAT BUILD ============

  Map<String, dynamic> _build1COrderData(OrderSyncRequest request) {
    return {
      'Date': request.orderDate.toIso8601String(),
      'Number': request.orderNumber,
      'Контрагент': {
        'Ref_Key': request.customerId,
        'Code': request.customerCode,
        'Description': request.customerName,
        'ЦеноваяГруппа_Key': request.priceGroupId,
        'Ответственный_Key': request.agentId,
      },
      'Ответственный': {
        'Ref_Key': request.agentId,
        'Code': request.agentCode,
        'Description': request.agentName,
      },
      'Склад': {
        'Ref_Key': request.warehouseId,
        'Code': request.warehouseCode,
        'Description': request.warehouseName,
      },
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
          'Комментарий': item.notes ?? '',
          'Подарок': item.isGift,
          if (item.promotionId != null) 'Акция_Key': item.promotionId,
        };
      }).toList(),
      'СуммаДокумента': request.totalAmount,
      'Валюта': request.currency,
      'СпособОплаты': request.paymentMethod,
      'УсловияОплаты': request.paymentTerms,
      'Отсрочка': request.paymentDays,
      'ДатаДоставки': request.deliveryDate?.toIso8601String(),
      'ВремяДоставки': request.deliveryTimeSlot,
      'АдресДоставки': request.deliveryAddress,
      'Комментарий': request.notes ?? '',
      'Статус': 'Новый',
    };
  }

  // ============ SAP FORMAT BUILD ============

  Map<String, dynamic> _buildSAPOrderData(OrderSyncRequest request) {
    return {
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
      'CustomerPurchaseOrderDate':
          request.orderDate.toIso8601String().substring(0, 10),
      'PaymentTerms': request.paymentTerms,
      'TransactionCurrency': request.currency,
      'SalesDistrict': request.regionId,
      'SalesPerson': request.agentCode,
      'DeliveryBlock': '',
      'BillingBlock': '',
      'OverallDeliveryStatus': 'A',
      'OverallOrderStatus': 'A',
      'TotalNetAmount': request.totalAmount.toString(),
      'CustomerGroup': request.customerGroupId,
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
          'NetPriceAmount': item.unitPrice.toString(),
          'to_PricingElement': [
            {
              'ConditionType': 'ZPRC',
              'ConditionRateAmount': item.unitPrice.toString(),
              'ConditionCurrency': request.currency,
              'ConditionQuantity': '1',
              'ConditionUnit': item.unitName,
            },
            if (item.discountPercent > 0)
              {
                'ConditionType': 'ZDIS',
                'ConditionRateAmount': item.discountPercent.toString(),
                'ConditionCurrency': request.currency,
              },
          ],
        };
      }).toList(),
      'to_Partner': [
        {
          'PartnerFunction': 'SP',
          'PartnerFunctionName': 'Sold-To Party',
          'Customer': request.customerCode,
          'CustomerName': request.customerName,
        },
        {
          'PartnerFunction': 'SH',
          'PartnerFunctionName': 'Ship-To Party',
          'Customer': request.customerCode,
          'CustomerName': request.customerName,
        },
      ],
    };
  }

  // ============ 1C RETURN FORMAT ============

  Map<String, dynamic> _build1CReturnData(ReturnSyncRequest request) {
    return {
      'Date': request.returnDate.toIso8601String(),
      'Number': request.returnNumber,
      'ЗаказКлиента_Key': request.originalOrderId,
      'ЗаказКлиента_Nomer': request.originalOrderNumber,
      'Контрагент': {
        'Ref_Key': request.customerId,
        'Code': request.customerCode,
      },
      'Ответственный': {
        'Ref_Key': request.agentId,
      },
      'Склад': {
        'Ref_Key': request.warehouseId,
      },
      'ТабличнаяЧасть': request.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return {
          'НомерСтроки': index + 1,
          'Номенклатура_Key': item.productId,
          'Номенклатура_Code': item.productCode,
          'Номенклатура_Description': item.productName,
          'Количество': item.quantity,
          'ЕдиницаИзмерения_Key': item.unitId,
          'Цена': item.unitPrice,
          'Сумма': item.amount,
          'ПричинаВозврата': item.returnReason,
          'Состояние': item.condition,
          'Комментарий': item.notes ?? '',
        };
      }).toList(),
      'СуммаДокумента': request.totalAmount,
      'Валюта': 'UZS',
      'ПричинаВозврата': request.returnReason,
      'Комментарий': request.notes ?? '',
      'Статус': 'Новый',
    };
  }

  // ============ SAP RETURN FORMAT ============

  Map<String, dynamic> _buildSAPReturnData(ReturnSyncRequest request) {
    return {
      'SalesOrderType': 'ZRE',
      'SalesOrganization': '1000',
      'DistributionChannel': '10',
      'Division': '00',
      'SoldToParty': request.customerCode,
      'PurchaseOrderNumber': request.returnNumber,
      'CustomerReference': request.originalOrderNumber,
      'RequestedDeliveryDate':
          request.returnDate.toIso8601String().substring(0, 10),
      'TransactionCurrency': 'UZS',
      'ReturnReason': request.returnReason,
      'OriginalSalesOrder': request.sapOriginalOrder ?? '',
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
          'ItemCategory': 'REN',
          'ReturnReason': item.returnReason,
          'Condition': item.condition,
          'NetAmount': item.amount.toString(),
        };
      }).toList(),
    };
  }

  void dispose() {
    _eventController.close();
  }
}
