import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/customer_sync_entities.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';
import '../datasources/customer_local_datasource.dart';
import '../models/customer_models_mapper.dart';

// ============================================================
// CUSTOMER REPOSITORY IMPLEMENTATION
// ============================================================

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  final CustomerLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CustomerRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // ============ AGENT PROFILE ============

  @override
  Future<Either<Failure, AgentProfile>> getAgentProfile(String agentId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getAgentProfile(agentId);
        await localDataSource.cacheAgentProfile(data);
        return Right(AgentProfileMapper.fromJson(data));
      } else {
        final cached = await localDataSource.getCachedAgentProfile();
        if (cached != null) return Right(AgentProfileMapper.fromJson(cached));
        return const Left(CacheFailure(message: 'Agent profili topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AgentProfile>> syncAgentProfile(String agentId) async {
    try {
      final data = await remoteDataSource.getAgentProfile(agentId);
      await localDataSource.cacheAgentProfile(data);
      return Right(AgentProfileMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ CUSTOMERS ============

  @override
  Future<Either<Failure, List<SyncedCustomer>>> getAgentCustomers({
    required String agentId,
    String? search,
    String? regionId,
    bool? isActive,
    bool? hasDebt,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getAgentCustomers(
          agentId: agentId,
          search: search,
          regionId: regionId,
          isActive: isActive,
          hasDebt: hasDebt,
          page: page,
          limit: limit,
        );

        final customers =
            data.map((d) => SyncedCustomerMapper.fromJson(d)).toList();
        await localDataSource.cacheCustomers(data);
        return Right(customers);
      } else {
        final cached = await localDataSource.getCachedCustomers(
          search: search,
          agentId: agentId,
        );
        final customers =
            cached.map((d) => SyncedCustomerMapper.fromJson(d)).toList();
        return Right(customers);
      }
    } catch (e) {
      try {
        final cached = await localDataSource.getCachedCustomers(
          search: search,
          agentId: agentId,
        );
        final customers =
            cached.map((d) => SyncedCustomerMapper.fromJson(d)).toList();
        return Right(customers);
      } catch (_) {
        return Left(ErrorHandler.handleException(
            e is Exception ? e : Exception(e.toString())));
      }
    }
  }

  @override
  Future<Either<Failure, SyncedCustomer>> getCustomerById(
      String customerId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getCustomerById(customerId);
        await localDataSource.saveCustomer(data);
        return Right(SyncedCustomerMapper.fromJson(data));
      } else {
        final cached = await localDataSource.getCustomer(customerId);
        if (cached != null) return Right(SyncedCustomerMapper.fromJson(cached));
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, SyncedCustomer>> getCustomerFrom1C(
      String customerId) async {
    try {
      final items =
          await remoteDataSource.syncCustomersFrom1C(agentCode: 'AG001');
      final matches = items.where((item) =>
          item['id']?.toString() == customerId ||
          item['Ref_Key']?.toString() == customerId ||
          item['Code']?.toString() == customerId);
      if (matches.isEmpty)
        return const Left(NotFoundFailure(resource: '1C mijoz'));
      await localDataSource.saveCustomer(matches.first);
      return Right(SyncedCustomerMapper.fromJson(matches.first));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, SyncedCustomer>> getCustomerFromSAP(
      String customerId) async {
    try {
      final items =
          await remoteDataSource.syncCustomersFromSAP(salesPerson: 'AG001');
      final matches = items.where((item) =>
          item['id']?.toString() == customerId ||
          item['Customer']?.toString() == customerId ||
          item['CustomerID']?.toString() == customerId);
      if (matches.isEmpty)
        return const Left(NotFoundFailure(resource: 'SAP mijoz'));
      await localDataSource.saveCustomer(matches.first);
      return Right(SyncedCustomerMapper.fromJson(matches.first));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ SYNC ============

  @override
  Future<Either<Failure, CustomerSyncResult>> syncCustomersFrom1C({
    required String agentId,
    DateTime? sinceDate,
  }) async {
    try {
      final startTime = DateTime.now();
      final data = await remoteDataSource.syncCustomersFrom1C(
        agentCode: agentId,
        sinceDate: sinceDate,
      );

      await localDataSource.cacheCustomers(data);
      await localDataSource.saveLastSyncTime();

      return Right(CustomerSyncResult(
        source: SyncSource.oneC,
        status: SyncStatus.completed,
        totalCustomers: data.length,
        newCustomers: 0,
        updatedCustomers: data.length,
        unchangedCustomers: 0,
        failedCustomers: 0,
        errors: [],
        startedAt: startTime,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(startTime),
      ));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, CustomerSyncResult>> syncCustomersFromSAP({
    required String agentId,
    DateTime? sinceDate,
  }) async {
    try {
      final startTime = DateTime.now();
      final data = await remoteDataSource.syncCustomersFromSAP(
        salesPerson: agentId,
        sinceDate: sinceDate,
      );

      await localDataSource.cacheCustomers(data);
      await localDataSource.saveLastSyncTime();

      return Right(CustomerSyncResult(
        source: SyncSource.sap,
        status: SyncStatus.completed,
        totalCustomers: data.length,
        newCustomers: 0,
        updatedCustomers: data.length,
        unchangedCustomers: 0,
        failedCustomers: 0,
        errors: [],
        startedAt: startTime,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(startTime),
      ));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, CustomerSyncResult>> syncAllCustomers({
    required String agentId,
  }) async {
    try {
      final startTime = DateTime.now();

      // 1C dan yuklash
      final data1C = await remoteDataSource.syncCustomersFrom1C(
        agentCode: agentId,
      );

      // SAP dan yuklash
      final dataSAP = await remoteDataSource.syncCustomersFromSAP(
        salesPerson: agentId,
      );

      // Birlashtirish
      final allData = [...data1C, ...dataSAP];
      await localDataSource.cacheCustomers(allData);
      await localDataSource.saveLastSyncTime();

      return Right(CustomerSyncResult(
        source: SyncSource.both,
        status: SyncStatus.completed,
        totalCustomers: allData.length,
        newCustomers: 0,
        updatedCustomers: allData.length,
        unchangedCustomers: 0,
        failedCustomers: 0,
        errors: [],
        startedAt: startTime,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(startTime),
      ));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastCustomerSyncTime() async {
    try {
      final time = await localDataSource.getLastSyncTime();
      return Right(time);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, List<CustomerSyncResult>>> getSyncHistory({
    int limit = 10,
  }) async {
    try {
      final lastSync = await localDataSource.getLastSyncTime();
      if (lastSync == null) return const Right([]);
      return Right([
        CustomerSyncResult(
          source: SyncSource.both,
          status: SyncStatus.completed,
          totalCustomers: 0,
          newCustomers: 0,
          updatedCustomers: 0,
          unchangedCustomers: 0,
          failedCustomers: 0,
          errors: const [],
          startedAt: lastSync,
          completedAt: lastSync,
          duration: Duration.zero,
        ),
      ].take(limit).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ OFFLINE ============

  @override
  Future<Either<Failure, List<SyncedCustomer>>> getCachedCustomers({
    String? search,
    String? agentId,
  }) async {
    try {
      final cached = await localDataSource.getCachedCustomers(
        search: search,
        agentId: agentId,
      );
      final customers =
          cached.map((d) => SyncedCustomerMapper.fromJson(d)).toList();
      return Right(customers);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> cacheCustomers(
      List<SyncedCustomer> customers) async {
    try {
      final data =
          customers.map((c) => SyncedCustomerMapper.toJson(c)).toList();
      await localDataSource.cacheCustomers(data);
      return const Right(true);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> clearCustomerCache() async {
    try {
      await localDataSource.clearAll();
      return const Right(true);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ CREATE/UPDATE ============

  @override
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
  }) async {
    try {
      final data = {
        'name': name,
        'address': address,
        'phone': phone,
        'agent_id': agentId,
        'inn': inn,
        'email': email,
        'contact_person': contactPerson,
        'latitude': latitude,
        'longitude': longitude,
        'price_group_id': priceGroupId,
      };

      final result = await remoteDataSource.createCustomer(data);
      await localDataSource.saveCustomer(result);
      return Right(SyncedCustomerMapper.fromJson(result));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, SyncedCustomer>> updateCustomer({
    required String customerId,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? contactPerson,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (address != null) data['address'] = address;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (contactPerson != null) data['contact_person'] = contactPerson;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;

      final result = await remoteDataSource.updateCustomer(customerId, data);
      await localDataSource.saveCustomer(result);
      return Right(SyncedCustomerMapper.fromJson(result));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ ORDERS & PAYMENTS ============

  @override
  Future<Either<Failure, List<CustomerOrder>>> getCustomerOrders({
    required String customerId,
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getCustomerOrders(
          customerId: customerId,
          limit: limit,
        );
        await localDataSource.cacheCustomerOrders(customerId, data);
        return Right(data.map((d) => CustomerOrder.fromJson(d)).toList());
      } else {
        final cached =
            await localDataSource.getCachedCustomerOrders(customerId);
        return Right(cached.map((d) => CustomerOrder.fromJson(d)).toList());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<CustomerPayment>>> getCustomerPayments({
    required String customerId,
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getCustomerPayments(
          customerId: customerId,
          limit: limit,
        );
        await localDataSource.cacheCustomerPayments(customerId, data);
        return Right(data.map((d) => CustomerPayment.fromJson(d)).toList());
      } else {
        final cached =
            await localDataSource.getCachedCustomerPayments(customerId);
        return Right(cached.map((d) => CustomerPayment.fromJson(d)).toList());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }
}
