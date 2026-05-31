import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/agent_dashboard.dart';
import '../../domain/usecases/get_agent_dashboard.dart';
import '../../domain/usecases/get_agent_orders.dart';
import '../../domain/usecases/create_agent_order.dart';
import '../../domain/repositories/agent_repository.dart';
import '../../../../core/usecases/usecase.dart';

// ============ EVENTS ============

abstract class AgentDashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Dashboard yuklash
class AgentDashboardLoadRequested extends AgentDashboardEvent {}

/// Dashboard yangilash (pull-to-refresh)
class AgentDashboardRefreshRequested extends AgentDashboardEvent {}

/// Buyurtmalar yuklash
class AgentOrdersLoadRequested extends AgentDashboardEvent {
  final String? status;
  final int page;

  AgentOrdersLoadRequested({this.status, this.page = 1});

  @override
  List<Object?> get props => [status, page];
}

/// Yangi buyurtma yaratish
class AgentOrderCreateRequested extends AgentDashboardEvent {
  final CreateOrderParams params;

  AgentOrderCreateRequested(this.params);

  @override
  List<Object?> get props => [params];
}

/// Tashrifni boshlash
class AgentVisitCheckInRequested extends AgentDashboardEvent {
  final String visitId;
  final double latitude;
  final double longitude;

  AgentVisitCheckInRequested({
    required this.visitId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [visitId, latitude, longitude];
}

/// Tashrifni yakunlash
class AgentVisitCheckOutRequested extends AgentDashboardEvent {
  final String visitId;
  final String? notes;
  final double? orderAmount;

  AgentVisitCheckOutRequested({
    required this.visitId,
    this.notes,
    this.orderAmount,
  });

  @override
  List<Object?> get props => [visitId, notes, orderAmount];
}

/// KPI yuklash
class AgentKPILoadRequested extends AgentDashboardEvent {
  final String period;

  AgentKPILoadRequested({this.period = 'monthly'});

  @override
  List<Object?> get props => [period];
}

// ============ STATES ============

abstract class AgentDashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Boshlang'ich holat
class AgentDashboardInitial extends AgentDashboardState {}

/// Yuklanmoqda
class AgentDashboardLoading extends AgentDashboardState {}

/// Dashboard yuklandi
class AgentDashboardLoaded extends AgentDashboardState {
  final AgentDashboard dashboard;

  AgentDashboardLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

/// Buyurtmalar yuklandi
class AgentOrdersLoaded extends AgentDashboardState {
  final List<AgentOrder> orders;
  final bool hasMore;
  final int currentPage;

  AgentOrdersLoaded({
    required this.orders,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [orders, hasMore, currentPage];
}

/// Buyurtma yaratildi
class AgentOrderCreated extends AgentDashboardState {
  final AgentOrder order;

  AgentOrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

/// Tashrif boshlandi
class AgentVisitCheckedIn extends AgentDashboardState {
  final AgentVisit visit;

  AgentVisitCheckedIn(this.visit);

  @override
  List<Object?> get props => [visit];
}

/// Tashrif yakunlandi
class AgentVisitCheckedOut extends AgentDashboardState {
  final AgentVisit visit;

  AgentVisitCheckedOut(this.visit);

  @override
  List<Object?> get props => [visit];
}

/// KPI yuklandi
class AgentKPILoaded extends AgentDashboardState {
  final AgentKPI kpi;

  AgentKPILoaded(this.kpi);

  @override
  List<Object?> get props => [kpi];
}

/// Xatolik
class AgentDashboardError extends AgentDashboardState {
  final String message;
  final String? errorCode;

  AgentDashboardError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

// ============ BLOC ============

class AgentDashboardBloc
    extends Bloc<AgentDashboardEvent, AgentDashboardState> {
  final GetAgentDashboard _getDashboard;
  final GetAgentOrders _getOrders;
  final CreateAgentOrder _createOrder;
  final AgentRepository _repository;

  AgentDashboardBloc({
    required GetAgentDashboard getDashboard,
    required GetAgentOrders getOrders,
    required CreateAgentOrder createOrder,
    required AgentRepository repository,
  })  : _getDashboard = getDashboard,
        _getOrders = getOrders,
        _createOrder = createOrder,
        _repository = repository,
        super(AgentDashboardInitial()) {
    on<AgentDashboardLoadRequested>(_onDashboardLoad);
    on<AgentDashboardRefreshRequested>(_onDashboardRefresh);
    on<AgentOrdersLoadRequested>(_onOrdersLoad);
    on<AgentOrderCreateRequested>(_onOrderCreate);
    on<AgentVisitCheckInRequested>(_onVisitCheckIn);
    on<AgentVisitCheckOutRequested>(_onVisitCheckOut);
    on<AgentKPILoadRequested>(_onKPILoad);
  }

  // Dashboard yuklash
  Future<void> _onDashboardLoad(
    AgentDashboardLoadRequested event,
    Emitter<AgentDashboardState> emit,
  ) async {
    emit(AgentDashboardLoading());

    final result = await _getDashboard(NoParams());

    result.fold(
      (failure) => emit(AgentDashboardError(
        message: failure.message,
        errorCode: failure.statusCode?.toString(),
      )),
      (dashboard) => emit(AgentDashboardLoaded(dashboard)),
    );
  }

  // Dashboard yangilash
  Future<void> _onDashboardRefresh(
    AgentDashboardRefreshRequested event,
    Emitter<AgentDashboardState> emit,
  ) async {
    final result = await _getDashboard(NoParams());

    result.fold(
      (failure) => emit(AgentDashboardError(message: failure.message)),
      (dashboard) => emit(AgentDashboardLoaded(dashboard)),
    );
  }

  // Buyurtmalar yuklash
  Future<void> _onOrdersLoad(
    AgentOrdersLoadRequested event,
    Emitter<AgentDashboardState> emit,
  ) async {
    emit(AgentDashboardLoading());

    final result = await _getOrders(AgentOrdersParams(
      status: event.status,
      page: event.page,
    ));

    result.fold(
      (failure) => emit(AgentDashboardError(message: failure.message)),
      (orders) => emit(AgentOrdersLoaded(
        orders: orders,
        hasMore: orders.length >= 20,
        currentPage: event.page,
      )),
    );
  }

  // Buyurtma yaratish
  Future<void> _onOrderCreate(
    AgentOrderCreateRequested event,
    Emitter<AgentDashboardState> emit,
  ) async {
    emit(AgentDashboardLoading());

    final result = await _createOrder(event.params);

    result.fold(
      (failure) => emit(AgentDashboardError(message: failure.message)),
      (order) => emit(AgentOrderCreated(order)),
    );
  }

  // Tashrifni boshlash
  Future<void> _onVisitCheckIn(
    AgentVisitCheckInRequested event,
    Emitter<AgentDashboardState> emit,
  ) async {
    emit(AgentDashboardLoading());

    final result = await _repository.checkInVisit(
      visitId: event.visitId,
      latitude: event.latitude,
      longitude: event.longitude,
    );

    result.fold(
      (failure) => emit(AgentDashboardError(message: failure.message)),
      (visit) => emit(AgentVisitCheckedIn(visit)),
    );
  }

  // Tashrifni yakunlash
  Future<void> _onVisitCheckOut(
    AgentVisitCheckOutRequested event,
    Emitter<AgentDashboardState> emit,
  ) async {
    emit(AgentDashboardLoading());

    final result = await _repository.checkOutVisit(
      visitId: event.visitId,
      notes: event.notes,
      orderAmount: event.orderAmount,
    );

    result.fold(
      (failure) => emit(AgentDashboardError(message: failure.message)),
      (visit) => emit(AgentVisitCheckedOut(visit)),
    );
  }

  // KPI yuklash
  Future<void> _onKPILoad(
    AgentKPILoadRequested event,
    Emitter<AgentDashboardState> emit,
  ) async {
    final result = await _repository.getKPI(period: event.period);

    result.fold(
      (failure) => emit(AgentDashboardError(message: failure.message)),
      (kpi) => emit(AgentKPILoaded(kpi)),
    );
  }
}
