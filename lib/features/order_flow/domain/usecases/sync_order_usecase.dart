import '../entities/order_flow_entities.dart';

import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

import '../repositories/order_flow_repository.dart';

// ============================================================
// BUYURTMA SINXRONLASH USE CASE
// Buyurtmani 1C va SAP tizimlariga yuborish
// ============================================================

/// Bitta buyurtmani sinxronlash
class SyncOrderToAllSystemsUseCase implements UseCase<Order, SyncOrderParams> {
  final OrderFlowRepository repository;

  SyncOrderToAllSystemsUseCase(this.repository);

  @override
  Future<Either<Failure, Order>> call(SyncOrderParams params) async {
    // 1. Buyurtmani olish
    final orderResult = await repository.getOrderById(params.orderId);

    return orderResult.fold(
      (failure) => Left(failure),
      (order) async {
        // 2. Buyurtma holatini tekshirish
        if (order.status != OrderStatus.draft &&
            order.status != OrderStatus.syncFailed) {
          return Left(OrderFailure(
            message: 'Buyurtma allaqachon yuborilgan',
          ));
        }

        // 3. Holatni "yuborilmoqda" ga o'zgartirish
        await repository.updateOrderStatus(
          orderId: order.id,
          status: OrderStatus.pending,
        );

        // 4. 1C ga yuborish
        final result1C = await _syncTo1C(order);

        // 5. SAP ga yuborish
        final resultSAP = await _syncToSAP(order);

        // 6. Natijalarni birlashtirish
        return _combineResults(order, result1C, resultSAP);
      },
    );
  }

  /// 1C ga yuborish
  Future<Either<Failure, Order>> _syncTo1C(Order order) async {
    try {
      return await repository.syncOrderTo1C(order.id);
    } catch (e) {
      // 1C xatoligi - SAP ga ta'sir qilmaydi
      return Left(ServerFailure(
        message: '1C ga yuborishda xatolik: $e',
      ));
    }
  }

  /// SAP ga yuborish
  Future<Either<Failure, Order>> _syncToSAP(Order order) async {
    try {
      return await repository.syncOrderToSAP(order.id);
    } catch (e) {
      return Left(ServerFailure(
        message: 'SAP ga yuborishda xatolik: $e',
      ));
    }
  }

  /// Natijalarni birlashtirish
  Either<Failure, Order> _combineResults(
    Order order,
    Either<Failure, Order> result1C,
    Either<Failure, Order> resultSAP,
  ) {
    String? error1C;
    String? errorSAP;
    Order? updatedOrder = order;

    result1C.fold(
      (failure) => error1C = failure.message,
      (o) => updatedOrder = o,
    );

    resultSAP.fold(
      (failure) => errorSAP = failure.message,
      (o) => updatedOrder = o,
    );

    // Ikkalasi ham muvaffaqiyatsiz
    if (error1C != null && errorSAP != null) {
      return Left(ServerFailure(
        message: 'Sinxronlash muvaffaqiyatsiz:\n1C: $error1C\nSAP: $errorSAP',
      ));
    }

    // Biri muvaffaqiyatsiz
    if (error1C != null || errorSAP != null) {
      return Right(updatedOrder!.copyWith(
        status: OrderStatus.submitted,
        syncError: 'Qisman sinxronlash: ${error1C ?? errorSAP}',
      ));
    }

    // Ikkalasi ham muvaffaqiyatli
    return Right(updatedOrder!.copyWith(
      status: OrderStatus.confirmed,
      confirmedAt: DateTime.now(),
    ));
  }
}

// ============================================================
// BARCHA SINXRONLANMAGAN BUYURTMALARNI SINXRONLASH
// ============================================================

class SyncAllPendingOrdersUseCase implements UseCase<SyncResult, NoParams> {
  final OrderFlowRepository repository;

  SyncAllPendingOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, SyncResult>> call(NoParams params) async {
    // 1. Sinxronlanmagan buyurtmalarni olish
    final pendingResult = await repository.getPendingSyncOrders();

    return pendingResult.fold(
      (failure) => Left(failure),
      (orders) async {
        if (orders.isEmpty) {
          return const Right(SyncResult(
            total: 0,
            success: 0,
            failed: 0,
            errors: [],
          ));
        }

        // 2. Har birini sinxronlash
        int success = 0;
        int failed = 0;
        List<SyncError> errors = [];

        for (final order in orders) {
          final result = await repository.syncOrderToAll(order.id);

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
          total: orders.length,
          success: success,
          failed: failed,
          errors: errors,
        ));
      },
    );
  }
}

// ============================================================
// BUYURTMA HOLATINI SINXRONLASH (POLLING)
// ============================================================

class PollOrderStatusUseCase implements UseCase<Order, SyncOrderParams> {
  final OrderFlowRepository repository;

  PollOrderStatusUseCase(this.repository);

  @override
  Future<Either<Failure, Order>> call(SyncOrderParams params) async {
    return await repository.getOrderById(params.orderId);
  }
}

// ============================================================
// PARAMETRLAR
// ============================================================

class SyncOrderParams extends Equatable {
  final String orderId;
  final bool force; // Majburan qayta yuborish

  const SyncOrderParams({
    required this.orderId,
    this.force = false,
  });

  @override
  List<Object?> get props => [orderId, force];
}
