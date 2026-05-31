import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_sync_entities.dart';
import 'package:equatable/equatable.dart';

// ============================================================
// CUSTOMER REPOSITORY - Agent mijozlari
// ============================================================

abstract class CustomerRepository {
  // ============ AGENT PROFILI ============

  /// Agent profilini olish (1C/SAP dan)
  Future<Either<Failure, AgentProfile>> getAgentProfile(String agentId);

  /// Agent profilini sinxronlash
  Future<Either<Failure, AgentProfile>> syncAgentProfile(String agentId);

  // ============ MIJOZLAR ============

  /// Agent biriktirilgan mijozlar (1C dan)
  Future<Either<Failure, List<SyncedCustomer>>> getAgentCustomers({
    required String agentId,
    String? search,
    String? regionId,
    bool? isActive,
    bool? hasDebt,
    int page = 1,
    int limit = 50,
  });

  /// Mijoz tafsilotlari
  Future<Either<Failure, SyncedCustomer>> getCustomerById(String customerId);

  /// Mijoz tafsilotlari (1C dan)
  Future<Either<Failure, SyncedCustomer>> getCustomerFrom1C(String customerId);

  /// Mijoz tafsilotlari (SAP dan)
  Future<Either<Failure, SyncedCustomer>> getCustomerFromSAP(String customerId);

  // ============ SINXRONLASH ============

  /// 1C dan mijozlarni yuklash
  Future<Either<Failure, CustomerSyncResult>> syncCustomersFrom1C({
    required String agentId,
    DateTime? sinceDate,
  });

  /// SAP dan mijozlarni yuklash
  Future<Either<Failure, CustomerSyncResult>> syncCustomersFromSAP({
    required String agentId,
    DateTime? sinceDate,
  });

  /// Barcha mijozlarni sinxronlash (1C + SAP)
  Future<Either<Failure, CustomerSyncResult>> syncAllCustomers({
    required String agentId,
  });

  /// Oxirgi sinxronlash vaqti
  Future<Either<Failure, DateTime?>> getLastCustomerSyncTime();

  /// Sinxronlash tarixi
  Future<Either<Failure, List<CustomerSyncResult>>> getSyncHistory({
    int limit = 10,
  });

  // ============ OFFLINE ============

  /// Local cache dan olish
  Future<Either<Failure, List<SyncedCustomer>>> getCachedCustomers({
    String? search,
    String? agentId,
  });

  /// Local ga saqlash
  Future<Either<Failure, bool>> cacheCustomers(List<SyncedCustomer> customers);

  /// Cache ni tozalash
  Future<Either<Failure, bool>> clearCustomerCache();

  // ============ QO'SHIMCHA ============

  /// Yangi mijoz qo'shish (1C/SAP ga)
  Future<Either<Failure, SyncedCustomer>> createCustomer({
    required String name,
    required String address,
    required String phone,
    required String agentId,
    String? inn,
    String? email,
    String? contactPerson,
    double? latitude,
    double? longitude,
    required String priceGroupId,
  });

  /// Mijozni yangilash
  Future<Either<Failure, SyncedCustomer>> updateCustomer({
    required String customerId,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? contactPerson,
    double? latitude,
    double? longitude,
  });

  /// Mijoz buyurtmalari tarixi
  Future<Either<Failure, List<CustomerOrder>>> getCustomerOrders({
    required String customerId,
    int limit = 20,
  });

  /// Mijoz to'lovlari tarixi
  Future<Either<Failure, List<CustomerPayment>>> getCustomerPayments({
    required String customerId,
    int limit = 20,
  });
}

/// Mijoz buyurtmasi (tarix uchun)
class CustomerOrder extends Equatable {
  final String id;
  final String orderNumber;
  final DateTime date;
  final double amount;
  final String status;

  const CustomerOrder({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.amount,
    required this.status,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      id: (json['id'] ?? json['order_id'] ?? '').toString(),
      orderNumber: (json['order_number'] ?? json['number'] ?? '').toString(),
      date: DateTime.tryParse(
              (json['date'] ?? json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      amount: (json['amount'] ?? json['total_amount'] ?? 0).toDouble(),
      status: (json['status'] ?? 'unknown').toString(),
    );
  }

  @override
  List<Object?> get props => [id, orderNumber];
}

/// Mijoz to'lovi (tarix uchun)
class CustomerPayment extends Equatable {
  final String id;
  final DateTime date;
  final double amount;
  final String method;
  final String? reference;

  const CustomerPayment({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    this.reference,
  });

  factory CustomerPayment.fromJson(Map<String, dynamic> json) {
    return CustomerPayment(
      id: (json['id'] ?? json['payment_id'] ?? '').toString(),
      date: DateTime.tryParse(
              (json['date'] ?? json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      amount: (json['amount'] ?? 0).toDouble(),
      method:
          (json['method'] ?? json['payment_method'] ?? 'unknown').toString(),
      reference: json['reference']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, date, amount];
}
