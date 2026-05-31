import 'package:equatable/equatable.dart';

// ============================================================
// LOCATION MODELS - GPS ma'lumotlari
// ============================================================

/// GPS nuqta
class LocationPoint extends Equatable {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed; // m/s
  final double? speedKmh; // km/h
  final double? heading; // yo'nalish (0-360)
  final DateTime timestamp;
  final String? activity; // walking, driving, stationary, running
  final double? batteryLevel;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.speedKmh,
    this.heading,
    required this.timestamp,
    this.activity,
    this.batteryLevel,
  });

  factory LocationPoint.fromPosition(dynamic position) {
    return LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed,
      speedKmh: position.speed != null ? position.speed! * 3.6 : null,
      heading: position.heading,
      timestamp: position.timestamp ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'accuracy': accuracy,
        'speed': speed,
        'speed_kmh': speedKmh,
        'heading': heading,
        'timestamp': timestamp.toIso8601String(),
        'activity': activity,
        'battery_level': batteryLevel,
      };

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      altitude: json['altitude']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      speed: json['speed']?.toDouble(),
      speedKmh: json['speed_kmh']?.toDouble(),
      heading: json['heading']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      activity: json['activity'],
      batteryLevel: json['battery_level']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, timestamp];
}

/// Geofence nuqtasi
class GeofenceZone extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double radius; // metr
  final String type; // customer, warehouse, checkpoint
  final String? relatedId; // customer_id, warehouse_id
  final bool isActive;
  final DateTime createdAt;

  const GeofenceZone({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.type,
    this.relatedId,
    required this.isActive,
    required this.createdAt,
  });

  /// Nuqta geofence ichidami?
  bool contains(double lat, double lng) {
    final distance = _calculateDistance(latitude, longitude, lat, lng);
    return distance <= radius;
  }

  /// Masofa (metr)
  double distanceTo(double lat, double lng) {
    return _calculateDistance(latitude, longitude, lat, lng);
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Haversine formula
    const R = 6371000; // Yer radiusi (metr)
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRad(lat1)) *
            _cos(_toRad(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);
    final c = 2 * _asin(_sqrt(a));
    return R * c;
  }

  static double _toRad(double deg) => deg * (3.14159265359 / 180);
  static double _sin(double x) =>
      x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  static double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  static double _sqrt(double x) => x > 0 ? x * (1 + (1 - x) / 2) : 0;
  static double _asin(double x) => x + (x * x * x) / 6;

  @override
  List<Object?> get props => [id, latitude, longitude, radius];
}

/// Marshrut segmenti
class RouteSegment extends Equatable {
  final LocationPoint startPoint;
  final LocationPoint endPoint;
  final double distance; // metr
  final Duration duration;
  final double averageSpeed; // km/h
  final String activity; // walking, driving

  const RouteSegment({
    required this.startPoint,
    required this.endPoint,
    required this.distance,
    required this.duration,
    required this.averageSpeed,
    required this.activity,
  });

  @override
  List<Object?> get props => [startPoint, endPoint];
}

/// Kunlik marshrut
class DailyRoute extends Equatable {
  final String driverId;
  final DateTime date;
  final List<LocationPoint> points;
  final List<RouteSegment> segments;
  final double totalDistance; // km
  final Duration totalTime;
  final Duration drivingTime;
  final Duration walkingTime;
  final Duration idleTime;
  final int stopsCount;
  final double averageSpeed; // km/h
  final double maxSpeed; // km/h
  final DateTime? startTime;
  final DateTime? endTime;
  final List<GeofenceZone> visitedZones;

  const DailyRoute({
    required this.driverId,
    required this.date,
    required this.points,
    required this.segments,
    required this.totalDistance,
    required this.totalTime,
    required this.drivingTime,
    required this.walkingTime,
    required this.idleTime,
    required this.stopsCount,
    required this.averageSpeed,
    required this.maxSpeed,
    this.startTime,
    this.endTime,
    required this.visitedZones,
  });

  @override
  List<Object?> get props => [driverId, date];
}

/// Tracking holati
enum TrackingStatus {
  inactive, // Yoqilmagan
  starting, // Boshlanmoqda
  active, // Faol
  paused, // Vaqtincha to'xtagan
  error, // Xatolik
}

/// Tracking konfiguratsiya
class TrackingConfig extends Equatable {
  final Duration interval; // GPS intervali
  final double distanceFilter; // Masofa filtri (metr)
  final bool enableBackground; // Background tracking
  final bool enableGeofencing; // Geofencing
  final bool enableActivityRecognition; // Faollik aniqlash
  final bool enableBatteryOptimization; // Batareya optimizatsiya
  final int notificationId; // Foreground notification ID

  const TrackingConfig({
    this.interval = const Duration(seconds: 30),
    this.distanceFilter = 10,
    this.enableBackground = true,
    this.enableGeofencing = true,
    this.enableActivityRecognition = true,
    this.enableBatteryOptimization = true,
    this.notificationId = 888,
  });

  @override
  List<Object?> get props => [interval, distanceFilter];
}

/// Xatolik turi
enum LocationErrorType {
  permissionDenied,
  serviceDisabled,
  timeout,
  accuracy,
  unknown,
}

/// Xatolik
class LocationError extends Equatable {
  final LocationErrorType type;
  final String message;
  final dynamic details;

  const LocationError({
    required this.type,
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [type, message];
}
