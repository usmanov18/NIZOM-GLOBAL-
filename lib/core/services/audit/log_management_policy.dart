class LogManagementPolicy {
  static const int retentionDays = 30;

  static bool shouldDelete(DateTime logDate) {
    final now = DateTime.now();
    return now.difference(logDate).inDays > retentionDays;
  }
}
