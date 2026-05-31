import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/config/env_config.dart';
import '../../domain/entities/supervisor_entities.dart';

// ============================================================
// SUPERVISOR BLOC
// Agentlarni boshqarish, monitoring, vazifalar
// ============================================================

// ============ EVENTS ============

abstract class SupervisorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Dashboard yuklash
class SupervisorDashboardLoadRequested extends SupervisorEvent {
  final String supervisorId;

  SupervisorDashboardLoadRequested({required this.supervisorId});
}

/// Agentlar holatini yuklash
class AgentStatusesLoadRequested extends SupervisorEvent {
  final String supervisorId;

  AgentStatusesLoadRequested({required this.supervisorId});
}

/// Agent tafsilotlari
class AgentDetailLoadRequested extends SupervisorEvent {
  final String agentId;

  AgentDetailLoadRequested({required this.agentId});
}

/// Agent marshrutini yuklash
class AgentRouteLoadRequested extends SupervisorEvent {
  final String agentId;
  final DateTime date;

  AgentRouteLoadRequested({required this.agentId, required this.date});
}

/// Vazifa yaratish
class TaskCreateRequested extends SupervisorEvent {
  final AgentTask task;

  TaskCreateRequested({required this.task});
}

/// Vazifa holatini yangilash
class TaskStatusUpdateRequested extends SupervisorEvent {
  final String taskId;
  final String status;

  TaskStatusUpdateRequested({required this.taskId, required this.status});
}

/// Agentlar vazifalarini yuklash
class TasksLoadRequested extends SupervisorEvent {
  final String supervisorId;
  final String? agentId;
  final String? status;

  TasksLoadRequested({
    required this.supervisorId,
    this.agentId,
    this.status,
  });
}

/// Ish jadvalini yangilash
class ScheduleUpdateRequested extends SupervisorEvent {
  final AgentSchedule schedule;

  ScheduleUpdateRequested({required this.schedule});
}

/// Ish jadvalini yuklash
class ScheduleLoadRequested extends SupervisorEvent {
  final String agentId;

  ScheduleLoadRequested({required this.agentId});
}

// ============ STATES ============

abstract class SupervisorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SupervisorInitial extends SupervisorState {}

class SupervisorLoading extends SupervisorState {}

class SupervisorDashboardLoaded extends SupervisorState {
  final SupervisorDashboard dashboard;

  SupervisorDashboardLoaded({required this.dashboard});
}

class AgentStatusesLoaded extends SupervisorState {
  final List<AgentStatus> agents;
  final int onlineCount;
  final int offlineCount;

  AgentStatusesLoaded({
    required this.agents,
    required this.onlineCount,
    required this.offlineCount,
  });
}

class AgentDetailLoaded extends SupervisorState {
  final AgentStatus agent;
  final List<AgentTask> tasks;
  final AgentSchedule? schedule;

  AgentDetailLoaded({
    required this.agent,
    required this.tasks,
    this.schedule,
  });
}

class AgentRouteLoaded extends SupervisorState {
  final AgentDailyRoute route;

  AgentRouteLoaded({required this.route});
}

class TasksLoaded extends SupervisorState {
  final List<AgentTask> tasks;
  final int pendingCount;
  final int overdueCount;

  TasksLoaded({
    required this.tasks,
    required this.pendingCount,
    required this.overdueCount,
  });
}

class TaskCreated extends SupervisorState {
  final AgentTask task;

  TaskCreated({required this.task});
}

class TaskUpdated extends SupervisorState {
  final AgentTask task;

  TaskUpdated({required this.task});
}

class ScheduleLoaded extends SupervisorState {
  final AgentSchedule schedule;

  ScheduleLoaded({required this.schedule});
}

class ScheduleUpdated extends SupervisorState {
  final AgentSchedule schedule;

  ScheduleUpdated({required this.schedule});
}

class SupervisorError extends SupervisorState {
  final String message;

  SupervisorError({required this.message});
}

// ============ BLOC ============

class SupervisorBloc extends Bloc<SupervisorEvent, SupervisorState> {
  SupervisorBloc() : super(SupervisorInitial()) {
    on<SupervisorDashboardLoadRequested>(_onDashboardLoad);
    on<AgentStatusesLoadRequested>(_onAgentStatusesLoad);
    on<AgentDetailLoadRequested>(_onAgentDetailLoad);
    on<AgentRouteLoadRequested>(_onAgentRouteLoad);
    on<TaskCreateRequested>(_onTaskCreate);
    on<TaskStatusUpdateRequested>(_onTaskStatusUpdate);
    on<TasksLoadRequested>(_onTasksLoad);
    on<ScheduleUpdateRequested>(_onScheduleUpdate);
    on<ScheduleLoadRequested>(_onScheduleLoad);
  }

  Future<void> _onDashboardLoad(
    SupervisorDashboardLoadRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());
    if (!EnvConfig.isDemoMode) {
      emit(SupervisorError(
          message: 'Supervisor dashboard real servisga ulanmagan'));
      return;
    }
    await Future.delayed(const Duration(seconds: 1));

    emit(SupervisorDashboardLoaded(
      dashboard: SupervisorDashboard(
        supervisorId: event.supervisorId,
        supervisorName: 'Menejerov Menejer',
        date: DateTime.now(),
        totalAgents: 15,
        onlineAgents: 12,
        agentsOnRoute: 5,
        agentsVisiting: 4,
        agentsOnBreak: 3,
        offlineAgents: 3,
        todayOrders: 45,
        todaySales: 156000000,
        pendingOrders: 8,
        confirmedOrders: 32,
        cancelledOrders: 5,
        todayVisits: 60,
        completedVisits: 42,
        missedVisits: 3,
        todayCollections: 89000000,
        outstandingDebt: 234000000,
        topAgents: [],
        bottomAgents: [],
        pendingTasks: 12,
        overdueTasks: 3,
      ),
    ));
  }

  Future<void> _onAgentStatusesLoad(
    AgentStatusesLoadRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());
    if (!EnvConfig.isDemoMode) {
      emit(
          SupervisorError(message: 'Agent statuslari real servisga ulanmagan'));
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    final agents = List.generate(
        15,
        (i) => AgentStatus(
              agentId: 'agent_$i',
              agentCode: 'AG${(i + 1).toString().padLeft(3, '0')}',
              agentName: 'Agent ${i + 1}',
              phone: '+998 90 ${100 + i} ${10 + i} ${20 + i}',
              currentStatus: i < 12
                  ? (i < 5
                      ? 'on_route'
                      : i < 9
                          ? 'visiting'
                          : 'break')
                  : 'offline',
              lastOnlineAt: DateTime.now().subtract(Duration(minutes: i * 5)),
              currentLatitude: 41.2995 + (i * 0.01),
              currentLongitude: 69.2401 + (i * 0.01),
              todayOrders: (i + 1) * 2,
              todaySales: (i + 1) * 5000000.0,
              todayVisits: (i + 1) * 3,
              todayCompletedVisits: (i + 1) * 2,
              todayDistance: (i + 1) * 3.5,
              shiftStartTime: DateTime.now().subtract(const Duration(hours: 6)),
              workedHours: Duration(hours: 6 - i % 3),
              pendingTasks: i % 3,
              completedTasks: i * 2,
            ));

    emit(AgentStatusesLoaded(
      agents: agents,
      onlineCount: 12,
      offlineCount: 3,
    ));
  }

  Future<void> _onAgentDetailLoad(
    AgentDetailLoadRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final agent = AgentStatus(
      agentId: event.agentId,
      agentCode: 'AG001',
      agentName: 'Karimov Alisher',
      phone: '+998 90 123 45 67',
      currentStatus: 'visiting',
      lastOnlineAt: DateTime.now(),
      currentLatitude: 41.2995,
      currentLongitude: 69.2401,
      todayOrders: 8,
      todaySales: 34000000,
      todayVisits: 12,
      todayCompletedVisits: 8,
      todayDistance: 25.5,
      shiftStartTime: DateTime.now().subtract(const Duration(hours: 7)),
      workedHours: const Duration(hours: 6, minutes: 30),
      pendingTasks: 2,
      completedTasks: 6,
    );

    final tasks = [
      AgentTask(
        id: 'task_1',
        agentId: event.agentId,
        supervisorId: 'sup_1',
        title: 'Barka supermarketiga tashrif',
        description: 'Yangi mahsulotlar taqdimoti',
        type: 'visit',
        priority: 'high',
        status: 'pending',
        customerId: 'cust_1',
        customerName: 'Super Market Barka',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    emit(AgentDetailLoaded(agent: agent, tasks: tasks));
  }

  Future<void> _onAgentRouteLoad(
    AgentRouteLoadRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());
    if (!EnvConfig.isDemoMode) {
      emit(SupervisorError(message: 'Agent marshruti real servisga ulanmagan'));
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));

    emit(AgentRouteLoaded(
      route: AgentDailyRoute(
        agentId: event.agentId,
        agentName: 'Agent 1',
        date: event.date,
        points: [
          AgentRoutePoint(
            agentId: event.agentId,
            latitude: 41.2995,
            longitude: 69.2401,
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
            activity: 'walking',
          ),
          AgentRoutePoint(
            agentId: event.agentId,
            latitude: 41.3050,
            longitude: 69.2500,
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            activity: 'visiting',
          ),
        ],
        totalDistance: 25.5,
        totalTime: const Duration(hours: 6),
        visitsCount: 8,
      ),
    ));
  }

  Future<void> _onTaskCreate(
    TaskCreateRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    emit(TaskCreated(task: event.task));
  }

  Future<void> _onTaskStatusUpdate(
    TaskStatusUpdateRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());
    await Future.delayed(const Duration(milliseconds: 300));

    emit(SupervisorInitial());
  }

  Future<void> _onTasksLoad(
    TasksLoadRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final tasks = List.generate(
        10,
        (i) => AgentTask(
              id: 'task_$i',
              agentId: event.agentId ?? 'agent_${i % 5}',
              supervisorId: event.supervisorId,
              title: 'Vazifa ${i + 1}',
              description: 'Vazifa tavsifi',
              type: i % 3 == 0
                  ? 'visit'
                  : i % 3 == 1
                      ? 'order'
                      : 'collection',
              priority: i % 3 == 0
                  ? 'high'
                  : i % 3 == 1
                      ? 'medium'
                      : 'low',
              status: i < 3
                  ? 'pending'
                  : i < 6
                      ? 'completed'
                      : 'overdue',
              dueDate: DateTime.now().add(Duration(days: i - 3)),
              createdAt: DateTime.now().subtract(Duration(days: i)),
            ));

    emit(TasksLoaded(
      tasks: tasks,
      pendingCount: 3,
      overdueCount: 4,
    ));
  }

  Future<void> _onScheduleUpdate(
    ScheduleUpdateRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    emit(ScheduleUpdated(schedule: event.schedule));
  }

  Future<void> _onScheduleLoad(
    ScheduleLoadRequested event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    emit(ScheduleLoaded(
      schedule: AgentSchedule(
        agentId: event.agentId,
        supervisorId: 'sup_1',
        workStartTime: '08:00',
        workEndTime: '18:00',
        workDays: [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday'
        ],
        maxWorkHours: 8,
        breakDurationMinutes: 60,
        orderStartTime: '08:00',
        orderEndTime: '17:00',
        canOrderOnWeekends: false,
        maxOrdersPerDay: 20,
        maxOrderAmount: 100000000,
        maxDiscountPercent: 15,
        maxVisitsPerDay: 15,
        minVisitDurationMinutes: 15,
        maxTravelDistanceKm: 50,
        maxCashCollection: 50000000,
        requirePaymentProof: true,
      ),
    ));
  }
}
