import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/delivery_entities.dart';

// ============================================================
// DELIVERY REPOSITORY - Yetkazib berish API
// ============================================================

abstract class DeliveryRepository {
  // ============ YETKAZISH BUYURTMALARI ============

  /// Haydovchi yetkazish buyurtmalari
  Future<Either<Failure, List<DeliveryOrder>>> getDeliveries({
    String? driverId,
    String? status,
    DateTime? date,
    int page = 1,
    int limit = 20,
  });

  /// Yetkazish tafsilotlari
  Future<Either<Failure, DeliveryOrder>> getDeliveryById(String deliveryId);

  /// Buyurtma bo'yicha yetkazish
  Future<Either<Failure, DeliveryOrder>> getDeliveryByOrderId(String orderId);

  // ============ YETKAZISH HOLATI ============

  /// Yetkazishni haydovchiga biriktirish
  Future<Either<Failure, DeliveryOrder>> assignDriver({
    required String deliveryId,
    required String driverId,
    required String driverName,
    required String vehicleNumber,
  });

  /// Ombordan olish (pick up)
  Future<Either<Failure, DeliveryOrder>> pickOrder({
    required String deliveryId,
    List<DeliveryItem>? pickedItems,
  });

  /// Yo'lga chiqish
  Future<Either<Failure, DeliveryOrder>> depart({
    required String deliveryId,
    required double latitude,
    required double longitude,
  });

  /// Manzilga yetib kelish
  Future<Either<Failure, DeliveryOrder>> arrive({
    required String deliveryId,
    required double latitude,
    required double longitude,
  });

  /// Yetkazib berish tasdig'i
  Future<Either<Failure, DeliveryOrder>> confirmDelivery({
    required DeliveryConfirmation confirmation,
  });

  /// Muvaffaqiyatsiz yetkazish
  Future<Either<Failure, DeliveryOrder>> markAsFailed({
    required String deliveryId,
    required String reason,
    String? notes,
    List<String>? photoUrls,
    required double latitude,
    required double longitude,
  });

  /// Qaytarish
  Future<Either<Failure, DeliveryOrder>> markAsReturned({
    required String deliveryId,
    required List<DeliveryReturnItem> returnedItems,
    required String returnReason,
    String? notes,
  });

  // ============ MARSHRUT ============

  /// Haydovchi marshruti
  Future<Either<Failure, DeliveryRoute>> getRoute({
    required String driverId,
    required DateTime date,
  });

  /// Marshrutni optimizatsiya qilish
  Future<Either<Failure, DeliveryRoute>> optimizeRoute({
    required String driverId,
    required DateTime date,
    required List<String> deliveryIds,
  });

  /// Marshrutni boshlash
  Future<Either<Failure, DeliveryRoute>> startRoute({
    required String routeId,
    required double latitude,
    required double longitude,
  });

  /// Marshrutni tugatish
  Future<Either<Failure, DeliveryRoute>> completeRoute({
    required String routeId,
  });

  // ============ GPS TRACKING ============

  /// GPS lokatsiya yuborish
  Future<Either<Failure, bool>> sendLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    required double? altitude,
    required double? accuracy,
    required double? speed,
    required double? heading,
    required DateTime timestamp,
  });

  /// Haydovchi kunlik marshruti
  Future<Either<Failure, DriverDailyTrack>> getDailyTrack({
    required String driverId,
    required DateTime date,
  });

  /// Haydovchi real vaqt holati
  Future<Either<Failure, DriverStatus>> getDriverStatus(String driverId);

  /// Barcha haydovchilar holati
  Future<Either<Failure, List<DriverStatus>>> getAllDriversStatus();

  // ============ STATISTIKA ============

  /// Yetkazish statistikasi
  Future<Either<Failure, DeliveryStatistics>> getStatistics({
    required String period,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  // ============ 1C/SAP SINXRONLASH ============

  /// Yetkazishni 1C ga yuborish
  Future<Either<Failure, DeliveryOrder>> syncDeliveryTo1C(String deliveryId);

  /// Yetkazishni SAP ga yuborish
  Future<Either<Failure, DeliveryOrder>> syncDeliveryToSAP(String deliveryId);

  /// Sinxronlanmagan yetkazishlar
  Future<Either<Failure, List<DeliveryOrder>>> getPendingSyncDeliveries();

  /// Barcha sinxronlash
  Future<Either<Failure, int>> syncAllPendingDeliveries();
}
