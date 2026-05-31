import 'package:equatable/equatable.dart';

/// Auth User entity
class AuthUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;
  final String? regionId;
  final String? regionName;
  final String? warehouseId;
  final String? warehouseName;
  final List<String> allowedWarehouseIds;
  final String? code;
  final bool isActive;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    this.regionId,
    this.regionName,
    this.warehouseId,
    this.warehouseName,
    this.allowedWarehouseIds = const [],
    this.code,
    required this.isActive,
  });

  bool get isAdmin => role == 'admin';
  bool get isSupervisor => role == 'supervisor';
  bool get isAgent => role == 'agent';
  bool get isDelivery => role == 'delivery';

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'agent',
      avatar: json['avatar'],
      regionId: json['region_id'],
      regionName: json['region_name'],
      warehouseId: json['warehouse_id'] ?? json['warehouseId'],
      warehouseName: json['warehouse_name'] ?? json['warehouseName'],
      allowedWarehouseIds: List<String>.from(
          json['allowed_warehouse_ids'] ?? json['allowedWarehouseIds'] ?? []),
      code: json['code'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar,
      'region_id': regionId,
      'region_name': regionName,
      'warehouse_id': warehouseId,
      'warehouse_name': warehouseName,
      'allowed_warehouse_ids': allowedWarehouseIds,
      'code': code,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [id, role, isActive];
}
