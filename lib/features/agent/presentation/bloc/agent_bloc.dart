import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/agent_dashboard.dart';
import '../../domain/repositories/agent_repository.dart';

// ============================================================
// AGENT BLOC - To'liq ishlaydigan
// ============================================================

// ============ EVENTS ============

abstract class AgentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AgentDashboardLoadRequested extends AgentEvent {}

class AgentDashboardRefreshRequested extends AgentEvent {}

class AgentOrdersLoadRequested extends AgentEvent {
  final String? status;
  final int page;
  AgentOrdersLoadRequested({this.status, this.page = 1});
}

class AgentOrderCreateRequested extends AgentEvent {
  final String customerId;
  final List<OrderItem> items;
  final String? notes;
  final DateTime? deliveryDate;
  AgentOrderCreateRequested({
    required this.customerId,
    required this.items,
    this.notes,
    this.deliveryDate,
  });
}

class AgentVisitsLoadRequested extends AgentEvent {
  final DateTime? date;
  AgentVisitsLoadRequested({this.date});
}

class AgentVisitCheckInRequested extends AgentEvent {
  final String visitId;
  final double latitude;
  final double longitude;
  AgentVisitCheckInRequested({
    required this.visitId,
    required this.latitude,
    required this.longitude,
  });
}

class AgentVisitCheckOutRequested extends AgentEvent {
  final String visitId;
  final String? notes;
  final double? orderAmount;
  AgentVisitCheckOutRequested({
    required this.visitId,
    this.notes,
    this.orderAmount,
  });
}

class AgentKPILoadRequested extends AgentEvent {
  final String period;
  AgentKPILoadRequested({this.period = 'monthly'});
}

// ============ STATES ============

abstract class AgentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AgentInitial extends AgentState {}

class AgentLoading extends AgentState {}

class AgentDashboardLoaded extends AgentState {
  final AgentDashboard dashboard;
  AgentDashboardLoaded(this.dashboard);
}

class AgentOrdersLoaded extends AgentState {
  final List<AgentOrder> orders;
  final bool hasMore;
  final int currentPage;
  AgentOrdersLoaded({
    required this.orders,
    this.hasMore = false,
    this.currentPage = 1,
  });
}

class AgentOrderCreated extends AgentState {
  final AgentOrder order;
  AgentOrderCreated(this.order);
}

class AgentVisitsLoaded extends AgentState {
  final List<AgentVisit> visits;
  AgentVisitsLoaded(this.visits);
}

class AgentVisitCheckedIn extends AgentState {
  final AgentVisit visit;
  AgentVisitCheckedIn(this.visit);
}

class AgentVisitCheckedOut extends AgentState {
  final AgentVisit visit;
  AgentVisitCheckedOut(this.visit);
}

class AgentKPILoaded extends AgentState {
  final AgentKPI kpi;
  AgentKPILoaded(this.kpi);
}

class AgentError extends AgentState {
  final String message;
  AgentError(this.message);
}

// ============ BLOC ============

class AgentBloc extends Bloc<AgentEvent, AgentState> {
  final AgentRepository repository;

  AgentBloc({required this.repository}) : super(AgentInitial()) {
    on<AgentDashboardLoadRequested>(_onDashboardLoad);
    on<AgentDashboardRefreshRequested>(_onDashboardRefresh);
    on<AgentOrdersLoadRequested>(_onOrdersLoad);
    on<AgentOrderCreateRequested>(_onOrderCreate);
    on<AgentVisitsLoadRequested>(_onVisitsLoad);
    on<AgentVisitCheckInRequested>(_onVisitCheckIn);
    on<AgentVisitCheckOutRequested>(_onVisitCheckOut);
    on<AgentKPILoadRequested>(_onKPILoad);
  }

  Future<void> _onDashboardLoad(
    AgentDashboardLoadRequested event,
    Emitter<AgentState> emit,
  ) async {
    emit(AgentLoading());
    final result = await repository.getDashboard();
    result.fold(
      (failure) => emit(AgentError(failure.message)),
      (dashboard) => emit(AgentDashboardLoaded(dashboard)),
    );
  }

  Future<void> _onDashboardRefresh(
    AgentDashboardRefreshRequested event,
    Emitter<AgentState> emit,
  ) async {
    final result = await repository.getDashboard();
    result.fold(
      (failure) => emit(AgentError(failure.message)),
      (dashboard) => emit(AgentDashboardLoaded(dashboard)),
    );
  }

  Future<void> _onOrdersLoad(
    AgentOrdersLoadRequested event,
    Emitter<AgentState> emit,
  ) async {
    emit(AgentLoading());
    final result = await repository.getOrders(
      status: event.status,
      page: event.page,
    );
    result.fold(
      (failure) => emit(AgentError(failure.message)),
      (orders) => emit(AgentOrdersLoaded(
        orders: orders,
        hasMore: orders.length >= 20,
        currentPage: event.page,
      )),
    );
  }

  Future<void> _onOrderCreate(
    AgentOrderCreateRequested event,
    Emitter<AgentState> emit,
  ) async {
    emit(AgentLoading());
    final result = await repository.createOrder(
      customerId: event.customerId,
      items: event.items,
      notes: event.notes,
      deliveryDate: event.deliveryDate,
    );
    result.fold(
      (failure) => emit(AgentError(failure.message)),
      (order) => emit(AgentOrderCreated(order)),
    );
  }

  Future<void> _onVisitsLoad(
    AgentVisitsLoadRequested event,
    Emitter<AgentState> emit,
  ) async {
    emit(AgentLoading());
    final result = await repository.getVisits(date: event.date);
    result.fold(
      (failure) => emit(AgentError(failure.message)),
      (visits) => emit(AgentVisitsLoaded(visits)),
    );
  }

  Future<void> _onVisitCheckIn(
    AgentVisitCheckInRequested event,
    Emitter<AgentState> emit,
  ) async {
    emit(AgentLoading());
    final result = await repository.checkInVisit(
      visitId: event.visitId,
      latitude: event.latitude,
      longitude: event.longitude,
    );
    result.fold(
      (failure) => emit(AgentError(failure.message)),
      (visit) => emit(AgentVisitCheckedIn(visit)),
    );
  }

  Future<void> _onVisitCheckOut(
    AgentVisitCheckOutRequested event,
    Emitter<AgentState> emit,
  ) async {
    emit(AgentLoading());
    final result = await repository.checkOutVisit(
      visitId: event.visitId,
      notes: event.notes,
      orderAmount: event.orderAmount,
    );
    result.fold(
      (failure) => emit(AgentError(failure.message)),
      (visit) => emit(AgentVisitCheckedOut(visit)),
    );
  }

  Future<void> _onKPILoad(
    AgentKPILoadRequested event,
    Emitter<AgentState> emit,
  ) async {
    final result = await repository.getKPI(period: event.period);
    result.fold(
      (failure) => emit(AgentError(failure.message)),
      (kpi) => emit(AgentKPILoaded(kpi)),
    );
  }
}
