import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'models/location_models.dart';
import 'package:equatable/equatable.dart';

// ============================================================
// LOCATION SERVICE - Professional GPS Tracking
// ============================================================

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // State
  TrackingStatus _status = TrackingStatus.inactive;
  TrackingConfig _config = const TrackingConfig();
  LocationPoint? _lastPoint;
  final List<LocationPoint> _points = [];
  final List<GeofenceZone> _geofences = [];

  // Streams
  final StreamController<LocationPoint> _locationController =
      StreamController<LocationPoint>.broadcast();
  final StreamController<TrackingStatus> _statusController =
      StreamController<TrackingStatus>.broadcast();
  final StreamController<GeofenceEvent> _geofenceController =
      StreamController<GeofenceEvent>.broadcast();
  final StreamController<LocationError> _errorController =
      StreamController<LocationError>.broadcast();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _activityTimer;

  // Getters
  TrackingStatus get status => _status;
  LocationPoint? get lastPoint => _lastPoint;
  List<LocationPoint> get points => List.unmodifiable(_points);
  Stream<LocationPoint> get locationStream => _locationController.stream;
  Stream<TrackingStatus> get statusStream => _statusController.stream;
  Stream<GeofenceEvent> get geofenceStream => _geofenceController.stream;
  Stream<LocationError> get errorStream => _errorController.stream;

  // ============ INITIALIZATION ============

  /// GPS xizmatini ishga tushirish
  Future<bool> initialize({TrackingConfig? config}) async {
    try {
      if (config != null) _config = config;

      // Permission tekshirish
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        _emitError(LocationError(
          type: LocationErrorType.permissionDenied,
          message: 'Lokatsiya ruxsati berilmagan',
        ));
        return false;
      }

      // Service tekshirish
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _emitError(LocationError(
          type: LocationErrorType.serviceDisabled,
          message: 'GPS o\'chirilgan',
        ));
        return false;
      }

      _updateStatus(TrackingStatus.inactive);
      return true;
    } catch (e) {
      _emitError(LocationError(
        type: LocationErrorType.unknown,
        message: 'GPS xatoligi: $e',
      ));
      return false;
    }
  }

  // ============ PERMISSION ============

  /// Ruxsatlarni tekshirish
  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Ruxsat so'rash
  Future<bool> requestPermission() async {
    return await checkPermission();
  }

  // ============ JORIY LOKATSIYA ============

  /// Joriy lokatsiyani olish
  Future<LocationPoint?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout,
      );

      final point = LocationPoint.fromPosition(position);
      _lastPoint = point;
      _locationController.add(point);

      return point;
    } catch (e) {
      _emitError(LocationError(
        type: LocationErrorType.timeout,
        message: 'Lokatsiya olish vaqti tugadi',
      ));
      return null;
    }
  }

  // ============ TRACKING ============

  /// Tracking boshlash
  Future<bool> startTracking({TrackingConfig? config}) async {
    try {
      if (config != null) _config = config;

      final hasPermission = await checkPermission();
      if (!hasPermission) return false;

      _updateStatus(TrackingStatus.starting);

      // Position stream
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: _config.distanceFilter.toInt(),
          timeLimit: _config.interval,
        ),
      ).listen(
        (position) => _onPositionUpdate(position),
        onError: (error) => _onPositionError(error),
        onDone: () => _onPositionDone(),
      );

      _updateStatus(TrackingStatus.active);

      // Activity recognition timer
      if (_config.enableActivityRecognition) {
        _startActivityRecognition();
      }

      return true;
    } catch (e) {
      _updateStatus(TrackingStatus.error);
      _emitError(LocationError(
        type: LocationErrorType.unknown,
        message: 'Tracking boshlashda xatolik: $e',
      ));
      return false;
    }
  }

  /// Tracking to'xtatish
  Future<void> stopTracking() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _activityTimer?.cancel();
    _activityTimer = null;
    _updateStatus(TrackingStatus.inactive);
  }

  /// Tracking pauza
  Future<void> pauseTracking() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _updateStatus(TrackingStatus.paused);
  }

  /// Tracking davom ettirish
  Future<void> resumeTracking() async {
    if (_status == TrackingStatus.paused) {
      await startTracking(config: _config);
    }
  }

  // ============ POSITION HANDLERS ============

  void _onPositionUpdate(Position position) {
    final point = LocationPoint.fromPosition(position);
    _lastPoint = point;
    _points.add(point);

    // Stream ga yuborish
    _locationController.add(point);

    // Geofencing tekshirish
    if (_config.enableGeofencing) {
      _checkGeofences(point);
    }

    // Batareya optimizatsiya
    if (_config.enableBatteryOptimization) {
      _optimizeBattery(point);
    }
  }

  void _onPositionError(dynamic error) {
    _emitError(LocationError(
      type: LocationErrorType.unknown,
      message: 'GPS xatoligi: $error',
    ));
  }

  void _onPositionDone() {
    _updateStatus(TrackingStatus.inactive);
  }

  // ============ GEOFENCING ============

  /// Geofence qo'shish
  void addGeofence(GeofenceZone zone) {
    _geofences.add(zone);
  }

  /// Geofence o'chirish
  void removeGeofence(String zoneId) {
    _geofences.removeWhere((z) => z.id == zoneId);
  }

  /// Geofences tozalash
  void clearGeofences() {
    _geofences.clear();
  }

  /// Geofencing tekshirish
  void _checkGeofences(LocationPoint point) {
    for (final zone in _geofences) {
      if (!zone.isActive) continue;

      final isInside = zone.contains(point.latitude, point.longitude);
      final wasInside = _lastPoint != null &&
          zone.contains(_lastPoint!.latitude, _lastPoint!.longitude);

      if (isInside && !wasInside) {
        // Kirish
        _geofenceController.add(GeofenceEvent(
          zoneId: zone.id,
          zoneName: zone.name,
          type: GeofenceEventType.enter,
          point: point,
          timestamp: DateTime.now(),
        ));
      } else if (!isInside && wasInside) {
        // Chiqish
        _geofenceController.add(GeofenceEvent(
          zoneId: zone.id,
          zoneName: zone.name,
          type: GeofenceEventType.exit,
          point: point,
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  // ============ ACTIVITY RECOGNITION ============

  void _startActivityRecognition() {
    _activityTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _detectActivity(),
    );
  }

  void _detectActivity() {
    if (_lastPoint == null) return;

    final speed = _lastPoint!.speed ?? 0;
    String activity;

    if (speed < 0.5) {
      activity = 'stationary';
    } else if (speed < 2) {
      activity = 'walking';
    } else if (speed < 5) {
      activity = 'running';
    } else {
      activity = 'driving';
    }

    // Activity ni yangilash
    final updatedPoint = LocationPoint(
      latitude: _lastPoint!.latitude,
      longitude: _lastPoint!.longitude,
      altitude: _lastPoint!.altitude,
      accuracy: _lastPoint!.accuracy,
      speed: _lastPoint!.speed,
      speedKmh: _lastPoint!.speedKmh,
      heading: _lastPoint!.heading,
      timestamp: _lastPoint!.timestamp,
      activity: activity,
    );

    _lastPoint = updatedPoint;
  }

  // ============ BATTERY OPTIMIZATION ============

  void _optimizeBattery(LocationPoint point) {
    // Agar harakatlanmayotgan bo'lsa, intervalni oshirish
    if (point.speed != null && point.speed! < 0.5) {
      // Stationary - intervalni oshirish
    }
  }

  // ============ MASOFA HISOBASH ============

  /// Ikki nuqta orasidagi masofa (metr)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Kunlik masofa (km)
  double getDailyDistance() {
    if (_points.length < 2) return 0;

    double totalDistance = 0;
    for (int i = 1; i < _points.length; i++) {
      totalDistance += calculateDistance(
        _points[i - 1].latitude,
        _points[i - 1].longitude,
        _points[i].latitude,
        _points[i].longitude,
      );
    }

    return totalDistance / 1000; // km
  }

  // ============ STATUS ============

  void _updateStatus(TrackingStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  void _emitError(LocationError error) {
    _errorController.add(error);
  }

  // ============ DATA ============

  /// Marshrut ma'lumotlarini olish
  DailyRoute getDailyRoute(String driverId) {
    final now = DateTime.now();
    final todayPoints = _points
        .where(
          (p) =>
              p.timestamp.year == now.year &&
              p.timestamp.month == now.month &&
              p.timestamp.day == now.day,
        )
        .toList();

    return DailyRoute(
      driverId: driverId,
      date: now,
      points: todayPoints,
      segments: [],
      totalDistance: getDailyDistance(),
      totalTime: Duration.zero,
      drivingTime: Duration.zero,
      walkingTime: Duration.zero,
      idleTime: Duration.zero,
      stopsCount: 0,
      averageSpeed: 0,
      maxSpeed: 0,
      visitedZones: [],
    );
  }

  /// Ma'lumotlarni tozalash
  void clearData() {
    _points.clear();
    _lastPoint = null;
  }

  /// Xizmatni tozalash
  void dispose() {
    stopTracking();
    _locationController.close();
    _statusController.close();
    _geofenceController.close();
    _errorController.close();
  }
}

// ============ GEOFENCE EVENT ============

enum GeofenceEventType {
  enter,
  exit,
  dwell,
}

class GeofenceEvent extends Equatable {
  final String zoneId;
  final String zoneName;
  final GeofenceEventType type;
  final LocationPoint point;
  final DateTime timestamp;

  const GeofenceEvent({
    required this.zoneId,
    required this.zoneName,
    required this.type,
    required this.point,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [zoneId, type, timestamp];
}
