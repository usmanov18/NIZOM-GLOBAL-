import 'package:equatable/equatable.dart';

// ============================================================
// ROUTE MODELS - Marshrut modellari
// ============================================================

/// Marshrut nuqtasi
class RouteWaypoint extends Equatable {
  final String id;
  final String orderId;
  final String customerName;
  final String address;
  final double latitude;
  final double longitude;
  final int sequence;
  final String timeSlot;
  final double? estimatedArrival;
  final double? estimatedDuration;
  final double? distanceFromPrevious;
  final String status; // pending, arrived, completed, skipped
  final DateTime? arrivedAt;
  final DateTime? completedAt;

  const RouteWaypoint({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    required this.timeSlot,
    this.estimatedArrival,
    this.estimatedDuration,
    this.distanceFromPrevious,
    required this.status,
    this.arrivedAt,
    this.completedAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isSkipped => status == 'skipped';

  @override
  List<Object?> get props => [id, sequence, status];
}

/// Optimallashtirilgan marshrut
class OptimizedRoute extends Equatable {
  final String id;
  final String driverId;
  final DateTime date;
  final List<RouteWaypoint> waypoints;
  final double totalDistance; // km
  final int totalTime; // minutes
  final double estimatedFuelCost;
  final List<RouteSegment> segments;
  final RoutePolyline? polyline;
  final DateTime optimizedAt;

  const OptimizedRoute({
    required this.id,
    required this.driverId,
    required this.date,
    required this.waypoints,
    required this.totalDistance,
    required this.totalTime,
    required this.estimatedFuelCost,
    required this.segments,
    this.polyline,
    required this.optimizedAt,
  });

  int get completedStops => waypoints.where((w) => w.isCompleted).length;
  int get totalStops => waypoints.length;
  double get completionRate => totalStops > 0 ? completedStops / totalStops : 0;

  @override
  List<Object?> get props => [id, date];
}

/// Marshrut segmenti
class RouteSegment extends Equatable {
  final String fromWaypointId;
  final String toWaypointId;
  final double distance; // km
  final int duration; // minutes
  final String? instruction; // Yo'nalish
  final List<LatLng> polylinePoints;

  const RouteSegment({
    required this.fromWaypointId,
    required this.toWaypointId,
    required this.distance,
    required this.duration,
    this.instruction,
    this.polylinePoints = const [],
  });

  @override
  List<Object?> get props => [fromWaypointId, toWaypointId];
}

/// LatLng
class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Marshrut polyline
class RoutePolyline extends Equatable {
  final List<LatLng> points;
  final String encodedPolyline;

  const RoutePolyline({
    required this.points,
    required this.encodedPolyline,
  });

  @override
  List<Object?> get props => [encodedPolyline];
}

/// Marshrut optimallashtirish parametrlari
class RouteOptimizationParams extends Equatable {
  final List<RouteWaypoint> waypoints;
  final LatLng startLocation;
  final LatLng? endLocation;
  final String optimizeFor; // time, distance
  final bool considerTraffic;
  final List<TimeWindow>? timeWindows;
  final double? vehicleCapacity;

  const RouteOptimizationParams({
    required this.waypoints,
    required this.startLocation,
    this.endLocation,
    this.optimizeFor = 'time',
    this.considerTraffic = true,
    this.timeWindows,
    this.vehicleCapacity,
  });

  @override
  List<Object?> get props => [waypoints, optimizeFor];
}

/// Vaqt oynasi
class TimeWindow extends Equatable {
  final String waypointId;
  final DateTime earliest;
  final DateTime latest;

  const TimeWindow({
    required this.waypointId,
    required this.earliest,
    required this.latest,
  });

  bool isWithinWindow(DateTime time) {
    return time.isAfter(earliest) && time.isBefore(latest);
  }

  @override
  List<Object?> get props => [waypointId];
}

/// Trafik ma'lumotlari
class TrafficInfo extends Equatable {
  final String segmentId;
  final double distance;
  final int normalDuration; // minutes
  final int currentDuration; // minutes
  final double trafficLevel; // 0.0-1.0 (0=yengil, 1=tiqilinch)
  final String? incidentType; // accident, construction, weather
  final String? incidentDescription;

  const TrafficInfo({
    required this.segmentId,
    required this.distance,
    required this.normalDuration,
    required this.currentDuration,
    required this.trafficLevel,
    this.incidentType,
    this.incidentDescription,
  });

  double get delayMinutes => (currentDuration - normalDuration).toDouble();

  @override
  List<Object?> get props => [segmentId, trafficLevel];
}
