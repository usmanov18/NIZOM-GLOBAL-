import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SalesReport>> getSalesReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? agentId,
    String? regionId,
  }) async {
    try {
      final data = await remoteDataSource.getSalesReport(
        fromDate: fromDate,
        toDate: toDate,
        agentId: agentId,
        regionId: regionId,
      );
      return Right(_parseSalesReport(data, fromDate, toDate));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> getDailyReport({
    required String agentId,
    required DateTime date,
  }) async {
    try {
      final data = await remoteDataSource.getDailyReport(agentId, date);
      return Right(_parseDailyReport(data, agentId, date));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAgentReport({
    required String agentId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      return Right(
          await remoteDataSource.getAgentReport(agentId, fromDate, toDate));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? segment,
  }) async {
    try {
      return Right(await remoteDataSource.getCustomerReport(fromDate, toDate,
          segment: segment));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getProductReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? categoryId,
  }) async {
    try {
      return Right(await remoteDataSource.getProductReport(fromDate, toDate,
          categoryId: categoryId));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPaymentReport({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      return Right(await remoteDataSource.getPaymentReport(fromDate, toDate));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDeliveryReport({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      return Right(await remoteDataSource.getDeliveryReport(fromDate, toDate));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, String>> exportReport({
    required ReportType type,
    required ReportFormat format,
    required DateTime fromDate,
    required DateTime toDate,
    String? agentId,
  }) async {
    try {
      final fileUrl = await remoteDataSource.exportReport({
        'type': type.name,
        'format': format.name,
        'from': fromDate.toIso8601String().substring(0, 10),
        'to': toDate.toIso8601String().substring(0, 10),
        if (agentId != null) 'agent_id': agentId,
      });
      return Right(fileUrl);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  SalesReport _parseSalesReport(
      Map<String, dynamic> data, DateTime fromDate, DateTime toDate) {
    return SalesReport(
      fromDate: fromDate,
      toDate: toDate,
      totalSales: (data['total_sales'] ?? data['totalSales'] ?? 0).toDouble(),
      totalOrders: data['total_orders'] ?? data['totalOrders'] ?? 0,
      avgOrderValue:
          (data['avg_order_value'] ?? data['avgOrderValue'] ?? 0).toDouble(),
      salesGrowth:
          (data['sales_growth'] ?? data['salesGrowth'] ?? 0).toDouble(),
      dailySales: (data['daily_sales'] as List? ?? [])
          .map((item) => DailySalesData(
                date: DateTime.parse(
                    item['date'] ?? DateTime.now().toIso8601String()),
                amount: (item['amount'] ?? 0).toDouble(),
                orders: item['orders'] ?? 0,
              ))
          .toList(),
      categorySales: (data['category_sales'] as List? ?? [])
          .map((item) => CategorySalesData(
                category: item['category'] ?? '',
                amount: (item['amount'] ?? 0).toDouble(),
                quantity: item['quantity'] ?? 0,
                percentage: (item['percentage'] ?? 0).toDouble(),
              ))
          .toList(),
      agentSales: (data['agent_sales'] as List? ?? [])
          .map((item) => AgentSalesData(
                agentId: item['agent_id'] ?? '',
                agentName: item['agent_name'] ?? '',
                sales: (item['sales'] ?? 0).toDouble(),
                orders: item['orders'] ?? 0,
                target: (item['target'] ?? 0).toDouble(),
                progress: (item['progress'] ?? 0).toDouble(),
              ))
          .toList(),
    );
  }

  DailyReport _parseDailyReport(
      Map<String, dynamic> data, String agentId, DateTime date) {
    return DailyReport(
      date: date,
      agentId: agentId,
      agentName: data['agent_name'] ?? '',
      totalOrders: data['total_orders'] ?? 0,
      totalSales: (data['total_sales'] ?? 0).toDouble(),
      totalCollections: (data['total_collections'] ?? 0).toDouble(),
      totalVisits: data['total_visits'] ?? 0,
      completedVisits: data['completed_visits'] ?? 0,
      totalDistance: (data['total_distance'] ?? 0).toDouble(),
      workHours: Duration(minutes: data['work_minutes'] ?? 0),
      topProducts: List<Map<String, dynamic>>.from(data['top_products'] ?? []),
      topCustomers:
          List<Map<String, dynamic>>.from(data['top_customers'] ?? []),
    );
  }
}
