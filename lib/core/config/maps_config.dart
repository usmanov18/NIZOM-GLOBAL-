import 'env_config.dart';

/// Google Maps konfiguratsiya
class MapsConfig {
  static String get apiKey {
    switch (EnvConfig.environment) {
      case Environment.development:
        return 'YOUR_DEV_GOOGLE_MAPS_KEY';
      case Environment.staging:
        return 'YOUR_STAGING_GOOGLE_MAPS_KEY';
      case Environment.production:
        return 'YOUR_PROD_GOOGLE_MAPS_KEY';
    }
  }

  static const double defaultLatitude = 41.2995; // Toshkent
  static const double defaultLongitude = 69.2401;
  static const double defaultZoom = 12.0;
  static const double routeZoom = 14.0;

  // Geofencing
  static const double defaultGeofenceRadius = 100.0; // metr
  static const double checkInRadius = 100.0;

  // GPS
  static const int gpsIntervalSeconds = 30;
  static const int gpsDistanceFilter = 10; // metr
}
