import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/visit_entities.dart';
import '../../domain/repositories/visit_repository.dart';

// ============================================================
// VISIT BLOC - Tashriflar boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class VisitEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class VisitsLoadRequested extends VisitEvent {
  final String agentId;
  final DateTime? date;
  final String? status;
  VisitsLoadRequested({this.agentId = 'current', this.date, this.status});
}

class VisitCreateRequested extends VisitEvent {
  final String customerId;
  final VisitType type;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String? purpose;
  VisitCreateRequested({
    required this.customerId,
    required this.type,
    required this.scheduledDate,
    required this.scheduledTime,
    this.purpose,
  });
}

class VisitCheckInRequested extends VisitEvent {
  final String visitId;
  final double latitude;
  final double longitude;
  VisitCheckInRequested({
    required this.visitId,
    required this.latitude,
    required this.longitude,
  });
}

class VisitCheckOutRequested extends VisitEvent {
  final String visitId;
  final double latitude;
  final double longitude;
  final String? notes;
  final double? orderAmount;
  final double? collectionAmount;
  VisitCheckOutRequested({
    required this.visitId,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.orderAmount,
    this.collectionAmount,
  });
}

class VisitCancelRequested extends VisitEvent {
  final String visitId;
  final String reason;
  VisitCancelRequested({required this.visitId, required this.reason});
}

class VisitRescheduleRequested extends VisitEvent {
  final String visitId;
  final DateTime newDate;
  final String newTime;
  VisitRescheduleRequested({
    required this.visitId,
    required this.newDate,
    required this.newTime,
  });
}

class VisitStatisticsLoadRequested extends VisitEvent {
  final DateTime fromDate;
  final DateTime toDate;
  VisitStatisticsLoadRequested({required this.fromDate, required this.toDate});
}

class WeeklyPlanLoadRequested extends VisitEvent {
  final DateTime weekStart;
  WeeklyPlanLoadRequested({required this.weekStart});
}

// ============ STATES ============

abstract class VisitState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VisitInitial extends VisitState {}

class VisitLoading extends VisitState {}

class VisitsLoaded extends VisitState {
  final List<Visit> visits;
  VisitsLoaded(this.visits);
}

class VisitCreated extends VisitState {
  final Visit visit;
  VisitCreated(this.visit);
}

class VisitCheckedIn extends VisitState {
  final Visit visit;
  VisitCheckedIn(this.visit);
}

class VisitCheckedOut extends VisitState {
  final Visit visit;
  VisitCheckedOut(this.visit);
}

class VisitCancelled extends VisitState {}

class VisitRescheduled extends VisitState {
  final Visit visit;
  VisitRescheduled(this.visit);
}

class VisitStatisticsLoaded extends VisitState {
  final VisitStatistics stats;
  VisitStatisticsLoaded(this.stats);
}

class WeeklyPlanLoaded extends VisitState {
  final List<Visit> visits;
  WeeklyPlanLoaded(this.visits);
}

class VisitError extends VisitState {
  final String message;
  VisitError(this.message);
}

// ============ BLOC ============

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final VisitRepository repository;

  VisitBloc({required this.repository}) : super(VisitInitial()) {
    on<VisitsLoadRequested>(_onVisitsLoad);
    on<VisitCreateRequested>(_onVisitCreate);
    on<VisitCheckInRequested>(_onCheckIn);
    on<VisitCheckOutRequested>(_onCheckOut);
    on<VisitCancelRequested>(_onCancel);
    on<VisitRescheduleRequested>(_onReschedule);
    on<VisitStatisticsLoadRequested>(_onStatisticsLoad);
    on<WeeklyPlanLoadRequested>(_onWeeklyPlanLoad);
  }

  Future<void> _onVisitsLoad(
    VisitsLoadRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());
    final result = await repository.getVisits(
      agentId: event.agentId,
      date: event.date,
      status: event.status,
    );
    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (visits) => emit(VisitsLoaded(visits)),
    );
  }

  Future<void> _onVisitCreate(
    VisitCreateRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());
    final result = await repository.createVisit(
      agentId: 'current',
      customerId: event.customerId,
      type: event.type,
      scheduledDate: event.scheduledDate,
      scheduledTime: event.scheduledTime,
      purpose: event.purpose,
    );
    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (visit) => emit(VisitCreated(visit)),
    );
  }

  Future<void> _onCheckIn(
    VisitCheckInRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());
    final result = await repository.checkIn(
      visitId: event.visitId,
      latitude: event.latitude,
      longitude: event.longitude,
    );
    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (visit) => emit(VisitCheckedIn(visit)),
    );
  }

  Future<void> _onCheckOut(
    VisitCheckOutRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());
    final result = await repository.checkOut(
      visitId: event.visitId,
      latitude: event.latitude,
      longitude: event.longitude,
      notes: event.notes,
      orderAmount: event.orderAmount,
      collectionAmount: event.collectionAmount,
    );
    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (visit) => emit(VisitCheckedOut(visit)),
    );
  }

  Future<void> _onCancel(
    VisitCancelRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());
    final result = await repository.cancelVisit(
      visitId: event.visitId,
      reason: event.reason,
    );
    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (_) => emit(VisitCancelled()),
    );
  }

  Future<void> _onReschedule(
    VisitRescheduleRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());
    final result = await repository.rescheduleVisit(
      visitId: event.visitId,
      newDate: event.newDate,
      newTime: event.newTime,
    );
    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (visit) => emit(VisitRescheduled(visit)),
    );
  }

  Future<void> _onStatisticsLoad(
    VisitStatisticsLoadRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());
    final result = await repository.getStatistics(
      agentId: 'current',
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (stats) => emit(VisitStatisticsLoaded(stats)),
    );
  }

  Future<void> _onWeeklyPlanLoad(
    WeeklyPlanLoadRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());
    final result = await repository.getWeeklyPlan(
      agentId: 'current',
      weekStart: event.weekStart,
    );
    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (visits) => emit(WeeklyPlanLoaded(visits)),
    );
  }
}
