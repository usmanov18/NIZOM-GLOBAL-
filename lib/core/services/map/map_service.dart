import 'dart:math';

// ============================================================
// MAP SERVICE - Xarita xizmati
// ============================================================

class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  // ============ DISTANCE ============

  /// Ikki nuqta orasidagi masofa (metr)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000; // Yer radiusi (metr)
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * (3.14159265359 / 180);

  /// Masofani formatlash
  String formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Vaqtni hisoblash (daqiqa)
  int estimateTime(double distanceMeters, {double speedKmh = 30}) {
    final distanceKm = distanceMeters / 1000;
    return (distanceKm / speedKmh * 60).ceil();
  }

  /// Vaqtni formatlash
  String formatDuration(int minutes) {
    if (minutes < 60) return '$minutes daq';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours soat $mins daq';
  }

  // ============ GEOFENCE ============

  /// Nuqta doira ichidami?
  bool isInsideGeofence({
    required double pointLat,
    required double pointLon,
    required double centerLat,
    required double centerLon,
    required double radiusMeters,
  }) {
    final distance = calculateDistance(
      pointLat,
      pointLon,
      centerLat,
      centerLon,
    );
    return distance <= radiusMeters;
  }

  // ============ POLYLINE ============

  /// Polyline encoding (Google format)
  String encodePolyline(List<List<double>> points) {
    final buffer = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;

    for (final point in points) {
      final lat = (point[0] * 1e5).round();
      final lng = (point[1] * 1e5).round();

      final dLat = lat - prevLat;
      final dLng = lng - prevLng;

      buffer.write(_encodeValue(dLat));
      buffer.write(_encodeValue(dLng));

      prevLat = lat;
      prevLng = lng;
    }

    return buffer.toString();
  }

  /// Polyline decoding
  List<List<double>> decodePolyline(String encoded) {
    final points = <List<double>>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;

      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final dLat = (result & 1) != 1 ? result >> 1 : ~(result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final dLng = (result & 1) != 1 ? result >> 1 : ~(result >> 1);
      lng += dLng;

      points.add([lat / 1e5, lng / 1e5]);
    }

    return points;
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

  // ============ MARKERS ============

  /// Markerlarni clasterlash
  List<Map<String, dynamic>> clusterMarkers(
    List<Map<String, dynamic>> markers, {
    double clusterRadius = 100,
  }) {
    final clusters = <Map<String, dynamic>>[];
    final used = <int>{};

    for (int i = 0; i < markers.length; i++) {
      if (used.contains(i)) continue;

      final cluster = <Map<String, dynamic>>[markers[i]];
      used.add(i);

      for (int j = i + 1; j < markers.length; j++) {
        if (used.contains(j)) continue;

        final distance = calculateDistance(
          markers[i]['lat'],
          markers[i]['lng'],
          markers[j]['lat'],
          markers[j]['lng'],
        );

        if (distance <= clusterRadius) {
          cluster.add(markers[j]);
          used.add(j);
        }
      }

      if (cluster.length > 1) {
        // Cluster markazini hisoblash
        final avgLat = cluster.fold<double>(0, (sum, m) => sum + m['lat']) /
            cluster.length;
        final avgLng = cluster.fold<double>(0, (sum, m) => sum + m['lng']) /
            cluster.length;

        clusters.add({
          'lat': avgLat,
          'lng': avgLng,
          'count': cluster.length,
          'markers': cluster,
          'isCluster': true,
        });
      } else {
        clusters.add(markers[i]);
      }
    }

    return clusters;
  }
}
