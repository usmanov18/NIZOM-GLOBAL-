import '../../domain/entities/order_flow_entities.dart';

import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/errors/failures.dart';
import '../../../../core/network/one_c/one_c_api_client.dart';
import '../../../../core/network/sap/sap_api_client.dart';
import '../../../../core/services/sync_queue/sync_queue_service.dart';

import '../../domain/repositories/order_flow_repository.dart';
import '../../domain/policies/order_validation_policy.dart';
import '../datasources/order_local_datasource.dart';
import '../mappers/order_sync_payload_mapper.dart';
import '../mappers/order_sync_payload_validator.dart';

// ============================================================
// ORDER FLOW REPOSITORY IMPLEMENTATION
// 1C va SAP bilan ishlash, offline cache
// ============================================================

class OrderFlowRepositoryImpl implements OrderFlowRepository {
  final OneCAPIClient oneCClient;
  final SAPAPIClient sapClient;
  final OrderLocalDataSource localDataSource;
  final SyncQueueService? syncQueueService;
  final bool isOnline;
  final String agentCode;

  OrderFlowRepositoryImpl({
    required this.oneCClient,
    required this.sapClient,
    required this.localDataSource,
    this.syncQueueService,
    required this.isOnline,
    this.agentCode = 'AG001',
  });

  Either<Failure, Order>? _validateOrderBeforeSync(Order order) {
    final validation = OrderValidationPolicy.validateBeforeSync(
      role: 'agent',
      order: order,
    );
    if (!validation.isValid) {
      return Left(
          ValidationFailure(message: validation.blockingMessages.join('\n')));
    }
    return null;
  }

  Map<String, dynamic> _orderSyncPayload(Order order) =>
      OrderSyncPayloadMapper.generic(order);

  Map<String, dynamic>? _pricingSnapshotFor(Order order, String productId) =>
      OrderSyncPayloadMapper.pricingSnapshotFor(order, productId);

  Map<String, dynamic> _territoryPayload(Order order) =>
      OrderSyncPayloadMapper.territory(order);

  Failure? _syncPayloadFailure(OrderSyncPayloadValidationResult validation) {
    if (!validation.isValid) {
      return ValidationFailure(message: validation.blockingMessages.join('\n'));
    }
    return null;
  }

  Future<void> _enqueueOrderSync(Order order) async {
    await syncQueueService?.enqueueOrder(
      orderId: order.id,
      payload: _orderSyncPayload(order),
    );
  }

  // ============ MIJOZLAR ============

  @override
  Future<Either<Failure, List<OrderCustomer>>> getCustomers({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (isOnline) {
        // 1C dan olish
        final result = await oneCClient.getAgentCustomers(
          agentCode: agentCode,
          top: limit,
          skip: (page - 1) * limit,
        );

        return result.fold(
          (failure) => Left(failure),
          (data) {
            final customers = data
                .map((json) => OrderCustomer(
                      id: json['Ref_Key'] ?? '',
                      code: json['Code'] ?? '',
                      name: json['Description'] ?? '',
                      legalName: json['LegalName'] ?? '',
                      inn: json['INN'] ?? '',
                      address: json['Address'] ?? '',
                      phone: json['Phone'] ?? '',
                      email: json['Email'],
                      contactPerson: json['ContactPerson'],
                      latitude: json['Latitude']?.toDouble(),
                      longitude: json['Longitude']?.toDouble(),
                      agentId: 'agent_1',
                      priceGroupId: json['PriceGroup_Key'] ?? '',
                      paymentTerms: json['PaymentTerms'] ?? 'NET30',
                      creditLimit: (json['CreditLimit'] ?? 0).toDouble(),
                      currentDebt: (json['CurrentDebt'] ?? 0).toDouble(),
                      availableCredit: ((json['CreditLimit'] ?? 0) -
                              (json['CurrentDebt'] ?? 0))
                          .toDouble(),
                      paymentDelayDays: json['PaymentDelayDays'] ?? 30,
                      isActive: json['IsActive'] ?? true,
                      isBlocked: json['IsBlocked'] ?? false,
                      blockReason: json['BlockReason'],
                      lastOrderDate: json['LastOrderDate'] != null
                          ? DateTime.parse(json['LastOrderDate'])
                          : null,
                      lastOrderAmount:
                          (json['LastOrderAmount'] ?? 0).toDouble(),
                    ))
                .toList();

            // Cache ga saqlash
            localDataSource.cacheCustomers(data);

            return Right(customers);
          },
        );
      } else {
        // Offline - cache dan olish
        final cached = await localDataSource.getCachedCustomers();
        return Right(cached
            .map((json) => OrderCustomer(
                  id: json['Ref_Key'] ?? '',
                  code: json['Code'] ?? '',
                  name: json['Description'] ?? '',
                  legalName: json['LegalName'] ?? '',
                  inn: json['INN'] ?? '',
                  address: json['Address'] ?? '',
                  phone: json['Phone'] ?? '',
                  agentId: 'agent_1',
                  priceGroupId: json['PriceGroup_Key'] ?? '',
                  paymentTerms: 'NET30',
                  creditLimit: 0,
                  currentDebt: 0,
                  availableCredit: 0,
                  paymentDelayDays: 30,
                  isActive: true,
                  isBlocked: false,
                  lastOrderAmount: 0,
                ))
            .toList());
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Mijozlar yuklashda xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderCustomer>> getCustomerById(
      String customerId) async {
    try {
      final result = await oneCClient.getCustomerDetails(customerId);
      return result.fold(
        (failure) => Left(failure),
        (json) => Right(OrderCustomer(
          id: json['Ref_Key'] ?? '',
          code: json['Code'] ?? '',
          name: json['Description'] ?? '',
          legalName: json['LegalName'] ?? '',
          inn: json['INN'] ?? '',
          address: json['Address'] ?? '',
          phone: json['Phone'] ?? '',
          agentId: 'agent_1',
          priceGroupId: json['PriceGroup_Key'] ?? '',
          paymentTerms: 'NET30',
          creditLimit: (json['CreditLimit'] ?? 0).toDouble(),
          currentDebt: (json['CurrentDebt'] ?? 0).toDouble(),
          availableCredit: 0,
          paymentDelayDays: 30,
          isActive: true,
          isBlocked: false,
          lastOrderAmount: 0,
        )),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Mijoz topilmadi'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getCustomerOrders({
    required String customerId,
    int limit = 10,
  }) async {
    try {
      final orders = await localDataSource.getAllOrders();
      final filtered = orders
          .where((order) => order.customerId == customerId)
          .take(limit)
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Mijoz buyurtmalarini olishda xatolik'));
    }
  }

  // ============ MAHSULOTLAR ============

  @override
  Future<Either<Failure, List<OrderProduct>>> getProducts({
    String? categoryId,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final result = await oneCClient.getProducts(
        categoryId: categoryId,
        search: search,
        top: limit,
        skip: (page - 1) * limit,
      );

      return result.fold(
        (failure) => Left(failure),
        (data) => Right(data
            .map((json) => OrderProduct(
                  id: json['Ref_Key'] ?? '',
                  code: json['Code'] ?? '',
                  name: json['Description'] ?? '',
                  sku: json['SKU'] ?? '',
                  barcode: json['Barcode'],
                  categoryId: json['ProductCategory_Key'] ?? '',
                  categoryName: json['ProductCategory_Description'] ?? '',
                  description: json['DescriptionFull'],
                  imageUrl: json['ImageUrl'],
                  unitOfMeasure: json['UnitOfMeasure'] ?? 'dona',
                  weight: (json['Weight'] ?? 0).toDouble(),
                  volume: (json['Volume'] ?? 0).toDouble(),
                  isActive: json['DeletionMark'] != true,
                  isAvailable: json['IsAvailable'] ?? true,
                ))
            .toList()),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Mahsulotlar yuklashda xatolik'));
    }
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getCategories() async {
    try {
      final productsResult = await getProducts(limit: 200);
      return productsResult.fold(
        (failure) => Left(failure),
        (products) {
          final grouped = <String, List<OrderProduct>>{};
          for (final product in products) {
            final id = product.categoryId.isEmpty
                ? 'uncategorized'
                : product.categoryId;
            grouped.putIfAbsent(id, () => <OrderProduct>[]).add(product);
          }
          final categories = grouped.entries.map((entry) {
            final first = entry.value.first;
            return ProductCategory(
              id: entry.key,
              name: first.categoryName.isEmpty
                  ? 'Kategoriyasiz'
                  : first.categoryName,
              productCount: entry.value.length,
            );
          }).toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          return Right(categories);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Kategoriyalarni olishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, ProductPrice>> getProductPrice({
    required String productId,
    required String priceGroupId,
  }) async {
    try {
      final result = await oneCClient.getProductPrice(
        productRefKey: productId,
        priceGroupRefKey: priceGroupId,
      );

      return result.fold(
        (failure) => Left(failure),
        (json) => Right(ProductPrice(
          productId: productId,
          productCode: json['Product_Code'] ?? '',
          productName: json['Product_Description'] ?? '',
          priceGroupId: priceGroupId,
          basePrice: (json['BasePrice'] ?? 0).toDouble(),
          discountPercent: (json['DiscountPercent'] ?? 0).toDouble(),
          discountAmount: (json['DiscountAmount'] ?? 0).toDouble(),
          finalPrice: (json['Price'] ?? 0).toDouble(),
          currency: json['Currency'] ?? 'UZS',
          hasPromotion: json['HasPromotion'] ?? false,
        )),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Narx yuklashda xatolik'));
    }
  }

  @override
  Future<Either<Failure, List<ProductPrice>>> getProductsPrices({
    required List<String> productIds,
    required String priceGroupId,
  }) async {
    final prices = <ProductPrice>[];
    for (final id in productIds) {
      final result =
          await getProductPrice(productId: id, priceGroupId: priceGroupId);
      result.fold(
        (_) {},
        (price) => prices.add(price),
      );
    }
    return Right(prices);
  }

  // ============ OMBOR ============

  @override
  Future<Either<Failure, ProductStock>> getProductStock({
    required String productId,
    required String warehouseId,
  }) async {
    try {
      final result = await oneCClient.getStockBalance(
        warehouseRefKey: warehouseId,
        productRefKey: productId,
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          if (data.isNotEmpty) {
            final json = data.first;
            return Right(ProductStock(
              productId: productId,
              productCode: json['Product_Code'] ?? '',
              warehouseId: warehouseId,
              warehouseName: json['Warehouse_Description'] ?? '',
              availableQuantity: (json['Quantity'] ?? 0).toDouble(),
              reservedQuantity: (json['Reserved'] ?? 0).toDouble(),
              orderedQuantity: (json['Ordered'] ?? 0).toDouble(),
              actualQuantity:
                  ((json['Quantity'] ?? 0) - (json['Reserved'] ?? 0))
                      .toDouble(),
              unitOfMeasure: json['UnitOfMeasure'] ?? 'dona',
              lastUpdated: DateTime.now(),
            ));
          }
          return Right(ProductStock(
            productId: productId,
            productCode: '',
            warehouseId: warehouseId,
            warehouseName: '',
            availableQuantity: 0,
            reservedQuantity: 0,
            orderedQuantity: 0,
            actualQuantity: 0,
            unitOfMeasure: 'dona',
            lastUpdated: DateTime.now(),
          ));
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Ombor qoldig\'ini olishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, List<ProductStock>>> getProductsStock({
    required List<String> productIds,
    required String warehouseId,
  }) async {
    final stocks = <ProductStock>[];
    for (final id in productIds) {
      final result =
          await getProductStock(productId: id, warehouseId: warehouseId);
      result.fold(
        (_) {},
        (stock) => stocks.add(stock),
      );
    }
    return Right(stocks);
  }

  // ============ BUYURTMALAR ============

  @override
  Future<Either<Failure, Order>> createOrder(Order order) async {
    try {
      // Local ga saqlash
      await localDataSource.saveOrder(order);
      await _enqueueOrderSync(order);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: 'Buyurtma yaratishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, Order>> updateOrder(Order order) async {
    try {
      await localDataSource.saveOrder(order);
      await _enqueueOrderSync(order);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: 'Buyurtma yangilashda xatolik'));
    }
  }

  @override
  Future<Either<Failure, Order>> submitOrder(String orderId) async {
    try {
      final order = await localDataSource.getOrder(orderId);
      if (order == null) return const Left(OrderNotFoundFailure());

      final updatedOrder = order.copyWith(
        status: OrderStatus.submitted,
        submittedAt: DateTime.now(),
      );
      await localDataSource.saveOrder(updatedOrder);
      return Right(updatedOrder);
    } catch (e) {
      return Left(ServerFailure(message: 'Buyurtma yuborishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, Order>> syncOrderTo1C(String orderId) async {
    try {
      final order = await localDataSource.getOrder(orderId);
      if (order == null) return const Left(OrderNotFoundFailure());
      final validationFailure = _validateOrderBeforeSync(order);
      if (validationFailure != null) return validationFailure;

      final orderData = OrderSyncPayloadMapper.oneC(order);
      final payloadFailure =
          _syncPayloadFailure(OrderSyncPayloadValidator.oneC(orderData));
      if (payloadFailure != null) return Left(payloadFailure);

      final result = await oneCClient.createOrder(orderData);

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final updated = order.copyWith(
            externalId1C: data['Ref_Key'],
            documentNumber1C: data['Number'],
            syncedTo1CAt: DateTime.now(),
            status: OrderStatus.syncedTo1C,
          );
          localDataSource.saveOrder(updated);
          return Right(updated);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: '1C ga yuborishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, Order>> syncOrderToSAP(String orderId) async {
    try {
      final order = await localDataSource.getOrder(orderId);
      if (order == null) return const Left(OrderNotFoundFailure());
      final validationFailure = _validateOrderBeforeSync(order);
      if (validationFailure != null) return validationFailure;

      final orderData = OrderSyncPayloadMapper.sap(order);
      final payloadFailure =
          _syncPayloadFailure(OrderSyncPayloadValidator.sap(orderData));
      if (payloadFailure != null) return Left(payloadFailure);

      final result = await sapClient.createOrder(orderData);

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final updated = order.copyWith(
            externalIdSAP: data['SalesOrder'],
            documentNumberSAP: data['SalesOrder'],
            syncedToSAPAt: DateTime.now(),
          );
          localDataSource.saveOrder(updated);
          return Right(updated);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'SAP ga yuborishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, Order>> syncOrderToAll(String orderId) async {
    final order = await localDataSource.getOrder(orderId);
    if (order == null) return const Left(OrderNotFoundFailure());

    // --- SAGA ORCHESTRATION START ---
    // 1. Birinchi bo'lib 1C ga yuboramiz (Stock reservation)
    final result1C = await syncOrderTo1C(orderId);

    return await result1C.fold(
        (failure1C) => Left(ServerFailure(
            message:
                '1C xatosi tufayli butun tranzaksiya to\'xtatildi: ${failure1C.message}')),
        (synced1C) async {
      // 2. 1C muvaffaqiyatli bo'lsa, SAP ga yuboramiz (Financials)
      final resultSAP = await syncOrderToSAP(orderId);

      return await resultSAP.fold(
        (failureSAP) async {
          // COMPENSATING ACTION: SAP xato bersa, 1C dagi buyurtmani "Pending-Error" qilish kerak
          await updateOrderStatus(
              orderId: orderId,
              status: OrderStatus.syncFailed,
              comment: 'SAP xatosi: ${failureSAP.message}');
          return Left(ServerFailure(
              message:
                  '1C ga yozildi, lekin SAP rad etdi. Admin aralashuvi shart.'));
        },
        (syncedSAP) => Right(syncedSAP), // Har ikkala tizim tasdiqladi
      );
    });
    // --- SAGA ORCHESTRATION END ---
  }

  @override
  Future<Either<Failure, Order>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? comment,
  }) async {
    try {
      final order = await localDataSource.getOrder(orderId);
      if (order == null) return const Left(OrderNotFoundFailure());

      final updated = order.copyWith(status: status);
      await localDataSource.saveOrder(updated);
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(message: 'Holat yangilashda xatolik'));
    }
  }

  @override
  Future<Either<Failure, Order>> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final order = await localDataSource.getOrder(orderId);
      if (order == null) return const Left(OrderNotFoundFailure());

      final updated = order.copyWith(
        status: OrderStatus.cancelled,
        cancelReason: reason,
      );
      await localDataSource.saveOrder(updated);
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(message: 'Bekor qilishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrders({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final orders = await localDataSource.getAllOrders();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(message: 'Buyurtmalarni olishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final order = await localDataSource.getOrder(orderId);
      if (order == null) return const Left(OrderNotFoundFailure());
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: 'Buyurtma topilmadi'));
    }
  }

  // ============ OFFLINE ============

  @override
  Future<Either<Failure, List<Order>>> getPendingSyncOrders() async {
    try {
      final orders = await localDataSource.getPendingOrders();
      return Right(orders);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Sinxronlash buyurtmalarini olishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, SyncResult>> syncAllPendingOrders() async {
    try {
      final pending = await localDataSource.getPendingOrders();
      int success = 0;
      int failed = 0;
      List<SyncError> errors = [];

      for (final order in pending) {
        final result = await syncOrderToAll(order.id);
        result.fold(
          (failure) {
            failed++;
            errors.add(SyncError(
              orderId: order.id,
              orderNumber: order.orderNumber,
              system: 'Both',
              errorMessage: failure.message,
              errorCode: failure.statusCode ?? 0,
            ));
          },
          (_) => success++,
        );
      }

      return Right(SyncResult(
        total: pending.length,
        success: success,
        failed: failed,
        errors: errors,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Sinxronlashda xatolik'));
    }
  }

  @override
  Future<Either<Failure, Order>> saveOrderLocally(Order order) async {
    try {
      await localDataSource.saveOrder(order);
      await _enqueueOrderSync(order);
      return Right(order);
    } catch (e) {
      return Left(CacheFailure(message: 'Local saqlashda xatolik'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteLocalOrder(String orderId) async {
    try {
      await localDataSource.deleteOrder(orderId);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(message: 'O\'chirishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, String>> generateOrderNumber() async {
    try {
      final now = DateTime.now();
      final number =
          'ORD-${now.year}-${now.millisecondsSinceEpoch.toString().substring(8)}';
      return Right(number);
    } catch (e) {
      return Left(ServerFailure(message: 'Raqam generatsiyasida xatolik'));
    }
  }
}
