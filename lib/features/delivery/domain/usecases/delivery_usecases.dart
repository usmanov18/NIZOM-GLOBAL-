import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/delivery_entities.dart';
import '../repositories/delivery_repository.dart';

// ============================================================
// DELIVERY USECASES
// ============================================================

class GetDeliveryStats implements UseCase<DeliveryStatistics, NoParams> {
  final DeliveryRepository repository;
  GetDeliveryStats(this.repository);

  @override
  Future<Either<Failure, DeliveryStatistics>> call(NoParams params) {
    return repository.getStatistics(period: 'daily');
  }
}

class GetDeliveries
    implements UseCase<List<DeliveryOrder>, GetDeliveriesParams> {
  final DeliveryRepository repository;
  GetDeliveries(this.repository);

  @override
  Future<Either<Failure, List<DeliveryOrder>>> call(
      GetDeliveriesParams params) {
    return repository.getDeliveries(
      status: params.status,
      date: params.date,
      page: params.page,
    );
  }
}

class PickOrder implements UseCase<DeliveryOrder, String> {
  final DeliveryRepository repository;
  PickOrder(this.repository);

  @override
  Future<Either<Failure, DeliveryOrder>> call(String deliveryId) {
    return repository.pickOrder(deliveryId: deliveryId);
  }
}

class DepartDelivery implements UseCase<DeliveryOrder, DepartParams> {
  final DeliveryRepository repository;
  DepartDelivery(this.repository);

  @override
  Future<Either<Failure, DeliveryOrder>> call(DepartParams params) {
    return repository.depart(
      deliveryId: params.deliveryId,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class ConfirmDelivery implements UseCase<DeliveryOrder, DeliveryConfirmation> {
  final DeliveryRepository repository;
  ConfirmDelivery(this.repository);

  @override
  Future<Either<Failure, DeliveryOrder>> call(
      DeliveryConfirmation confirmation) {
    return repository.confirmDelivery(confirmation: confirmation);
  }
}

class MarkAsFailed implements UseCase<DeliveryOrder, MarkFailedParams> {
  final DeliveryRepository repository;
  MarkAsFailed(this.repository);

  @override
  Future<Either<Failure, DeliveryOrder>> call(MarkFailedParams params) {
    return repository.markAsFailed(
      deliveryId: params.deliveryId,
      reason: params.reason,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class SendLocation implements UseCase<bool, SendLocationParams> {
  final DeliveryRepository repository;
  SendLocation(this.repository);

  @override
  Future<Either<Failure, bool>> call(SendLocationParams params) {
    return repository.sendLocation(
      driverId: params.driverId,
      latitude: params.latitude,
      longitude: params.longitude,
      altitude: params.altitude,
      accuracy: params.accuracy,
      speed: params.speed,
      heading: params.heading,
      timestamp: params.timestamp,
    );
  }
}

class GetDriverStatus implements UseCase<DriverStatus, String> {
  final DeliveryRepository repository;
  GetDriverStatus(this.repository);

  @override
  Future<Either<Failure, DriverStatus>> call(String driverId) {
    return repository.getDriverStatus(driverId);
  }
}

class GetRoute implements UseCase<DeliveryRoute, GetRouteParams> {
  final DeliveryRepository repository;
  GetRoute(this.repository);

  @override
  Future<Either<Failure, DeliveryRoute>> call(GetRouteParams params) {
    return repository.getRoute(
      driverId: params.driverId,
      date: params.date,
    );
  }
}

// ============ PARAMS ============

class GetDeliveriesParams extends Equatable {
  final String? status;
  final DateTime? date;
  final int page;

  const GetDeliveriesParams({this.status, this.date, this.page = 1});

  @override
  List<Object?> get props => [status, date, page];
}

class DepartParams extends Equatable {
  final String deliveryId;
  final double latitude;
  final double longitude;

  const DepartParams({
    required this.deliveryId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [deliveryId, latitude, longitude];
}

class MarkFailedParams extends Equatable {
  final String deliveryId;
  final String reason;
  final double latitude;
  final double longitude;

  const MarkFailedParams({
    required this.deliveryId,
    required this.reason,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [deliveryId, reason];
}

class SendLocationParams extends Equatable {
  final String driverId;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  const SendLocationParams({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [driverId, latitude, longitude, timestamp];
}

class GetRouteParams extends Equatable {
  final String driverId;
  final DateTime date;

  const GetRouteParams({required this.driverId, required this.date});

  @override
  List<Object?> get props => [driverId, date];
}
