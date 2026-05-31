import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import 'models/analytics_models.dart';

// ============================================================
// ANALYTICS SERVICE - Professional Analitika
// ============================================================

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // ============ DASHBOARD ============

  Future<Either<Failure, DashboardData>> getDashboard({
    required String agentId,
    PeriodType period = PeriodType.daily,
  }) async {
    try {
      final now = DateTime.now();
      DateTime fromDate;

      switch (period) {
        case PeriodType.daily:
          fromDate = DateTime(now.year, now.month, now.day);
          break;
        case PeriodType.weekly:
          fromDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case PeriodType.monthly:
          fromDate = DateTime(now.year, now.month, 1);
          break;
        default:
          fromDate = DateTime(now.year, now.month, 1);
      }

      return Right(DashboardData(
        sales: SalesStatistics(
          period: period,
          fromDate: fromDate,
          toDate: now,
          totalSales: 156000000,
          totalOrders: 45,
          avgOrderValue: 3466667,
          maxOrderValue: 12000000,
          minOrderValue: 500000,
          salesGrowth: 12.5,
          ordersGrowth: 8.3,
          avgGrowth: 3.9,
          previousPeriodSales: 139000000,
          previousPeriodOrders: 42,
        ),
        payments: const PaymentAnalytics(
          totalCollected: 120000000,
          cashAmount: 70000000,
          cardAmount: 30000000,
          transferAmount: 15000000,
          creditAmount: 5000000,
          collectionRate: 0.77,
          outstandingDebt: 36000000,
          overdueDebt: 12000000,
          overdueCustomers: 8,
        ),
        weeklySales: List.generate(
            7,
            (i) => DailySales(
                  date: now.subtract(Duration(days: 6 - i)),
                  amount: 15000000 + (i * 3000000),
                  orders: 5 + i,
                  avgOrder: 3000000,
                )),
        topCategories: const [
          CategorySales(
              categoryId: '1',
              categoryName: 'Ichimliklar',
              amount: 45000000,
              quantity: 500,
              percentage: 29,
              growth: 15),
          CategorySales(
              categoryId: '2',
              categoryName: 'Sut mahsulotlari',
              amount: 30000000,
              quantity: 300,
              percentage: 19,
              growth: 8),
          CategorySales(
              categoryId: '3',
              categoryName: 'Non mahsulotlari',
              amount: 25000000,
              quantity: 400,
              percentage: 16,
              growth: 5),
        ],
        topAgents: List.generate(
            5,
            (i) => AgentPerformance(
                  agentId: 'agent_$i',
                  agentName: 'Agent ${i + 1}',
                  agentCode: 'AG${(i + 1).toString().padLeft(3, '0')}',
                  sales: 30000000 - (i * 5000000),
                  orders: 15 - (i * 2),
                  visits: 20 - (i * 3),
                  completedVisits: 18 - (i * 3),
                  collections: 25000000 - (i * 4000000),
                  distance: 45 - (i * 5),
                  rating: 4.8 - (i * 0.1),
                  salesProgress: 0.95 - (i * 0.1),
                  visitProgress: 0.9 - (i * 0.1),
                )),
        topProducts: const [
          ProductAnalytics(
              productId: '1',
              productName: 'Coca-Cola 1.5L',
              category: 'Ichimliklar',
              quantitySold: 240,
              revenue: 24000000,
              avgPrice: 100000,
              stockQuantity: 500,
              stockValue: 50000000,
              growth: 20),
          ProductAnalytics(
              productId: '2',
              productName: 'Fanta 1.5L',
              category: 'Ichimliklar',
              quantitySold: 180,
              revenue: 18000000,
              avgPrice: 100000,
              stockQuantity: 300,
              stockValue: 30000000,
              growth: 15),
          ProductAnalytics(
              productId: '3',
              productName: 'Sprite 0.5L',
              category: 'Ichimliklar',
              quantitySold: 320,
              revenue: 16000000,
              avgPrice: 50000,
              stockQuantity: 800,
              stockValue: 40000000,
              growth: 10),
        ],
        topCustomers: const [
          CustomerAnalytics(
              customerId: '1',
              customerName: 'Super Market Barka',
              totalSales: 45000000,
              totalOrders: 12,
              avgOrder: 3750000,
              currentDebt: 5000000,
              daysSinceLastOrder: 2,
              segment: 'vip'),
          CustomerAnalytics(
              customerId: '2',
              customerName: 'Market O\'zbekiston',
              totalSales: 32000000,
              totalOrders: 8,
              avgOrder: 4000000,
              currentDebt: 0,
              daysSinceLastOrder: 5,
              segment: 'active'),
          CustomerAnalytics(
              customerId: '3',
              customerName: 'Mini Market Farhod',
              totalSales: 28000000,
              totalOrders: 10,
              avgOrder: 2800000,
              currentDebt: 3000000,
              daysSinceLastOrder: 1,
              segment: 'vip'),
        ],
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Dashboard yuklashda xatolik: $e'));
    }
  }

  // ============ SAVDO HISOBOTLARI ============

  Future<Either<Failure, SalesStatistics>> getSalesReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? agentId,
    String? regionId,
  }) async {
    try {
      return Right(SalesStatistics(
        period: PeriodType.custom,
        fromDate: fromDate,
        toDate: toDate,
        totalSales: 567000000,
        totalOrders: 156,
        avgOrderValue: 3634615,
        maxOrderValue: 25000000,
        minOrderValue: 250000,
        salesGrowth: 15.2,
        ordersGrowth: 10.5,
        avgGrowth: 4.3,
        previousPeriodSales: 493000000,
        previousPeriodOrders: 141,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Savdo hisoboti yuklashda xatolik'));
    }
  }

  // ============ AGENT HISOBOTLARI ============

  Future<Either<Failure, AgentPerformance>> getAgentReport({
    required String agentId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      return Right(AgentPerformance(
        agentId: agentId,
        agentName: 'Karimov Alisher',
        agentCode: 'AG001',
        sales: 156000000,
        orders: 45,
        visits: 60,
        completedVisits: 52,
        collections: 120000000,
        distance: 234.5,
        rating: 4.7,
        salesProgress: 0.78,
        visitProgress: 0.87,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Agent hisoboti yuklashda xatolik'));
    }
  }

  // ============ MAHSULOT HISOBOTLARI ============

  Future<Either<Failure, List<ProductAnalytics>>> getProductReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? categoryId,
    int limit = 20,
  }) async {
    try {
      return Right(List.generate(
          limit,
          (i) => ProductAnalytics(
                productId: 'prod_$i',
                productName: 'Mahsulot ${i + 1}',
                category: 'Kategoriya ${(i % 5) + 1}',
                quantitySold: 100 - (i * 5),
                revenue: 10000000 - (i * 500000),
                avgPrice: 100000,
                stockQuantity: 200 - (i * 10),
                stockValue: 20000000 - (i * 1000000),
                growth: 15.0 - i,
              )));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Mahsulot hisoboti yuklashda xatolik'));
    }
  }

  // ============ MIJOZ HISOBOTLARI ============

  Future<Either<Failure, List<CustomerAnalytics>>> getCustomerReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? segment,
    int limit = 20,
  }) async {
    try {
      return Right(List.generate(
          limit,
          (i) => CustomerAnalytics(
                customerId: 'cust_$i',
                customerName: 'Mijoz ${i + 1}',
                totalSales: 20000000 - (i * 1000000),
                totalOrders: 10 - i,
                avgOrder: 2000000,
                currentDebt: i % 3 == 0 ? 5000000 : 0,
                daysSinceLastOrder: i * 2,
                segment: i < 3
                    ? 'vip'
                    : i < 7
                        ? 'active'
                        : 'inactive',
              )));
    } catch (e) {
      return Left(ServerFailure(message: 'Mijoz hisoboti yuklashda xatolik'));
    }
  }

  // ============ TO'LOV HISOBOTLARI ============

  Future<Either<Failure, PaymentAnalytics>> getPaymentReport({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      return const Right(PaymentAnalytics(
        totalCollected: 450000000,
        cashAmount: 250000000,
        cardAmount: 120000000,
        transferAmount: 60000000,
        creditAmount: 20000000,
        collectionRate: 0.82,
        outstandingDebt: 120000000,
        overdueDebt: 45000000,
        overdueCustomers: 15,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'To\'lov hisoboti yuklashda xatolik'));
    }
  }

  // ============ EKSPORT ============

  Future<Either<Failure, String>> exportReport({
    required ReportParams params,
  }) async {
    try {
      final safeType =
          params.reportType.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
      final safeFormat = (params.exportFormat ?? ExportFormat.pdf).name;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return Right('/tmp/nizom_global_${safeType}_$timestamp.$safeFormat');
    } catch (e) {
      return Left(ServerFailure(message: 'Eksport xatoligi'));
    }
  }
}
