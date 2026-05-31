// ============================================================
// SAP S/4HANA - MIJOZ (BUSINESS PARTNER/CUSTOMER) MODELS
// Haqiqiy SAP OData API ga mos
// ============================================================

/// SAP Business Partner / Customer - to'liq tuzilma
///
/// SAP da mijozlar "Business Partner" da saqlanadi
/// API: /sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer
class SAPCustomer {
  final String customer; // Customer Number (0000100001)
  final String customerName; // Customer Name (Name 1)
  final String customerName2; // Customer Name 2
  final String customerFullName; // Full Name

  // ============ КЛАССИФИКАЦИЯ (TASNIFLASH) ============
  final String accountGroup; // Account Group (KUNA, KUNB, KUNN)
  final String accountGroupName; // Account Group Name
  final String customerClassification; // Customer Classification
  final String industryCode; // Industry Code
  final String industryCodeName; // Industry Code Name

  // ============ НОМИ / МАНЗИЛ (NAME/ADDRESS) ============
  final String organizationBPName1; // Organization Name 1
  final String organizationBPName2; // Organization Name 2
  final String organizationBPName3; // Organization Name 3
  final String organizationBPName4; // Organization Name 4
  final String searchTerm1; // Search Term 1
  final String searchTerm2; // Search Term 2

  // ============ МАНЗИЛ (ADDRESS) ============
  final String street; // Street
  final String streetName; // Street Name
  final String houseNumber; // House Number
  final String city; // City
  final String cityCode; // City Code
  final String postalCode; // Postal Code
  final String district; // District
  final String region; // Region (State)
  final String regionName; // Region Name
  final String country; // Country
  final String countryName; // Country Name
  final String timeZone; // Time Zone
  final String addressNotes; // Address Notes

  // ============ ГЕОЛОКАЦИЯ ============
  final double? latitude; // Latitude
  final double? longitude; // Longitude

  // ============ ТЕЛЕФОН / EMAIL (CONTACTS) ============
  final String phoneNumber; // Phone Number
  final String? phoneNumberExtension; // Phone Extension
  final String? mobilePhone; // Mobile Phone
  final String? faxNumber; // Fax Number
  final String? emailAddress; // Email Address
  final String? websiteUrl; // Website URL

  // ============ КОНТАКТНОЕ ЛИЦО ============
  final String? contactPerson; // Contact Person
  final String? contactPersonFunction; // Function
  final String? contactPersonDepartment; // Department
  final String? contactPersonPhone; // Contact Phone
  final String? contactPersonEmail; // Contact Email

  // ============ СОЛИҚ (TAX) ============
  final String taxNumber1; // Tax Number 1 (INN/STIR)
  final String taxNumber2; // Tax Number 2
  final String taxNumberType; // Tax Number Type
  final String vatRegistrationNumber; // VAT Registration
  final bool isTaxExempt; // Tax Exempt
  final String? taxExemptReason; // Tax Exempt Reason

  // ============ САВДО (SALES) ============
  final String salesOrganization; // Sales Organization
  final String salesOrganizationName; // Sales Org Name
  final String distributionChannel; // Distribution Channel
  final String distributionChannelName; // Dist Channel Name
  final String division; // Division
  final String divisionName; // Division Name
  final String salesDistrict; // Sales District
  final String salesDistrictName; // Sales District Name
  final String salesOffice; // Sales Office
  final String salesOfficeName; // Sales Office Name
  final String salesGroup; // Sales Group
  final String salesGroupName; // Sales Group Name
  final String salesPerson; // Sales Person (Agent)
  final String salesPersonName; // Sales Person Name
  final String customerPriceGroup; // Customer Price Group
  final String customerPriceGroupName; // Price Group Name
  final String pricingProcedure; // Pricing Procedure

  // ============ ТУЛОВ (PAYMENT) ============
  final String paymentTerms; // Payment Terms
  final String paymentTermsDescription; // Payment Terms Description
  final int paymentDays; // Payment Days
  final String paymentMethod; // Payment Method
  final String dunningProcedure; // Dunning Procedure
  final String creditControlArea; // Credit Control Area
  final double creditLimit; // Credit Limit
  final double creditExposure; // Credit Exposure
  final String currency; // Currency
  final String reconciliationAccount; // Reconciliation Account

  // ============ БАНК (BANK) ============
  final String? bankKey; // Bank Key
  final String? bankName; // Bank Name
  final String? bankAccount; // Bank Account
  final String? bankAccountHolder; // Account Holder
  final String? iban; // IBAN
  final String? swiftCode; // SWIFT Code

  // ============ КАРЗ (DEBT) ============
  final double balanceAmount; // Balance Amount
  final double overdueAmount; // Overdue Amount
  final double specialBalance; // Special GL Balance
  final DateTime? lastPaymentDate; // Last Payment Date
  final double lastPaymentAmount; // Last Payment Amount
  final int dunningLevel; // Dunning Level
  final DateTime? dunningDate; // Dunning Date

  // ============ САВДО СТАТИСТИКАСИ ============
  final int totalOrders; // Total Orders
  final double totalSales; // Total Sales
  final int ordersThisMonth; // Orders This Month
  final double salesThisMonth; // Sales This Month
  final double averageOrderValue; // Average Order Value
  final DateTime? lastOrderDate; // Last Order Date
  final double lastOrderAmount; // Last Order Amount

  // ============ ТАШРИФЛАР ============
  final int totalVisits; // Total Visits
  final DateTime? lastVisitDate; // Last Visit Date
  final int visitFrequency; // Visit Frequency (days)

  // ============ ШАРТЛАР (CONDITIONS) ============
  final String? deliveryPriority; // Delivery Priority
  final String? shippingCondition; // Shipping Condition
  final String? deliveringPlant; // Delivering Plant
  final String? deliveringPlantName; // Plant Name
  final String? transportationZone; // Transportation Zone
  final String? incoterms; // Incoterms
  final String? incotermsLocation; // Incoterms Location
  final bool partialDeliveryAllowed; // Partial Delivery
  final double? maximumPartialDeliveries; // Max Partial Deliveries

  // ============ ХОЛАТ (STATUS) ============
  final bool isMarkedForDeletion; // Deletion Flag
  final bool isBlocked; // Blocked
  final String? blockReason; // Block Reason
  final bool isCentralDeletionBlock; // Central Deletion Block
  final bool isPostingBlock; // Posting Block
  final String customerStatus; // Customer Status

  // ============ ВАКТ (DATES) ============
  final DateTime? createdAt; // Created On
  final String? createdBy; // Created By
  final DateTime? lastChangedAt; // Last Changed On
  final String? lastChangedBy; // Last Changed By

  const SAPCustomer({
    required this.customer,
    required this.customerName,
    required this.customerName2,
    required this.customerFullName,
    required this.accountGroup,
    required this.accountGroupName,
    required this.customerClassification,
    required this.industryCode,
    required this.industryCodeName,
    required this.organizationBPName1,
    required this.organizationBPName2,
    required this.organizationBPName3,
    required this.organizationBPName4,
    required this.searchTerm1,
    required this.searchTerm2,
    required this.street,
    required this.streetName,
    required this.houseNumber,
    required this.city,
    required this.cityCode,
    required this.postalCode,
    required this.district,
    required this.region,
    required this.regionName,
    required this.country,
    required this.countryName,
    required this.timeZone,
    required this.addressNotes,
    this.latitude,
    this.longitude,
    required this.phoneNumber,
    this.phoneNumberExtension,
    this.mobilePhone,
    this.faxNumber,
    this.emailAddress,
    this.websiteUrl,
    this.contactPerson,
    this.contactPersonFunction,
    this.contactPersonDepartment,
    this.contactPersonPhone,
    this.contactPersonEmail,
    required this.taxNumber1,
    required this.taxNumber2,
    required this.taxNumberType,
    required this.vatRegistrationNumber,
    required this.isTaxExempt,
    this.taxExemptReason,
    required this.salesOrganization,
    required this.salesOrganizationName,
    required this.distributionChannel,
    required this.distributionChannelName,
    required this.division,
    required this.divisionName,
    required this.salesDistrict,
    required this.salesDistrictName,
    required this.salesOffice,
    required this.salesOfficeName,
    required this.salesGroup,
    required this.salesGroupName,
    required this.salesPerson,
    required this.salesPersonName,
    required this.customerPriceGroup,
    required this.customerPriceGroupName,
    required this.pricingProcedure,
    required this.paymentTerms,
    required this.paymentTermsDescription,
    required this.paymentDays,
    required this.paymentMethod,
    required this.dunningProcedure,
    required this.creditControlArea,
    required this.creditLimit,
    required this.creditExposure,
    required this.currency,
    required this.reconciliationAccount,
    this.bankKey,
    this.bankName,
    this.bankAccount,
    this.bankAccountHolder,
    this.iban,
    this.swiftCode,
    required this.balanceAmount,
    required this.overdueAmount,
    required this.specialBalance,
    this.lastPaymentDate,
    required this.lastPaymentAmount,
    required this.dunningLevel,
    this.dunningDate,
    required this.totalOrders,
    required this.totalSales,
    required this.ordersThisMonth,
    required this.salesThisMonth,
    required this.averageOrderValue,
    this.lastOrderDate,
    required this.lastOrderAmount,
    required this.totalVisits,
    this.lastVisitDate,
    required this.visitFrequency,
    this.deliveryPriority,
    this.shippingCondition,
    this.deliveringPlant,
    this.deliveringPlantName,
    this.transportationZone,
    this.incoterms,
    this.incotermsLocation,
    required this.partialDeliveryAllowed,
    this.maximumPartialDeliveries,
    required this.isMarkedForDeletion,
    required this.isBlocked,
    this.blockReason,
    required this.isCentralDeletionBlock,
    required this.isPostingBlock,
    required this.customerStatus,
    this.createdAt,
    this.createdBy,
    this.lastChangedAt,
    this.lastChangedBy,
  });

  bool get canOrder => !isMarkedForDeletion && !isBlocked && !isPostingBlock;
  bool get hasDebt => balanceAmount > 0;
  bool get hasOverdueDebt => overdueAmount > 0;
  bool get hasLocation => latitude != null && longitude != null;
  double get availableCredit => creditLimit - creditExposure;

  /// SAP JSON dan yaratish
  factory SAPCustomer.fromJson(Map<String, dynamic> json) {
    return SAPCustomer(
      customer: json['Customer'] ?? '',
      customerName: json['CustomerName'] ?? '',
      customerName2: json['CustomerName2'] ?? '',
      customerFullName:
          '${json['CustomerName'] ?? ''} ${json['CustomerName2'] ?? ''}'.trim(),
      accountGroup: json['CustomerAccountGroup'] ?? '',
      accountGroupName: json['CustomerAccountGroupName'] ?? '',
      customerClassification: json['CustomerClassification'] ?? '',
      industryCode: json['IndustryCode'] ?? '',
      industryCodeName: json['IndustryCodeName'] ?? '',
      organizationBPName1: json['OrganizationBPName1'] ?? '',
      organizationBPName2: json['OrganizationBPName2'] ?? '',
      organizationBPName3: json['OrganizationBPName3'] ?? '',
      organizationBPName4: json['OrganizationBPName4'] ?? '',
      searchTerm1: json['SearchTerm1'] ?? '',
      searchTerm2: json['SearchTerm2'] ?? '',
      street: json['Street'] ?? '',
      streetName: json['StreetName'] ?? '',
      houseNumber: json['HouseNumber'] ?? '',
      city: json['CityName'] ?? json['City'] ?? '',
      cityCode: json['CityCode'] ?? '',
      postalCode: json['PostalCode'] ?? '',
      district: json['District'] ?? '',
      region: json['Region'] ?? '',
      regionName: json['RegionName'] ?? '',
      country: json['Country'] ?? '',
      countryName: json['CountryName'] ?? '',
      timeZone: json['TimeZone'] ?? '',
      addressNotes: json['AddressNotes'] ?? '',
      latitude: json['Latitude']?.toDouble(),
      longitude: json['Longitude']?.toDouble(),
      phoneNumber: json['PhoneNumber'] ?? json['TelephoneNumber'] ?? '',
      phoneNumberExtension: json['PhoneNumberExtension'],
      mobilePhone: json['MobilePhone'],
      faxNumber: json['FaxNumber'],
      emailAddress: json['EmailAddress'] ?? json['EMailAddress'],
      websiteUrl: json['WebsiteUrl'],
      contactPerson: json['ContactPerson'],
      contactPersonFunction: json['ContactPersonFunction'],
      contactPersonDepartment: json['ContactPersonDepartment'],
      contactPersonPhone: json['ContactPersonPhone'],
      contactPersonEmail: json['ContactPersonEmail'],
      taxNumber1: json['TaxNumber1'] ?? json['FiscalAddress'] ?? '',
      taxNumber2: json['TaxNumber2'] ?? '',
      taxNumberType: json['TaxNumberType'] ?? '',
      vatRegistrationNumber: json['VATRegistration'] ?? '',
      isTaxExempt: json['IsTaxExempt'] ?? false,
      taxExemptReason: json['TaxExemptReason'],
      salesOrganization: json['SalesOrganization'] ?? '',
      salesOrganizationName: json['SalesOrganizationName'] ?? '',
      distributionChannel: json['DistributionChannel'] ?? '',
      distributionChannelName: json['DistributionChannelName'] ?? '',
      division: json['Division'] ?? '',
      divisionName: json['DivisionName'] ?? '',
      salesDistrict: json['SalesDistrict'] ?? '',
      salesDistrictName: json['SalesDistrictName'] ?? '',
      salesOffice: json['SalesOffice'] ?? '',
      salesOfficeName: json['SalesOfficeName'] ?? '',
      salesGroup: json['SalesGroup'] ?? '',
      salesGroupName: json['SalesGroupName'] ?? '',
      salesPerson:
          json['SalesPerson'] ?? json['PartnerFunction_SalesPerson'] ?? '',
      salesPersonName: json['SalesPersonName'] ?? '',
      customerPriceGroup: json['CustomerPriceGroup'] ?? '',
      customerPriceGroupName: json['CustomerPriceGroupName'] ?? '',
      pricingProcedure: json['PricingProcedure'] ?? '',
      paymentTerms: json['PaymentTerms'] ?? '',
      paymentTermsDescription: json['PaymentTermsDescription'] ?? '',
      paymentDays: json['PaymentDays'] ?? 30,
      paymentMethod: json['PaymentMethod'] ?? '',
      dunningProcedure: json['DunningProcedure'] ?? '',
      creditControlArea: json['CreditControlArea'] ?? '',
      creditLimit: (json['CreditLimit'] ?? 0).toDouble(),
      creditExposure: (json['CreditExposure'] ?? 0).toDouble(),
      currency: json['Currency'] ?? 'UZS',
      reconciliationAccount: json['ReconciliationAccount'] ?? '',
      bankKey: json['BankKey'],
      bankName: json['BankName'],
      bankAccount: json['BankAccount'],
      bankAccountHolder: json['BankAccountHolder'],
      iban: json['IBAN'],
      swiftCode: json['SWIFTCode'],
      balanceAmount: (json['BalanceAmount'] ?? 0).toDouble(),
      overdueAmount: (json['OverdueAmount'] ?? 0).toDouble(),
      specialBalance: (json['SpecialGLBalance'] ?? 0).toDouble(),
      lastPaymentDate: json['LastPaymentDate'] != null
          ? DateTime.parse(json['LastPaymentDate'])
          : null,
      lastPaymentAmount: (json['LastPaymentAmount'] ?? 0).toDouble(),
      dunningLevel: json['DunningLevel'] ?? 0,
      dunningDate: json['DunningDate'] != null
          ? DateTime.parse(json['DunningDate'])
          : null,
      totalOrders: json['TotalOrders'] ?? 0,
      totalSales: (json['TotalSales'] ?? 0).toDouble(),
      ordersThisMonth: json['OrdersThisMonth'] ?? 0,
      salesThisMonth: (json['SalesThisMonth'] ?? 0).toDouble(),
      averageOrderValue: (json['AverageOrderValue'] ?? 0).toDouble(),
      lastOrderDate: json['LastOrderDate'] != null
          ? DateTime.parse(json['LastOrderDate'])
          : null,
      lastOrderAmount: (json['LastOrderAmount'] ?? 0).toDouble(),
      totalVisits: json['TotalVisits'] ?? 0,
      lastVisitDate: json['LastVisitDate'] != null
          ? DateTime.parse(json['LastVisitDate'])
          : null,
      visitFrequency: json['VisitFrequency'] ?? 7,
      deliveryPriority: json['DeliveryPriority'],
      shippingCondition: json['ShippingCondition'],
      deliveringPlant: json['DeliveringPlant'],
      deliveringPlantName: json['DeliveringPlantName'],
      transportationZone: json['TransportationZone'],
      incoterms: json['Incoterms'],
      incotermsLocation: json['IncotermsLocation'],
      partialDeliveryAllowed: json['PartialDeliveryAllowed'] ?? true,
      maximumPartialDeliveries: json['MaximumPartialDeliveries']?.toDouble(),
      isMarkedForDeletion: json['IsMarkedForDeletion'] ?? false,
      isBlocked: json['IsBlocked'] ?? false,
      blockReason: json['BlockReason'],
      isCentralDeletionBlock: json['CentralDeletionBlock'] ?? false,
      isPostingBlock: json['PostingBlock'] ?? false,
      customerStatus: json['CustomerStatus'] ?? 'active',
      createdAt: json['CreationDate'] != null
          ? DateTime.parse(json['CreationDate'])
          : null,
      createdBy: json['CreatedByUser'],
      lastChangedAt: json['LastChangeDate'] != null
          ? DateTime.parse(json['LastChangeDate'])
          : null,
      lastChangedBy: json['LastChangedByUser'],
    );
  }
}

/// SAP Customer Partner Functions (Hamkor funksiyalar)
class SAPCustomerPartnerFunction {
  final String customer;
  final String
      partnerFunction; // SH (Ship-to), BP (Bill-to), SP (Sold-to), PY (Payer)
  final String partnerFunctionName;
  final String partnerNumber;
  final String partnerName;
  final String? partnerAddress;

  const SAPCustomerPartnerFunction({
    required this.customer,
    required this.partnerFunction,
    required this.partnerFunctionName,
    required this.partnerNumber,
    required this.partnerName,
    this.partnerAddress,
  });

  factory SAPCustomerPartnerFunction.fromJson(Map<String, dynamic> json) {
    return SAPCustomerPartnerFunction(
      customer: json['Customer'] ?? '',
      partnerFunction: json['PartnerFunction'] ?? '',
      partnerFunctionName: json['PartnerFunctionName'] ?? '',
      partnerNumber: json['PartnerNumber'] ?? '',
      partnerName: json['PartnerName'] ?? '',
      partnerAddress: json['PartnerAddress'],
    );
  }
}
