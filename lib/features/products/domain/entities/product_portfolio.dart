import 'package:equatable/equatable.dart';

/// Mahsulot qaysi tizimdan kelgani.
enum ProductSourceSystem { oneC, sap, manual, mixed }

/// Assortiment/tovar portfel turi.
enum AssortmentType {
  mandatory, // majburiy assortiment
  recommended, // tavsiya qilingan
  optional, // ixtiyoriy
  seasonal, // mavsumiy
  promo, // aksiya/promo
  restricted, // cheklangan
}

/// Portfolio statusi.
enum PortfolioStatus { active, inactive, archived }

/// Tovar portfeli / assortiment guruhi.
/// Masalan: Ichimliklar, Snack, Qandolat, Premium, Horeca, Distributor A va h.k.
class ProductPortfolio extends Equatable {
  final String id;
  final String code;
  final String name;
  final String? description;
  final ProductSourceSystem sourceSystem;
  final AssortmentType assortmentType;
  final PortfolioStatus status;
  final String? parentId;
  final List<String> categoryIds;
  final List<String> productIds;
  final List<String> brands;
  final List<String> channels; // retail, horeca, wholesale...
  final int priority;
  final DateTime? validFrom;
  final DateTime? validTo;

  const ProductPortfolio({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.sourceSystem,
    required this.assortmentType,
    this.status = PortfolioStatus.active,
    this.parentId,
    this.categoryIds = const [],
    this.productIds = const [],
    this.brands = const [],
    this.channels = const [],
    this.priority = 0,
    this.validFrom,
    this.validTo,
  });

  bool get isActive => status == PortfolioStatus.active;

  bool get isCurrentlyValid {
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validTo != null && now.isAfter(validTo!)) return false;
    return true;
  }

  factory ProductPortfolio.fromJson(Map<String, dynamic> json) {
    return ProductPortfolio(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      sourceSystem: ProductSourceSystem.values.firstWhere(
        (e) =>
            e.name == json['source_system'] || e.name == json['sourceSystem'],
        orElse: () => ProductSourceSystem.mixed,
      ),
      assortmentType: AssortmentType.values.firstWhere(
        (e) =>
            e.name == json['assortment_type'] ||
            e.name == json['assortmentType'],
        orElse: () => AssortmentType.optional,
      ),
      status: PortfolioStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PortfolioStatus.active,
      ),
      parentId: json['parent_id'] ?? json['parentId'],
      categoryIds:
          List<String>.from(json['category_ids'] ?? json['categoryIds'] ?? []),
      productIds:
          List<String>.from(json['product_ids'] ?? json['productIds'] ?? []),
      brands: List<String>.from(json['brands'] ?? []),
      channels: List<String>.from(json['channels'] ?? []),
      priority: json['priority'] ?? 0,
      validFrom:
          DateTime.tryParse(json['valid_from'] ?? json['validFrom'] ?? ''),
      validTo: DateTime.tryParse(json['valid_to'] ?? json['validTo'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'sourceSystem': sourceSystem.name,
        'assortmentType': assortmentType.name,
        'status': status.name,
        'parentId': parentId,
        'categoryIds': categoryIds,
        'productIds': productIds,
        'brands': brands,
        'channels': channels,
        'priority': priority,
        'validFrom': validFrom?.toIso8601String(),
        'validTo': validTo?.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, code, name, sourceSystem, assortmentType, status];
}

/// Agent/menejer/supervisor uchun portfolio ruxsati.
class PortfolioAssignment extends Equatable {
  final String id;
  final String userId;
  final String userRole; // agent, manager, supervisor
  final List<String> portfolioIds;
  final List<String> allowedProductIds;
  final List<String> deniedProductIds;
  final bool canSellOutsidePortfolio;
  final DateTime assignedAt;
  final String assignedBy;

  const PortfolioAssignment({
    required this.id,
    required this.userId,
    required this.userRole,
    required this.portfolioIds,
    this.allowedProductIds = const [],
    this.deniedProductIds = const [],
    this.canSellOutsidePortfolio = false,
    required this.assignedAt,
    required this.assignedBy,
  });

  bool canAccessProduct(String productId, List<ProductPortfolio> portfolios) {
    if (deniedProductIds.contains(productId)) return false;
    if (allowedProductIds.contains(productId)) return true;
    if (canSellOutsidePortfolio) return true;
    return portfolios
        .where((p) => portfolioIds.contains(p.id))
        .any((p) => p.productIds.contains(productId));
  }

  factory PortfolioAssignment.fromJson(Map<String, dynamic> json) {
    return PortfolioAssignment(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      userRole: json['user_role'] ?? json['userRole'] ?? 'agent',
      portfolioIds: List<String>.from(
          json['portfolio_ids'] ?? json['portfolioIds'] ?? []),
      allowedProductIds: List<String>.from(
          json['allowed_product_ids'] ?? json['allowedProductIds'] ?? []),
      deniedProductIds: List<String>.from(
          json['denied_product_ids'] ?? json['deniedProductIds'] ?? []),
      canSellOutsidePortfolio: json['can_sell_outside_portfolio'] ??
          json['canSellOutsidePortfolio'] ??
          false,
      assignedAt:
          DateTime.tryParse(json['assigned_at'] ?? json['assignedAt'] ?? '') ??
              DateTime.now(),
      assignedBy: json['assigned_by'] ?? json['assignedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userRole': userRole,
        'portfolioIds': portfolioIds,
        'allowedProductIds': allowedProductIds,
        'deniedProductIds': deniedProductIds,
        'canSellOutsidePortfolio': canSellOutsidePortfolio,
        'assignedAt': assignedAt.toIso8601String(),
        'assignedBy': assignedBy,
      };

  @override
  List<Object?> get props => [id, userId, userRole, portfolioIds];
}

/// Portfolio assignment o‘zgarishlari uchun audit log.
class PortfolioAuditLog extends Equatable {
  final String id;
  final String event;
  final String actorId;
  final String actorRole;
  final String targetUserId;
  final String targetUserRole;
  final List<String> oldPortfolioIds;
  final List<String> newPortfolioIds;
  final bool oldCanSellOutsidePortfolio;
  final bool newCanSellOutsidePortfolio;
  final DateTime createdAt;

  const PortfolioAuditLog({
    required this.id,
    required this.event,
    required this.actorId,
    required this.actorRole,
    required this.targetUserId,
    required this.targetUserRole,
    required this.oldPortfolioIds,
    required this.newPortfolioIds,
    required this.oldCanSellOutsidePortfolio,
    required this.newCanSellOutsidePortfolio,
    required this.createdAt,
  });

  factory PortfolioAuditLog.fromJson(Map<String, dynamic> json) {
    return PortfolioAuditLog(
      id: json['id']?.toString() ?? '',
      event: json['event'] ?? 'portfolio_assignment_updated',
      actorId: json['actor_id'] ?? json['actorId'] ?? '',
      actorRole: json['actor_role'] ?? json['actorRole'] ?? '',
      targetUserId: json['target_user_id'] ?? json['targetUserId'] ?? '',
      targetUserRole: json['target_user_role'] ?? json['targetUserRole'] ?? '',
      oldPortfolioIds: List<String>.from(
          json['old_portfolio_ids'] ?? json['oldPortfolioIds'] ?? []),
      newPortfolioIds: List<String>.from(
          json['new_portfolio_ids'] ?? json['newPortfolioIds'] ?? []),
      oldCanSellOutsidePortfolio: json['old_can_sell_outside_portfolio'] ??
          json['oldCanSellOutsidePortfolio'] ??
          false,
      newCanSellOutsidePortfolio: json['new_can_sell_outside_portfolio'] ??
          json['newCanSellOutsidePortfolio'] ??
          false,
      createdAt:
          DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'event': event,
        'actorId': actorId,
        'actorRole': actorRole,
        'targetUserId': targetUserId,
        'targetUserRole': targetUserRole,
        'oldPortfolioIds': oldPortfolioIds,
        'newPortfolioIds': newPortfolioIds,
        'oldCanSellOutsidePortfolio': oldCanSellOutsidePortfolio,
        'newCanSellOutsidePortfolio': newCanSellOutsidePortfolio,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, event, actorId, targetUserId, createdAt];
}
