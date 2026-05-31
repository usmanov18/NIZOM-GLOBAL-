import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_sync_entities.dart';
import '../repositories/customer_repository.dart';

// ============================================================
// CUSTOMER USECASES
// ============================================================

class GetAgentCustomers
    implements UseCase<List<SyncedCustomer>, GetCustomersParams> {
  final CustomerRepository repository;
  GetAgentCustomers(this.repository);

  @override
  Future<Either<Failure, List<SyncedCustomer>>> call(
      GetCustomersParams params) {
    return repository.getAgentCustomers(
      agentId: params.agentId,
      search: params.search,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetCustomerById implements UseCase<SyncedCustomer, String> {
  final CustomerRepository repository;
  GetCustomerById(this.repository);

  @override
  Future<Either<Failure, SyncedCustomer>> call(String id) {
    return repository.getCustomerById(id);
  }
}

class SyncCustomersFrom1C implements UseCase<CustomerSyncResult, String> {
  final CustomerRepository repository;
  SyncCustomersFrom1C(this.repository);

  @override
  Future<Either<Failure, CustomerSyncResult>> call(String agentId) {
    return repository.syncCustomersFrom1C(agentId: agentId);
  }
}

class SyncCustomersFromSAP implements UseCase<CustomerSyncResult, String> {
  final CustomerRepository repository;
  SyncCustomersFromSAP(this.repository);

  @override
  Future<Either<Failure, CustomerSyncResult>> call(String agentId) {
    return repository.syncCustomersFromSAP(agentId: agentId);
  }
}

class SyncAllCustomers implements UseCase<CustomerSyncResult, String> {
  final CustomerRepository repository;
  SyncAllCustomers(this.repository);

  @override
  Future<Either<Failure, CustomerSyncResult>> call(String agentId) {
    return repository.syncAllCustomers(agentId: agentId);
  }
}

class CreateCustomer implements UseCase<SyncedCustomer, CreateCustomerParams> {
  final CustomerRepository repository;
  CreateCustomer(this.repository);

  @override
  Future<Either<Failure, SyncedCustomer>> call(CreateCustomerParams params) {
    return repository.createCustomer(
      name: params.name,
      address: params.address,
      phone: params.phone,
      agentId: params.agentId,
      inn: params.inn,
      email: params.email,
      contactPerson: params.contactPerson,
      latitude: params.latitude,
      longitude: params.longitude,
      priceGroupId: params.priceGroupId,
    );
  }
}

// ============ PARAMS ============

class GetCustomersParams extends Equatable {
  final String agentId;
  final String? search;
  final int page;
  final int limit;

  const GetCustomersParams({
    required this.agentId,
    this.search,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [agentId, search, page];
}

class CreateCustomerParams extends Equatable {
  final String name;
  final String address;
  final String phone;
  final String agentId;
  final String? inn;
  final String? email;
  final String? contactPerson;
  final double? latitude;
  final double? longitude;
  final String priceGroupId;

  const CreateCustomerParams({
    required this.name,
    required this.address,
    required this.phone,
    required this.agentId,
    this.inn,
    this.email,
    this.contactPerson,
    this.latitude,
    this.longitude,
    required this.priceGroupId,
  });

  @override
  List<Object?> get props => [name, phone, agentId];
}
