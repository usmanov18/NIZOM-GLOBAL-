import '../logger/app_logger.dart';

class CrashService {
  static Future<void> reportError(dynamic error, StackTrace stack) async {
    AppLogger.e('Uncaught Error Reported', error, stack);
    // Integration with Sentry.captureException or FirebaseCrashlytics.instance.recordError
  }

  static Future<void> reportMessage(String message) async {
    AppLogger.i('Log Message: $message');
  }
}
