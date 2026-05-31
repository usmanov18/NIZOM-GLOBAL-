import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit_entities.dart';
import '../repositories/visit_repository.dart';

// ============================================================
// VISIT USECASES
// ============================================================

class GetVisits implements UseCase<List<Visit>, GetVisitsParams> {
  final VisitRepository repository;
  GetVisits(this.repository);

  @override
  Future<Either<Failure, List<Visit>>> call(GetVisitsParams params) {
    return repository.getVisits(
      agentId: params.agentId,
      date: params.date,
      status: params.status,
      page: params.page,
    );
  }
}

class CreateVisit implements UseCase<Visit, CreateVisitParams> {
  final VisitRepository repository;
  CreateVisit(this.repository);

  @override
  Future<Either<Failure, Visit>> call(CreateVisitParams params) {
    return repository.createVisit(
      agentId: params.agentId,
      customerId: params.customerId,
      type: params.type,
      scheduledDate: params.scheduledDate,
      scheduledTime: params.scheduledTime,
      purpose: params.purpose,
    );
  }
}

class CheckInVisit implements UseCase<Visit, CheckInParams> {
  final VisitRepository repository;
  CheckInVisit(this.repository);

  @override
  Future<Either<Failure, Visit>> call(CheckInParams params) {
    return repository.checkIn(
      visitId: params.visitId,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class CheckOutVisit implements UseCase<Visit, CheckOutParams> {
  final VisitRepository repository;
  CheckOutVisit(this.repository);

  @override
  Future<Either<Failure, Visit>> call(CheckOutParams params) {
    return repository.checkOut(
      visitId: params.visitId,
      latitude: params.latitude,
      longitude: params.longitude,
      notes: params.notes,
      orderAmount: params.orderAmount,
      collectionAmount: params.collectionAmount,
    );
  }
}

class GetVisitStatistics
    implements UseCase<VisitStatistics, GetVisitStatsParams> {
  final VisitRepository repository;
  GetVisitStatistics(this.repository);

  @override
  Future<Either<Failure, VisitStatistics>> call(GetVisitStatsParams params) {
    return repository.getStatistics(
      agentId: params.agentId,
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

class GetWeeklyPlan implements UseCase<List<Visit>, GetWeeklyPlanParams> {
  final VisitRepository repository;
  GetWeeklyPlan(this.repository);

  @override
  Future<Either<Failure, List<Visit>>> call(GetWeeklyPlanParams params) {
    return repository.getWeeklyPlan(
      agentId: params.agentId,
      weekStart: params.weekStart,
    );
  }
}

// ============ PARAMS ============

class GetVisitsParams extends Equatable {
  final String agentId;
  final DateTime? date;
  final String? status;
  final int page;

  const GetVisitsParams({
    required this.agentId,
    this.date,
    this.status,
    this.page = 1,
  });

  @override
  List<Object?> get props => [agentId, date, status, page];
}

class CreateVisitParams extends Equatable {
  final String agentId;
  final String customerId;
  final VisitType type;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String? purpose;

  const CreateVisitParams({
    required this.agentId,
    required this.customerId,
    required this.type,
    required this.scheduledDate,
    required this.scheduledTime,
    this.purpose,
  });

  @override
  List<Object?> get props => [agentId, customerId, scheduledDate];
}

class CheckInParams extends Equatable {
  final String visitId;
  final double latitude;
  final double longitude;

  const CheckInParams({
    required this.visitId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [visitId];
}

class CheckOutParams extends Equatable {
  final String visitId;
  final double latitude;
  final double longitude;
  final String? notes;
  final double? orderAmount;
  final double? collectionAmount;

  const CheckOutParams({
    required this.visitId,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.orderAmount,
    this.collectionAmount,
  });

  @override
  List<Object?> get props => [visitId];
}

class GetVisitStatsParams extends Equatable {
  final String agentId;
  final DateTime fromDate;
  final DateTime toDate;

  const GetVisitStatsParams({
    required this.agentId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [agentId, fromDate, toDate];
}

class GetWeeklyPlanParams extends Equatable {
  final String agentId;
  final DateTime weekStart;

  const GetWeeklyPlanParams({
    required this.agentId,
    required this.weekStart,
  });

  @override
  List<Object?> get props => [agentId, weekStart];
}
