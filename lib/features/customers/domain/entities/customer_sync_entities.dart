import 'package:equatable/equatable.dart';

// ============================================================
// MIJOZLARNI SINXRONLASH ENTITIES
// 1C va SAP dan agentga biriktirilgan mijozlarni yuklash
// ============================================================

/// Sinxronlash holati
enum SyncStatus {
  pending, // Kutilmoqda
  syncing, // Sinxronlanmoqda
  completed, // Tugadi
  failed, // Xatolik
  partial, // Qisman tugadi
}

/// Sinxronlash manbasi
enum SyncSource {
  oneC, // 1C:Enterprise
  sap, // SAP S/4HANA
  both, // Ikkalasi
}

// ============ AGENT PROFILI ============

/// Agent profili - 1C/SAP dan olingan
class AgentProfile extends Equatable {
  final String id;
  final String externalId1C; // 1C dagi ID
  final String externalIdSAP; // SAP dagi ID
  final String code; // Agent kodi (AG001)
  final String name;
  final String phone;
  final String email;
  final String? avatar;

  // Ish joyi
  final String regionId;
  final String regionName;
  final String territoryId;
  final String territoryName;
  final String warehouseId;
  final String warehouseName;

  // KPI
  final double monthlyPlan;
  final double monthlyFact;
  final double planPercentage;
  final int visitPlan;
  final int visitFact;

  // Mijozlar statistikasi
  final int totalCustomers;
  final int activeCustomers;
  final int customersWithDebt;

  // Sinxronlash
  final DateTime? lastSyncAt;
  final SyncStatus syncStatus;

  const AgentProfile({
    required this.id,
    required this.externalId1C,
    required this.externalIdSAP,
    required this.code,
    required this.name,
    required this.phone,
    required this.email,
    this.avatar,
    required this.regionId,
    required this.regionName,
    required this.territoryId,
    required this.territoryName,
    required this.warehouseId,
    required this.warehouseName,
    required this.monthlyPlan,
    required this.monthlyFact,
    required this.planPercentage,
    required this.visitPlan,
    required this.visitFact,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.customersWithDebt,
    this.lastSyncAt,
    required this.syncStatus,
  });

  bool get needsSync =>
      lastSyncAt == null || DateTime.now().difference(lastSyncAt!).inHours > 1;

  @override
  List<Object?> get props => [id, externalId1C, externalIdSAP, code];
}

// ============ MIJOZ (SINXRONLASH UCHUN) ============

/// Mijoz entity - 1C/SAP dan yuklanadigan
class SyncedCustomer extends Equatable {
  // Identifikatsiya
  final String id;
  final String externalId1C; // 1C dagi Ref_Key
  final String externalIdSAP; // SAP dagi CustomerNumber
  final String code; // Mijoz kodi (C00001)
  final String name; // Tashkilot nomi
  final String legalName; // Yuridik nomi
  final String inn; // STIR/Soliq raqami
  final String oked; // OKED kodi

  // Aloqa
  final String address;
  final String? regionId;
  final String? regionName;
  final String? districtId;
  final String? districtName;
  final String phone;
  final String? phone2;
  final String? email;
  final String? website;
  final String? contactPerson;
  final String? contactPersonPhone;

  // Geolokatsiya
  final double? latitude;
  final double? longitude;
  final String? gpsNotes; // GPS izohlari

  // Savdo
  final String agentId; // Agent ID
  final String agentCode; // Agent kodi
  final String agentName; // Agent nomi
  final String priceGroupId; // Narx guruhi ID
  final String priceGroupName; // Narx guruhi nomi
  final String paymentTerms; // To'lov shartlari
  final int paymentDelayDays; // To'lov muddati (kun)
  final double creditLimit; // Kredit limit
  final String currency; // Valyuta

  // Qarzdorlik
  final double currentDebt; // Joriy qarz
  final double overdueDebt; // Muddati o'tgan qarz
  final DateTime? lastPaymentDate;
  final double lastPaymentAmount;

  // Savdo statistikasi
  final int totalOrders; // Jami buyurtmalar
  final double totalSales; // Jami sotuv
  final DateTime? lastOrderDate;
  final double lastOrderAmount;
  final int ordersThisMonth; // Shu oyda
  final double salesThisMonth; // Shu oyda

  // Tashriflar
  final int totalVisits; // Jami tashriflar
  final DateTime? lastVisitDate;
  final int visitFrequency; // Tashrif chastotasi (kun)

  // Holat
  final bool isActive; // Faol
  final bool isBlocked; // Bloklangan
  final String? blockReason;
  final bool isVIP; // VIP mijoz
  final String customerType; // corporate, individual, government

  // Sinxronlash
  final SyncSource syncSource; // Qaysi tizimdan
  final DateTime lastSyncedAt;
  final String? syncError;

  const SyncedCustomer({
    required this.id,
    required this.externalId1C,
    required this.externalIdSAP,
    required this.code,
    required this.name,
    required this.legalName,
    required this.inn,
    required this.oked,
    required this.address,
    this.regionId,
    this.regionName,
    this.districtId,
    this.districtName,
    required this.phone,
    this.phone2,
    this.email,
    this.website,
    this.contactPerson,
    this.contactPersonPhone,
    this.latitude,
    this.longitude,
    this.gpsNotes,
    required this.agentId,
    required this.agentCode,
    required this.agentName,
    required this.priceGroupId,
    required this.priceGroupName,
    required this.paymentTerms,
    required this.paymentDelayDays,
    required this.creditLimit,
    required this.currency,
    required this.currentDebt,
    required this.overdueDebt,
    this.lastPaymentDate,
    required this.lastPaymentAmount,
    required this.totalOrders,
    required this.totalSales,
    this.lastOrderDate,
    required this.lastOrderAmount,
    required this.ordersThisMonth,
    required this.salesThisMonth,
    required this.totalVisits,
    this.lastVisitDate,
    required this.visitFrequency,
    required this.isActive,
    required this.isBlocked,
    this.blockReason,
    required this.isVIP,
    required this.customerType,
    required this.syncSource,
    required this.lastSyncedAt,
    this.syncError,
  });

  // Computed properties
  bool get canOrder => isActive && !isBlocked;
  bool get hasDebt => currentDebt > 0;
  bool get hasOverdueDebt => overdueDebt > 0;
  bool get hasLocation => latitude != null && longitude != null;
  double get availableCredit => creditLimit - currentDebt;

  bool get needsSync => DateTime.now().difference(lastSyncedAt).inHours > 1;

  // Factory: 1C dan yaratish
  factory SyncedCustomer.from1C(Map<String, dynamic> json, String agentId) {
    return SyncedCustomer(
      id: json['Ref_Key'] ?? '',
      externalId1C: json['Ref_Key'] ?? '',
      externalIdSAP: '',
      code: json['Code'] ?? '',
      name: json['Description'] ?? '',
      legalName: json['LegalName'] ?? json['Description'] ?? '',
      inn: json['INN'] ?? '',
      oked: json['OKED'] ?? '',
      address: json['Address'] ?? '',
      regionId: json['Region_Key'],
      regionName: json['Region_Description'],
      districtId: json['District_Key'],
      districtName: json['District_Description'],
      phone: json['Phone'] ?? '',
      phone2: json['Phone2'],
      email: json['Email'],
      contactPerson: json['ContactPerson'],
      latitude: json['Latitude']?.toDouble(),
      longitude: json['Longitude']?.toDouble(),
      agentId: agentId,
      agentCode: json['Agent_Code'] ?? '',
      agentName: json['Agent_Description'] ?? '',
      priceGroupId: json['PriceGroup_Key'] ?? '',
      priceGroupName: json['PriceGroup_Description'] ?? '',
      paymentTerms: json['PaymentTerms'] ?? 'NET30',
      paymentDelayDays: json['PaymentDelayDays'] ?? 30,
      creditLimit: (json['CreditLimit'] ?? 0).toDouble(),
      currency: json['Currency'] ?? 'UZS',
      currentDebt: (json['CurrentDebt'] ?? 0).toDouble(),
      overdueDebt: (json['OverdueDebt'] ?? 0).toDouble(),
      lastPaymentAmount: (json['LastPaymentAmount'] ?? 0).toDouble(),
      totalOrders: json['TotalOrders'] ?? 0,
      totalSales: (json['TotalSales'] ?? 0).toDouble(),
      lastOrderAmount: (json['LastOrderAmount'] ?? 0).toDouble(),
      ordersThisMonth: json['OrdersThisMonth'] ?? 0,
      salesThisMonth: (json['SalesThisMonth'] ?? 0).toDouble(),
      totalVisits: json['TotalVisits'] ?? 0,
      visitFrequency: json['VisitFrequency'] ?? 7,
      isActive: json['IsActive'] ?? true,
      isBlocked: json['IsBlocked'] ?? false,
      blockReason: json['BlockReason'],
      isVIP: json['IsVIP'] ?? false,
      customerType: json['CustomerType'] ?? 'corporate',
      syncSource: SyncSource.oneC,
      lastSyncedAt: DateTime.now(),
    );
  }

  // Factory: SAP dan yaratish
  factory SyncedCustomer.fromSAP(Map<String, dynamic> json, String agentId) {
    return SyncedCustomer(
      id: json['Customer'] ?? '',
      externalId1C: '',
      externalIdSAP: json['Customer'] ?? '',
      code: json['Customer'] ?? '',
      name: json['CustomerName'] ?? '',
      legalName: json['LegalName'] ?? json['CustomerName'] ?? '',
      inn: json['TaxNumber1'] ?? '',
      oked: '',
      address: '${json['Street'] ?? ''} ${json['City'] ?? ''}',
      regionId: json['Region'],
      regionName: json['RegionName'],
      phone: json['PhoneNumber'] ?? '',
      email: json['EmailAddress'],
      contactPerson: json['ContactPerson'],
      latitude: json['Latitude']?.toDouble(),
      longitude: json['Longitude']?.toDouble(),
      agentId: agentId,
      agentCode: json['SalesPerson'] ?? '',
      agentName: json['SalesPersonName'] ?? '',
      priceGroupId: json['CustomerPriceGroup'] ?? '',
      priceGroupName: json['CustomerPriceGroupName'] ?? '',
      paymentTerms: json['PaymentTerms'] ?? '',
      paymentDelayDays: json['PaymentDays'] ?? 30,
      creditLimit: (json['CreditLimit'] ?? 0).toDouble(),
      currency: json['Currency'] ?? 'UZS',
      currentDebt: (json['BalanceAmount'] ?? 0).toDouble(),
      overdueDebt: (json['OverdueAmount'] ?? 0).toDouble(),
      lastPaymentAmount: 0,
      totalOrders: json['TotalOrders'] ?? 0,
      totalSales: (json['TotalSales'] ?? 0).toDouble(),
      lastOrderAmount: 0,
      ordersThisMonth: 0,
      salesThisMonth: 0,
      totalVisits: 0,
      visitFrequency: 7,
      isActive: json['IsMarkedForDeletion'] != true,
      isBlocked: json['IsBlocked'] ?? false,
      isVIP: false,
      customerType: 'corporate',
      syncSource: SyncSource.sap,
      lastSyncedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, externalId1C, externalIdSAP, code, agentId];
}

// ============ SINXRONLASH NATIJASI ============

/// Sinxronlash natijasi
class CustomerSyncResult extends Equatable {
  final SyncSource source;
  final SyncStatus status;
  final int totalCustomers;
  final int newCustomers;
  final int updatedCustomers;
  final int unchangedCustomers;
  final int failedCustomers;
  final List<CustomerSyncError> errors;
  final DateTime startedAt;
  final DateTime completedAt;
  final Duration duration;

  const CustomerSyncResult({
    required this.source,
    required this.status,
    required this.totalCustomers,
    required this.newCustomers,
    required this.updatedCustomers,
    required this.unchangedCustomers,
    required this.failedCustomers,
    required this.errors,
    required this.startedAt,
    required this.completedAt,
    required this.duration,
  });

  bool get isSuccess => status == SyncStatus.completed && failedCustomers == 0;
  bool get hasErrors => failedCustomers > 0;

  @override
  List<Object?> get props => [source, status, totalCustomers];
}

/// Sinxronlash xatoligi
class CustomerSyncError extends Equatable {
  final String customerId;
  final String customerCode;
  final String customerName;
  final SyncSource source;
  final int errorCode;
  final String errorMessage;

  const CustomerSyncError({
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.source,
    required this.errorCode,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [customerId, source, errorCode];
}
