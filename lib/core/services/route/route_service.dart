import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import 'models/route_models.dart';

// ============================================================
// ROUTE SERVICE - Professional Marshrut Optimizatsiya
// ============================================================

class RouteService {
  static final RouteService _instance = RouteService._internal();
  factory RouteService() => _instance;
  RouteService._internal();

  // ============ OPTIMIZATSIYA ============

  /// Marshrutni optimallashtirish (Nearest Neighbor + 2-opt)
  Future<Either<Failure, OptimizedRoute>> optimizeRoute({
    required RouteOptimizationParams params,
  }) async {
    try {
      final waypoints = List<RouteWaypoint>.from(params.waypoints);

      if (waypoints.isEmpty) {
        return Left(ValidationFailure(message: 'Manzillar ro\'yxati bo\'sh'));
      }

      // 1. Nearest Neighbor algoritmi
      var optimized = _nearestNeighbor(waypoints, params.startLocation);

      // 2. 2-opt optimallashtirish
      optimized = _twoOptImprovement(optimized);

      // 3. Masofa va vaqt hisoblash
      final segments = _calculateSegments(optimized);
      final totalDistance = segments.fold<double>(
        0,
        (sum, s) => sum + s.distance,
      );
      final totalTime = segments.fold<int>(
        0,
        (sum, s) => sum + s.duration,
      );

      // 4. Yoqilg'i xarajati
      final fuelCost = _calculateFuelCost(totalDistance);

      // 5. Polyline
      final polyline = _generatePolyline(optimized);

      return Right(OptimizedRoute(
        id: 'route_${DateTime.now().millisecondsSinceEpoch}',
        driverId: 'current',
        date: DateTime.now(),
        waypoints: optimized,
        totalDistance: totalDistance,
        totalTime: totalTime,
        estimatedFuelCost: fuelCost,
        segments: segments,
        polyline: polyline,
        optimizedAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Marshrut optimallashtirishda xatolik: $e'));
    }
  }

  /// Nearest Neighbor algoritmi
  List<RouteWaypoint> _nearestNeighbor(
    List<RouteWaypoint> waypoints,
    LatLng startLocation,
  ) {
    final unvisited = List<RouteWaypoint>.from(waypoints);
    final route = <RouteWaypoint>[];
    var current = startLocation;
    int sequence = 1;

    while (unvisited.isNotEmpty) {
      // Eng yaqin manzilni topish
      RouteWaypoint? nearest;
      double minDistance = double.infinity;

      for (final wp in unvisited) {
        final distance = _calculateDistance(
          current.latitude,
          current.longitude,
          wp.latitude,
          wp.longitude,
        );
        if (distance < minDistance) {
          minDistance = distance;
          nearest = wp;
        }
      }

      if (nearest != null) {
        route.add(RouteWaypoint(
          id: nearest.id,
          orderId: nearest.orderId,
          customerName: nearest.customerName,
          address: nearest.address,
          latitude: nearest.latitude,
          longitude: nearest.longitude,
          sequence: sequence++,
          timeSlot: nearest.timeSlot,
          distanceFromPrevious: minDistance / 1000, // km
          status: 'pending',
        ));

        current = LatLng(
          latitude: nearest.latitude,
          longitude: nearest.longitude,
        );
        unvisited.remove(nearest);
      }
    }

    return route;
  }

  /// 2-opt optimallashtirish
  List<RouteWaypoint> _twoOptImprovement(List<RouteWaypoint> route) {
    if (route.length < 4) return route;

    var improved = List<RouteWaypoint>.from(route);
    bool improvedFlag = true;

    while (improvedFlag) {
      improvedFlag = false;

      for (int i = 0; i < improved.length - 2; i++) {
        for (int j = i + 2; j < improved.length; j++) {
          final currentDistance = _segmentDistance(improved, i, i + 1) +
              _segmentDistance(improved, j, j + 1);

          final newDistance = _segmentDistance(improved, i, j) +
              _segmentDistance(improved, i + 1, j + 1);

          if (newDistance < currentDistance) {
            // Segmentlarni almashtirish
            final reversed = improved.sublist(i + 1, j + 1).reversed.toList();
            improved = [
              ...improved.sublist(0, i + 1),
              ...reversed,
              ...improved.sublist(j + 1),
            ];
            improvedFlag = true;
          }
        }
      }
    }

    // Sequence yangilash
    return improved.asMap().entries.map((entry) {
      return RouteWaypoint(
        id: entry.value.id,
        orderId: entry.value.orderId,
        customerName: entry.value.customerName,
        address: entry.value.address,
        latitude: entry.value.latitude,
        longitude: entry.value.longitude,
        sequence: entry.key + 1,
        timeSlot: entry.value.timeSlot,
        distanceFromPrevious: entry.value.distanceFromPrevious,
        status: entry.value.status,
      );
    }).toList();
  }

  double _segmentDistance(List<RouteWaypoint> route, int i, int j) {
    if (i < 0 || j >= route.length) return 0;
    return _calculateDistance(
      route[i].latitude,
      route[i].longitude,
      route[j].latitude,
      route[j].longitude,
    );
  }

  /// Segmentlarni hisoblash
  List<RouteSegment> _calculateSegments(List<RouteWaypoint> waypoints) {
    final segments = <RouteSegment>[];

    for (int i = 0; i < waypoints.length - 1; i++) {
      final from = waypoints[i];
      final to = waypoints[i + 1];

      final distance = _calculateDistance(
            from.latitude,
            from.longitude,
            to.latitude,
            to.longitude,
          ) /
          1000; // km

      final duration = _estimateDuration(distance);

      segments.add(RouteSegment(
        fromWaypointId: from.id,
        toWaypointId: to.id,
        distance: distance,
        duration: duration,
        instruction: '${from.customerName} dan ${to.customerName} ga',
      ));
    }

    return segments;
  }

  /// Yoqilg'i xarajati hisoblash
  double _calculateFuelCost(double distanceKm) {
    const fuelConsumptionPer100Km = 12.0; // litr/100km
    const fuelPricePerLiter = 9500; // so'm/litr

    final fuelNeeded = (distanceKm / 100) * fuelConsumptionPer100Km;
    return fuelNeeded * fuelPricePerLiter;
  }

  /// Polyline yaratish
  RoutePolyline _generatePolyline(List<RouteWaypoint> waypoints) {
    final points = waypoints
        .map((w) => LatLng(latitude: w.latitude, longitude: w.longitude))
        .toList();

    final encoded = _encodePolyline(points);

    return RoutePolyline(
      points: points,
      encodedPolyline: encoded,
    );
  }

  /// Google Polyline encoding
  String _encodePolyline(List<LatLng> points) {
    // Simplified polyline encoding
    final buffer = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;

    for (final point in points) {
      final lat = (point.latitude * 1e5).round();
      final lng = (point.longitude * 1e5).round();

      final dLat = lat - prevLat;
      final dLng = lng - prevLng;

      buffer.write(_encodeValue(dLat));
      buffer.write(_encodeValue(dLng));

      prevLat = lat;
      prevLng = lng;
    }

    return buffer.toString();
  }

  String _encodeValue(int value) {
    final buffer = StringBuffer();
    int shifted = value << 1;
    if (value < 0) shifted = ~shifted;

    while (shifted >= 0x20) {
      buffer.write(String.fromCharCode((0x20 | (shifted & 0x1f)) + 63));
      shifted >>= 5;
    }
    buffer.write(String.fromCharCode(shifted + 63));

    return buffer.toString();
  }

  // ============ YORDAMCHI ============

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Yer radiusi (metr)
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * (3.14159265359 / 180);

  int _estimateDuration(double distanceKm) {
    const averageSpeedKmH = 30.0; // O'rtacha tezlik shaharda
    return (distanceKm / averageSpeedKmH * 60).round(); // daqiqa
  }

  // ============ MARSHRUT HOLATI ============

  /// Marshrut holatini yangilash
  Future<OptimizedRoute> updateWaypointStatus({
    required OptimizedRoute route,
    required String waypointId,
    required String status,
    DateTime? arrivedAt,
    DateTime? completedAt,
  }) async {
    final updatedWaypoints = route.waypoints.map((wp) {
      if (wp.id == waypointId) {
        return RouteWaypoint(
          id: wp.id,
          orderId: wp.orderId,
          customerName: wp.customerName,
          address: wp.address,
          latitude: wp.latitude,
          longitude: wp.longitude,
          sequence: wp.sequence,
          timeSlot: wp.timeSlot,
          estimatedArrival: wp.estimatedArrival,
          estimatedDuration: wp.estimatedDuration,
          distanceFromPrevious: wp.distanceFromPrevious,
          status: status,
          arrivedAt: arrivedAt ?? wp.arrivedAt,
          completedAt: completedAt ?? wp.completedAt,
        );
      }
      return wp;
    }).toList();

    return OptimizedRoute(
      id: route.id,
      driverId: route.driverId,
      date: route.date,
      waypoints: updatedWaypoints,
      totalDistance: route.totalDistance,
      totalTime: route.totalTime,
      estimatedFuelCost: route.estimatedFuelCost,
      segments: route.segments,
      polyline: route.polyline,
      optimizedAt: route.optimizedAt,
    );
  }
}
