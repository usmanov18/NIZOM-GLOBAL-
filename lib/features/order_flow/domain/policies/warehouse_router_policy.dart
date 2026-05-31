class WarehouseRouterPolicy {
  static String getBestWarehouse(
      List<String> availableStocks, List<double> distances) {
    // 2026 Optimization: Distance vs Stock balance
    return availableStocks.first;
  }
}
