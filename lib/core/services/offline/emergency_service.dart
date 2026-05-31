import 'package:hive/hive.dart';
import '../logger/app_logger.dart';

class EmergencyService {
  static Future<void> hardReset() async {
    AppLogger.e('🚨 EMERGENCY RESET TRIGGERED!');
    await Hive.deleteFromDisk();
    // Ilovani qayta yuklash mantiqi (SystemChannels.platform.invokeMethod('SystemNavigator.pop'))
  }
}
