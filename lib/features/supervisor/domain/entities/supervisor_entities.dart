import 'package:equatable/equatable.dart';

// ============================================================
// SUPERVISOR/MENEJER ENTITIES
// Agentlarni boshqarish, buyurtmalar monitoringi
// ============================================================

// ============ AGENT HOLATI ============

/// Agent real vaqt holati
class AgentStatus extends Equatable {
  factory AgentStatus.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String agentId;
  final String agentCode;
  final String agentName;
  final String phone;
  final String? avatar;

  // Real vaqt holati
  final String currentStatus; // online, offline, on_route, visiting, break
  final DateTime? lastOnlineAt;
  final DateTime? lastLocationAt;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? currentAddress;

  // Bugungi statistika
  final int todayOrders;
  final double todaySales;
  final int todayVisits;
  final int todayCompletedVisits;
  final double todayDistance; // km

  // Ish vaqti
  final DateTime? shiftStartTime;
  final DateTime? shiftEndTime;
  final Duration workedHours;
  final Duration? breakDuration;

  // Vazifalar
  final int pendingTasks;
  final int completedTasks;

  const AgentStatus({
    required this.agentId,
    required this.agentCode,
    required this.agentName,
    required this.phone,
    this.avatar,
    required this.currentStatus,
    this.lastOnlineAt,
    this.lastLocationAt,
    this.currentLatitude,
    this.currentLongitude,
    this.currentAddress,
    required this.todayOrders,
    required this.todaySales,
    required this.todayVisits,
    required this.todayCompletedVisits,
    required this.todayDistance,
    this.shiftStartTime,
    this.shiftEndTime,
    required this.workedHours,
    this.breakDuration,
    required this.pendingTasks,
    required this.completedTasks,
  });

  bool get isOnline =>
      currentStatus == 'online' ||
      currentStatus == 'on_route' ||
      currentStatus == 'visiting';

  bool get isOnRoute => currentStatus == 'on_route';
  bool get isVisiting => currentStatus == 'visiting';
  bool get isOnBreak => currentStatus == 'break';
  bool get hasLocation => currentLatitude != null && currentLongitude != null;

  double get visitCompletionRate =>
      todayVisits > 0 ? todayCompletedVisits / todayVisits : 0;

  @override
  List<Object?> get props => [agentId, currentStatus];
}

// ============ AGENT VAZIFASI ============

/// Agentga berilgan vazifa
class AgentTask extends Equatable {
  factory AgentTask.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String agentId;
  final String supervisorId;
  final String title;
  final String description;
  final String type; // visit, order, collection, training, other
  final String priority; // high, medium, low
  final String status; // pending, in_progress, completed, overdue, cancelled

  // Mijoz
  final String? customerId;
  final String? customerName;
  final String? customerAddress;

  // Vaqt
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? startedAt;

  // Natija
  final String? result;
  final double? amount;
  final String? notes;
  final List<String>? attachments;

  const AgentTask({
    required this.id,
    required this.agentId,
    required this.supervisorId,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    this.customerId,
    this.customerName,
    this.customerAddress,
    required this.dueDate,
    required this.createdAt,
    this.completedAt,
    this.startedAt,
    this.result,
    this.amount,
    this.notes,
    this.attachments,
  });

  bool get isOverdue =>
      status != 'completed' &&
      status != 'cancelled' &&
      dueDate.isBefore(DateTime.now());

  bool get isHighPriority => priority == 'high';

  @override
  List<Object?> get props => [id, agentId, status];
}

// ============ AGENT ISH JADVALI ============

/// Agent ish jadvali va cheklovlar
class AgentSchedule extends Equatable {
  factory AgentSchedule.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String agentId;
  final String supervisorId;

  // Ish vaqti
  final String workStartTime; // 08:00
  final String workEndTime; // 18:00
  final List<String> workDays; // monday, tuesday, ...
  final int maxWorkHours; // 8
  final int breakDurationMinutes; // 60

  // Buyurtma cheklovlari
  final String orderStartTime; // 08:00
  final String orderEndTime; // 17:00
  final bool canOrderOnWeekends;
  final int maxOrdersPerDay;
  final double maxOrderAmount;
  final double maxDiscountPercent;

  // Tashrif cheklovlari
  final int maxVisitsPerDay;
  final int minVisitDurationMinutes; // 15
  final double maxTravelDistanceKm; // 50

  // To'lov cheklovlari
  final double maxCashCollection;
  final bool requirePaymentProof;
  final bool requireSignature;

  const AgentSchedule({
    required this.agentId,
    required this.supervisorId,
    required this.workStartTime,
    required this.workEndTime,
    required this.workDays,
    required this.maxWorkHours,
    required this.breakDurationMinutes,
    required this.orderStartTime,
    required this.orderEndTime,
    required this.canOrderOnWeekends,
    required this.maxOrdersPerDay,
    required this.maxOrderAmount,
    required this.maxDiscountPercent,
    required this.maxVisitsPerDay,
    required this.minVisitDurationMinutes,
    required this.maxTravelDistanceKm,
    required this.maxCashCollection,
    required this.requirePaymentProof,
    this.requireSignature = false,
  });

  /// Buyurtma yozish mumkinmi?
  bool canCreateOrder(DateTime dateTime) {
    final now = dateTime;
    final dayName = _getDayName(now.weekday);

    // Ish kunlari tekshirish
    if (!workDays.contains(dayName)) {
      if (!canOrderOnWeekends) return false;
    }

    // Vaqt tekshirish
    final orderStart = _parseTime(orderStartTime);
    final orderEnd = _parseTime(orderEndTime);
    final currentTime = now.hour * 60 + now.minute;

    return currentTime >= orderStart && currentTime <= orderEnd;
  }

  /// Ish vaqtida ekanligini tekshirish
  bool isWorkingHours(DateTime dateTime) {
    final dayName = _getDayName(dateTime.weekday);
    if (!workDays.contains(dayName)) return false;

    final start = _parseTime(workStartTime);
    final end = _parseTime(workEndTime);
    final current = dateTime.hour * 60 + dateTime.minute;

    return current >= start && current <= end;
  }

  String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return days[weekday - 1];
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  List<Object?> get props => [agentId, supervisorId];
}

// ============ SUPERVISOR DASHBOARD ============

/// Supervisor dashboard ma'lumotlari
class SupervisorDashboard extends Equatable {
  factory SupervisorDashboard.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String supervisorId;
  final String supervisorName;
  final DateTime date;

  // Agentlar statistikasi
  final int totalAgents;
  final int onlineAgents;
  final int agentsOnRoute;
  final int agentsVisiting;
  final int agentsOnBreak;
  final int offlineAgents;

  // Buyurtmalar
  final int todayOrders;
  final double todaySales;
  final int pendingOrders;
  final int confirmedOrders;
  final int cancelledOrders;

  // Tashriflar
  final int todayVisits;
  final int completedVisits;
  final int missedVisits;

  // To'lovlar
  final double todayCollections;
  final double outstandingDebt;

  // Top agentlar
  final List<AgentStatus> topAgents;
  final List<AgentStatus> bottomAgents;

  // Vazifalar
  final int pendingTasks;
  final int overdueTasks;

  const SupervisorDashboard({
    required this.supervisorId,
    required this.supervisorName,
    required this.date,
    required this.totalAgents,
    required this.onlineAgents,
    required this.agentsOnRoute,
    required this.agentsVisiting,
    required this.agentsOnBreak,
    required this.offlineAgents,
    required this.todayOrders,
    required this.todaySales,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.cancelledOrders,
    required this.todayVisits,
    required this.completedVisits,
    required this.missedVisits,
    required this.todayCollections,
    required this.outstandingDebt,
    required this.topAgents,
    required this.bottomAgents,
    required this.pendingTasks,
    required this.overdueTasks,
  });

  double get agentOnlineRate =>
      totalAgents > 0 ? onlineAgents / totalAgents : 0;

  double get visitCompletionRate =>
      todayVisits > 0 ? completedVisits / todayVisits : 0;

  @override
  List<Object?> get props => [supervisorId, date];
}

// ============ AGENT XARITA MA'LUMOTI ============

/// Agent marshrut ma'lumoti (xarita uchun)
class AgentRoutePoint extends Equatable {
  factory AgentRoutePoint.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String agentId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? activity; // walking, driving, visiting

  const AgentRoutePoint({
    required this.agentId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.activity,
  });

  @override
  List<Object?> get props => [agentId, timestamp];
}

/// Agent kunlik marshruti
class AgentDailyRoute extends Equatable {
  factory AgentDailyRoute.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String agentId;
  final String agentName;
  final DateTime date;
  final List<AgentRoutePoint> points;
  final double totalDistance;
  final Duration totalTime;
  final int visitsCount;

  const AgentDailyRoute({
    required this.agentId,
    required this.agentName,
    required this.date,
    required this.points,
    required this.totalDistance,
    required this.totalTime,
    required this.visitsCount,
  });

  @override
  List<Object?> get props => [agentId, date];
}
