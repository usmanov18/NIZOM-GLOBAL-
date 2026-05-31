import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'models/analytics_models.dart';
import 'analytics_service.dart';

// ============================================================
// ANALYTICS BLOC - Analitika boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class AnalyticsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends AnalyticsEvent {
  final String agentId;
  final PeriodType period;
  DashboardLoadRequested(
      {required this.agentId, this.period = PeriodType.daily});
}

class SalesReportLoadRequested extends AnalyticsEvent {
  final DateTime fromDate;
  final DateTime toDate;
  final String? agentId;
  SalesReportLoadRequested(
      {required this.fromDate, required this.toDate, this.agentId});
}

class AgentReportLoadRequested extends AnalyticsEvent {
  final String agentId;
  final DateTime fromDate;
  final DateTime toDate;
  AgentReportLoadRequested(
      {required this.agentId, required this.fromDate, required this.toDate});
}

class ProductReportLoadRequested extends AnalyticsEvent {
  final DateTime fromDate;
  final DateTime toDate;
  final String? categoryId;
  ProductReportLoadRequested(
      {required this.fromDate, required this.toDate, this.categoryId});
}

class CustomerReportLoadRequested extends AnalyticsEvent {
  final DateTime fromDate;
  final DateTime toDate;
  final String? segment;
  CustomerReportLoadRequested(
      {required this.fromDate, required this.toDate, this.segment});
}

class PaymentReportLoadRequested extends AnalyticsEvent {
  final DateTime fromDate;
  final DateTime toDate;
  PaymentReportLoadRequested({required this.fromDate, required this.toDate});
}

class ReportExportRequested extends AnalyticsEvent {
  final ReportParams params;
  ReportExportRequested(this.params);
}

// ============ STATES ============

abstract class AnalyticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class DashboardLoaded extends AnalyticsState {
  final DashboardData data;
  DashboardLoaded(this.data);
}

class SalesReportLoaded extends AnalyticsState {
  final SalesStatistics report;
  SalesReportLoaded(this.report);
}

class AgentReportLoaded extends AnalyticsState {
  final AgentPerformance report;
  AgentReportLoaded(this.report);
}

class ProductReportLoaded extends AnalyticsState {
  final List<ProductAnalytics> products;
  ProductReportLoaded(this.products);
}

class CustomerReportLoaded extends AnalyticsState {
  final List<CustomerAnalytics> customers;
  CustomerReportLoaded(this.customers);
}

class PaymentReportLoaded extends AnalyticsState {
  final PaymentAnalytics report;
  PaymentReportLoaded(this.report);
}

class ReportExported extends AnalyticsState {
  final String filePath;
  ReportExported(this.filePath);
}

class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}

// ============ BLOC ============

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsService _service;

  AnalyticsBloc({required AnalyticsService service})
      : _service = service,
        super(AnalyticsInitial()) {
    on<DashboardLoadRequested>(_onDashboardLoad);
    on<SalesReportLoadRequested>(_onSalesReportLoad);
    on<AgentReportLoadRequested>(_onAgentReportLoad);
    on<ProductReportLoadRequested>(_onProductReportLoad);
    on<CustomerReportLoadRequested>(_onCustomerReportLoad);
    on<PaymentReportLoadRequested>(_onPaymentReportLoad);
    on<ReportExportRequested>(_onReportExport);
  }

  Future<void> _onDashboardLoad(
    DashboardLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await _service.getDashboard(
      agentId: event.agentId,
      period: event.period,
    );
    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (data) => emit(DashboardLoaded(data)),
    );
  }

  Future<void> _onSalesReportLoad(
    SalesReportLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await _service.getSalesReport(
      fromDate: event.fromDate,
      toDate: event.toDate,
      agentId: event.agentId,
    );
    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (report) => emit(SalesReportLoaded(report)),
    );
  }

  Future<void> _onAgentReportLoad(
    AgentReportLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await _service.getAgentReport(
      agentId: event.agentId,
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (report) => emit(AgentReportLoaded(report)),
    );
  }

  Future<void> _onProductReportLoad(
    ProductReportLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await _service.getProductReport(
      fromDate: event.fromDate,
      toDate: event.toDate,
      categoryId: event.categoryId,
    );
    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (products) => emit(ProductReportLoaded(products)),
    );
  }

  Future<void> _onCustomerReportLoad(
    CustomerReportLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await _service.getCustomerReport(
      fromDate: event.fromDate,
      toDate: event.toDate,
      segment: event.segment,
    );
    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (customers) => emit(CustomerReportLoaded(customers)),
    );
  }

  Future<void> _onPaymentReportLoad(
    PaymentReportLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await _service.getPaymentReport(
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (report) => emit(PaymentReportLoaded(report)),
    );
  }

  Future<void> _onReportExport(
    ReportExportRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await _service.exportReport(params: event.params);
    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (filePath) => emit(ReportExported(filePath)),
    );
  }
}
