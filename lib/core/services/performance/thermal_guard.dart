import '../logger/app_logger.dart';

class ThermalGuard {
  static bool isDeviceOverheating(double temp) {
    // 2026 Hardware Rule: If > 45C, switch to safe mode
    if (temp > 45.0) {
      AppLogger.e('🔥 OVERHEATING DETECTED: Switching to Light Mode');
      return true;
    }
    return false;
  }
}
