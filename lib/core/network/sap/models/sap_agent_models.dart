// ============================================================
// SAP S/4HANA - AGENT (SALES PERSON/PERSONNEL) MODELS
// Haqiqiy SAP OData API ga mos
// ============================================================

/// SAP Sales Person (Agent) - to'liq tuzilma
///
/// SAP da agentlar "Personnel Master" yoki "Sales Employee" da saqlanadi
/// API: /sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder (SalesPerson field)
class SAPAgent {
  final String personnelNumber; // Personnel Number (00000001)
  final String firstName; // First Name
  final String lastName; // Last Name
  final String fullName; // Full Name
  final String? middleName; // Middle Name

  // ============ ШАХСИЙ МАЪЛУМОТЛАР ============
  final String? birthDate; // Date of Birth
  final String? gender; // Gender (M, F)
  final String? nationality; // Nationality
  final String? maritalStatus; // Marital Status

  // ============ АЛОКА (CONTACTS) ============
  final String? phoneNumber; // Phone Number
  final String? mobilePhone; // Mobile Phone
  final String? emailAddress; // Email Address
  final String? address; // Home Address

  // ============ ОРГАНИЗАЦИЯ (ORGANIZATION) ============
  final String companyCode; // Company Code
  final String companyName; // Company Name
  final String personnelArea; // Personnel Area
  final String personnelAreaName; // Personnel Area Name
  final String personnelSubarea; // Personnel Subarea
  final String personnelSubareaName; // Personnel Subarea Name
  final String organizationalUnit; // Organizational Unit
  final String organizationalUnitName; // Org Unit Name
  final String costCenter; // Cost Center
  final String costCenterName; // Cost Center Name

  // ============ ЛАВОЗИМ (POSITION) ============
  final String position; // Position
  final String positionName; // Position Name
  final String job; // Job
  final String jobName; // Job Name
  final String employeeGroup; // Employee Group
  final String employeeGroupName; // Employee Group Name
  final String employeeSubgroup; // Employee Subgroup
  final String employeeSubgroupName; // Employee Subgroup Name

  // ============ СОТУВ (SALES) ============
  final String salesOrganization; // Sales Organization
  final String salesOrganizationName; // Sales Org Name
  final String distributionChannel; // Distribution Channel
  final String distributionChannelName; // Dist Channel Name
  final String division; // Division
  final String divisionName; // Division Name
  final String salesOffice; // Sales Office
  final String salesOfficeName; // Sales Office Name
  final String salesGroup; // Sales Group
  final String salesGroupName; // Sales Group Name
  final String salesDistrict; // Sales District
  final String salesDistrictName; // Sales District Name
  final String salesTerritory; // Sales Territory
  final String salesTerritoryName; // Sales Territory Name

  // ============ ХУДУД (TERRITORY) ============
  final String region; // Region
  final String regionName; // Region Name
  final List<String> assignedRegions; // Assigned Regions
  final String? warehouse; // Default Warehouse
  final String? warehouseName; // Warehouse Name

  // ============ СУПЕРВАЙЗЕР ============
  final String? supervisorId; // Supervisor ID
  final String? supervisorName; // Supervisor Name

  // ============ ИШ ВАҚТИ (WORK SCHEDULE) ============
  final String workStartTime; // Work Start Time
  final String workEndTime; // Work End Time
  final List<String> workDays; // Work Days
  final int maxWorkHoursPerDay; // Max Hours Per Day
  final int breakDuration; // Break Duration (minutes)

  // ============ КПИ ============
  final double monthlyTarget; // Monthly Sales Target
  final double monthlyActual; // Monthly Sales Actual
  final double targetAchievement; // Target Achievement %
  final int visitTarget; // Visit Target
  final int visitActual; // Visit Actual
  final double collectionTarget; // Collection Target
  final double collectionActual; // Collection Actual
  final double rating; // Performance Rating (1-5)

  // ============ СТАТИСТИКА ============
  final int totalOrders; // Total Orders
  final double totalSales; // Total Sales
  final int totalCustomers; // Total Customers
  final int totalVisits; // Total Visits
  final double totalCollections; // Total Collections
  final DateTime? lastOrderDate; // Last Order Date
  final DateTime? lastVisitDate; // Last Visit Date

  // ============ ХОЛАТ (STATUS) ============
  final bool isActive; // Active
  final bool isBlocked; // Blocked
  final String? blockReason; // Block Reason
  final bool isOnline; // Online Status
  final String currentStatus; // Current Status
  final double? currentLatitude; // Current Latitude
  final double? currentLongitude; // Current Longitude
  final DateTime? lastLocationUpdate; // Last Location Update

  // ============ ВАКТ (DATES) ============
  final DateTime? hireDate; // Hire Date
  final DateTime? terminationDate; // Termination Date
  final DateTime? createdAt; // Created At
  final DateTime? lastChangedAt; // Last Changed At

  const SAPAgent({
    required this.personnelNumber,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.middleName,
    this.birthDate,
    this.gender,
    this.nationality,
    this.maritalStatus,
    this.phoneNumber,
    this.mobilePhone,
    this.emailAddress,
    this.address,
    required this.companyCode,
    required this.companyName,
    required this.personnelArea,
    required this.personnelAreaName,
    required this.personnelSubarea,
    required this.personnelSubareaName,
    required this.organizationalUnit,
    required this.organizationalUnitName,
    required this.costCenter,
    required this.costCenterName,
    required this.position,
    required this.positionName,
    required this.job,
    required this.jobName,
    required this.employeeGroup,
    required this.employeeGroupName,
    required this.employeeSubgroup,
    required this.employeeSubgroupName,
    required this.salesOrganization,
    required this.salesOrganizationName,
    required this.distributionChannel,
    required this.distributionChannelName,
    required this.division,
    required this.divisionName,
    required this.salesOffice,
    required this.salesOfficeName,
    required this.salesGroup,
    required this.salesGroupName,
    required this.salesDistrict,
    required this.salesDistrictName,
    required this.salesTerritory,
    required this.salesTerritoryName,
    required this.region,
    required this.regionName,
    required this.assignedRegions,
    this.warehouse,
    this.warehouseName,
    this.supervisorId,
    this.supervisorName,
    required this.workStartTime,
    required this.workEndTime,
    required this.workDays,
    required this.maxWorkHoursPerDay,
    required this.breakDuration,
    required this.monthlyTarget,
    required this.monthlyActual,
    required this.targetAchievement,
    required this.visitTarget,
    required this.visitActual,
    required this.collectionTarget,
    required this.collectionActual,
    required this.rating,
    required this.totalOrders,
    required this.totalSales,
    required this.totalCustomers,
    required this.totalVisits,
    required this.totalCollections,
    this.lastOrderDate,
    this.lastVisitDate,
    required this.isActive,
    required this.isBlocked,
    this.blockReason,
    required this.isOnline,
    required this.currentStatus,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationUpdate,
    this.hireDate,
    this.terminationDate,
    this.createdAt,
    this.lastChangedAt,
  });

  bool get canWork => isActive && !isBlocked;
  bool get hasLocation => currentLatitude != null && currentLongitude != null;

  /// SAP JSON dan yaratish
  factory SAPAgent.fromJson(Map<String, dynamic> json) {
    return SAPAgent(
      personnelNumber: json['PersonnelNumber'] ?? json['EmployeeID'] ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      fullName: json['FullName'] ??
          '${json['FirstName'] ?? ''} ${json['LastName'] ?? ''}'.trim(),
      middleName: json['MiddleName'],
      birthDate: json['DateOfBirth'],
      gender: json['Gender'],
      nationality: json['Nationality'],
      maritalStatus: json['MaritalStatus'],
      phoneNumber: json['PhoneNumber'],
      mobilePhone: json['MobilePhone'],
      emailAddress: json['EmailAddress'] ?? json['EMailAddress'],
      address: json['HomeAddress'],
      companyCode: json['CompanyCode'] ?? '',
      companyName: json['CompanyCodeName'] ?? '',
      personnelArea: json['PersonnelArea'] ?? '',
      personnelAreaName: json['PersonnelAreaName'] ?? '',
      personnelSubarea: json['PersonnelSubarea'] ?? '',
      personnelSubareaName: json['PersonnelSubareaName'] ?? '',
      organizationalUnit: json['OrganizationalUnit'] ?? '',
      organizationalUnitName: json['OrganizationalUnitName'] ?? '',
      costCenter: json['CostCenter'] ?? '',
      costCenterName: json['CostCenterName'] ?? '',
      position: json['Position'] ?? '',
      positionName: json['PositionName'] ?? '',
      job: json['Job'] ?? '',
      jobName: json['JobName'] ?? '',
      employeeGroup: json['EmployeeGroup'] ?? '',
      employeeGroupName: json['EmployeeGroupName'] ?? '',
      employeeSubgroup: json['EmployeeSubgroup'] ?? '',
      employeeSubgroupName: json['EmployeeSubgroupName'] ?? '',
      salesOrganization: json['SalesOrganization'] ?? '',
      salesOrganizationName: json['SalesOrganizationName'] ?? '',
      distributionChannel: json['DistributionChannel'] ?? '',
      distributionChannelName: json['DistributionChannelName'] ?? '',
      division: json['Division'] ?? '',
      divisionName: json['DivisionName'] ?? '',
      salesOffice: json['SalesOffice'] ?? '',
      salesOfficeName: json['SalesOfficeName'] ?? '',
      salesGroup: json['SalesGroup'] ?? '',
      salesGroupName: json['SalesGroupName'] ?? '',
      salesDistrict: json['SalesDistrict'] ?? '',
      salesDistrictName: json['SalesDistrictName'] ?? '',
      salesTerritory: json['SalesTerritory'] ?? '',
      salesTerritoryName: json['SalesTerritoryName'] ?? '',
      region: json['Region'] ?? '',
      regionName: json['RegionName'] ?? '',
      assignedRegions: (json['AssignedRegions'] as List?)?.cast<String>() ?? [],
      warehouse: json['Warehouse'],
      warehouseName: json['WarehouseName'],
      supervisorId: json['SupervisorID'],
      supervisorName: json['SupervisorName'],
      workStartTime: json['WorkStartTime'] ?? '08:00',
      workEndTime: json['WorkEndTime'] ?? '18:00',
      workDays: (json['WorkDays'] as List?)?.cast<String>() ??
          ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'],
      maxWorkHoursPerDay: json['MaxWorkHoursPerDay'] ?? 8,
      breakDuration: json['BreakDuration'] ?? 60,
      monthlyTarget: (json['MonthlyTarget'] ?? 0).toDouble(),
      monthlyActual: (json['MonthlyActual'] ?? 0).toDouble(),
      targetAchievement: (json['TargetAchievement'] ?? 0).toDouble(),
      visitTarget: json['VisitTarget'] ?? 0,
      visitActual: json['VisitActual'] ?? 0,
      collectionTarget: (json['CollectionTarget'] ?? 0).toDouble(),
      collectionActual: (json['CollectionActual'] ?? 0).toDouble(),
      rating: (json['Rating'] ?? 0).toDouble(),
      totalOrders: json['TotalOrders'] ?? 0,
      totalSales: (json['TotalSales'] ?? 0).toDouble(),
      totalCustomers: json['TotalCustomers'] ?? 0,
      totalVisits: json['TotalVisits'] ?? 0,
      totalCollections: (json['TotalCollections'] ?? 0).toDouble(),
      lastOrderDate: json['LastOrderDate'] != null
          ? DateTime.parse(json['LastOrderDate'])
          : null,
      lastVisitDate: json['LastVisitDate'] != null
          ? DateTime.parse(json['LastVisitDate'])
          : null,
      isActive: json['IsActive'] ?? !(json['IsBlocked'] ?? false),
      isBlocked: json['IsBlocked'] ?? false,
      blockReason: json['BlockReason'],
      isOnline: json['IsOnline'] ?? false,
      currentStatus: json['CurrentStatus'] ?? 'offline',
      currentLatitude: json['CurrentLatitude']?.toDouble(),
      currentLongitude: json['CurrentLongitude']?.toDouble(),
      lastLocationUpdate: json['LastLocationUpdate'] != null
          ? DateTime.parse(json['LastLocationUpdate'])
          : null,
      hireDate:
          json['HireDate'] != null ? DateTime.parse(json['HireDate']) : null,
      terminationDate: json['TerminationDate'] != null
          ? DateTime.parse(json['TerminationDate'])
          : null,
      createdAt: json['CreationDate'] != null
          ? DateTime.parse(json['CreationDate'])
          : null,
      lastChangedAt: json['LastChangeDate'] != null
          ? DateTime.parse(json['LastChangeDate'])
          : null,
    );
  }
}
