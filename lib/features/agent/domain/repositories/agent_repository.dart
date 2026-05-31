import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/agent_dashboard.dart';
import 'package:equatable/equatable.dart';

/// Agent Repository - Domain qatlamida interface
abstract class AgentRepository {
  /// Dashboard ma'lumotlarini olish
  Future<Either<Failure, AgentDashboard>> getDashboard();

  /// Agent buyurtmalarini olish
  Future<Either<Failure, List<AgentOrder>>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  });

  /// Agent tashriflarini olish
  Future<Either<Failure, List<AgentVisit>>> getVisits({
    DateTime? date,
    String? status,
  });

  /// Yangi buyurtma yaratish
  Future<Either<Failure, AgentOrder>> createOrder({
    required String customerId,
    required List<OrderItem> items,
    String? notes,
    DateTime? deliveryDate,
  });

  /// Buyurtma holatini yangilash
  Future<Either<Failure, bool>> updateOrderStatus({
    required String orderId,
    required String status,
    String? comment,
  });

  /// Tashrifni boshlash (check-in)
  Future<Either<Failure, AgentVisit>> checkInVisit({
    required String visitId,
    required double latitude,
    required double longitude,
  });

  /// Tashrifni yakunlash (check-out)
  Future<Either<Failure, AgentVisit>> checkOutVisit({
    required String visitId,
    String? notes,
    double? orderAmount,
  });

  /// KPI ma'lumotlarini olish
  Future<Either<Failure, AgentKPI>> getKPI({
    required String period, // daily, weekly, monthly
  });

  /// Kunlik hisobot
  Future<Either<Failure, AgentDailyReport>> getDailyReport({
    required DateTime date,
  });

  /// Mijozlar ro'yxati
  Future<Either<Failure, List<AgentCustomer>>> getCustomers({
    String? search,
    int page = 1,
    int limit = 20,
  });

  /// Offline buyurtmalarni sinxronlash
  Future<Either<Failure, int>> syncPendingOrders();
}

/// Order Item entity
class OrderItem extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [productId, quantity, unitPrice];
}

/// Agent Customer entity
class AgentCustomer extends Equatable {
  final String id;
  final String name;
  final String code;
  final String address;
  final String phone;
  final double? latitude;
  final double? longitude;
  final double currentDebt;
  final int totalOrders;
  final DateTime? lastVisitDate;
  final bool isActive;

  const AgentCustomer({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.phone,
    this.latitude,
    this.longitude,
    required this.currentDebt,
    required this.totalOrders,
    this.lastVisitDate,
    required this.isActive,
  });

  bool get hasDebt => currentDebt > 0;
  bool get hasLocation => latitude != null && longitude != null;

  factory AgentCustomer.fromJson(Map<String, dynamic> json) {
    return AgentCustomer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['customer_name'] ?? '',
      code: json['code'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      currentDebt:
          (json['current_debt'] ?? json['currentDebt'] ?? 0).toDouble(),
      totalOrders: json['total_orders'] ?? json['totalOrders'] ?? 0,
      lastVisitDate: DateTime.tryParse(
          json['last_visit_date'] ?? json['lastVisitDate'] ?? ''),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, code];
}

/// Agent Daily Report entity
class AgentDailyReport extends Equatable {
  final DateTime date;
  final int totalVisits;
  final int completedVisits;
  final int totalOrders;
  final double totalSales;
  final double totalCollections;
  final List<AgentOrder> orders;
  final List<AgentVisit> visits;

  const AgentDailyReport({
    required this.date,
    required this.totalVisits,
    required this.completedVisits,
    required this.totalOrders,
    required this.totalSales,
    required this.totalCollections,
    required this.orders,
    required this.visits,
  });

  double get visitCompletionRate =>
      totalVisits > 0 ? completedVisits / totalVisits : 0;

  factory AgentDailyReport.fromJson(Map<String, dynamic> json) {
    return AgentDailyReport(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      totalVisits: json['total_visits'] ?? json['totalVisits'] ?? 0,
      completedVisits: json['completed_visits'] ?? json['completedVisits'] ?? 0,
      totalOrders: json['total_orders'] ?? json['totalOrders'] ?? 0,
      totalSales: (json['total_sales'] ?? json['totalSales'] ?? 0).toDouble(),
      totalCollections:
          (json['total_collections'] ?? json['totalCollections'] ?? 0)
              .toDouble(),
      orders: (json['orders'] as List? ?? [])
          .map((e) => AgentOrder.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      visits: (json['visits'] as List? ?? [])
          .map((e) => AgentVisit.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [date, totalOrders, totalSales];
}
