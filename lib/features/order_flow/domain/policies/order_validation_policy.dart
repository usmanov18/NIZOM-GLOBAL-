import '../../../../core/security/role_permission_policy.dart';
import '../../../products/domain/entities/product_portfolio.dart';
import '../../../products/domain/policies/product_access_resolver.dart';
import 'product_stock_resolver.dart';
import '../entities/order_flow_entities.dart';

class OrderValidationIssue {
  final String code;
  final String message;
  final bool blocking;

  const OrderValidationIssue({
    required this.code,
    required this.message,
    this.blocking = true,
  });
}

class OrderValidationResult {
  final List<OrderValidationIssue> issues;

  const OrderValidationResult(this.issues);

  bool get isValid => issues.where((e) => e.blocking).isEmpty;
  List<String> get blockingMessages =>
      issues.where((e) => e.blocking).map((e) => e.message).toList();
  List<String> get warnings =>
      issues.where((e) => !e.blocking).map((e) => e.message).toList();
}

/// Order yaratish/saqlash/sync oldidan yakuniy biznes tekshiruv.
class OrderValidationPolicy {
  const OrderValidationPolicy._();

  static OrderValidationResult validateDraftOrder({
    required String role,
    required OrderCustomer? customer,
    required List<OrderItem> items,
    required String selectedWarehouseId,
    required List<String> allowedWarehouseIds,
    required Map<String, dynamic>? territoryMetadata,
  }) {
    final issues = <OrderValidationIssue>[];

    if (!RolePermissionPolicy.canCreateOrder(role)) {
      issues.add(const OrderValidationIssue(
        code: 'role_denied',
        message: 'Bu rol uchun buyurtma yaratish ruxsat etilmagan',
      ));
    }

    if (customer == null) {
      issues.add(const OrderValidationIssue(
          code: 'customer_required', message: 'Mijoz tanlanmagan'));
    } else {
      if (!customer.canOrder) {
        issues.add(OrderValidationIssue(
          code: 'customer_blocked',
          message: customer.isBlocked
              ? 'Mijoz bloklangan: ${customer.blockReason ?? ''}'
              : 'Mijoz faol emas',
        ));
      }
    }

    if (items.isEmpty) {
      issues.add(const OrderValidationIssue(
          code: 'items_required', message: 'Kamida bitta mahsulot qo‘shing'));
    }

    if (!allowedWarehouseIds.contains(selectedWarehouseId)) {
      issues.add(const OrderValidationIssue(
        code: 'warehouse_denied',
        message: 'Tanlangan sklad agentga biriktirilmagan',
      ));
    }

    final hasDirectMatch = territoryMetadata?['hasDirectRegionMatch'];
    if (hasDirectMatch == false) {
      issues.add(OrderValidationIssue(
        code: 'territory_no_direct_match',
        message: territoryMetadata?['resolutionWarning'] ??
            'Mijoz hududi uchun mos sklad topilmadi',
        blocking: false,
      ));
    }

    if (territoryMetadata == null ||
        territoryMetadata['selectedWarehouseId'] == null) {
      issues.add(const OrderValidationIssue(
        code: 'territory_snapshot_missing',
        message: 'Territory/sklad resolution snapshot mavjud emas',
        blocking: false,
      ));
    }

    for (final item in items) {
      if (item.quantity <= 0) {
        issues.add(OrderValidationIssue(
            code: 'invalid_quantity',
            message: '${item.productName}: miqdor noto‘g‘ri'));
      }
      final stockDecision = ProductStockResolver.resolve(
        requestedQuantity: item.quantity,
        availableQuantity: (item.availableStock ?? 0).toInt(),
      );
      if (!stockDecision.canAddToCart) {
        issues.add(OrderValidationIssue(
          code: 'stock_blocked',
          message:
              '${item.productName}: ${stockDecision.message ?? 'qoldiq yetarli emas'}',
        ));
      } else if (stockDecision.requiresWarning) {
        issues.add(OrderValidationIssue(
          code: 'stock_limited',
          message: '${item.productName}: ${stockDecision.message}',
          blocking: false,
        ));
      }
    }

    return OrderValidationResult(issues);
  }

  static OrderValidationResult validateBeforeSync({
    required String role,
    required Order order,
    Duration maxTerritoryAge = const Duration(minutes: 30),
  }) {
    final issues = <OrderValidationIssue>[];

    if (!RolePermissionPolicy.canSyncOrders(role)) {
      issues.add(const OrderValidationIssue(
        code: 'sync_role_denied',
        message: 'Bu rol uchun order sync ruxsat etilmagan',
      ));
    }

    if (!(order.status == OrderStatus.draft ||
        order.status == OrderStatus.syncFailed ||
        order.status == OrderStatus.pending)) {
      issues.add(OrderValidationIssue(
        code: 'sync_invalid_status',
        message: 'Order sync uchun noto‘g‘ri status: ${order.status.name}',
      ));
    }

    if (order.items.isEmpty) {
      issues.add(const OrderValidationIssue(
        code: 'sync_empty_order',
        message: 'Bo‘sh order sync qilinmaydi',
      ));
    }

    if (order.warehouseId.isEmpty) {
      issues.add(const OrderValidationIssue(
        code: 'sync_warehouse_missing',
        message: 'Order skladga bog‘lanmagan',
      ));
    }

    final metadata = order.metadata;
    if (metadata == null) {
      issues.add(const OrderValidationIssue(
        code: 'sync_metadata_missing',
        message: 'Order territory metadata mavjud emas',
        blocking: false,
      ));
    } else {
      final selectedWarehouseId = metadata['selectedWarehouseId'];
      if (selectedWarehouseId != null &&
          selectedWarehouseId != order.warehouseId) {
        issues.add(const OrderValidationIssue(
          code: 'sync_warehouse_mismatch',
          message:
              'Order warehouseId va territory selectedWarehouseId mos emas',
        ));
      }

      final resolvedAtRaw = metadata['resolvedAt'];
      final resolvedAt =
          resolvedAtRaw == null ? null : DateTime.tryParse(resolvedAtRaw);
      if (resolvedAt == null) {
        issues.add(const OrderValidationIssue(
          code: 'sync_resolution_time_missing',
          message: 'Territory resolution vaqti topilmadi',
          blocking: false,
        ));
      } else if (DateTime.now().difference(resolvedAt) > maxTerritoryAge) {
        issues.add(const OrderValidationIssue(
          code: 'sync_resolution_stale',
          message: 'Territory/sklad resolution eskirgan',
          blocking: false,
        ));
      }

      if (metadata['hasDirectRegionMatch'] == false) {
        issues.add(OrderValidationIssue(
          code: 'sync_no_direct_region_match',
          message: metadata['resolutionWarning'] ??
              'Mijoz hududi va agent skladlari to‘liq mos emas',
          blocking: false,
        ));
      }
    }

    for (final item in order.items) {
      final stockDecision = ProductStockResolver.resolve(
        requestedQuantity: item.quantity,
        availableQuantity: (item.availableStock ?? 0).toInt(),
      );
      if (!stockDecision.canAddToCart) {
        issues.add(OrderValidationIssue(
          code: 'sync_stock_blocked',
          message:
              '${item.productName}: ${stockDecision.message ?? 'qoldiq yetarli emas'}',
        ));
      } else if (stockDecision.requiresWarning) {
        issues.add(OrderValidationIssue(
          code: 'sync_stock_warning',
          message: '${item.productName}: ${stockDecision.message}',
          blocking: false,
        ));
      }
    }

    return OrderValidationResult(issues);
  }

  static OrderValidationIssue? validateProductAccess({
    required String role,
    required String productId,
    required List<String> productPortfolioIds,
    required PortfolioAssignment? assignment,
    required List<ProductPortfolio> portfolios,
  }) {
    if (assignment == null) {
      return const OrderValidationIssue(
        code: 'portfolio_assignment_missing',
        message: 'Portfolio assignment topilmadi',
      );
    }
    final decision = ProductAccessResolver.resolve(
      role: role,
      productId: productId,
      productPortfolioIds: productPortfolioIds,
      assignment: assignment,
      portfolios: portfolios,
    );
    if (!decision.canSell) {
      return OrderValidationIssue(
        code: 'product_access_denied',
        message: decision.reason ?? 'Mahsulotga ruxsat yo‘q',
      );
    }
    return null;
  }
}
