import 'package:equatable/equatable.dart';

// ============================================================
// ADMIN EXTENDED ENTITIES
// Tizim monitoringi, audit log, rollar, hisobotlar
// ============================================================

// ============ SYSTEM HEALTH ============

/// Tizim holati
class SystemHealth extends Equatable {
  factory SystemHealth.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String status; // healthy, degraded, down
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final int activeUsers;
  final int totalRequests;
  final double avgResponseTime; // ms
  final double errorRate; // %
  final DateTime lastChecked;

  // Service holatlari
  final ServiceStatus apiStatus;
  final ServiceStatus databaseStatus;
  final ServiceStatus oneCStatus;
  final ServiceStatus sapStatus;
  final ServiceStatus firebaseStatus;

  const SystemHealth({
    required this.status,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.activeUsers,
    required this.totalRequests,
    required this.avgResponseTime,
    required this.errorRate,
    required this.lastChecked,
    required this.apiStatus,
    required this.databaseStatus,
    required this.oneCStatus,
    required this.sapStatus,
    required this.firebaseStatus,
  });

  bool get isHealthy => status == 'healthy';
  bool get isDegraded => status == 'degraded';
  bool get isDown => status == 'down';

  @override
  List<Object?> get props => [status, lastChecked];
}

/// Service holati
class ServiceStatus extends Equatable {
  factory ServiceStatus.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String name;
  final String status; // online, offline, degraded
  final double responseTime; // ms
  final DateTime? lastChecked;
  final String? errorMessage;

  const ServiceStatus({
    required this.name,
    required this.status,
    required this.responseTime,
    this.lastChecked,
    this.errorMessage,
  });

  bool get isOnline => status == 'online';

  @override
  List<Object?> get props => [name, status];
}

// ============ SYSTEM ALERT ============

/// Tizim ogohlantirishi
class SystemAlert extends Equatable {
  factory SystemAlert.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String type; // error, warning, info
  final String category; // system, sync, agent, order
  final String title;
  final String message;
  final String severity; // critical, high, medium, low
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final bool isAcknowledged;
  final Map<String, dynamic>? metadata;

  const SystemAlert({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.message,
    required this.severity,
    required this.createdAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
    required this.isAcknowledged,
    this.metadata,
  });

  bool get isCritical => severity == 'critical';
  bool get isHigh => severity == 'high';

  @override
  List<Object?> get props => [id, type, severity];
}

// ============ AUDIT LOG ============

/// Audit jurnali yozuvi
class AuditLogEntry extends Equatable {
  factory AuditLogEntry.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String action; // create, update, delete, login, logout, sync
  final String entity; // agent, order, customer, settings, restriction
  final String entityId;
  final String description;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final String? ipAddress;
  final String? deviceId;
  final DateTime timestamp;

  const AuditLogEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.description,
    this.oldValue,
    this.newValue,
    this.ipAddress,
    this.deviceId,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, action, entity, timestamp];
}

// ============ ADMIN ROLE ============

/// Admin roli
class AdminRole extends Equatable {
  factory AdminRole.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String name;
  final String description;
  final List<String> permissions;
  final bool isSystem; // Tizim roli (o'chirib bo'lmaydi)
  final int userCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AdminRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.isSystem,
    required this.userCount,
    required this.createdAt,
    this.updatedAt,
  });

  bool hasPermission(String permission) => permissions.contains(permission);

  @override
  List<Object?> get props => [id, name];
}

// ============ ADMIN AGENT ============

/// Admin ko'radigan agent ma'lumotlari
class AdminAgent extends Equatable {
  factory AdminAgent.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String code;
  final String name;
  final String phone;
  final String email;
  final String? avatar;
  final String regionId;
  final String regionName;
  final String supervisorId;
  final String supervisorName;
  final String warehouseId;
  final String warehouseName;
  final String status; // active, inactive, blocked
  final String? blockReason;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? lastSyncAt;

  // Statistika
  final int totalOrders;
  final double totalSales;
  final int totalCustomers;
  final int totalVisits;
  final double rating;

  const AdminAgent({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
    required this.email,
    this.avatar,
    required this.regionId,
    required this.regionName,
    required this.supervisorId,
    required this.supervisorName,
    required this.warehouseId,
    required this.warehouseName,
    required this.status,
    this.blockReason,
    required this.createdAt,
    this.lastLoginAt,
    this.lastSyncAt,
    required this.totalOrders,
    required this.totalSales,
    required this.totalCustomers,
    required this.totalVisits,
    required this.rating,
  });

  bool get isActive => status == 'active';
  bool get isBlocked => status == 'blocked';

  @override
  List<Object?> get props => [id, code, status];
}

// ============ ADMIN SUPERVISOR ============

/// Admin supervisor
class AdminSupervisor extends Equatable {
  factory AdminSupervisor.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String code;
  final String name;
  final String phone;
  final String email;
  final List<String> regionIds;
  final List<String> regionNames;
  final List<String> agentIds;
  final int agentCount;
  final bool isActive;
  final DateTime createdAt;

  const AdminSupervisor({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
    required this.email,
    required this.regionIds,
    required this.regionNames,
    required this.agentIds,
    required this.agentCount,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, code];
}

// ============ PERFORMANCE METRICS ============

/// Samaradorlik ko'rsatkichlari
class PerformanceMetrics extends Equatable {
  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String period; // daily, weekly, monthly
  final DateTime fromDate;
  final DateTime toDate;

  // Savdo
  final double totalSales;
  final double salesTarget;
  final double salesGrowth; // %
  final int totalOrders;
  final double avgOrderValue;

  // Agentlar
  final int activeAgents;
  final double agentProductivity; // orders per agent
  final double topAgentSales;
  final double bottomAgentSales;

  // Mijozlar
  final int newCustomers;
  final int activeCustomers;
  final double customerRetention; // %

  // To'lovlar
  final double totalCollections;
  final double collectionRate; // %
  final double outstandingDebt;

  // Tashriflar
  final int totalVisits;
  final double visitCompletionRate; // %

  const PerformanceMetrics({
    required this.period,
    required this.fromDate,
    required this.toDate,
    required this.totalSales,
    required this.salesTarget,
    required this.salesGrowth,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.activeAgents,
    required this.agentProductivity,
    required this.topAgentSales,
    required this.bottomAgentSales,
    required this.newCustomers,
    required this.activeCustomers,
    required this.customerRetention,
    required this.totalCollections,
    required this.collectionRate,
    required this.outstandingDebt,
    required this.totalVisits,
    required this.visitCompletionRate,
  });

  double get salesProgress => salesTarget > 0 ? totalSales / salesTarget : 0;

  @override
  List<Object?> get props => [period, fromDate, toDate];
}

// ============ SALES REPORT ============

/// Savdo hisoboti
class AdminSalesReport extends Equatable {
  factory AdminSalesReport.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final DateTime fromDate;
  final DateTime toDate;
  final double totalSales;
  final int totalOrders;
  final double avgOrderValue;
  final List<DailySales> dailySales;
  final List<CategorySales> categorySales;
  final List<RegionSales> regionSales;

  const AdminSalesReport({
    required this.fromDate,
    required this.toDate,
    required this.totalSales,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.dailySales,
    required this.categorySales,
    required this.regionSales,
  });

  @override
  List<Object?> get props => [fromDate, toDate, totalSales];
}

class DailySales extends Equatable {
  factory DailySales.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final DateTime date;
  final double amount;
  final int orders;

  const DailySales(
      {required this.date, required this.amount, required this.orders});

  @override
  List<Object?> get props => [date];
}

class CategorySales extends Equatable {
  factory CategorySales.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String categoryId;
  final String categoryName;
  final double amount;
  final int quantity;
  final double percentage;

  const CategorySales({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.quantity,
    required this.percentage,
  });

  @override
  List<Object?> get props => [categoryId];
}

class RegionSales extends Equatable {
  factory RegionSales.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String regionId;
  final String regionName;
  final double amount;
  final int orders;
  final int agents;

  const RegionSales({
    required this.regionId,
    required this.regionName,
    required this.amount,
    required this.orders,
    required this.agents,
  });

  @override
  List<Object?> get props => [regionId];
}

// ============ AGENT PERFORMANCE ============

/// Agent samaradorligi
class AdminAgentPerformance extends Equatable {
  factory AdminAgentPerformance.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String agentId;
  final String agentName;
  final DateTime fromDate;
  final DateTime toDate;

  final double totalSales;
  final double salesTarget;
  final double salesProgress;
  final int totalOrders;
  final double avgOrderValue;
  final int totalVisits;
  final double visitCompletionRate;
  final double totalCollections;
  final double collectionRate;
  final int newCustomers;
  final double rating;
  final List<DailyPerformance> dailyPerformance;

  const AdminAgentPerformance({
    required this.agentId,
    required this.agentName,
    required this.fromDate,
    required this.toDate,
    required this.totalSales,
    required this.salesTarget,
    required this.salesProgress,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.totalVisits,
    required this.visitCompletionRate,
    required this.totalCollections,
    required this.collectionRate,
    required this.newCustomers,
    required this.rating,
    required this.dailyPerformance,
  });

  @override
  List<Object?> get props => [agentId, fromDate, toDate];
}

class DailyPerformance extends Equatable {
  factory DailyPerformance.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final DateTime date;
  final double sales;
  final int orders;
  final int visits;
  final double collections;

  const DailyPerformance({
    required this.date,
    required this.sales,
    required this.orders,
    required this.visits,
    required this.collections,
  });

  @override
  List<Object?> get props => [date];
}

// ============ TOP PRODUCTS/CUSTOMERS ============

class AdminTopProduct extends Equatable {
  factory AdminTopProduct.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String productId;
  final String productName;
  final String category;
  final int quantity;
  final double amount;
  final int rank;

  const AdminTopProduct({
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.amount,
    required this.rank,
  });

  @override
  List<Object?> get props => [productId, rank];
}

class AdminTopCustomer extends Equatable {
  factory AdminTopCustomer.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String customerId;
  final String customerName;
  final String agentName;
  final int orders;
  final double amount;
  final double debt;
  final int rank;

  const AdminTopCustomer({
    required this.customerId,
    required this.customerName,
    required this.agentName,
    required this.orders,
    required this.amount,
    required this.debt,
    required this.rank,
  });

  @override
  List<Object?> get props => [customerId, rank];
}

// ============ SYNC STATUS ============

class SyncStatus extends Equatable {
  factory SyncStatus.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final bool is1CConnected;
  final bool isSAPConnected;
  final DateTime? last1CSync;
  final DateTime? lastSAPSync;
  final int pendingItems;
  final int failedItems;
  final List<SyncLogEntry> recentLogs;

  const SyncStatus({
    required this.is1CConnected,
    required this.isSAPConnected,
    this.last1CSync,
    this.lastSAPSync,
    required this.pendingItems,
    required this.failedItems,
    required this.recentLogs,
  });

  @override
  List<Object?> get props => [is1CConnected, isSAPConnected, pendingItems];
}

class SyncLogEntry extends Equatable {
  factory SyncLogEntry.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String system; // 1c, sap
  final String action; // sync_customers, sync_orders, sync_products
  final String status; // success, failed, partial
  final int itemsProcessed;
  final int itemsFailed;
  final String? errorMessage;
  final DateTime timestamp;
  final Duration duration;

  const SyncLogEntry({
    required this.id,
    required this.system,
    required this.action,
    required this.status,
    required this.itemsProcessed,
    required this.itemsFailed,
    this.errorMessage,
    required this.timestamp,
    required this.duration,
  });

  bool get isSuccess => status == 'success';
  bool get hasErrors => itemsFailed > 0;

  @override
  List<Object?> get props => [id, system, action, status];
}

// ============ BULK OPERATION ============

class BulkOperationResult extends Equatable {
  factory BulkOperationResult.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final int total;
  final int success;
  final int failed;
  final List<String> errors;
  final Duration duration;

  const BulkOperationResult({
    required this.total,
    required this.success,
    required this.failed,
    required this.errors,
    required this.duration,
  });

  bool get allSuccess => failed == 0;

  @override
  List<Object?> get props => [total, success, failed];
}
