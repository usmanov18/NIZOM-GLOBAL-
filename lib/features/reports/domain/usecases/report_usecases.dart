import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_entities.dart';
import '../repositories/report_repository.dart';

// ============================================================
// REPORT USECASES
// ============================================================

class GetSalesReport implements UseCase<SalesReport, GetReportParams> {
  final ReportRepository repository;
  GetSalesReport(this.repository);

  @override
  Future<Either<Failure, SalesReport>> call(GetReportParams params) {
    return repository.getSalesReport(
      fromDate: params.fromDate,
      toDate: params.toDate,
      agentId: params.agentId,
    );
  }
}

class GetDailyReport implements UseCase<DailyReport, GetDailyReportParams> {
  final ReportRepository repository;
  GetDailyReport(this.repository);

  @override
  Future<Either<Failure, DailyReport>> call(GetDailyReportParams params) {
    return repository.getDailyReport(
      agentId: params.agentId,
      date: params.date,
    );
  }
}

class GetCustomerReport
    implements UseCase<List<Map<String, dynamic>>, GetReportParams> {
  final ReportRepository repository;
  GetCustomerReport(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      GetReportParams params) {
    return repository.getCustomerReport(
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

class GetProductReport
    implements UseCase<List<Map<String, dynamic>>, GetReportParams> {
  final ReportRepository repository;
  GetProductReport(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      GetReportParams params) {
    return repository.getProductReport(
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

class ExportReport implements UseCase<String, ExportReportParams> {
  final ReportRepository repository;
  ExportReport(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportReportParams params) {
    return repository.exportReport(
      type: params.type,
      format: params.format,
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

// ============ PARAMS ============

class GetReportParams extends Equatable {
  final DateTime fromDate;
  final DateTime toDate;
  final String? agentId;
  final String? regionId;

  const GetReportParams({
    required this.fromDate,
    required this.toDate,
    this.agentId,
    this.regionId,
  });

  @override
  List<Object?> get props => [fromDate, toDate, agentId];
}

class GetDailyReportParams extends Equatable {
  final String agentId;
  final DateTime date;

  const GetDailyReportParams({
    required this.agentId,
    required this.date,
  });

  @override
  List<Object?> get props => [agentId, date];
}

class ExportReportParams extends Equatable {
  final ReportType type;
  final ReportFormat format;
  final DateTime fromDate;
  final DateTime toDate;
  final String? agentId;

  const ExportReportParams({
    required this.type,
    required this.format,
    required this.fromDate,
    required this.toDate,
    this.agentId,
  });

  @override
  List<Object?> get props => [type, format, fromDate, toDate];
}
