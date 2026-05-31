enum SyncPulse { intense, normal, batterySaver, critical }

class AdaptivePulseService {
  static Duration getInterval(int batteryLevel, bool isMoving) {
    if (batteryLevel < 15) return const Duration(minutes: 60);
    if (isMoving) return const Duration(minutes: 5);
    return const Duration(minutes: 15);
  }
}
