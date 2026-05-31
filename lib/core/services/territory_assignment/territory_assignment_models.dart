import 'package:equatable/equatable.dart';

/// Ma'lumot qaysi tizimdan aniqlanganini bildiradi.
enum AssignmentSource { oneC, sap, localCache, manual, mixed }

/// Region / hudud.
class SalesRegion extends Equatable {
  final String id;
  final String code;
  final String name;
  final String? parentId;
  final AssignmentSource source;

  const SalesRegion({
    required this.id,
    required this.code,
    required this.name,
    this.parentId,
    required this.source,
  });

  factory SalesRegion.fromJson(Map<String, dynamic> json,
      {AssignmentSource? source}) {
    return SalesRegion(
      id: json['id'] ??
          json['Ref_Key'] ??
          json['Region'] ??
          json['SalesOffice'] ??
          '',
      code: json['code'] ??
          json['Code'] ??
          json['RegionCode'] ??
          json['SalesOffice'] ??
          '',
      name: json['name'] ??
          json['Description'] ??
          json['RegionName'] ??
          json['SalesOfficeName'] ??
          '',
      parentId: json['parent_id'] ?? json['Parent_Key'] ?? json['ParentRegion'],
      source: source ?? AssignmentSource.localCache,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'parentId': parentId,
        'source': source.name,
      };

  @override
  List<Object?> get props => [id, code, source];
}

/// Sklad / ombor.
class SalesWarehouse extends Equatable {
  final String id;
  final String code;
  final String name;
  final String regionId;
  final String regionName;
  final bool isDefault;
  final bool isActive;
  final AssignmentSource source;

  const SalesWarehouse({
    required this.id,
    required this.code,
    required this.name,
    required this.regionId,
    required this.regionName,
    this.isDefault = false,
    this.isActive = true,
    required this.source,
  });

  factory SalesWarehouse.fromJson(Map<String, dynamic> json,
      {AssignmentSource? source}) {
    return SalesWarehouse(
      id: json['id'] ??
          json['Ref_Key'] ??
          json['Warehouse'] ??
          json['Plant'] ??
          '',
      code: json['code'] ??
          json['Code'] ??
          json['WarehouseCode'] ??
          json['Plant'] ??
          '',
      name: json['name'] ??
          json['Description'] ??
          json['WarehouseName'] ??
          json['PlantName'] ??
          '',
      regionId: json['region_id'] ??
          json['Region_Key'] ??
          json['Region'] ??
          json['SalesOffice'] ??
          '',
      regionName: json['region_name'] ??
          json['Region_Description'] ??
          json['RegionName'] ??
          json['SalesOfficeName'] ??
          '',
      isDefault: json['is_default'] ?? json['IsDefault'] ?? false,
      isActive: json['is_active'] ?? json['IsActive'] ?? true,
      source: source ?? AssignmentSource.localCache,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'regionId': regionId,
        'regionName': regionName,
        'isDefault': isDefault,
        'isActive': isActive,
        'source': source.name,
      };

  @override
  List<Object?> get props => [id, code, regionId, source];
}

/// Agentning region va skladlarga biriktirilishi.
class AgentTerritoryAssignment extends Equatable {
  final String agentId;
  final String agentCode;
  final String agentName;
  final String regionId;
  final String regionName;
  final String defaultWarehouseId;
  final List<String> allowedWarehouseIds;
  final AssignmentSource source;
  final DateTime updatedAt;

  const AgentTerritoryAssignment({
    required this.agentId,
    required this.agentCode,
    required this.agentName,
    required this.regionId,
    required this.regionName,
    required this.defaultWarehouseId,
    required this.allowedWarehouseIds,
    required this.source,
    required this.updatedAt,
  });

  factory AgentTerritoryAssignment.fromJson(Map<String, dynamic> json,
      {AssignmentSource? source}) {
    final defaultWarehouse = json['default_warehouse_id'] ??
        json['DefaultWarehouse_Key'] ??
        json['DefaultWarehouse'] ??
        json['Plant'] ??
        'warehouse_1';
    final allowed = List<String>.from(
      json['allowed_warehouse_ids'] ??
          json['AllowedWarehouseKeys'] ??
          json['AllowedWarehouses'] ??
          [defaultWarehouse],
    );

    return AgentTerritoryAssignment(
      agentId: json['agent_id'] ??
          json['id'] ??
          json['Ref_Key'] ??
          json['PersonnelNumber'] ??
          '',
      agentCode: json['agent_code'] ??
          json['code'] ??
          json['Code'] ??
          json['PersonnelNumber'] ??
          '',
      agentName: json['agent_name'] ??
          json['name'] ??
          json['Description'] ??
          json['FullName'] ??
          '',
      regionId: json['region_id'] ??
          json['Region_Key'] ??
          json['SalesOffice'] ??
          'region_1',
      regionName: json['region_name'] ??
          json['Region_Description'] ??
          json['SalesOfficeName'] ??
          'Toshkent',
      defaultWarehouseId: defaultWarehouse,
      allowedWarehouseIds: allowed.isEmpty ? [defaultWarehouse] : allowed,
      source: source ?? AssignmentSource.localCache,
      updatedAt:
          DateTime.tryParse(json['updated_at'] ?? json['Modified'] ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'agentId': agentId,
        'agentCode': agentCode,
        'agentName': agentName,
        'regionId': regionId,
        'regionName': regionName,
        'defaultWarehouseId': defaultWarehouseId,
        'allowedWarehouseIds': allowedWarehouseIds,
        'source': source.name,
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [agentId, agentCode, regionId, defaultWarehouseId, allowedWarehouseIds];
}

/// Mijoz qaysi region va qaysi skladlardan xizmat olishini bildiradi.
class CustomerTerritoryProfile extends Equatable {
  final String customerId;
  final String customerCode;
  final String customerName;
  final String regionId;
  final String regionName;
  final List<String> serviceWarehouseIds;
  final String? preferredWarehouseId;
  final AssignmentSource source;
  final DateTime updatedAt;

  const CustomerTerritoryProfile({
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.regionId,
    required this.regionName,
    required this.serviceWarehouseIds,
    this.preferredWarehouseId,
    required this.source,
    required this.updatedAt,
  });

  factory CustomerTerritoryProfile.fromJson(Map<String, dynamic> json,
      {AssignmentSource? source}) {
    final preferred = json['preferred_warehouse_id'] ??
        json['PreferredWarehouse_Key'] ??
        json['DefaultWarehouse'] ??
        json['Plant'];
    final warehouses = List<String>.from(
      json['service_warehouse_ids'] ??
          json['ServiceWarehouseKeys'] ??
          json['AllowedWarehouses'] ??
          [if (preferred != null) preferred],
    );

    return CustomerTerritoryProfile(
      customerId: json['customer_id'] ??
          json['id'] ??
          json['Ref_Key'] ??
          json['Customer'] ??
          '',
      customerCode: json['customer_code'] ??
          json['code'] ??
          json['Code'] ??
          json['Customer'] ??
          '',
      customerName: json['customer_name'] ??
          json['name'] ??
          json['Description'] ??
          json['CustomerName'] ??
          '',
      regionId: json['region_id'] ??
          json['Region_Key'] ??
          json['Region'] ??
          json['SalesOffice'] ??
          'region_1',
      regionName: json['region_name'] ??
          json['Region_Description'] ??
          json['RegionName'] ??
          json['SalesOfficeName'] ??
          'Toshkent',
      serviceWarehouseIds: warehouses.isEmpty ? ['warehouse_1'] : warehouses,
      preferredWarehouseId: preferred,
      source: source ?? AssignmentSource.localCache,
      updatedAt:
          DateTime.tryParse(json['updated_at'] ?? json['Modified'] ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'customerCode': customerCode,
        'customerName': customerName,
        'regionId': regionId,
        'regionName': regionName,
        'serviceWarehouseIds': serviceWarehouseIds,
        'preferredWarehouseId': preferredWarehouseId,
        'source': source.name,
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [customerId, customerCode, regionId, serviceWarehouseIds];
}

/// Zakaz uchun yakuniy sklad yechimi.
class OrderWarehouseResolution extends Equatable {
  final String agentId;
  final String customerId;
  final List<String> availableWarehouseIds;
  final String selectedWarehouseId;
  final bool hasDirectRegionMatch;
  final String? warningMessage;
  final AssignmentSource source;
  final DateTime resolvedAt;

  const OrderWarehouseResolution({
    required this.agentId,
    required this.customerId,
    required this.availableWarehouseIds,
    required this.selectedWarehouseId,
    required this.hasDirectRegionMatch,
    this.warningMessage,
    required this.source,
    required this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        agentId,
        customerId,
        availableWarehouseIds,
        selectedWarehouseId,
        hasDirectRegionMatch
      ];
}
