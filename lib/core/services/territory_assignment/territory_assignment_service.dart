import 'dart:async';

import '../../config/env_config.dart';
import 'territory_assignment_local_datasource.dart';
import 'territory_assignment_models.dart';
import 'territory_assignment_policy.dart';
import 'territory_assignment_remote_datasource.dart';

/// Real-timega yaqin region/sklad resolver.
/// 1C/SAPdan o‘qiydi, local cachega saqlaydi, order yozishda bitta API beradi.
class TerritoryAssignmentService {
  final TerritoryAssignmentRemoteDataSource remoteDataSource;
  final TerritoryAssignmentLocalDataSource localDataSource;

  final _controller = StreamController<OrderWarehouseResolution>.broadcast();
  Stream<OrderWarehouseResolution> get resolutionStream => _controller.stream;

  TerritoryAssignmentService({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  static const Duration freshFor = Duration(minutes: 30);

  bool _isFresh(DateTime updatedAt) {
    return DateTime.now().difference(updatedAt) <= freshFor;
  }

  Future<AgentTerritoryAssignment> resolveAgent(
    String agentCodeOrId, {
    bool forceRefresh = false,
    bool preferCache = false,
  }) async {
    final cached = await localDataSource.getAgentAssignment(agentCodeOrId);
    if (!forceRefresh &&
        cached != null &&
        (preferCache || _isFresh(cached.updatedAt))) {
      return cached;
    }

    final remote = await remoteDataSource.getAgentFrom1C(agentCodeOrId);
    if (remote != null) {
      await localDataSource.saveAgentAssignment(remote);
      return remote;
    }

    if (cached != null) return cached;
    if (EnvConfig.isDemoMode) return _demoAgent(agentCodeOrId);
    throw StateError('Agent territory assignment topilmadi: $agentCodeOrId');
  }

  Future<CustomerTerritoryProfile> resolveCustomer(
    String customerCodeOrId, {
    bool forceRefresh = false,
    bool preferCache = false,
  }) async {
    final cached = await localDataSource.getCustomerProfile(customerCodeOrId);
    if (!forceRefresh &&
        cached != null &&
        (preferCache || _isFresh(cached.updatedAt))) {
      return cached;
    }

    final from1C = await remoteDataSource.getCustomerFrom1C(customerCodeOrId);
    if (from1C != null) {
      await localDataSource.saveCustomerProfile(from1C);
      return from1C;
    }

    final fromSAP = await remoteDataSource.getCustomerFromSAP(customerCodeOrId);
    if (fromSAP != null) {
      await localDataSource.saveCustomerProfile(fromSAP);
      return fromSAP;
    }

    if (cached != null) return cached;
    if (EnvConfig.isDemoMode) return _demoCustomer(customerCodeOrId);
    throw StateError('Customer territory profile topilmadi: $customerCodeOrId');
  }

  Future<OrderWarehouseResolution> resolveOrderWarehouse({
    required String agentCodeOrId,
    required String customerCodeOrId,
    bool forceRefresh = false,
    bool preferCache = false,
  }) async {
    final agent = await resolveAgent(agentCodeOrId,
        forceRefresh: forceRefresh, preferCache: preferCache);
    final customer = await resolveCustomer(customerCodeOrId,
        forceRefresh: forceRefresh, preferCache: preferCache);
    final resolution = TerritoryAssignmentPolicy.resolveOrderWarehouse(
      agent: agent,
      customer: customer,
    );
    _controller.add(resolution);
    return resolution;
  }

  Future<OrderWarehouseResolution> refreshNow({
    required String agentCodeOrId,
    required String customerCodeOrId,
  }) {
    return resolveOrderWarehouse(
      agentCodeOrId: agentCodeOrId,
      customerCodeOrId: customerCodeOrId,
      forceRefresh: true,
    );
  }

  void dispose() {
    _controller.close();
  }

  AgentTerritoryAssignment _demoAgent(String codeOrId) {
    return AgentTerritoryAssignment(
      agentId: codeOrId,
      agentCode: codeOrId,
      agentName: 'Demo agent',
      regionId: 'region_tashkent',
      regionName: 'Toshkent',
      defaultWarehouseId: 'warehouse_1',
      allowedWarehouseIds: const ['warehouse_1', 'warehouse_2'],
      source: AssignmentSource.localCache,
      updatedAt: DateTime.now(),
    );
  }

  CustomerTerritoryProfile _demoCustomer(String codeOrId) {
    final id = codeOrId.toLowerCase();
    if (id.contains('sam') || id.contains('cust_1') || id.contains('cust_4')) {
      return CustomerTerritoryProfile(
        customerId: codeOrId,
        customerCode: codeOrId,
        customerName: 'Samarqand mijoz',
        regionId: 'region_samarkand',
        regionName: 'Samarqand',
        serviceWarehouseIds: const ['warehouse_3', 'warehouse_1'],
        preferredWarehouseId: 'warehouse_3',
        source: AssignmentSource.localCache,
        updatedAt: DateTime.now(),
      );
    }
    if (id.contains('bux') || id.contains('cust_2') || id.contains('cust_5')) {
      return CustomerTerritoryProfile(
        customerId: codeOrId,
        customerCode: codeOrId,
        customerName: 'Buxoro mijoz',
        regionId: 'region_bukhara',
        regionName: 'Buxoro',
        serviceWarehouseIds: const ['warehouse_1'],
        preferredWarehouseId: 'warehouse_1',
        source: AssignmentSource.localCache,
        updatedAt: DateTime.now(),
      );
    }
    return CustomerTerritoryProfile(
      customerId: codeOrId,
      customerCode: codeOrId,
      customerName: 'Toshkent mijoz',
      regionId: 'region_tashkent',
      regionName: 'Toshkent',
      serviceWarehouseIds: const ['warehouse_2', 'warehouse_1'],
      preferredWarehouseId: 'warehouse_2',
      source: AssignmentSource.localCache,
      updatedAt: DateTime.now(),
    );
  }
}
