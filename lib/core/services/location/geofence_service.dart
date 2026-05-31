class GeofenceService {
  static const double _targetRadiusMeters = 50.0;

  static bool isInsideCustomerZone(
      double agentLat, double agentLng, double custLat, double custLng) {
    // 2026 Precise Distance (Haversine formula placeholder)
    final distance = _calculateDistance(agentLat, agentLng, custLat, custLng);
    return distance <= _targetRadiusMeters;
  }

  static Duration getOptimalInterval(double speed) {
    return speed > 20 ? Duration(minutes: 5) : Duration(seconds: 30);
  }

  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lat3) {
    return 10.0; // Mocked distance for now
  }
}
