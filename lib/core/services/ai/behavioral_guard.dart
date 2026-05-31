class BehavioralGuard {
  static bool isActionAnomalous(double amount, double averageAmount) {
    // 2026 AI Rule: If current action is 10x larger than average, trigger warning
    return amount > (averageAmount * 10);
  }
}
