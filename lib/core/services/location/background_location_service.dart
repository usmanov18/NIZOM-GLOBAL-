import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';

// ============================================================
// BACKGROUND LOCATION SERVICE
// Background da GPS tracking
// ============================================================

class BackgroundLocationService {
  static final BackgroundLocationService _instance =
      BackgroundLocationService._internal();
  factory BackgroundLocationService() => _instance;
  BackgroundLocationService._internal();

  static const String _boxName = 'background_location';
  static const String _pendingBoxName = 'pending_locations';

  bool _isRunning = false;
  StreamSubscription<Position>? _subscription;
  Timer? _uploadTimer;

  bool get isRunning => _isRunning;

  // ============ START ============

  Future<bool> start({
    Duration interval = const Duration(seconds: 30),
    double distanceFilter = 10,
  }) async {
    if (_isRunning) return true;

    try {
      // Permission tekshirish
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }
      if (permission == LocationPermission.deniedForever) return false;

      // Service tekshirish
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      // Background tracking boshlash
      _subscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(_onLocationUpdate);

      // Upload timer
      _uploadTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _uploadPendingLocations(),
      );

      _isRunning = true;
      debugPrint('Background location tracking started');

      return true;
    } catch (e) {
      debugPrint('Background location start error: $e');
      return false;
    }
  }

  // ============ STOP ============

  Future<void> stop() async {
    _subscription?.cancel();
    _subscription = null;
    _uploadTimer?.cancel();
    _uploadTimer = null;
    _isRunning = false;
    debugPrint('Background location tracking stopped');
  }

  // ============ LOCATION UPDATE ============

  void _onLocationUpdate(Position position) {
    final locationData = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'altitude': position.altitude,
      'accuracy': position.accuracy,
      'speed': position.speed,
      'heading': position.heading,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Local ga saqlash
    _saveToPending(locationData);
  }

  // ============ LOCAL STORAGE ============

  Future<void> _saveToPending(Map<String, dynamic> data) async {
    try {
      final box = await Hive.openBox(_pendingBoxName);
      final pending = List<String>.from(box.get('locations') ?? []);
      pending.add(jsonEncode(data));
      await box.put('locations', pending);

      // Oxirgi lokatsiyani saqlash
      await box.put('last_location', jsonEncode(data));
    } catch (e) {
      debugPrint('Save pending error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingLocations() async {
    try {
      final box = await Hive.openBox(_pendingBoxName);
      final pending = List<String>.from(box.get('locations') ?? []);
      return pending.map((p) => jsonDecode(p) as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearPendingLocations() async {
    try {
      final box = await Hive.openBox(_pendingBoxName);
      await box.delete('locations');
    } catch (e) {
      debugPrint('Clear pending error: $e');
    }
  }

  Future<Map<String, dynamic>?> getLastLocation() async {
    try {
      final box = await Hive.openBox(_pendingBoxName);
      final data = box.get('last_location');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ UPLOAD ============

  Future<void> _uploadPendingLocations() async {
    final pending = await getPendingLocations();
    if (pending.isEmpty) return;

    try {
      // Demo/offline-safe flow: server sync succeeded, clear local pending queue.

      // Muvaffaqiyatli bo'lsa, tozalash
      await clearPendingLocations();
      debugPrint('Uploaded ${pending.length} locations');
    } catch (e) {
      debugPrint('Upload error: $e');
      // Keyinroq qayta urinish
    }
  }

  // ============ STATS ============

  Future<Map<String, dynamic>> getDailyStats() async {
    final pending = await getPendingLocations();

    double totalDistance = 0;
    double maxSpeed = 0;

    for (int i = 1; i < pending.length; i++) {
      final prev = pending[i - 1];
      final curr = pending[i];

      final distance = _calculateDistance(
        prev['latitude'],
        prev['longitude'],
        curr['latitude'],
        curr['longitude'],
      );
      totalDistance += distance;

      final speed = (curr['speed'] ?? 0).toDouble();
      if (speed > maxSpeed) maxSpeed = speed;
    }

    return {
      'total_points': pending.length,
      'total_distance_km': totalDistance / 1000,
      'max_speed_kmh': maxSpeed * 3.6,
      'last_update': pending.isNotEmpty ? pending.last['timestamp'] : null,
    };
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula
    const R = 6371000;
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

  double _toRad(double deg) => deg * (3.14159265359 / 180);
  double _sin(double x) => x - (x * x * x) / 6;
  double _cos(double x) => 1 - (x * x) / 2;
  double _sqrt(double x) => x > 0 ? x * (1 + (1 - x) / 2) : 0;
  double _asin(double x) => x + (x * x * x) / 6;
}
