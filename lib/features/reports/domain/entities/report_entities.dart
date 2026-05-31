import 'package:equatable/equatable.dart';

// ============================================================
// REPORT ENTITIES - Hisobotlar
// JSON factories qo'shildi
// ============================================================

enum ReportType {
  sales,
  customers,
  products,
  agents,
  payments,
  delivery,
  inventory,
  financial
}

enum ReportFormat { pdf, excel, csv }

class SalesReport extends Equatable {
  final DateTime fromDate;
  final DateTime toDate;
  final double totalSales;
  final int totalOrders;
  final double avgOrderValue;
  final double salesGrowth;
  final List<DailySalesData> dailySales;
  final List<CategorySalesData> categorySales;
  final List<AgentSalesData> agentSales;

  const SalesReport({
    required this.fromDate,
    required this.toDate,
    required this.totalSales,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.salesGrowth,
    required this.dailySales,
    required this.categorySales,
    required this.agentSales,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) => SalesReport(
        fromDate: DateTime.parse(json['fromDate']),
        toDate: DateTime.parse(json['toDate']),
        totalSales: (json['totalSales'] ?? 0).toDouble(),
        totalOrders: json['totalOrders'] ?? 0,
        avgOrderValue: (json['avgOrderValue'] ?? 0).toDouble(),
        salesGrowth: (json['salesGrowth'] ?? 0).toDouble(),
        dailySales: (json['dailySales'] as List? ?? [])
            .map((e) => DailySalesData.fromJson(e))
            .toList(),
        categorySales: (json['categorySales'] as List? ?? [])
            .map((e) => CategorySalesData.fromJson(e))
            .toList(),
        agentSales: (json['agentSales'] as List? ?? [])
            .map((e) => AgentSalesData.fromJson(e))
            .toList(),
      );

  @override
  List<Object?> get props => [fromDate, toDate, totalSales];
}

class DailySalesData extends Equatable {
  final DateTime date;
  final double amount;
  final int orders;
  const DailySalesData(
      {required this.date, required this.amount, required this.orders});
  factory DailySalesData.fromJson(Map<String, dynamic> json) => DailySalesData(
        date: DateTime.parse(json['date']),
        amount: (json['amount'] ?? 0).toDouble(),
        orders: json['orders'] ?? 0,
      );
  @override
  List<Object?> get props => [date];
}

class CategorySalesData extends Equatable {
  final String category;
  final double amount;
  final int quantity;
  final double percentage;
  const CategorySalesData(
      {required this.category,
      required this.amount,
      required this.quantity,
      required this.percentage});
  factory CategorySalesData.fromJson(Map<String, dynamic> json) =>
      CategorySalesData(
        category: json['category'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 0,
        percentage: (json['percentage'] ?? 0).toDouble(),
      );
  @override
  List<Object?> get props => [category];
}

class AgentSalesData extends Equatable {
  final String agentId;
  final String agentName;
  final double sales;
  final int orders;
  final double target;
  final double progress;
  const AgentSalesData(
      {required this.agentId,
      required this.agentName,
      required this.sales,
      required this.orders,
      required this.target,
      required this.progress});
  factory AgentSalesData.fromJson(Map<String, dynamic> json) => AgentSalesData(
        agentId: json['agentId'] ?? '',
        agentName: json['agentName'] ?? '',
        sales: (json['sales'] ?? 0).toDouble(),
        orders: json['orders'] ?? 0,
        target: (json['target'] ?? 0).toDouble(),
        progress: (json['progress'] ?? 0).toDouble(),
      );
  @override
  List<Object?> get props => [agentId];
}

class DailyReport extends Equatable {
  final DateTime date;
  final String agentId;
  final String agentName;
  final int totalOrders;
  final double totalSales;
  final double totalCollections;
  final int totalVisits;
  final int completedVisits;
  final double totalDistance;
  final Duration workHours;
  final List<Map<String, dynamic>> topProducts;
  final List<Map<String, dynamic>> topCustomers;

  const DailyReport({
    required this.date,
    required this.agentId,
    required this.agentName,
    required this.totalOrders,
    required this.totalSales,
    required this.totalCollections,
    required this.totalVisits,
    required this.completedVisits,
    required this.totalDistance,
    required this.workHours,
    required this.topProducts,
    required this.topCustomers,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) => DailyReport(
        date: DateTime.parse(json['date']),
        agentId: json['agentId'] ?? '',
        agentName: json['agentName'] ?? '',
        totalOrders: json['totalOrders'] ?? 0,
        totalSales: (json['totalSales'] ?? 0).toDouble(),
        totalCollections: (json['totalCollections'] ?? 0).toDouble(),
        totalVisits: json['totalVisits'] ?? 0,
        completedVisits: json['completedVisits'] ?? 0,
        totalDistance: (json['totalDistance'] ?? 0).toDouble(),
        workHours: Duration(seconds: json['workHoursSeconds'] ?? 0),
        topProducts: List<Map<String, dynamic>>.from(json['topProducts'] ?? []),
        topCustomers:
            List<Map<String, dynamic>>.from(json['topCustomers'] ?? []),
      );

  @override
  List<Object?> get props => [date, agentId];
}
