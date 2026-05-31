import 'dart:math' as math;

import 'package:equatable/equatable.dart';

// ============================================================
// TRACKING ENTITIES - Real vaqt kuzatish
// ============================================================

/// Agent real vaqt holati
class AgentLiveStatus extends Equatable {
  factory AgentLiveStatus.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String agentId;
  final String agentName;
  final String agentCode;
  final String status; // online, on_route, visiting, break, offline
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final DateTime lastUpdate;
  final String? currentCustomer;
  final String? currentAddress;
  final double? batteryLevel;
  final double? distanceToNext;
  final int? etaMinutes;

  const AgentLiveStatus({
    required this.agentId,
    required this.agentName,
    required this.agentCode,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
    required this.lastUpdate,
    this.currentCustomer,
    this.currentAddress,
    this.batteryLevel,
    this.distanceToNext,
    this.etaMinutes,
  });

  bool get isOnline => status != 'offline';
  bool get isMoving => (speed ?? 0) > 1;
  bool get isLowBattery => (batteryLevel ?? 100) < 20;

  @override
  List<Object?> get props => [agentId, status, lastUpdate];
}

/// Agent marshrut nuqtasi
class RoutePoint extends Equatable {
  factory RoutePoint.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? heading;
  final String? activity;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.heading,
    this.activity,
  });

  @override
  List<Object?> get props => [latitude, longitude, timestamp];
}

/// Agent marshrut
class AgentRoute extends Equatable {
  factory AgentRoute.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String agentId;
  final DateTime date;
  final List<RoutePoint> points;
  final double totalDistance;
  final Duration totalTime;
  final int stopsCount;
  final DateTime? startTime;
  final DateTime? endTime;

  const AgentRoute({
    required this.agentId,
    required this.date,
    required this.points,
    required this.totalDistance,
    required this.totalTime,
    required this.stopsCount,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [agentId, date];
}

/// Geofence zona
class GeofenceZone extends Equatable {
  factory GeofenceZone.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final String type; // customer, warehouse, checkpoint
  final bool isActive;

  const GeofenceZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.type,
    required this.isActive,
  });

  bool contains(double lat, double lng) {
    if (!isActive) return false;
    return distanceTo(lat, lng) <= radius;
  }

  /// Markazdan berilgan nuqtagacha masofa (metr).
  double distanceTo(double lat, double lng) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _toRadians(lat - latitude);
    final dLng = _toRadians(lng - longitude);
    final centerLat = _toRadians(latitude);
    final pointLat = _toRadians(lat);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(centerLat) *
            math.cos(pointLat) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  @override
  List<Object?> get props => [id, latitude, longitude, radius];
}

/// SOS signal
class SOSAlert extends Equatable {
  factory SOSAlert.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String agentId;
  final String agentName;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? message;

  const SOSAlert({
    required this.agentId,
    required this.agentName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.message,
  });

  @override
  List<Object?> get props => [agentId, timestamp];
}
