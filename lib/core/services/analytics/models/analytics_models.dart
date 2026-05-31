import 'package:equatable/equatable.dart';

// ============================================================
// ANALYTICS MODELS - Analitika va hisobotlar
// ============================================================

/// Davr turi
enum PeriodType {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
  custom,
}

/// Grafik turi
enum ChartType {
  line,
  bar,
  pie,
  area,
  scatter,
  radar,
}

/// Eksport formati
enum ExportFormat {
  pdf,
  excel,
  csv,
  json,
}

/// Sotuv statistikasi
class SalesStatistics extends Equatable {
  final PeriodType period;
  final DateTime fromDate;
  final DateTime toDate;

  // Umumiy
  final double totalSales;
  final int totalOrders;
  final double avgOrderValue;
  final double maxOrderValue;
  final double minOrderValue;

  // O'sish
  final double salesGrowth; // %
  final double ordersGrowth; // %
  final double avgGrowth; // %

  // Taqqoslash
  final double previousPeriodSales;
  final double previousPeriodOrders;

  const SalesStatistics({
    required this.period,
    required this.fromDate,
    required this.toDate,
    required this.totalSales,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.maxOrderValue,
    required this.minOrderValue,
    required this.salesGrowth,
    required this.ordersGrowth,
    required this.avgGrowth,
    required this.previousPeriodSales,
    required this.previousPeriodOrders,
  });

  @override
  List<Object?> get props => [period, fromDate, toDate];
}

/// Kunlik sotuv
class DailySales extends Equatable {
  final DateTime date;
  final double amount;
  final int orders;
  final double avgOrder;

  const DailySales({
    required this.date,
    required this.amount,
    required this.orders,
    required this.avgOrder,
  });

  @override
  List<Object?> get props => [date];
}

/// Kategoriya sotuv
class CategorySales extends Equatable {
  final String categoryId;
  final String categoryName;
  final double amount;
  final int quantity;
  final double percentage;
  final double growth;

  const CategorySales({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.quantity,
    required this.percentage,
    required this.growth,
  });

  @override
  List<Object?> get props => [categoryId];
}

/// Hudud sotuv
class RegionSales extends Equatable {
  final String regionId;
  final String regionName;
  final double amount;
  final int orders;
  final int agents;
  final double avgPerAgent;

  const RegionSales({
    required this.regionId,
    required this.regionName,
    required this.amount,
    required this.orders,
    required this.agents,
    required this.avgPerAgent,
  });

  @override
  List<Object?> get props => [regionId];
}

/// Agent samaradorligi
class AgentPerformance extends Equatable {
  final String agentId;
  final String agentName;
  final String agentCode;
  final double sales;
  final int orders;
  final int visits;
  final int completedVisits;
  final double collections;
  final double distance;
  final double rating;
  final double salesProgress;
  final double visitProgress;

  const AgentPerformance({
    required this.agentId,
    required this.agentName,
    required this.agentCode,
    required this.sales,
    required this.orders,
    required this.visits,
    required this.completedVisits,
    required this.collections,
    required this.distance,
    required this.rating,
    required this.salesProgress,
    required this.visitProgress,
  });

  @override
  List<Object?> get props => [agentId];
}

/// Mijoz tahlili
class CustomerAnalytics extends Equatable {
  final String customerId;
  final String customerName;
  final double totalSales;
  final int totalOrders;
  final double avgOrder;
  final double currentDebt;
  final DateTime? lastOrderDate;
  final int daysSinceLastOrder;
  final String segment; // vip, active, new, inactive, debtor

  const CustomerAnalytics({
    required this.customerId,
    required this.customerName,
    required this.totalSales,
    required this.totalOrders,
    required this.avgOrder,
    required this.currentDebt,
    this.lastOrderDate,
    required this.daysSinceLastOrder,
    required this.segment,
  });

  @override
  List<Object?> get props => [customerId];
}

/// Mahsulot tahlili
class ProductAnalytics extends Equatable {
  final String productId;
  final String productName;
  final String category;
  final int quantitySold;
  final double revenue;
  final double avgPrice;
  final int stockQuantity;
  final double stockValue;
  final double growth;

  const ProductAnalytics({
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantitySold,
    required this.revenue,
    required this.avgPrice,
    required this.stockQuantity,
    required this.stockValue,
    required this.growth,
  });

  @override
  List<Object?> get props => [productId];
}

/// To'lov tahlili
class PaymentAnalytics extends Equatable {
  final double totalCollected;
  final double cashAmount;
  final double cardAmount;
  final double transferAmount;
  final double creditAmount;
  final double collectionRate;
  final double outstandingDebt;
  final double overdueDebt;
  final int overdueCustomers;

  const PaymentAnalytics({
    required this.totalCollected,
    required this.cashAmount,
    required this.cardAmount,
    required this.transferAmount,
    required this.creditAmount,
    required this.collectionRate,
    required this.outstandingDebt,
    required this.overdueDebt,
    required this.overdueCustomers,
  });

  @override
  List<Object?> get props => [totalCollected];
}

/// Hisobot parametrlari
class ReportParams extends Equatable {
  final String reportType;
  final PeriodType period;
  final DateTime fromDate;
  final DateTime toDate;
  final String? agentId;
  final String? regionId;
  final String? categoryId;
  final ExportFormat? exportFormat;

  const ReportParams({
    required this.reportType,
    required this.period,
    required this.fromDate,
    required this.toDate,
    this.agentId,
    this.regionId,
    this.categoryId,
    this.exportFormat,
  });

  @override
  List<Object?> get props => [reportType, fromDate, toDate];
}

/// Dashboard ma'lumotlari
class DashboardData extends Equatable {
  final SalesStatistics sales;
  final PaymentAnalytics payments;
  final List<DailySales> weeklySales;
  final List<CategorySales> topCategories;
  final List<AgentPerformance> topAgents;
  final List<ProductAnalytics> topProducts;
  final List<CustomerAnalytics> topCustomers;

  const DashboardData({
    required this.sales,
    required this.payments,
    required this.weeklySales,
    required this.topCategories,
    required this.topAgents,
    required this.topProducts,
    required this.topCustomers,
  });

  @override
  List<Object?> get props => [sales, payments];
}
