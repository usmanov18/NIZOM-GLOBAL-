// ============================================================
// SAP S/4HANA - MATERIAL MASTER MODELS
// Haqiqiy SAP OData API ga mos
// ============================================================

/// SAP Material Master (Mahsulot) - to'liq tuzilma
///
/// SAP da mahsulotlar "Material Master" da saqlanadi
/// API: /sap/opu/odata/sap/API_PRODUCT_SRV/A_Product
class SAPProduct {
  final String material; // Material Number (000000000000000001)
  final String materialType; // Material Type (FERT, HALB, ROH, HAWA)
  final String materialGroup; // Material Group (001, 002)
  final String materialGroupName; // Material Group Name
  final String industrySector; // Industry Sector (M, C)

  // ============ ТАВСИФОТ (DESCRIPTION) ============
  final String materialDescription; // Material Description (наименование)
  final String materialLongDescription; // Long Description
  final String materialShortDescription; // Short Description (1-2 tilda)

  // ============ БАЗОВЫЕ ДАННЫЕ (ASOSIY MA'LUMOTLAR) ============
  final String baseUnit; // Base Unit of Measure (EA, KG, L, M)
  final String baseUnitISO; // ISO Code (EA, KGM, LTR, MTR)
  final String materialBaseUnitDescription; // Unit Description

  // ============ ОЛЧАМЛАР (DIMENSIONS) ============
  final double? grossWeight; // Gross Weight (kg)
  final double? netWeight; // Net Weight (kg)
  final String weightUnit; // Weight Unit (KG)
  final double? volume; // Volume (m³)
  final String volumeUnit; // Volume Unit (M3)
  final double? length; // Length (m)
  final double? width; // Width (m)
  final double? height; // Height (m)
  final String dimensionUnit; // Dimension Unit (M)

  // ============ ЭАН/ШТРИХКОД (BARCODE) ============
  final String? eanUPC; // EAN/UPC (barcode)
  final String? eanType; // EAN Type (EAN13, EAN8, UPC)

  // ============ ПРОИЗВОДИТЕЛЬ (ИШЛАБ ЧИКАРУВЧИ) ============
  final String? manufacturerNumber; // Manufacturer Number
  final String? manufacturerName; // Manufacturer Name
  final String? manufacturerPartNumber; // Manufacturer Part Number
  final String? countryOfOrigin; // Country of Origin
  final String? countryOfOriginName; // Country Name

  // ============ СКЛАД (ОМБОР) ============
  final String? plant; // Plant (завод/склад)
  final String? plantName; // Plant Name
  final String? storageLocation; // Storage Location
  final String? storageLocationName; // Storage Location Name
  final double? stockQuantity; // Total Stock
  final double? unrestrictedStock; // Unrestricted Stock
  final double? blockedStock; // Blocked Stock
  final double? stockInTransit; // Stock in Transit
  final double? consignmentStock; // Consignment Stock

  // ============ ПРОДАЖИ (СОТУВ) ============
  final String? salesOrganization; // Sales Organization
  final String? distributionChannel; // Distribution Channel
  final String? division; // Division
  final String? salesUnit; // Sales Unit
  final double? minimumOrderQuantity; // Minimum Order Quantity
  final double? minimumDeliveryQuantity; // Minimum Delivery Qty
  final String? deliveringPlant; // Delivering Plant
  final String? transportationGroup; // Transportation Group
  final String? loadingGroup; // Loading Group
  final String? availabilityCheck; // Availability Check

  // ============ НАРХ (PRICING) ============
  final String? priceListType; // Price List Type
  final double? standardPrice; // Standard Price
  final double? movingAveragePrice; // Moving Average Price
  final String? pricingDate; // Pricing Date
  final String? taxClassification; // Tax Classification
  final double? taxRate; // Tax Rate (%)
  final String? customerPriceGroup; // Customer Price Group
  final String? materialPricingGroup; // Material Pricing Group

  // ============ СКИДКА (CHEGIRMA) ============
  final bool hasConditionRecord; // Condition Record exists
  final double? conditionRate; // Condition Rate
  final String? conditionType; // Condition Type (ZPRC, ZDIS)
  final String? conditionCurrency; // Condition Currency
  final DateTime? conditionValidFrom; // Valid From
  final DateTime? conditionValidTo; // Valid To

  // ============ КЛАССИФИКАЦИЯ (TASNIFLASH) ============
  final String? materialClassification; // Class
  final String? classType; // Class Type
  final List<SAPCharacteristic> characteristics; // Characteristics

  // ============ ИЗОБРАЖЕНИЕ (RASM) ============
  final String? materialImageUrl; // Document URL
  final String? documentInfoRecord; // Document Info Record

  // ============ ХОЛАТ (STATUS) ============
  final bool isMarkedForDeletion; // Deletion Flag
  final bool isBlockedForPurchasing; // Purchasing Block
  final bool isBlockedForSales; // Sales Block
  final bool isBatchManaged; // Batch Management
  final bool isSerialManaged; // Serial Number Profile
  final String? crossPlantMaterialStatus; // X-plant Status

  // ============ ВАКТ (DATES) ============
  final DateTime? createdAt; // Created On
  final String? createdBy; // Created By
  final DateTime? lastChangedAt; // Last Changed On
  final String? lastChangedBy; // Last Changed By

  const SAPProduct({
    required this.material,
    required this.materialType,
    required this.materialGroup,
    required this.materialGroupName,
    required this.industrySector,
    required this.materialDescription,
    required this.materialLongDescription,
    required this.materialShortDescription,
    required this.baseUnit,
    required this.baseUnitISO,
    required this.materialBaseUnitDescription,
    this.grossWeight,
    this.netWeight,
    required this.weightUnit,
    this.volume,
    required this.volumeUnit,
    this.length,
    this.width,
    this.height,
    required this.dimensionUnit,
    this.eanUPC,
    this.eanType,
    this.manufacturerNumber,
    this.manufacturerName,
    this.manufacturerPartNumber,
    this.countryOfOrigin,
    this.countryOfOriginName,
    this.plant,
    this.plantName,
    this.storageLocation,
    this.storageLocationName,
    this.stockQuantity,
    this.unrestrictedStock,
    this.blockedStock,
    this.stockInTransit,
    this.consignmentStock,
    this.salesOrganization,
    this.distributionChannel,
    this.division,
    this.salesUnit,
    this.minimumOrderQuantity,
    this.minimumDeliveryQuantity,
    this.deliveringPlant,
    this.transportationGroup,
    this.loadingGroup,
    this.availabilityCheck,
    this.priceListType,
    this.standardPrice,
    this.movingAveragePrice,
    this.pricingDate,
    this.taxClassification,
    this.taxRate,
    this.customerPriceGroup,
    this.materialPricingGroup,
    required this.hasConditionRecord,
    this.conditionRate,
    this.conditionType,
    this.conditionCurrency,
    this.conditionValidFrom,
    this.conditionValidTo,
    this.materialClassification,
    this.classType,
    this.characteristics = const [],
    this.materialImageUrl,
    this.documentInfoRecord,
    required this.isMarkedForDeletion,
    required this.isBlockedForPurchasing,
    required this.isBlockedForSales,
    required this.isBatchManaged,
    required this.isSerialManaged,
    this.crossPlantMaterialStatus,
    this.createdAt,
    this.createdBy,
    this.lastChangedAt,
    this.lastChangedBy,
  });

  /// SAP JSON dan yaratish
  factory SAPProduct.fromJson(Map<String, dynamic> json) {
    return SAPProduct(
      material: json['Material'] ?? '',
      materialType: json['MaterialType'] ?? '',
      materialGroup: json['MaterialGroup'] ?? '',
      materialGroupName: json['MaterialGroupName'] ?? '',
      industrySector: json['IndustrySector'] ?? '',
      materialDescription: json['MaterialDescription'] ?? '',
      materialLongDescription: json['MaterialLongDescription'] ?? '',
      materialShortDescription: json['MaterialShortDescription'] ?? '',
      baseUnit: json['BaseUnit'] ?? 'EA',
      baseUnitISO: json['BaseUnitISOCode'] ?? 'EA',
      materialBaseUnitDescription: json['BaseUnitDescription'] ?? '',
      grossWeight: json['GrossWeight']?.toDouble(),
      netWeight: json['NetWeight']?.toDouble(),
      weightUnit: json['WeightUnit'] ?? 'KG',
      volume: json['Volume']?.toDouble(),
      volumeUnit: json['VolumeUnit'] ?? 'M3',
      length: json['Length']?.toDouble(),
      width: json['Width']?.toDouble(),
      height: json['Height']?.toDouble(),
      dimensionUnit: json['DimensionUnit'] ?? 'M',
      eanUPC: json['EAN_UPC'] ?? json['EAN'],
      eanType: json['EANType'],
      manufacturerNumber: json['ManufacturerNumber'],
      manufacturerName: json['ManufacturerName'],
      manufacturerPartNumber: json['ManufacturerPartNumber'],
      countryOfOrigin: json['CountryOfOrigin'],
      countryOfOriginName: json['CountryOfOriginName'],
      plant: json['Plant'],
      plantName: json['PlantName'],
      storageLocation: json['StorageLocation'],
      storageLocationName: json['StorageLocationName'],
      stockQuantity: json['StockQuantity']?.toDouble(),
      unrestrictedStock: json['UnrestrictedStock']?.toDouble(),
      blockedStock: json['BlockedStock']?.toDouble(),
      stockInTransit: json['StockInTransit']?.toDouble(),
      consignmentStock: json['ConsignmentStock']?.toDouble(),
      salesOrganization: json['SalesOrganization'],
      distributionChannel: json['DistributionChannel'],
      division: json['Division'],
      salesUnit: json['SalesUnit'],
      minimumOrderQuantity: json['MinimumOrderQuantity']?.toDouble(),
      minimumDeliveryQuantity: json['MinimumDeliveryQuantity']?.toDouble(),
      deliveringPlant: json['DeliveringPlant'],
      transportationGroup: json['TransportationGroup'],
      loadingGroup: json['LoadingGroup'],
      availabilityCheck: json['AvailabilityCheck'],
      priceListType: json['PriceListType'],
      standardPrice: json['StandardPrice']?.toDouble(),
      movingAveragePrice: json['MovingAveragePrice']?.toDouble(),
      pricingDate: json['PricingDate'],
      taxClassification: json['TaxClassification'],
      taxRate: json['TaxRate']?.toDouble(),
      customerPriceGroup: json['CustomerPriceGroup'],
      materialPricingGroup: json['MaterialPricingGroup'],
      hasConditionRecord: json['HasConditionRecord'] ?? false,
      conditionRate: json['ConditionRate']?.toDouble(),
      conditionType: json['ConditionType'],
      conditionCurrency: json['ConditionCurrency'],
      conditionValidFrom: json['ConditionValidFrom'] != null
          ? DateTime.parse(json['ConditionValidFrom'])
          : null,
      conditionValidTo: json['ConditionValidTo'] != null
          ? DateTime.parse(json['ConditionValidTo'])
          : null,
      materialClassification: json['MaterialClassification'],
      classType: json['ClassType'],
      characteristics: (json['Characteristics'] as List?)
              ?.map((c) => SAPCharacteristic.fromJson(c))
              .toList() ??
          [],
      materialImageUrl: json['MaterialImageUrl'],
      documentInfoRecord: json['DocumentInfoRecord'],
      isMarkedForDeletion: json['IsMarkedForDeletion'] ?? false,
      isBlockedForPurchasing: json['IsBlockedForPurchasing'] ?? false,
      isBlockedForSales: json['IsBlockedForSales'] ?? false,
      isBatchManaged: json['IsBatchManagement'] ?? false,
      isSerialManaged: json['IsSerialManagement'] ?? false,
      crossPlantMaterialStatus: json['CrossPlantMaterialStatus'],
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

/// SAP Xususiyat (Characteristic)
class SAPCharacteristic {
  final String characteristicName;
  final String characteristicDescription;
  final String value;
  final String? valueDescription;
  final String? unitOfMeasure;

  const SAPCharacteristic({
    required this.characteristicName,
    required this.characteristicDescription,
    required this.value,
    this.valueDescription,
    this.unitOfMeasure,
  });

  factory SAPCharacteristic.fromJson(Map<String, dynamic> json) {
    return SAPCharacteristic(
      characteristicName: json['CharacteristicName'] ?? '',
      characteristicDescription: json['CharacteristicDescription'] ?? '',
      value: json['CharacteristicValue'] ?? '',
      valueDescription: json['CharacteristicValueDescription'],
      unitOfMeasure: json['UnitOfMeasure'],
    );
  }
}

/// SAP Narx sharti (Condition Record)
class SAPConditionRecord {
  final String conditionRecord; // Condition Record Number
  final String conditionType; // Condition Type (ZPRC, ZDIS, ZK07)
  final String conditionTypeName; // Condition Type Name
  final String material; // Material
  final String? customer; // Customer
  final String? customerName; // Customer Name
  final String? priceGroup; // Price Group
  final String? priceGroupName; // Price Group Name
  final double conditionRate; // Rate/Price
  final String conditionCurrency; // Currency
  final String conditionUnit; // Unit
  final DateTime validFrom; // Valid From
  final DateTime validTo; // Valid To
  final double? minimumQuantity; // Minimum Quantity
  final double? maximumQuantity; // Maximum Quantity
  final double? scaleRate; // Scale Rate
  final String? scaleUnit; // Scale Unit
  final bool isDeleted; // Deletion Indicator

  const SAPConditionRecord({
    required this.conditionRecord,
    required this.conditionType,
    required this.conditionTypeName,
    required this.material,
    this.customer,
    this.customerName,
    this.priceGroup,
    this.priceGroupName,
    required this.conditionRate,
    required this.conditionCurrency,
    required this.conditionUnit,
    required this.validFrom,
    required this.validTo,
    this.minimumQuantity,
    this.maximumQuantity,
    this.scaleRate,
    this.scaleUnit,
    required this.isDeleted,
  });

  factory SAPConditionRecord.fromJson(Map<String, dynamic> json) {
    return SAPConditionRecord(
      conditionRecord: json['ConditionRecord'] ?? '',
      conditionType: json['ConditionType'] ?? '',
      conditionTypeName: json['ConditionTypeName'] ?? '',
      material: json['Material'] ?? '',
      customer: json['Customer'],
      customerName: json['CustomerName'],
      priceGroup: json['CustomerPriceGroup'],
      priceGroupName: json['CustomerPriceGroupName'],
      conditionRate: (json['ConditionRateAmount'] ?? 0).toDouble(),
      conditionCurrency: json['ConditionCurrency'] ?? 'UZS',
      conditionUnit: json['ConditionUnit'] ?? '',
      validFrom: json['ConditionValidityStartDate'] != null
          ? DateTime.parse(json['ConditionValidityStartDate'])
          : DateTime.now(),
      validTo: json['ConditionValidityEndDate'] != null
          ? DateTime.parse(json['ConditionValidityEndDate'])
          : DateTime.now().add(const Duration(days: 365)),
      minimumQuantity: json['PricingScaleQuantity']?.toDouble(),
      maximumQuantity: json['PricingScaleMaximumQuantity']?.toDouble(),
      scaleRate: json['ConditionScaleRate']?.toDouble(),
      scaleUnit: json['ConditionScaleUnit'],
      isDeleted: json['ConditionDeletionStatus'] ?? false,
    );
  }

  bool get isActive =>
      !isDeleted &&
      validFrom.isBefore(DateTime.now()) &&
      validTo.isAfter(DateTime.now());
}

/// SAP Ombor qoldig'i
class SAPStockLevel {
  final String material;
  final String materialName;
  final String plant;
  final String plantName;
  final String storageLocation;
  final String storageLocationName;
  final double matlWrhsStQtyInMatlBaseUnit; // Total Stock
  final double unrestrictedStock; // Unrestricted
  final double qualityInspectionStock; // QI Stock
  final double blockedStock; // Blocked
  final double stockInTransit; // Transit
  final double reservedStock; // Reserved
  final String baseUnitOfMeasure;
  final DateTime lastChangeDateTime;

  const SAPStockLevel({
    required this.material,
    required this.materialName,
    required this.plant,
    required this.plantName,
    required this.storageLocation,
    required this.storageLocationName,
    required this.matlWrhsStQtyInMatlBaseUnit,
    required this.unrestrictedStock,
    required this.qualityInspectionStock,
    required this.blockedStock,
    required this.stockInTransit,
    required this.reservedStock,
    required this.baseUnitOfMeasure,
    required this.lastChangeDateTime,
  });

  double get availableStock => unrestrictedStock - reservedStock;
  bool get isInStock => availableStock > 0;
  bool get isLowStock => availableStock < 10;

  factory SAPStockLevel.fromJson(Map<String, dynamic> json) {
    return SAPStockLevel(
      material: json['Material'] ?? '',
      materialName: json['MaterialName'] ?? '',
      plant: json['Plant'] ?? '',
      plantName: json['PlantName'] ?? '',
      storageLocation: json['StorageLocation'] ?? '',
      storageLocationName: json['StorageLocationName'] ?? '',
      matlWrhsStQtyInMatlBaseUnit:
          (json['MatlWrhsStQtyInMatlBaseUnit'] ?? 0).toDouble(),
      unrestrictedStock: (json['UnrestrictedStock'] ?? 0).toDouble(),
      qualityInspectionStock: (json['QualityInspectionStock'] ?? 0).toDouble(),
      blockedStock: (json['BlockedStock'] ?? 0).toDouble(),
      stockInTransit: (json['StockInTransit'] ?? 0).toDouble(),
      reservedStock: (json['ReservedStock'] ?? 0).toDouble(),
      baseUnitOfMeasure: json['BaseUnitOfMeasure'] ?? 'EA',
      lastChangeDateTime: json['LastChangeDateTime'] != null
          ? DateTime.parse(json['LastChangeDateTime'])
          : DateTime.now(),
    );
  }
}
