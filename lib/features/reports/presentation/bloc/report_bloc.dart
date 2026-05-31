import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/repositories/report_repository.dart';

// ============================================================
// REPORT BLOb - Hisobotlar boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class ReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesReportLoadRequested extends ReportEvent {
  final DateTime fromDate;
  final DateTime toDate;
  final String? agentId;
  SalesReportLoadRequested(
      {required this.fromDate, required this.toDate, this.agentId});
}

class DailyReportLoadRequested extends ReportEvent {
  final String agentId;
  final DateTime date;
  DailyReportLoadRequested({required this.agentId, required this.date});
}

class CustomerReportLoadRequested extends ReportEvent {
  final DateTime fromDate;
  final DateTime toDate;
  final String? segment;
  CustomerReportLoadRequested(
      {required this.fromDate, required this.toDate, this.segment});
}

class ProductReportLoadRequested extends ReportEvent {
  final DateTime fromDate;
  final DateTime toDate;
  final String? categoryId;
  ProductReportLoadRequested(
      {required this.fromDate, required this.toDate, this.categoryId});
}

class ReportExportRequested extends ReportEvent {
  final ReportType type;
  final ReportFormat format;
  final DateTime fromDate;
  final DateTime toDate;
  ReportExportRequested({
    required this.type,
    required this.format,
    required this.fromDate,
    required this.toDate,
  });
}

// ============ STATES ============

abstract class ReportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class SalesReportLoaded extends ReportState {
  final SalesReport report;
  SalesReportLoaded(this.report);
}

class DailyReportLoaded extends ReportState {
  final DailyReport report;
  DailyReportLoaded(this.report);
}

class CustomerReportLoaded extends ReportState {
  final List<Map<String, dynamic>> customers;
  CustomerReportLoaded(this.customers);
}

class ProductReportLoaded extends ReportState {
  final List<Map<String, dynamic>> products;
  ProductReportLoaded(this.products);
}

class ReportExported extends ReportState {
  final String filePath;
  ReportExported(this.filePath);
}

class ReportError extends ReportState {
  final String message;
  ReportError(this.message);
}

// ============ BLOC ============

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repository;

  ReportBloc({required this.repository}) : super(ReportInitial()) {
    on<SalesReportLoadRequested>(_onSalesReport);
    on<DailyReportLoadRequested>(_onDailyReport);
    on<CustomerReportLoadRequested>(_onCustomerReport);
    on<ProductReportLoadRequested>(_onProductReport);
    on<ReportExportRequested>(_onExport);
  }

  Future<void> _onSalesReport(
      SalesReportLoadRequested event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await repository.getSalesReport(
      fromDate: event.fromDate,
      toDate: event.toDate,
      agentId: event.agentId,
    );
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) => emit(SalesReportLoaded(report)),
    );
  }

  Future<void> _onDailyReport(
      DailyReportLoadRequested event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await repository.getDailyReport(
      agentId: event.agentId,
      date: event.date,
    );
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) => emit(DailyReportLoaded(report)),
    );
  }

  Future<void> _onCustomerReport(
      CustomerReportLoadRequested event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await repository.getCustomerReport(
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (customers) => emit(CustomerReportLoaded(customers)),
    );
  }

  Future<void> _onProductReport(
      ProductReportLoadRequested event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await repository.getProductReport(
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (products) => emit(ProductReportLoaded(products)),
    );
  }

  Future<void> _onExport(
      ReportExportRequested event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await repository.exportReport(
      type: event.type,
      format: event.format,
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (filePath) => emit(ReportExported(filePath)),
    );
  }
}
