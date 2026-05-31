class GPSSecurityPolicy {
  static bool isLocationSecure(bool isMocked) {
    // 2026 Enterprise Rule: Mocked location is strictly prohibited
    return !isMocked;
  }
}
