import '../logger/app_logger.dart';

class UpdateService {
  static const String currentVersion = '1.2.0';

  Future<bool> isUpdateAvailable() async {
    // Kelajakda API ga murojaat qilib, production versiyasini tekshiradi
    AppLogger.i('Checking for updates...');
    return false;
  }
}
