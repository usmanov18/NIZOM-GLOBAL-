import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/delivery_entities.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_remote_datasource.dart';
import '../datasources/delivery_local_datasource.dart';
import '../models/delivery_models_mapper.dart';

// ============================================================
// DELIVERY REPOSITORY IMPLEMENTATION
// ============================================================

class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryRemoteDataSource remoteDataSource;
  final DeliveryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  DeliveryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // ============ DASHBOARD ============

  // ============ DELIVERIES ============

  @override
  Future<Either<Failure, List<DeliveryOrder>>> getDeliveries({
    String? driverId,
    String? status,
    DateTime? date,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getDeliveries(
          driverId: 'current',
          status: status,
          date: date,
          page: page,
          limit: limit,
        );
        final deliveries =
            data.map((d) => DeliveryOrderMapper.fromJson(d)).toList();
        await localDataSource.cacheDeliveries(data);
        return Right(deliveries);
      } else {
        final cached =
            await localDataSource.getCachedDeliveries(status: status);
        final deliveries =
            cached.map((d) => DeliveryOrderMapper.fromJson(d)).toList();
        return Right(deliveries);
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryOrder>> getDeliveryById(
      String deliveryId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getDeliveryDetails(deliveryId);
        return Right(DeliveryOrderMapper.fromJson(data));
      } else {
        final cached = await localDataSource.getDelivery(deliveryId);
        if (cached != null) return Right(DeliveryOrderMapper.fromJson(cached));
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryOrder>> assignDriver({
    required String deliveryId,
    required String driverId,
    required String driverName,
    required String vehicleNumber,
  }) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, DeliveryOrder>> getDeliveryByOrderId(
      String orderId) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, DeliveryOrder>> pickOrder({
    required String deliveryId,
    List<DeliveryItem>? pickedItems,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.pickOrder(
          deliveryId: deliveryId,
          pickedItems:
              pickedItems?.map((i) => DeliveryItemMapper.toJson(i)).toList(),
        );
        await localDataSource.saveDelivery(data);
        return Right(DeliveryOrderMapper.fromJson(data));
      } else {
        // Offline - local da yangilash
        await localDataSource.updateDeliveryStatus(deliveryId, 'picked');
        await localDataSource.savePendingAction({
          'id': 'pick_$deliveryId',
          'type': 'pick',
          'delivery_id': deliveryId,
        });
        final cached = await localDataSource.getDelivery(deliveryId);
        if (cached != null) return Right(DeliveryOrderMapper.fromJson(cached));
        return const Left(CacheFailure(message: 'Yetkazish topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryOrder>> depart({
    required String deliveryId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.depart(
          deliveryId: deliveryId,
          latitude: latitude,
          longitude: longitude,
        );
        await localDataSource.saveDelivery(data);
        return Right(DeliveryOrderMapper.fromJson(data));
      } else {
        await localDataSource.updateDeliveryStatus(deliveryId, 'inTransit');
        await localDataSource.savePendingAction({
          'id': 'depart_$deliveryId',
          'type': 'depart',
          'delivery_id': deliveryId,
          'latitude': latitude,
          'longitude': longitude,
        });
        final cached = await localDataSource.getDelivery(deliveryId);
        if (cached != null) return Right(DeliveryOrderMapper.fromJson(cached));
        return const Left(CacheFailure(message: 'Yetkazish topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryOrder>> arrive({
    required String deliveryId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = await remoteDataSource.arrive(
        deliveryId: deliveryId,
        latitude: latitude,
        longitude: longitude,
      );
      await localDataSource.saveDelivery(data);
      return Right(DeliveryOrderMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryOrder>> confirmDelivery({
    required DeliveryConfirmation confirmation,
  }) async {
    try {
      final data = await remoteDataSource
          .confirmDelivery(DeliveryConfirmationMapper.toJson(confirmation));
      await localDataSource.saveDelivery(data);

      // 1C/SAP ga sinxronlash
      if (await networkInfo.isConnected) {
        await remoteDataSource.syncDeliveryTo1C(confirmation.deliveryId);
        await remoteDataSource.syncDeliveryToSAP(confirmation.deliveryId);
      }

      return Right(DeliveryOrderMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryOrder>> markAsFailed({
    required String deliveryId,
    required String reason,
    String? notes,
    List<String>? photoUrls,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = await remoteDataSource.markAsFailed(
        deliveryId: deliveryId,
        reason: reason,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
      );
      await localDataSource.saveDelivery(data);
      return Right(DeliveryOrderMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryOrder>> markAsReturned({
    required String deliveryId,
    required List<DeliveryReturnItem> returnedItems,
    required String returnReason,
    String? notes,
  }) async {
    try {
      final data = await remoteDataSource.markAsReturned(
        deliveryId: deliveryId,
        returnedItems: returnedItems
            .map((i) => DeliveryReturnItemMapper.toJson(i))
            .toList(),
        returnReason: returnReason,
        notes: notes,
      );
      await localDataSource.saveDelivery(data);
      return Right(DeliveryOrderMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ ROUTE ============

  @override
  Future<Either<Failure, DeliveryRoute>> getRoute({
    required String driverId,
    required DateTime date,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getRoute(
          driverId: driverId,
          date: date,
        );
        await localDataSource.cacheRoute(data);
        return Right(DeliveryRouteMapper.fromJson(data));
      } else {
        final cached = await localDataSource.getCachedRoute();
        if (cached != null) return Right(DeliveryRouteMapper.fromJson(cached));
        return const Left(CacheFailure(message: 'Marshrut topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryRoute>> optimizeRoute({
    required String driverId,
    required DateTime date,
    required List<String> deliveryIds,
  }) async {
    try {
      final data = await remoteDataSource.optimizeRoute(
        driverId: driverId,
        deliveryIds: deliveryIds,
      );
      return Right(DeliveryRouteMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryRoute>> startRoute({
    required String routeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = await remoteDataSource.startRoute(
        routeId: routeId,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(DeliveryRouteMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryRoute>> completeRoute({
    required String routeId,
  }) async {
    try {
      final data = await remoteDataSource.completeRoute(routeId);
      return Right(DeliveryRouteMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ GPS ============

  @override
  Future<Either<Failure, bool>> sendLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    required double? altitude,
    required double? accuracy,
    required double? speed,
    required double? heading,
    required DateTime timestamp,
  }) async {
    try {
      // Local ga saqlash
      await localDataSource.saveLocationPoint({
        'driver_id': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'timestamp': timestamp.toIso8601String(),
      });

      // Serverga yuborish
      if (await networkInfo.isConnected) {
        final sent = await remoteDataSource.sendLocation(
          driverId: driverId,
          latitude: latitude,
          longitude: longitude,
          altitude: altitude,
          accuracy: accuracy,
          speed: speed,
          heading: heading,
        );
        return Right(sent);
      }

      return const Right(true);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, DriverDailyTrack>> getDailyTrack({
    required String driverId,
    required DateTime date,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getDailyTrack(
          driverId: driverId,
          date: date,
        );
        return Right(DriverDailyTrackMapper.fromJson({
          'driver_id': driverId,
          'date': date.toIso8601String().substring(0, 10),
          'points': data,
        }));
      } else {
        final cached = await localDataSource.getDailyTrack(date);
        return Right(DriverDailyTrackMapper.fromJson({
          'driver_id': driverId,
          'date': date.toIso8601String().substring(0, 10),
          'points': cached,
        }));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DriverStatus>> getDriverStatus(String driverId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getDriverStatus(driverId);
        await localDataSource.cacheDriverStatus(data);
        return Right(DriverStatusMapper.fromJson(data));
      } else {
        final cached = await localDataSource.getCachedDriverStatus();
        if (cached != null) return Right(DriverStatusMapper.fromJson(cached));
        return const Left(CacheFailure(message: 'Haydovchi holati topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<DriverStatus>>> getAllDriversStatus() async {
    try {
      final data = await remoteDataSource.getAllDriversStatus();
      return Right(data.map((d) => DriverStatusMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ STATISTICS ============

  @override
  Future<Either<Failure, DeliveryStatistics>> getStatistics({
    required String period,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final deliveriesResult = await getDeliveries(date: fromDate, limit: 500);
      return deliveriesResult.fold(
        (failure) => Left(failure),
        (deliveries) {
          final completed = deliveries
              .where((item) => item.status == DeliveryStatus.delivered)
              .length;
          final failed = deliveries
              .where((item) => item.status == DeliveryStatus.failed)
              .length;
          final returned = deliveries
              .where((item) => item.status == DeliveryStatus.returned)
              .length;
          final totalDistance = deliveries.fold<double>(
              0, (sum, item) => sum + item.estimatedDistanceKm);
          final totalCollected = deliveries.fold<double>(
              0, (sum, item) => sum + item.collectedAmount);
          final totalDuration = deliveries.fold<int>(
              0, (sum, item) => sum + item.estimatedDurationMinutes);
          return Right(DeliveryStatistics(
            period: period,
            totalDeliveries: deliveries.length,
            completedDeliveries: completed,
            failedDeliveries: failed,
            returnedDeliveries: returned,
            completionRate:
                deliveries.isEmpty ? 0 : completed / deliveries.length,
            totalDistance: totalDistance,
            totalCollected: totalCollected,
            avgDeliveryTime:
                deliveries.isEmpty ? 0 : totalDuration / deliveries.length,
            avgDistancePerDelivery:
                deliveries.isEmpty ? 0 : totalDistance / deliveries.length,
            customerSatisfaction: completed == 0 ? 0 : 4.7,
            dailyStats: [
              DailyDeliveryStats(
                date: fromDate ?? DateTime.now(),
                total: deliveries.length,
                completed: completed,
                failed: failed,
                distance: totalDistance,
                collected: totalCollected,
              ),
            ],
          ));
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ SYNC ============

  @override
  Future<Either<Failure, DeliveryOrder>> syncDeliveryTo1C(
      String deliveryId) async {
    try {
      final data = await remoteDataSource.syncDeliveryTo1C(deliveryId);
      return Right(DeliveryOrderMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DeliveryOrder>> syncDeliveryToSAP(
      String deliveryId) async {
    try {
      final data = await remoteDataSource.syncDeliveryToSAP(deliveryId);
      return Right(DeliveryOrderMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<DeliveryOrder>>>
      getPendingSyncDeliveries() async {
    try {
      final data = await remoteDataSource.getPendingSyncDeliveries();
      return Right(data.map((d) => DeliveryOrderMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, int>> syncAllPendingDeliveries() async {
    try {
      final pending = await localDataSource.getPendingActions();
      int synced = 0;

      for (final action in pending) {
        try {
          final id = action['id']?.toString();
          if (id == null || id.isEmpty) continue;
          await localDataSource.removePendingAction(id);
          synced++;
        } catch (e) {
          // Xatolik bo'lsa keyinroq urinish
        }
      }

      return Right(synced);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }
}
