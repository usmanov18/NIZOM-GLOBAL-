import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product_portfolio.dart';

/// Admin foydalanuvchi profilini yaratganda ishlatiladigan savdo profili.
/// Agent, menejer, supervisor bir xil bazaviy modeldan boshqariladi.
class SalesUserProfile extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final String role; // agent, manager, supervisor
  final String? code;
  final String? regionId;
  final String? regionName;
  final String? supervisorId;
  final String? managerId;
  final String? warehouseId; // default warehouse
  final List<String> allowedWarehouseIds;
  final String? channel; // retail, horeca, wholesale
  final bool isActive;
  final PortfolioAssignment portfolioAssignment;

  const SalesUserProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    this.code,
    this.regionId,
    this.regionName,
    this.supervisorId,
    this.managerId,
    this.warehouseId,
    this.allowedWarehouseIds = const [],
    this.channel,
    this.isActive = true,
    required this.portfolioAssignment,
  });

  bool get isAgent => role == 'agent';
  bool get isManager => role == 'manager';
  bool get isSupervisor => role == 'supervisor';

  factory SalesUserProfile.fromJson(Map<String, dynamic> json) {
    return SalesUserProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'agent',
      code: json['code'],
      regionId: json['region_id'] ?? json['regionId'],
      regionName: json['region_name'] ?? json['regionName'],
      supervisorId: json['supervisor_id'] ?? json['supervisorId'],
      managerId: json['manager_id'] ?? json['managerId'],
      warehouseId: json['warehouse_id'] ?? json['warehouseId'],
      allowedWarehouseIds: List<String>.from(
          json['allowed_warehouse_ids'] ?? json['allowedWarehouseIds'] ?? []),
      channel: json['channel'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      portfolioAssignment: PortfolioAssignment.fromJson(
        Map<String, dynamic>.from(
            json['portfolio_assignment'] ?? json['portfolioAssignment'] ?? {}),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'role': role,
        'code': code,
        'regionId': regionId,
        'regionName': regionName,
        'supervisorId': supervisorId,
        'managerId': managerId,
        'warehouseId': warehouseId,
        'allowedWarehouseIds': allowedWarehouseIds,
        'channel': channel,
        'isActive': isActive,
        'portfolioAssignment': portfolioAssignment.toJson(),
      };

  SalesUserProfile copyWith({
    String? fullName,
    String? phone,
    String? role,
    String? code,
    String? regionId,
    String? regionName,
    String? supervisorId,
    String? managerId,
    String? warehouseId,
    List<String>? allowedWarehouseIds,
    String? channel,
    bool? isActive,
    PortfolioAssignment? portfolioAssignment,
  }) {
    return SalesUserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      code: code ?? this.code,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      supervisorId: supervisorId ?? this.supervisorId,
      managerId: managerId ?? this.managerId,
      warehouseId: warehouseId ?? this.warehouseId,
      allowedWarehouseIds: allowedWarehouseIds ?? this.allowedWarehouseIds,
      channel: channel ?? this.channel,
      isActive: isActive ?? this.isActive,
      portfolioAssignment: portfolioAssignment ?? this.portfolioAssignment,
    );
  }

  @override
  List<Object?> get props =>
      [id, role, code, warehouseId, allowedWarehouseIds, portfolioAssignment];
}
