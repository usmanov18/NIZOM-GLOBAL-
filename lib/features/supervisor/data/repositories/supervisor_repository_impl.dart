import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/supervisor_entities.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../datasources/supervisor_remote_datasource.dart';
import '../datasources/supervisor_local_datasource.dart';

// ============================================================
// SUPERVISOR REPOSITORY IMPLEMENTATION
// ============================================================

class SupervisorRepositoryImpl implements SupervisorRepository {
  final SupervisorRemoteDataSource remoteDataSource;
  final SupervisorLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SupervisorRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SupervisorDashboard>> getDashboard(
      String supervisorId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getDashboard(supervisorId);
        await localDataSource.cacheDashboard(data);
        return Right(_parseDashboard(data));
      } else {
        final cached = await localDataSource.getCachedDashboard();
        if (cached != null) return Right(_parseDashboard(cached));
        return const Left(CacheFailure(message: 'Dashboard topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  SupervisorDashboard _parseDashboard(Map<String, dynamic> data) {
    return SupervisorDashboard(
      supervisorId: data['supervisor_id'] ?? '',
      supervisorName: data['supervisor_name'] ?? '',
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      totalAgents: data['total_agents'] ?? 0,
      onlineAgents: data['online_agents'] ?? 0,
      agentsOnRoute: data['agents_on_route'] ?? 0,
      agentsVisiting: data['agents_visiting'] ?? 0,
      agentsOnBreak: data['agents_on_break'] ?? 0,
      offlineAgents: data['offline_agents'] ?? 0,
      todayOrders: data['today_orders'] ?? 0,
      todaySales: (data['today_sales'] ?? 0).toDouble(),
      pendingOrders: data['pending_orders'] ?? 0,
      confirmedOrders: data['confirmed_orders'] ?? 0,
      cancelledOrders: data['cancelled_orders'] ?? 0,
      todayVisits: data['today_visits'] ?? 0,
      completedVisits: data['completed_visits'] ?? 0,
      missedVisits: data['missed_visits'] ?? 0,
      todayCollections: (data['today_collections'] ?? 0).toDouble(),
      outstandingDebt: (data['outstanding_debt'] ?? 0).toDouble(),
      topAgents: [],
      bottomAgents: [],
      pendingTasks: data['pending_tasks'] ?? 0,
      overdueTasks: data['overdue_tasks'] ?? 0,
    );
  }

  @override
  Future<Either<Failure, List<AgentStatus>>> getAgentsStatus(
      String supervisorId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getAgentsStatus(supervisorId);
        await localDataSource.cacheAgents(data);
        return Right(data.map((d) => _parseAgentStatus(d)).toList());
      } else {
        final cached = await localDataSource.getCachedAgents();
        return Right(cached.map((d) => _parseAgentStatus(d)).toList());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  AgentStatus _parseAgentStatus(Map<String, dynamic> d) {
    return AgentStatus(
      agentId: d['agent_id'] ?? '',
      agentCode: d['agent_code'] ?? '',
      agentName: d['agent_name'] ?? '',
      phone: d['phone'] ?? '',
      currentStatus: d['current_status'] ?? 'offline',
      lastOnlineAt: d['last_online_at'] != null
          ? DateTime.parse(d['last_online_at'])
          : null,
      currentLatitude: d['current_latitude']?.toDouble(),
      currentLongitude: d['current_longitude']?.toDouble(),
      todayOrders: d['today_orders'] ?? 0,
      todaySales: (d['today_sales'] ?? 0).toDouble(),
      todayVisits: d['today_visits'] ?? 0,
      todayCompletedVisits: d['today_completed_visits'] ?? 0,
      todayDistance: (d['today_distance'] ?? 0).toDouble(),
      workedHours: Duration(minutes: d['worked_minutes'] ?? 0),
      pendingTasks: d['pending_tasks'] ?? 0,
      completedTasks: d['completed_tasks'] ?? 0,
    );
  }

  @override
  Future<Either<Failure, AgentStatus>> getAgentDetail(String agentId) async {
    try {
      final data = await remoteDataSource.getAgentDetail(agentId);
      return Right(_parseAgentStatus(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<AgentRoutePoint>>> getAgentRoute({
    required String agentId,
    required DateTime date,
  }) async {
    try {
      final data = await remoteDataSource.getAgentRoute(agentId, date);
      return Right(data
          .map((d) => AgentRoutePoint(
                agentId: agentId,
                latitude: (d['latitude'] ?? 0).toDouble(),
                longitude: (d['longitude'] ?? 0).toDouble(),
                timestamp: DateTime.parse(
                    d['timestamp'] ?? DateTime.now().toIso8601String()),
                activity: d['activity'],
              ))
          .toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<AgentTask>>> getTasks({
    required String supervisorId,
    String? agentId,
    String? status,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getTasks(
          supervisorId: supervisorId,
          agentId: agentId,
          status: status,
        );
        await localDataSource.cacheTasks(data);
        return Right(data.map((d) => _parseTask(d)).toList());
      } else {
        final cached = await localDataSource.getCachedTasks();
        return Right(cached.map((d) => _parseTask(d)).toList());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  AgentTask _parseTask(Map<String, dynamic> d) {
    return AgentTask(
      id: d['id'] ?? '',
      agentId: d['agent_id'] ?? '',
      supervisorId: d['supervisor_id'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      type: d['type'] ?? 'other',
      priority: d['priority'] ?? 'medium',
      status: d['status'] ?? 'pending',
      customerId: d['customer_id'],
      customerName: d['customer_name'],
      dueDate: DateTime.parse(d['due_date'] ??
          DateTime.now().add(const Duration(days: 1)).toIso8601String()),
      createdAt:
          DateTime.parse(d['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt:
          d['completed_at'] != null ? DateTime.parse(d['completed_at']) : null,
      result: d['result'],
      amount: d['amount']?.toDouble(),
      notes: d['notes'],
    );
  }

  @override
  Future<Either<Failure, AgentTask>> createTask(AgentTask task) async {
    try {
      final data = await remoteDataSource.createTask({
        'agent_id': task.agentId,
        'supervisor_id': task.supervisorId,
        'title': task.title,
        'description': task.description,
        'type': task.type,
        'priority': task.priority,
        'due_date': task.dueDate.toIso8601String(),
        'customer_id': task.customerId,
      });
      return Right(_parseTask(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AgentTask>> updateTask({
    required String taskId,
    required String status,
    String? result,
  }) async {
    try {
      final data = await remoteDataSource.updateTask(taskId, {
        'status': status,
        if (result != null) 'result': result,
      });
      return Right(_parseTask(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AgentSchedule>> getSchedule(String agentId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getSchedule(agentId);
        await localDataSource.cacheSchedule(data, agentId);
        return Right(_parseSchedule(data));
      } else {
        final cached = await localDataSource.getCachedSchedule(agentId);
        if (cached != null) return Right(_parseSchedule(cached));
        return const Left(CacheFailure(message: 'Jadval topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  AgentSchedule _parseSchedule(Map<String, dynamic> d) {
    return AgentSchedule(
      agentId: d['agent_id'] ?? '',
      supervisorId: d['supervisor_id'] ?? '',
      workStartTime: d['work_start_time'] ?? '08:00',
      workEndTime: d['work_end_time'] ?? '18:00',
      workDays: List<String>.from(d['work_days'] ?? []),
      maxWorkHours: d['max_work_hours'] ?? 8,
      breakDurationMinutes: d['break_duration'] ?? 60,
      orderStartTime: d['order_start_time'] ?? '08:00',
      orderEndTime: d['order_end_time'] ?? '17:00',
      canOrderOnWeekends: d['can_order_weekends'] ?? false,
      maxOrdersPerDay: d['max_orders_day'] ?? 20,
      maxOrderAmount: (d['max_order_amount'] ?? 50000000).toDouble(),
      maxDiscountPercent: (d['max_discount_percent'] ?? 10).toDouble(),
      maxVisitsPerDay: d['max_visits_day'] ?? 15,
      minVisitDurationMinutes: d['min_visit_duration'] ?? 15,
      maxTravelDistanceKm: (d['max_travel_distance'] ?? 50).toDouble(),
      maxCashCollection: (d['max_cash_collection'] ?? 100000000).toDouble(),
      requirePaymentProof: d['require_payment_proof'] ?? true,
      requireSignature: d['require_signature'] ?? true,
    );
  }

  @override
  Future<Either<Failure, AgentSchedule>> updateSchedule(
      AgentSchedule schedule) async {
    try {
      final data = await remoteDataSource.updateSchedule({
        'agent_id': schedule.agentId,
        'work_start_time': schedule.workStartTime,
        'work_end_time': schedule.workEndTime,
        'work_days': schedule.workDays,
        'max_work_hours': schedule.maxWorkHours,
        'order_start_time': schedule.orderStartTime,
        'order_end_time': schedule.orderEndTime,
        'max_orders_day': schedule.maxOrdersPerDay,
        'max_order_amount': schedule.maxOrderAmount,
        'max_discount_percent': schedule.maxDiscountPercent,
      });
      await localDataSource.cacheSchedule(data, schedule.agentId);
      return Right(_parseSchedule(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatistics({
    required String supervisorId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final data = await remoteDataSource.getStatistics(
        supervisorId,
        fromDate,
        toDate,
      );
      return Right(data);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }
}
