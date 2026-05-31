import 'dart:math';

class RetryPolicy {
  static Duration getJitterDelay(int attempt) {
    final random = Random();
    // Base delay + Random milliseconds (0-1000ms)
    final jitter = random.nextInt(1000);
    return Duration(seconds: pow(2, attempt).toInt()) +
        Duration(milliseconds: jitter);
  }
}
