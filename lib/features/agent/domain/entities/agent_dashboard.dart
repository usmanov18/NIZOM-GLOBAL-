import 'package:equatable/equatable.dart';

/// Agent Dashboard ma'lumotlari - Domain Entity
class AgentDashboard extends Equatable {
  final AgentStats stats;
  final List<AgentOrder> recentOrders;
  final List<AgentVisit> todayVisits;
  final AgentKPI kpi;
  final List<QuickAction> quickActions;

  const AgentDashboard({
    required this.stats,
    required this.recentOrders,
    required this.todayVisits,
    required this.kpi,
    required this.quickActions,
  });

  factory AgentDashboard.fromJson(Map<String, dynamic> json) {
    return AgentDashboard(
      stats:
          AgentStats.fromJson(Map<String, dynamic>.from(json['stats'] ?? {})),
      recentOrders:
          ((json['recent_orders'] ?? json['recentOrders'] ?? []) as List)
              .map((e) => AgentOrder.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
      todayVisits: ((json['today_visits'] ?? json['todayVisits'] ?? []) as List)
          .map((e) => AgentVisit.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      kpi: AgentKPI.fromJson(Map<String, dynamic>.from(json['kpi'] ?? {})),
      quickActions:
          ((json['quick_actions'] ?? json['quickActions'] ?? []) as List)
              .map((e) => QuickAction.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
    );
  }

  @override
  List<Object?> get props =>
      [stats, recentOrders, todayVisits, kpi, quickActions];
}

/// Agent statistikasi
class AgentStats extends Equatable {
  final int todayOrders;
  final double todaySales;
  final int todayVisits;
  final int pendingOrders;
  final double totalDebt;
  final int newClients;
  final double avgOrderAmount;

  const AgentStats({
    required this.todayOrders,
    required this.todaySales,
    required this.todayVisits,
    required this.pendingOrders,
    required this.totalDebt,
    required this.newClients,
    required this.avgOrderAmount,
  });

  factory AgentStats.fromJson(Map<String, dynamic> json) {
    return AgentStats(
      todayOrders: json['today_orders'] ?? json['todayOrders'] ?? 0,
      todaySales: (json['today_sales'] ?? json['todaySales'] ?? 0).toDouble(),
      todayVisits: json['today_visits'] ?? json['todayVisits'] ?? 0,
      pendingOrders: json['pending_orders'] ?? json['pendingOrders'] ?? 0,
      totalDebt: (json['total_debt'] ?? json['totalDebt'] ?? 0).toDouble(),
      newClients: json['new_clients'] ?? json['newClients'] ?? 0,
      avgOrderAmount:
          (json['avg_order_amount'] ?? json['avgOrderAmount'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        todayOrders,
        todaySales,
        todayVisits,
        pendingOrders,
        totalDebt,
        newClients,
        avgOrderAmount,
      ];
}

/// Agent KPI ko'rsatkichlari
class AgentKPI extends Equatable {
  final double monthlyPlan;
  final double monthlyFact;
  final double planPercentage;
  final int visitPlan;
  final int visitFact;
  final double collectionPlan;
  final double collectionFact;

  const AgentKPI({
    required this.monthlyPlan,
    required this.monthlyFact,
    required this.planPercentage,
    required this.visitPlan,
    required this.visitFact,
    required this.collectionPlan,
    required this.collectionFact,
  });

  bool get isPlanOnTrack => planPercentage >= 0.8;

  factory AgentKPI.fromJson(Map<String, dynamic> json) {
    final plan =
        (json['monthly_plan'] ?? json['monthlyPlan'] ?? 100000000).toDouble();
    final fact = (json['monthly_fact'] ?? json['monthlyFact'] ?? 0).toDouble();
    return AgentKPI(
      monthlyPlan: plan,
      monthlyFact: fact,
      planPercentage: (json['plan_percentage'] ??
              json['planPercentage'] ??
              (plan == 0 ? 0 : fact / plan))
          .toDouble(),
      visitPlan: json['visit_plan'] ?? json['visitPlan'] ?? 0,
      visitFact: json['visit_fact'] ?? json['visitFact'] ?? 0,
      collectionPlan:
          (json['collection_plan'] ?? json['collectionPlan'] ?? 0).toDouble(),
      collectionFact:
          (json['collection_fact'] ?? json['collectionFact'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        monthlyPlan,
        monthlyFact,
        planPercentage,
        visitPlan,
        visitFact,
        collectionPlan,
        collectionFact,
      ];
}

/// Agent buyurtmasi (qisqacha)
class AgentOrder extends Equatable {
  final String id;
  final String orderNumber;
  final String customerName;
  final double amount;
  final String status;
  final DateTime createdAt;

  const AgentOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory AgentOrder.fromJson(Map<String, dynamic> json) {
    return AgentOrder(
      id: json['id']?.toString() ?? '',
      orderNumber:
          json['order_number'] ?? json['orderNumber'] ?? json['number'] ?? '',
      customerName: json['customer_name'] ?? json['customerName'] ?? '',
      amount:
          (json['amount'] ?? json['total_amount'] ?? json['totalAmount'] ?? 0)
              .toDouble(),
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ??
              DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, orderNumber, status];
}

/// Agent tashrifi
class AgentVisit extends Equatable {
  final String id;
  final String customerName;
  final String address;
  final DateTime scheduledTime;
  final String status; // planned, in_progress, completed, missed
  final double? latitude;
  final double? longitude;
  final String? notes;
  final double? orderAmount;

  const AgentVisit({
    required this.id,
    required this.customerName,
    required this.address,
    required this.scheduledTime,
    required this.status,
    this.latitude,
    this.longitude,
    this.notes,
    this.orderAmount,
  });

  bool get isCompleted => status == 'completed';
  bool get isMissed => status == 'missed';

  factory AgentVisit.fromJson(Map<String, dynamic> json) {
    return AgentVisit(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name'] ?? json['customerName'] ?? '',
      address: json['address'] ?? '',
      scheduledTime: DateTime.tryParse(
              json['scheduled_time'] ?? json['scheduledTime'] ?? '') ??
          DateTime.now(),
      status: json['status'] ?? 'planned',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      notes: json['notes'],
      orderAmount:
          json['order_amount']?.toDouble() ?? json['orderAmount']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, customerName, status];
}

/// Tezkor harakatlar
class QuickAction extends Equatable {
  final String id;
  final String title;
  final String icon;
  final String route;
  final String? badge;

  const QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.badge,
  });

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? '',
      route: json['route'] ?? '',
      badge: json['badge']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, title, route];
}
