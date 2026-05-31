import '../../domain/entities/customer_sync_entities.dart';

class AgentProfileMapper {
  static AgentProfile fromJson(Map<String, dynamic> json) {
    return AgentProfile(
      id: json['id'] ?? '',
      externalId1C: json['externalId1C'],
      externalIdSAP: json['externalIdSAP'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      regionId: json['regionId'] ?? '',
      regionName: json['regionName'] ?? '',
      territoryId: json['territoryId'],
      territoryName: json['territoryName'],
      warehouseId: json['warehouseId'] ?? '',
      warehouseName: json['warehouseName'] ?? '',
      monthlyPlan: json['monthlyPlan']?.toDouble() ?? 0.0,
      monthlyFact: json['monthlyFact']?.toDouble() ?? 0.0,
      planPercentage: json['planPercentage']?.toDouble() ?? 0.0,
      visitPlan: json['visitPlan'] ?? 0,
      visitFact: json['visitFact'] ?? 0,
      totalCustomers: json['totalCustomers'] ?? 0,
      activeCustomers: json['activeCustomers'] ?? 0,
      customersWithDebt: json['customersWithDebt'] ?? 0,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'])
          : DateTime.now(),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString() == 'SyncStatus.${json['syncStatus']}',
        orElse: () => SyncStatus.completed,
      ),
    );
  }
}

class SyncedCustomerMapper {
  static SyncedCustomer fromJson(Map<String, dynamic> json) {
    return SyncedCustomer(
      id: json['id'] ?? '',
      externalId1C: json['externalId1C'] ?? '',
      externalIdSAP: json['externalIdSAP'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      legalName: json['legalName'] ?? '',
      inn: json['inn'] ?? '',
      oked: json['oked'] ?? '',
      address: json['address'] ?? '',
      regionId: json['regionId'],
      regionName: json['regionName'],
      districtId: json['districtId'],
      districtName: json['districtName'],
      phone: json['phone'] ?? '',
      phone2: json['phone2'],
      email: json['email'],
      website: json['website'],
      contactPerson: json['contactPerson'],
      contactPersonPhone: json['contactPersonPhone'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      gpsNotes: json['gpsNotes'],
      agentId: json['agentId'] ?? '',
      agentCode: json['agentCode'] ?? '',
      agentName: json['agentName'] ?? '',
      priceGroupId: json['priceGroupId'] ?? '',
      priceGroupName: json['priceGroupName'] ?? '',
      paymentTerms: json['paymentTerms'] ?? '',
      paymentDelayDays: json['paymentDelayDays'] ?? 0,
      creditLimit: json['creditLimit']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'UZS',
      currentDebt: json['currentDebt']?.toDouble() ?? 0.0,
      overdueDebt: json['overdueDebt']?.toDouble() ?? 0.0,
      lastPaymentDate: json['lastPaymentDate'] != null
          ? DateTime.parse(json['lastPaymentDate'])
          : null,
      lastPaymentAmount: json['lastPaymentAmount']?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] ?? 0,
      totalSales: json['totalSales']?.toDouble() ?? 0.0,
      lastOrderDate: json['lastOrderDate'] != null
          ? DateTime.parse(json['lastOrderDate'])
          : null,
      lastOrderAmount: json['lastOrderAmount']?.toDouble() ?? 0.0,
      ordersThisMonth: json['ordersThisMonth'] ?? 0,
      salesThisMonth: json['salesThisMonth']?.toDouble() ?? 0.0,
      totalVisits: json['totalVisits'] ?? 0,
      lastVisitDate: json['lastVisitDate'] != null
          ? DateTime.parse(json['lastVisitDate'])
          : null,
      visitFrequency: json['visitFrequency'] ?? 0,
      isActive: json['isActive'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
      blockReason: json['blockReason'],
      isVIP: json['isVIP'] ?? false,
      customerType: json['customerType'] ?? 'corporate',
      syncSource: SyncSource.values.firstWhere(
        (e) => e.toString() == 'SyncSource.${json['syncSource']}',
        orElse: () => SyncSource.oneC,
      ),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : DateTime.now(),
      syncError: json['syncError'],
    );
  }

  static Map<String, dynamic> toJson(SyncedCustomer c) {
    return {
      'id': c.id,
      'externalId1C': c.externalId1C,
      'externalIdSAP': c.externalIdSAP,
      'code': c.code,
      'name': c.name,
      'legalName': c.legalName,
      'inn': c.inn,
      'oked': c.oked,
      'address': c.address,
      'regionId': c.regionId,
      'regionName': c.regionName,
      'districtId': c.districtId,
      'districtName': c.districtName,
      'phone': c.phone,
      'phone2': c.phone2,
      'email': c.email,
      'website': c.website,
      'contactPerson': c.contactPerson,
      'contactPersonPhone': c.contactPersonPhone,
      'latitude': c.latitude,
      'longitude': c.longitude,
      'gpsNotes': c.gpsNotes,
      'agentId': c.agentId,
      'agentCode': c.agentCode,
      'agentName': c.agentName,
      'priceGroupId': c.priceGroupId,
      'priceGroupName': c.priceGroupName,
      'paymentTerms': c.paymentTerms,
      'paymentDelayDays': c.paymentDelayDays,
      'creditLimit': c.creditLimit,
      'currency': c.currency,
      'currentDebt': c.currentDebt,
      'overdueDebt': c.overdueDebt,
      'lastPaymentDate': c.lastPaymentDate?.toIso8601String(),
      'lastPaymentAmount': c.lastPaymentAmount,
      'totalOrders': c.totalOrders,
      'totalSales': c.totalSales,
      'lastOrderDate': c.lastOrderDate?.toIso8601String(),
      'lastOrderAmount': c.lastOrderAmount,
      'ordersThisMonth': c.ordersThisMonth,
      'salesThisMonth': c.salesThisMonth,
      'totalVisits': c.totalVisits,
      'lastVisitDate': c.lastVisitDate?.toIso8601String(),
      'visitFrequency': c.visitFrequency,
      'isActive': c.isActive,
      'isBlocked': c.isBlocked,
      'blockReason': c.blockReason,
      'isVIP': c.isVIP,
      'customerType': c.customerType,
      'syncSource': c.syncSource.name,
      'lastSyncedAt': c.lastSyncedAt.toIso8601String(),
      'syncError': c.syncError,
    };
  }
}
