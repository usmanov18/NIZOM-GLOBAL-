import 'package:equatable/equatable.dart';

enum OrderRiskLevel { low, medium, high }

class WarehouseMismatchRecord extends Equatable {
  final String orderId;
  final String orderNumber;
  final String customerName;
  final String selectedWarehouseName;
  final List<String> customerServiceWarehouses;
  final List<String> agentAllowedWarehouses;
  final String source;
  final String warning;
  final OrderRiskLevel riskLevel;
  final DateTime createdAt;

  const WarehouseMismatchRecord({
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.selectedWarehouseName,
    required this.customerServiceWarehouses,
    required this.agentAllowedWarehouses,
    required this.source,
    required this.warning,
    this.riskLevel = OrderRiskLevel.medium,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [orderId, orderNumber, selectedWarehouseName, source, riskLevel];
}

class FailedSyncRecord extends Equatable {
  final String id;
  final String entityType;
  final String entityId;
  final int retryCount;
  final String category;
  final String error;
  final DateTime updatedAt;

  const FailedSyncRecord({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.retryCount,
    required this.category,
    required this.error,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, entityType, entityId, retryCount, category];
}

enum PortfolioRiskLevel { ok, warning, critical }

class PortfolioCoverageRecord extends Equatable {
  final String userId;
  final String name;
  final String role;
  final int assignedPortfolioCount;
  final int assignedSkuCount;
  final bool canSellOutsidePortfolio;
  final List<String> portfolioNames;
  final PortfolioRiskLevel riskLevel;
  final String? riskMessage;

  const PortfolioCoverageRecord({
    required this.userId,
    required this.name,
    required this.role,
    required this.assignedPortfolioCount,
    required this.assignedSkuCount,
    required this.canSellOutsidePortfolio,
    required this.portfolioNames,
    this.riskLevel = PortfolioRiskLevel.ok,
    this.riskMessage,
  });

  bool get hasPortfolio =>
      assignedPortfolioCount > 0 || canSellOutsidePortfolio;

  @override
  List<Object?> get props =>
      [userId, role, assignedPortfolioCount, assignedSkuCount, riskLevel];
}

class OperationalReportSummary extends Equatable {
  final int totalOrders;
  final int warehouseMismatchCount;
  final int failedSyncCount;
  final int usersWithoutPortfolio;
  final int totalProfiles;

  const OperationalReportSummary({
    required this.totalOrders,
    required this.warehouseMismatchCount,
    required this.failedSyncCount,
    required this.usersWithoutPortfolio,
    required this.totalProfiles,
  });

  @override
  List<Object?> get props => [
        totalOrders,
        warehouseMismatchCount,
        failedSyncCount,
        usersWithoutPortfolio,
        totalProfiles
      ];
}

class OperationalReportsBundle extends Equatable {
  final OperationalReportSummary summary;
  final List<WarehouseMismatchRecord> warehouseMismatches;
  final List<FailedSyncRecord> failedSyncs;
  final List<PortfolioCoverageRecord> portfolioCoverage;
  final List<SyncFailureCategoryRecord> syncFailureCategories;

  const OperationalReportsBundle({
    required this.summary,
    required this.warehouseMismatches,
    required this.failedSyncs,
    required this.portfolioCoverage,
    this.syncFailureCategories = const [],
  });

  @override
  List<Object?> get props => [
        summary,
        warehouseMismatches,
        failedSyncs,
        portfolioCoverage,
        syncFailureCategories
      ];
}

class SyncFailureCategoryRecord extends Equatable {
  final String category;
  final int count;

  const SyncFailureCategoryRecord(
      {required this.category, required this.count});

  @override
  List<Object?> get props => [category, count];
}
