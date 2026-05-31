class AppConstants {
  static const int maxSyncBatchSize = 500;
  static const int maxPendingOrders = 50;
  static const int syncIntervalMinutes = 15;
  static const int httpTimeoutSeconds = 60;
  static const String idempotencyHeader = 'X-Idempotency-Key';

  // Beta Release sozlamalari
  static const bool enableFeedback = true;
  static const bool forceUpdate = false;
  static const String supportPhone = '+998711234567';
}
