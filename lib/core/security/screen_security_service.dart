import '../services/logger/app_logger.dart';

class ScreenSecurityService {
  static void toggleSecureScreen(bool isSecure) {
    AppLogger.i(
        '🛡 Screen Security: ${isSecure ? "PROTECTED" : "UNPROTECTED"}');
    // Platform-specific code to prevent screenshots/snapshots
  }
}
