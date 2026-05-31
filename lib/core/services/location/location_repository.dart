import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import 'models/location_models.dart';
import 'package:equatable/equatable.dart';

// ============================================================
// LOCATION REPOSITORY - GPS ma'lumotlarini saqlash va yuborish
// ============================================================

abstract class LocationRepository {
  /// Lokatsiya yuborish
  Future<Either<Failure, bool>> sendLocation(LocationPoint point);

  /// Batch lokatsiya yuborish
  Future<Either<Failure, bool>> sendBatchLocations(List<LocationPoint> points);

  /// Agent marshrutini olish
  Future<Either<Failure, DailyRoute>> getDailyRoute({
    required String driverId,
    required DateTime date,
  });

  /// Geofence zonalarini olish
  Future<Either<Failure, List<GeofenceZone>>> getGeofences({
    String? driverId,
  });

  /// Agentlar real vaqt holati
  Future<Either<Failure, List<AgentLocation>>> getAgentsLocations({
    String? supervisorId,
  });
}

class LocationRepositoryImpl implements LocationRepository {
  final List<LocationPoint> _sentLocations = [];
  final Map<String, List<LocationPoint>> _routesByDriver = {};

  final List<GeofenceZone> _geofences = [
    GeofenceZone(
      id: 'warehouse_main',
      name: 'Asosiy ombor',
      description: 'NIZOM GLOBAL asosiy ombori',
      latitude: 41.2995,
      longitude: 69.2401,
      radius: 250,
      type: 'warehouse',
      relatedId: 'warehouse_1',
      isActive: true,
      createdAt: DateTime(2026),
    ),
    GeofenceZone(
      id: 'customer_chilonzor',
      name: 'Chilonzor mijoz zonasi',
      latitude: 41.2850,
      longitude: 69.2030,
      radius: 180,
      type: 'customer',
      relatedId: 'customer_demo_1',
      isActive: true,
      createdAt: DateTime(2026),
    ),
  ];

  @override
  Future<Either<Failure, bool>> sendLocation(LocationPoint point) async {
    try {
      _sentLocations.add(point);
      _routesByDriver
          .putIfAbsent('current', () => <LocationPoint>[])
          .add(point);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'Lokatsiya yuborishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, bool>> sendBatchLocations(
      List<LocationPoint> points) async {
    try {
      _sentLocations.addAll(points);
      _routesByDriver
          .putIfAbsent('current', () => <LocationPoint>[])
          .addAll(points);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'Lokatsiyalar yuborishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, DailyRoute>> getDailyRoute({
    required String driverId,
    required DateTime date,
  }) async {
    try {
      final points = _routesByDriver[driverId] ??
          _routesByDriver['current'] ??
          _demoRoutePoints(date);
      final segments = _buildSegments(points);
      final totalDistanceMeters =
          segments.fold<double>(0, (sum, segment) => sum + segment.distance);
      final totalTime = points.length < 2
          ? Duration.zero
          : points.last.timestamp.difference(points.first.timestamp).abs();
      final movingSegments =
          segments.where((segment) => segment.averageSpeed > 1).toList();
      final drivingTime = movingSegments.fold<Duration>(
          Duration.zero, (sum, segment) => sum + segment.duration);
      final maxSpeed = points.map((point) => point.speedKmh ?? 0).fold<double>(
          0, (maxValue, value) => value > maxValue ? value : maxValue);
      final visitedZones = _geofences
          .where((zone) => points
              .any((point) => zone.contains(point.latitude, point.longitude)))
          .toList();

      return Right(DailyRoute(
        driverId: driverId,
        date: date,
        points: points,
        segments: segments,
        totalDistance: totalDistanceMeters / 1000,
        totalTime: totalTime,
        drivingTime: drivingTime,
        walkingTime: Duration.zero,
        idleTime: totalTime - drivingTime,
        stopsCount: visitedZones.length,
        averageSpeed: totalTime.inMinutes == 0
            ? 0
            : (totalDistanceMeters / 1000) / (totalTime.inMinutes / 60),
        maxSpeed: maxSpeed,
        startTime: points.isEmpty ? null : points.first.timestamp,
        endTime: points.isEmpty ? null : points.last.timestamp,
        visitedZones: visitedZones,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Marshrut yuklanmadi'));
    }
  }

  List<LocationPoint> _demoRoutePoints(DateTime date) {
    return [
      LocationPoint(
        latitude: 41.2995,
        longitude: 69.2401,
        timestamp: date.subtract(const Duration(hours: 4)),
        accuracy: 10,
        speedKmh: 0,
      ),
      LocationPoint(
        latitude: 41.3111,
        longitude: 69.2797,
        timestamp: date.subtract(const Duration(hours: 3)),
        accuracy: 15,
        speedKmh: 45,
      ),
    ];
  }

  List<RouteSegment> _buildSegments(List<LocationPoint> points) {
    return [];
  }

  @override
  Future<Either<Failure, List<GeofenceZone>>> getGeofences({
    String? driverId,
  }) async {
    try {
      if (driverId == null) return Right(List<GeofenceZone>.from(_geofences));
      return Right(List<GeofenceZone>.from(_geofences));
    } catch (e) {
      return Left(ServerFailure(message: 'Geofence zonalar yuklanmadi'));
    }
  }

  @override
  Future<Either<Failure, List<AgentLocation>>> getAgentsLocations({
    String? supervisorId,
  }) async {
    try {
      final lastPoint = _sentLocations.isNotEmpty ? _sentLocations.last : null;
      final agents = <AgentLocation>[
        AgentLocation(
          agentId: 'agent_current',
          agentName: 'Joriy agent',
          latitude: lastPoint?.latitude ?? 41.2995,
          longitude: lastPoint?.longitude ?? 69.2401,
          speed: lastPoint?.speedKmh,
          activity: lastPoint?.activity ?? 'driving',
          timestamp: lastPoint?.timestamp ?? DateTime.now(),
          currentCustomer: 'Demo mijoz',
        ),
        AgentLocation(
          agentId: 'agent_demo_2',
          agentName: 'Agent 2',
          latitude: 41.3050,
          longitude: 69.2500,
          speed: 18,
          activity: 'visiting',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          currentCustomer: 'Chilonzor mijoz zonasi',
        ),
      ];
      return Right(agents);
    } catch (e) {
      return Left(ServerFailure(message: 'Agentlar joylashuvi yuklanmadi'));
    }
  }
}

/// Agent real vaqt joylashuvi
class AgentLocation extends Equatable {
  final String agentId;
  final String agentName;
  final double latitude;
  final double longitude;
  final double? speed;
  final String? activity;
  final DateTime timestamp;
  final String? currentCustomer;

  const AgentLocation({
    required this.agentId,
    required this.agentName,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.activity,
    required this.timestamp,
    this.currentCustomer,
  });

  @override
  List<Object?> get props => [agentId, latitude, longitude, timestamp];
}
