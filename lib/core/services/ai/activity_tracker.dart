import '../offline/box_manager.dart';

class ActivityTracker {
  static final List<Map<String, dynamic>> _ramCache = [];

  static Future<void> trackUserHabit(String action, String context) async {
    final entry = {
      'action': action,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _ramCache.add(entry);

    // Optimized: Using pre-opened box via BoxManager
    final box = await BoxManager.getBox('emergency_habits');
    await box.add(entry);

    if (_ramCache.length >= 10) {
      await _flushToPermanentDisk();
    }
  }

  static Future<void> _flushToPermanentDisk() async {
    final box = await BoxManager.getBox('user_habits');
    await box.addAll(_ramCache);
    _ramCache.clear();

    final emergency = await BoxManager.getBox('emergency_habits');
    await emergency.clear();
  }
}
