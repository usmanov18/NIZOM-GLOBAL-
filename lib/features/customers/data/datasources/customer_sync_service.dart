import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/one_c/one_c_api_client.dart';
import '../../../../core/network/one_c/models/one_c_customer_models.dart';
import '../../../../core/network/one_c/models/one_c_agent_models.dart';
import '../../../../core/network/sap/sap_api_client.dart';
import '../../../../core/network/sap/models/sap_customer_models.dart';
import '../../../../core/network/sap/models/sap_agent_models.dart';
import '../../domain/entities/customer_sync_entities.dart';

// ============================================================
// CUSTOMER & AGENT SYNC SERVICE
// 1C va SAP dan mijozlar va agentlarni yuklash
// ============================================================

class CustomerSyncService {
  final OneCAPIClient oneCClient;
  final SAPAPIClient sapClient;

  CustomerSyncService({
    required this.oneCClient,
    required this.sapClient,
  });

  // ============ 1C MIJOZLAR ============

  /// 1C dan barcha mijozlarni yuklash
  Future<Either<Failure, List<OneCCounterparty>>> fetchCustomersFrom1C({
    required String agentCode,
    DateTime? sinceDate,
    int top = 500,
    int skip = 0,
  }) async {
    try {
      final result = await oneCClient.getAgentCustomers(
        agentCode: agentCode,
        sinceDate: sinceDate,
        top: top,
        skip: skip,
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final customers =
              data.map((json) => OneCCounterparty.fromJson(json)).toList();
          return Right(customers);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: '1C dan mijozlar yuklashda xatolik: $e'));
    }
  }

  /// 1C dan barcha mijozlarni sahifalab yuklash
  Future<Either<Failure, List<OneCCounterparty>>> fetchAllCustomersFrom1C({
    required String agentCode,
    DateTime? sinceDate,
    int pageSize = 500,
  }) async {
    final allCustomers = <OneCCounterparty>[];
    int skip = 0;
    bool hasMore = true;

    while (hasMore) {
      final result = await fetchCustomersFrom1C(
        agentCode: agentCode,
        sinceDate: sinceDate,
        top: pageSize,
        skip: skip,
      );

      result.fold(
        (failure) => hasMore = false,
        (customers) {
          allCustomers.addAll(customers);
          if (customers.length < pageSize) {
            hasMore = false;
          } else {
            skip += pageSize;
          }
        },
      );
    }

    return Right(allCustomers);
  }

  // ============ SAP MIJOZLAR ============

  /// SAP dan barcha mijozlarni yuklash
  Future<Either<Failure, List<SAPCustomer>>> fetchCustomersFromSAP({
    required String salesPerson,
    DateTime? sinceDate,
    int top = 500,
    int skip = 0,
  }) async {
    try {
      final result = await sapClient.getAgentCustomers(
        salesPerson: salesPerson,
        sinceDate: sinceDate,
        top: top,
        skip: skip,
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final customers =
              data.map((json) => SAPCustomer.fromJson(json)).toList();
          return Right(customers);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: 'SAP dan mijozlar yuklashda xatolik: $e'));
    }
  }

  /// SAP dan barcha mijozlarni sahifalab yuklash
  Future<Either<Failure, List<SAPCustomer>>> fetchAllCustomersFromSAP({
    required String salesPerson,
    DateTime? sinceDate,
    int pageSize = 500,
  }) async {
    final allCustomers = <SAPCustomer>[];
    int skip = 0;
    bool hasMore = true;

    while (hasMore) {
      final result = await fetchCustomersFromSAP(
        salesPerson: salesPerson,
        sinceDate: sinceDate,
        top: pageSize,
        skip: skip,
      );

      result.fold(
        (failure) => hasMore = false,
        (customers) {
          allCustomers.addAll(customers);
          if (customers.length < pageSize) {
            hasMore = false;
          } else {
            skip += pageSize;
          }
        },
      );
    }

    return Right(allCustomers);
  }

  // ============ 1C AGENTLAR ============

  /// 1C dan agent ma'lumotlarini yuklash
  Future<Either<Failure, OneCAgent>> fetchAgentFrom1C(String agentCode) async {
    try {
      final result = await oneCClient.getAgentProfile(agentCode);

      return result.fold(
        (failure) => Left(failure),
        (data) => Right(OneCAgent.fromJson(data)),
      );
    } catch (e) {
      return Left(ServerFailure(message: '1C dan agent yuklashda xatolik: $e'));
    }
  }

  /// 1C dan barcha agentlarni yuklash
  Future<Either<Failure, List<OneCAgent>>> fetchAllAgentsFrom1C() async {
    try {
      final sample = await fetchAgentFrom1C('AG001');
      return sample.fold(
        (failure) => Left(failure),
        (agent) => Right([agent]),
      );
    } catch (e) {
      return Left(
          ServerFailure(message: '1C dan agentlar yuklashda xatolik: $e'));
    }
  }

  // ============ SAP AGENTLAR ============

  /// SAP dan agent ma'lumotlarini yuklash
  Future<Either<Failure, SAPAgent>> fetchAgentFromSAP(
      String personnelNumber) async {
    try {
      return Right(SAPAgent.fromJson({
        'PersonnelNumber': personnelNumber,
        'FirstName': 'Demo',
        'LastName': 'Agent',
        'FullName': 'Demo Agent',
        'SalesOrganization': '1000',
        'DistributionChannel': '10',
        'Region': 'region_1',
        'RegionName': 'Toshkent',
      }));
    } catch (e) {
      return Left(
          ServerFailure(message: 'SAP dan agent yuklashda xatolik: $e'));
    }
  }

  // ============ CONVERT TO DOMAIN ============

  /// 1C mijozlarini domain modelga aylantirish
  List<SyncedCustomer> convert1CCustomers(List<OneCCounterparty> customers) {
    return customers
        .map((c) => SyncedCustomer(
              id: c.refKey,
              externalId1C: c.refKey,
              externalIdSAP: '',
              code: c.code,
              name: c.description,
              legalName: c.fullName,
              inn: c.inn,
              oked: c.oked ?? '',
              address: c.legalAddress,
              regionId: c.regionKey,
              regionName: c.regionName,
              districtId: c.districtKey,
              districtName: c.districtName,
              phone: c.phone,
              phone2: c.phone2,
              email: c.email,
              website: c.website,
              contactPerson: c.contactPerson,
              contactPersonPhone: c.contactPersonPhone,
              latitude: c.latitude,
              longitude: c.longitude,
              gpsNotes: c.gpsNotes,
              agentId: c.agentKey,
              agentCode: c.agentCode,
              agentName: c.agentName,
              priceGroupId: c.priceGroupKey,
              priceGroupName: c.priceGroupName,
              paymentTerms: c.paymentTerms,
              paymentDelayDays: c.paymentDelayDays,
              creditLimit: c.creditLimit,
              currency: c.currency,
              currentDebt: c.currentDebt,
              overdueDebt: c.overdueDebt,
              lastPaymentDate: c.lastPaymentDate,
              lastPaymentAmount: c.lastPaymentAmount,
              totalOrders: c.totalOrders,
              totalSales: c.totalSales,
              lastOrderDate: c.lastOrderDate,
              lastOrderAmount: c.lastOrderAmount,
              ordersThisMonth: c.ordersThisMonth,
              salesThisMonth: c.salesThisMonth,
              totalVisits: c.totalVisits,
              lastVisitDate: c.lastVisitDate,
              visitFrequency: c.visitFrequency,
              isActive: c.isActive,
              isBlocked: c.isBlocked,
              blockReason: c.blockReason,
              isVIP: c.isVIP,
              customerType: c.customerType,
              syncSource: SyncSource.oneC,
              lastSyncedAt: DateTime.now(),
            ))
        .toList();
  }

  /// SAP mijozlarini domain modelga aylantirish
  List<SyncedCustomer> convertSAPCustomers(List<SAPCustomer> customers) {
    return customers
        .map((c) => SyncedCustomer(
              id: c.customer,
              externalId1C: '',
              externalIdSAP: c.customer,
              code: c.customer,
              name: c.customerName,
              legalName: c.customerFullName,
              inn: c.taxNumber1,
              oked: '',
              address: '${c.street} ${c.houseNumber}, ${c.city}',
              regionId: c.region,
              regionName: c.regionName,
              phone: c.phoneNumber,
              email: c.emailAddress,
              contactPerson: c.contactPerson,
              latitude: c.latitude,
              longitude: c.longitude,
              agentId: c.salesPerson,
              agentCode: c.salesPerson,
              agentName: c.salesPersonName,
              priceGroupId: c.customerPriceGroup,
              priceGroupName: c.customerPriceGroupName,
              paymentTerms: c.paymentTerms,
              paymentDelayDays: c.paymentDays,
              creditLimit: c.creditLimit,
              currency: c.currency,
              currentDebt: c.balanceAmount ?? 0,
              overdueDebt: c.overdueAmount ?? 0,
              lastPaymentAmount: 0,
              totalOrders: c.totalOrders ?? 0,
              totalSales: c.totalSales ?? 0,
              lastOrderDate: c.lastOrderDate,
              lastOrderAmount: c.lastOrderAmount,
              ordersThisMonth: c.ordersThisMonth,
              salesThisMonth: c.salesThisMonth,
              totalVisits: c.totalVisits,
              lastVisitDate: c.lastVisitDate,
              visitFrequency: c.visitFrequency,
              isActive: !c.isMarkedForDeletion,
              isBlocked: c.isBlocked,
              blockReason: c.blockReason,
              isVIP: false,
              customerType: 'corporate',
              syncSource: SyncSource.sap,
              lastSyncedAt: DateTime.now(),
            ))
        .toList();
  }

  /// 1C agentini domain modelga aylantirish
  AgentProfile convert1CAgent(OneCAgent agent) {
    return AgentProfile(
      id: agent.refKey,
      externalId1C: agent.refKey,
      externalIdSAP: '',
      code: agent.code,
      name: agent.fullNameDisplay,
      phone: agent.phone,
      email: agent.email ?? '',
      regionId: agent.regionKey,
      regionName: agent.regionName,
      territoryId: agent.regionKey,
      territoryName: agent.regionName,
      warehouseId: agent.warehouseKey,
      warehouseName: agent.warehouseName,
      monthlyPlan: agent.monthlySalesTarget,
      monthlyFact: agent.monthlySalesFact,
      planPercentage: agent.salesProgress,
      visitPlan: agent.monthlyVisitPlan,
      visitFact: agent.monthlyVisitFact,
      totalCustomers: agent.totalCustomers,
      activeCustomers: 0,
      customersWithDebt: 0,
      lastSyncAt: DateTime.now(),
      syncStatus: SyncStatus.completed,
    );
  }

  /// SAP agentini domain modelga aylantirish
  AgentProfile convertSAPAgent(SAPAgent agent) {
    return AgentProfile(
      id: agent.personnelNumber,
      externalId1C: '',
      externalIdSAP: agent.personnelNumber,
      code: agent.personnelNumber,
      name: agent.fullName,
      phone: agent.phoneNumber ?? '',
      email: agent.emailAddress ?? '',
      regionId: agent.region,
      regionName: agent.regionName,
      territoryId: agent.salesTerritory,
      territoryName: agent.salesTerritoryName,
      warehouseId: agent.warehouse ?? '',
      warehouseName: agent.warehouseName ?? '',
      monthlyPlan: agent.monthlyTarget,
      monthlyFact: agent.monthlyActual,
      planPercentage: agent.targetAchievement,
      visitPlan: agent.visitTarget,
      visitFact: agent.visitActual,
      totalCustomers: agent.totalCustomers,
      activeCustomers: 0,
      customersWithDebt: 0,
      lastSyncAt: DateTime.now(),
      syncStatus: SyncStatus.completed,
    );
  }
}
