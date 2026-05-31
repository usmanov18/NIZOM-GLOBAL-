class RetentionService {
  static const int traceRetentionDays = 90;

  static bool isTraceObsolete(DateTime createdAt) {
    return DateTime.now().difference(createdAt).inDays > traceRetentionDays;
  }
}
