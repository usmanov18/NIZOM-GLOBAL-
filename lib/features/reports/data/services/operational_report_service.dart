import '../../../../core/services/sync_queue/sync_queue_models.dart';
import '../../../../core/services/sync_queue/sync_queue_service.dart';
import '../../../admin/data/datasources/sales_user_profile_local_datasource.dart';
import '../../../order_flow/data/datasources/order_local_datasource.dart';
import '../../../products/domain/repositories/product_portfolio_repository.dart';
import '../../domain/entities/operational_report_models.dart';

class OperationalReportService {
  final OrderLocalDataSource orderLocalDataSource;
  final SyncQueueService syncQueueService;
  final SalesUserProfileLocalDataSource profileLocalDataSource;
  final ProductPortfolioRepository portfolioRepository;

  OperationalReportService({
    required this.orderLocalDataSource,
    required this.syncQueueService,
    required this.profileLocalDataSource,
    required this.portfolioRepository,
  });

  (PortfolioRiskLevel, String?) _portfolioRisk(
      String role, int portfolioCount, int skuCount, bool outside) {
    if (outside)
      return (
        PortfolioRiskLevel.warning,
        'Portfeldan tashqari sotish yoqilgan'
      );
    if (portfolioCount == 0)
      return (PortfolioRiskLevel.critical, 'Portfolio biriktirilmagan');
    if (role == 'agent' && skuCount < 5)
      return (PortfolioRiskLevel.warning, 'Agent SKU qamrovi past');
    if (role == 'manager' && portfolioCount < 2)
      return (
        PortfolioRiskLevel.warning,
        'Menejer uchun portfolio qamrovi past'
      );
    return (PortfolioRiskLevel.ok, null);
  }

  OrderRiskLevel _mismatchRisk(Map<String, dynamic> metadata) {
    final source = metadata['territorySource']?.toString() ?? '';
    final warning =
        metadata['resolutionWarning']?.toString().toLowerCase() ?? '';
    final available = metadata['availableWarehouseIds'];
    if (available is List && available.length <= 1) return OrderRiskLevel.high;
    if (source == 'localCache' || warning.contains('mos sklad'))
      return OrderRiskLevel.medium;
    return OrderRiskLevel.low;
  }

  Future<OperationalReportsBundle> buildReports() async {
    final orders = await orderLocalDataSource.getAllOrders();
    final queueItems = await syncQueueService.getAll();
    final profiles = await profileLocalDataSource.getProfiles();
    final portfoliosResult = await portfolioRepository.getPortfolios();
    final portfolios = portfoliosResult.fold(
        (_) => portfolioRepository.demoPortfolios, (items) => items);

    final mismatches = orders
        .where((order) => order.metadata?['hasDirectRegionMatch'] == false)
        .map((order) {
      final metadata = order.metadata ?? {};
      return WarehouseMismatchRecord(
        orderId: order.id,
        orderNumber: order.orderNumber,
        customerName: order.customerName,
        selectedWarehouseName:
            metadata['selectedWarehouseName'] ?? order.warehouseId,
        customerServiceWarehouses:
            List<String>.from(metadata['customerServiceWarehouseNames'] ?? []),
        agentAllowedWarehouses:
            List<String>.from(metadata['agentAllowedWarehouseNames'] ?? []),
        source: metadata['territorySource'] ?? 'local',
        warning: metadata['resolutionWarning'] ?? 'Warehouse mismatch',
        riskLevel: _mismatchRisk(metadata),
        createdAt: order.createdAt,
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final failedItems = queueItems
        .where((item) => item.status == SyncQueueStatus.failed)
        .toList();
    final failedSyncs = failedItems.map((item) {
      return FailedSyncRecord(
        id: item.id,
        entityType: item.entityType.name,
        entityId: item.entityId,
        retryCount: item.retryCount,
        category: item.failureCategory?.name ?? 'unknown',
        error: item.lastError ?? 'Unknown sync error',
        updatedAt: item.updatedAt,
      );
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final categoryCounts = <String, int>{};
    for (final item in failedItems) {
      final category = item.failureCategory?.name ?? 'unknown';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    final syncFailureCategories = categoryCounts.entries
        .map((e) => SyncFailureCategoryRecord(category: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final coverage = profiles.map((profile) {
      final ids = profile.portfolioAssignment.portfolioIds;
      final assigned =
          portfolios.where((portfolio) => ids.contains(portfolio.id)).toList();
      final skuCount = assigned.fold<int>(
          0, (sum, portfolio) => sum + portfolio.productIds.length);
      final risk = _portfolioRisk(profile.role, assigned.length, skuCount,
          profile.portfolioAssignment.canSellOutsidePortfolio);
      return PortfolioCoverageRecord(
        userId: profile.id,
        name: profile.fullName,
        role: profile.role,
        assignedPortfolioCount: assigned.length,
        assignedSkuCount: skuCount,
        canSellOutsidePortfolio:
            profile.portfolioAssignment.canSellOutsidePortfolio,
        portfolioNames: assigned.map((e) => e.name).toList(),
        riskLevel: risk.$1,
        riskMessage: risk.$2,
      );
    }).toList()
      ..sort((a, b) => a.role.compareTo(b.role));

    final summary = OperationalReportSummary(
      totalOrders: orders.length,
      warehouseMismatchCount: mismatches.length,
      failedSyncCount: failedSyncs.length,
      usersWithoutPortfolio:
          coverage.where((item) => !item.hasPortfolio).length,
      totalProfiles: profiles.length,
    );

    return OperationalReportsBundle(
      summary: summary,
      warehouseMismatches: mismatches,
      failedSyncs: failedSyncs,
      portfolioCoverage: coverage,
      syncFailureCategories: syncFailureCategories,
    );
  }
}
