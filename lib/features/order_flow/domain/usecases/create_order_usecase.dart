import '../entities/order_flow_entities.dart';

import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

import '../repositories/order_flow_repository.dart';

// ============================================================
// BUYURTMA YARATISH USE CASE
// Agent mijoz uchun yangi buyurtma yaratadi
// ============================================================

class CreateOrderUseCase implements UseCase<Order, CreateOrderParams> {
  final OrderFlowRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, Order>> call(CreateOrderParams params) async {
    // 1. Validatsiya
    final validationResult = _validate(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // 2. Mijozni tekshirish
    final customerResult = await repository.getCustomerById(params.customerId);
    return customerResult.fold(
      (failure) => Left(failure),
      (customer) async {
        // 3. Mijoz faol ekanligini tekshirish
        if (!customer.canOrder) {
          return Left(ValidationFailure(
            message: customer.isBlocked
                ? 'Mijoz bloklangan: ${customer.blockReason}'
                : 'Mijoz faol emas',
          ));
        }

        // 4. Mahsulot narxlarini olish
        final productIds = params.items.map((i) => i.productId).toList();
        final pricesResult = await repository.getProductsPrices(
          productIds: productIds,
          priceGroupId: customer.priceGroupId,
        );

        return pricesResult.fold(
          (failure) => Left(failure),
          (prices) async {
            // 5. Ombor qoldiqlarini olish
            final stockResult = await repository.getProductsStock(
              productIds: productIds,
              warehouseId: params.warehouseId,
            );

            return stockResult.fold(
              (failure) => Left(failure),
              (stocks) async {
                // 6. Buyurtma elementlarini yaratish
                final orderItems = _buildOrderItems(
                  params: params,
                  prices: prices,
                  stocks: stocks,
                );

                // 7. Ombor tekshirish
                final stockIssues = orderItems
                    .where((item) => !(item.isStockSufficient))
                    .toList();

                if (stockIssues.isNotEmpty && !params.allowPartialStock) {
                  final names =
                      stockIssues.map((i) => i.productName).join(', ');
                  return Left(InsufficientStockFailure());
                }

                // 8. Summalarni hisoblash
                final subtotal = orderItems.fold<double>(
                  0,
                  (sum, item) => sum + item.totalPrice,
                );
                final totalDiscount = orderItems.fold<double>(
                  0,
                  (sum, item) => sum + item.discountAmount,
                );
                final totalAmount = subtotal - totalDiscount;

                // 9. To'lov muddatini hisoblash
                final paymentDueDate = DateTime.now().add(
                  Duration(days: customer.paymentDelayDays),
                );

                // 10. Buyurtma raqamini olish
                final orderNumberResult =
                    await repository.generateOrderNumber();

                return orderNumberResult.fold(
                  (failure) => Left(failure),
                  (orderNumber) async {
                    // 11. Buyurtma yaratish
                    final order = Order(
                      id: const Uuid().v4(),
                      orderNumber: orderNumber,
                      customerId: customer.id,
                      customerCode: customer.code,
                      customerName: customer.name,
                      customerAddress: customer.address,
                      customerPhone: customer.phone,
                      customerLatitude: customer.latitude,
                      customerLongitude: customer.longitude,
                      priceGroupId: customer.priceGroupId,
                      agentId: params.agentId,
                      agentName: params.agentName,
                      agentCode: params.agentCode,
                      regionId: params.regionId,
                      warehouseId: params.warehouseId,
                      items: orderItems,
                      subtotal: subtotal,
                      totalDiscount: totalDiscount,
                      totalAmount: totalAmount,
                      paidAmount: 0,
                      remainingAmount: totalAmount,
                      currency: 'UZS',
                      paymentMethod: params.paymentMethod,
                      paymentTermDays: customer.paymentDelayDays,
                      paymentDueDate: paymentDueDate,
                      deliveryDate: params.deliveryDate,
                      deliveryTimeSlot: params.deliveryTimeSlot,
                      deliveryAddress:
                          params.deliveryAddress ?? customer.address,
                      deliveryLatitude:
                          params.deliveryLatitude ?? customer.latitude,
                      deliveryLongitude:
                          params.deliveryLongitude ?? customer.longitude,
                      status: OrderStatus.draft,
                      paymentStatus: PaymentStatus.unpaid,
                      createdAt: DateTime.now(),
                      notes: params.notes,
                    );

                    // 12. Local ga saqlash
                    final saveResult = await repository.saveOrderLocally(order);

                    return saveResult;
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// Validatsiya
  Failure? _validate(CreateOrderParams params) {
    if (params.customerId.isEmpty) {
      return const ValidationFailure(message: 'Mijozni tanlang');
    }
    if (params.items.isEmpty) {
      return const ValidationFailure(
          message: 'Kamida bitta mahsulot qo\'shing');
    }
    if (params.warehouseId.isEmpty) {
      return const ValidationFailure(message: 'Omborni tanlang');
    }

    // Dublikat mahsulotlarni tekshirish
    final productIds = params.items.map((i) => i.productId).toList();
    final uniqueIds = productIds.toSet();
    if (productIds.length != uniqueIds.length) {
      return const ValidationFailure(
        message: 'Takrorlangan mahsulotlar mavjud',
      );
    }

    // Miqdor tekshirish
    for (final item in params.items) {
      if (item.quantity <= 0) {
        return ValidationFailure(
          message: '${item.productName} miqdori 0 dan katta bo\'lishi kerak',
        );
      }
    }

    return null;
  }

  /// Buyurtma elementlarini yaratish
  List<OrderItem> _buildOrderItems({
    required CreateOrderParams params,
    required List<ProductPrice> prices,
    required List<ProductStock> stocks,
  }) {
    final items = <OrderItem>[];

    for (final paramItem in params.items) {
      final price = prices.firstWhere(
        (p) => p.productId == paramItem.productId,
        orElse: () => ProductPrice(
          productId: paramItem.productId,
          productCode: '',
          productName: paramItem.productName,
          priceGroupId: '',
          basePrice: 0,
          discountPercent: 0,
          discountAmount: 0,
          finalPrice: 0,
          currency: 'UZS',
          hasPromotion: false,
        ),
      );

      final stock = stocks.firstWhere(
        (s) => s.productId == paramItem.productId,
        orElse: () => ProductStock(
          productId: paramItem.productId,
          productCode: '',
          warehouseId: params.warehouseId,
          warehouseName: '',
          availableQuantity: 0,
          reservedQuantity: 0,
          orderedQuantity: 0,
          actualQuantity: 0,
          unitOfMeasure: 'dona',
          lastUpdated: DateTime.now(),
        ),
      );

      items.add(OrderItem.fromProductAndPrice(
        product: OrderProduct(
          id: paramItem.productId,
          code: price.productCode,
          name: paramItem.productName,
          sku: '',
          categoryId: '',
          categoryName: '',
          unitOfMeasure: 'dona',
          weight: 0,
          volume: 0,
          isActive: true,
          isAvailable: true,
        ),
        price: price,
        stock: stock,
        quantity: paramItem.quantity,
        notes: paramItem.notes,
      ));
    }

    return items;
  }
}

// ============ PARAMETRLAR ============

class CreateOrderParams extends Equatable {
  final String agentId;
  final String agentName;
  final String agentCode;
  final String regionId;
  final String customerId;
  final String warehouseId;
  final List<CreateOrderItemParams> items;
  final String paymentMethod; // cash, card, transfer, credit
  final DateTime? deliveryDate;
  final String? deliveryTimeSlot;
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? notes;
  final bool allowPartialStock; // Qisman ombor bilan ruxsat

  const CreateOrderParams({
    required this.agentId,
    required this.agentName,
    required this.agentCode,
    required this.regionId,
    required this.customerId,
    required this.warehouseId,
    required this.items,
    required this.paymentMethod,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.notes,
    this.allowPartialStock = false,
  });

  @override
  List<Object?> get props => [customerId, warehouseId, items];
}

class CreateOrderItemParams extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final String? notes;

  const CreateOrderItemParams({
    required this.productId,
    required this.productName,
    required this.quantity,
    this.notes,
  });

  @override
  List<Object?> get props => [productId, quantity];
}
