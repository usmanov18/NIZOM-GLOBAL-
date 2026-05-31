import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/report_entities.dart';

// ============================================================
// REPORT REPOSITORY - Hisobotlar API
// ============================================================

abstract class ReportRepository {
  /// Savdo hisoboti
  Future<Either<Failure, SalesReport>> getSalesReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? agentId,
    String? regionId,
  });

  /// Kunlik hisobot
  Future<Either<Failure, DailyReport>> getDailyReport({
    required String agentId,
    required DateTime date,
  });

  /// Agent hisoboti
  Future<Either<Failure, Map<String, dynamic>>> getAgentReport({
    required String agentId,
    required DateTime fromDate,
    required DateTime toDate,
  });

  /// Mijoz hisoboti
  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? segment,
  });

  /// Mahsulot hisoboti
  Future<Either<Failure, List<Map<String, dynamic>>>> getProductReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? categoryId,
  });

  /// To'lov hisoboti
  Future<Either<Failure, Map<String, dynamic>>> getPaymentReport({
    required DateTime fromDate,
    required DateTime toDate,
  });

  /// Yetkazish hisoboti
  Future<Either<Failure, Map<String, dynamic>>> getDeliveryReport({
    required DateTime fromDate,
    required DateTime toDate,
  });

  /// Hisobotni export qilish
  Future<Either<Failure, String>> exportReport({
    required ReportType type,
    required ReportFormat format,
    required DateTime fromDate,
    required DateTime toDate,
    String? agentId,
  });
}
