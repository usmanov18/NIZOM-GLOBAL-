// ============================================================
// SAP S/4HANA - BUYURTMA VA QAYTARISH FORMATLARI
// Haqiqiy SAP OData API ga mos
// ============================================================

/// SAP Sales Order (Buyurtma) - yuborish formati
///
/// SAP da buyurtmalar "Sales Order" da saqlanadi
/// API: /sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder
class SAPOrderRequest {
  final String salesOrderType; // Sales Order Type (ZOR, OR)
  final String salesOrganization; // Sales Organization (1000)
  final String distributionChannel; // Distribution Channel (10)
  final String division; // Division (00)
  final String soldToParty; // Sold-To Party (Customer)
  final String shipToParty; // Ship-To Party
  final String purchaseOrderNumber; // PO Number (buyurtma raqami)
  final DateTime requestedDeliveryDate; // Requested Delivery Date
  final String pricingDate; // Pricing Date
  final String customerPurchaseOrderDate; // Customer PO Date
  final String paymentTerms; // Payment Terms
  final String paymentMethod; // Payment Method
  final String incoterms; // Incoterms
  final String incotermsLocation; // Incoterms Location
  final String currency; // Document Currency
  final String salesDistrict; // Sales District
  final String salesOffice; // Sales Office
  final String salesGroup; // Sales Group
  final String salesPerson; // Sales Employee
  final String deliveryBlock; // Delivery Block
  final String billingBlock; // Billing Block
  final String overallDeliveryStatus; // Overall Delivery Status
  final String overallOrderStatus; // Overall Order Status
  final String totalPriceAmount; // Total Price Amount
  final String netAmount; // Net Amount
  final String taxAmount; // Tax Amount
  final String customerGroup; // Customer Group
  final String priceGroup; // Price Group
  final String priceListType; // Price List Type
  final String shippingCondition; // Shipping Condition
  final String shippingType; // Shipping Type
  final String deliveringPlant; // Delivering Plant
  final String storageLocation; // Storage Location
  final bool partialDeliveryAllowed; // Partial Delivery
  final String? deliveryPriority; // Delivery Priority
  final String customerReference; // Customer Reference
  final String headerText; // Header Text
  final List<SAPOrderItem> items; // Order Items
  final List<SAPOrderPartner> partners; // Partner Functions
  final List<SAPOrderCondition> conditions; // Pricing Conditions
  final List<SAPOrderScheduleLine> scheduleLines; // Schedule Lines
  final Map<String, dynamic>? customFields; // Custom Fields

  const SAPOrderRequest({
    required this.salesOrderType,
    required this.salesOrganization,
    required this.distributionChannel,
    required this.division,
    required this.soldToParty,
    required this.shipToParty,
    required this.purchaseOrderNumber,
    required this.requestedDeliveryDate,
    required this.pricingDate,
    required this.customerPurchaseOrderDate,
    required this.paymentTerms,
    required this.paymentMethod,
    required this.incoterms,
    required this.incotermsLocation,
    required this.currency,
    required this.salesDistrict,
    required this.salesOffice,
    required this.salesGroup,
    required this.salesPerson,
    required this.deliveryBlock,
    required this.billingBlock,
    required this.overallDeliveryStatus,
    required this.overallOrderStatus,
    required this.totalPriceAmount,
    required this.netAmount,
    required this.taxAmount,
    required this.customerGroup,
    required this.priceGroup,
    required this.priceListType,
    required this.shippingCondition,
    required this.shippingType,
    required this.deliveringPlant,
    required this.storageLocation,
    required this.partialDeliveryAllowed,
    this.deliveryPriority,
    required this.customerReference,
    required this.headerText,
    required this.items,
    required this.partners,
    required this.conditions,
    required this.scheduleLines,
    this.customFields,
  });

  /// JSON ga aylantirish (SAP ga yuborish uchun)
  Map<String, dynamic> toJson() {
    return {
      'SalesOrderType': salesOrderType,
      'SalesOrganization': salesOrganization,
      'DistributionChannel': distributionChannel,
      'Division': division,
      'SoldToParty': soldToParty,
      'ShipToParty': shipToParty,
      'PurchaseOrderNumber': purchaseOrderNumber,
      'RequestedDeliveryDate':
          requestedDeliveryDate.toIso8601String().substring(0, 10),
      'PricingDate': pricingDate,
      'CustomerPurchaseOrderDate': customerPurchaseOrderDate,
      'PaymentTerms': paymentTerms,
      'PaymentMethod': paymentMethod,
      'Incoterms': incoterms,
      'IncotermsLocation': incotermsLocation,
      'TransactionCurrency': currency,
      'SalesDistrict': salesDistrict,
      'SalesOffice': salesOffice,
      'SalesGroup': salesGroup,
      'SalesPerson': salesPerson,
      'DeliveryBlock': deliveryBlock,
      'BillingBlock': billingBlock,
      'OverallDeliveryStatus': overallDeliveryStatus,
      'OverallOrderStatus': overallOrderStatus,
      'TotalNetAmount': netAmount,
      'TaxAmount': taxAmount,
      'CustomerGroup': customerGroup,
      'PriceGroup': priceGroup,
      'PriceListType': priceListType,
      'ShippingCondition': shippingCondition,
      'ShippingType': shippingType,
      'DeliveringPlant': deliveringPlant,
      'StorageLocation': storageLocation,
      'PartialDeliveryIsAllowed': partialDeliveryAllowed,
      if (deliveryPriority != null) 'DeliveryPriority': deliveryPriority,
      'CustomerReference': customerReference,
      'HeaderText': headerText,
      'to_Item': items.map((item) => item.toJson()).toList(),
      'to_Partner': partners.map((p) => p.toJson()).toList(),
      'to_PricingElement': conditions.map((c) => c.toJson()).toList(),
      'to_ScheduleLine': scheduleLines.map((s) => s.toJson()).toList(),
      if (customFields != null) ...customFields!,
    };
  }
}

/// SAP Buyurtma elementi
class SAPOrderItem {
  final String salesOrderItem; // Item Number (000010)
  final String material; // Material Number
  final String materialDescription; // Material Description
  final String requestedQuantity; // Requested Quantity
  final String salesUnit; // Sales Unit (EA, KG)
  final String plant; // Plant (delivering plant)
  final String storageLocation; // Storage Location
  final String itemCategory; // Item Category (TAN)
  final String itemUsage; // Item Usage
  final String higherLevelItem; // Higher Level Item
  final String netAmount; // Net Amount
  final String taxAmount; // Tax Amount
  final String netPriceAmount; // Net Price
  final String pricingDate; // Pricing Date
  final String orderProbability; // Order Probability
  final String deliveryBlock; // Delivery Block
  final String billingBlock; // Billing Block
  final String reasonForRejection; // Reason for Rejection
  final String materialGroup; // Material Group
  final String productHierarchy; // Product Hierarchy
  final String customerMaterialNumber; // Customer Material Number
  final String batchNumber; // Batch Number
  final String warrantyDate; // Warranty Date
  final String? promotion; // Promotion
  final String? discountCondition; // Discount Condition
  final String headerText; // Item Text
  final List<SAPOrderItemCondition> conditions; // Item Conditions

  const SAPOrderItem({
    required this.salesOrderItem,
    required this.material,
    required this.materialDescription,
    required this.requestedQuantity,
    required this.salesUnit,
    required this.plant,
    required this.storageLocation,
    required this.itemCategory,
    required this.itemUsage,
    required this.higherLevelItem,
    required this.netAmount,
    required this.taxAmount,
    required this.netPriceAmount,
    required this.pricingDate,
    required this.orderProbability,
    required this.deliveryBlock,
    required this.billingBlock,
    required this.reasonForRejection,
    required this.materialGroup,
    required this.productHierarchy,
    required this.customerMaterialNumber,
    required this.batchNumber,
    required this.warrantyDate,
    this.promotion,
    this.discountCondition,
    required this.headerText,
    required this.conditions,
  });

  Map<String, dynamic> toJson() => {
        'SalesOrderItem': salesOrderItem,
        'Material': material,
        'MaterialDescription': materialDescription,
        'RequestedQuantity': requestedQuantity,
        'SalesUnit': salesUnit,
        'Plant': plant,
        'StorageLocation': storageLocation,
        'ItemCategory': itemCategory,
        'ItemUsage': itemUsage,
        'HigherLevelItem': higherLevelItem,
        'NetAmount': netAmount,
        'TaxAmount': taxAmount,
        'NetPriceAmount': netPriceAmount,
        'PricingDate': pricingDate,
        'OrderProbability': orderProbability,
        'DeliveryBlock': deliveryBlock,
        'BillingBlock': billingBlock,
        'ReasonForRejection': reasonForRejection,
        'MaterialGroup': materialGroup,
        'ProductHierarchy': productHierarchy,
        'CustomerMaterialNumber': customerMaterialNumber,
        'BatchNumber': batchNumber,
        'WarrantyDate': warrantyDate,
        if (promotion != null) 'Promotion': promotion,
        if (discountCondition != null) 'DiscountCondition': discountCondition,
        'HeaderText': headerText,
        'to_PricingElement': conditions.map((c) => c.toJson()).toList(),
      };
}

/// SAP Buyurtma elementi narx sharti
class SAPOrderItemCondition {
  final String conditionType; // Condition Type (ZPRC, ZDIS, ZK07)
  final String conditionRateAmount; // Rate Amount
  final String conditionCurrency; // Currency
  final String conditionQuantity; // Quantity
  final String conditionUnit; // Unit
  final String pricingScaleQuantity; // Scale Quantity

  const SAPOrderItemCondition({
    required this.conditionType,
    required this.conditionRateAmount,
    required this.conditionCurrency,
    required this.conditionQuantity,
    required this.conditionUnit,
    required this.pricingScaleQuantity,
  });

  Map<String, dynamic> toJson() => {
        'ConditionType': conditionType,
        'ConditionRateAmount': conditionRateAmount,
        'ConditionCurrency': conditionCurrency,
        'ConditionQuantity': conditionQuantity,
        'ConditionUnit': conditionUnit,
        'PricingScaleQuantity': pricingScaleQuantity,
      };
}

/// SAP Buyurtma hamkor (Partner)
class SAPOrderPartner {
  final String partnerFunction; // Partner Function (SP, SH, BP, PY)
  final String partnerFunctionName; // Name
  final String customer; // Customer Number
  final String customerName; // Customer Name

  const SAPOrderPartner({
    required this.partnerFunction,
    required this.partnerFunctionName,
    required this.customer,
    required this.customerName,
  });

  Map<String, dynamic> toJson() => {
        'PartnerFunction': partnerFunction,
        'PartnerFunctionName': partnerFunctionName,
        'Customer': customer,
        'CustomerName': customerName,
      };
}

/// SAP Narx sharti
class SAPOrderCondition {
  final String conditionType; // Condition Type
  final String conditionRateAmount; // Rate
  final String conditionCurrency; // Currency
  final String conditionValueAmount; // Value

  const SAPOrderCondition({
    required this.conditionType,
    required this.conditionRateAmount,
    required this.conditionCurrency,
    required this.conditionValueAmount,
  });

  Map<String, dynamic> toJson() => {
        'ConditionType': conditionType,
        'ConditionRateAmount': conditionRateAmount,
        'ConditionCurrency': conditionCurrency,
        'ConditionValueAmount': conditionValueAmount,
      };
}

/// SAP Yetkazish jadvali
class SAPOrderScheduleLine {
  final String salesOrderItem; // Item
  final String scheduleLineCategory; // Category
  final String requestedDeliveryDate; // Delivery Date
  final String confirmedQuantity; // Confirmed Qty
  final String deliveredQuantity; // Delivered Qty
  final String openQuantity; // Open Qty

  const SAPOrderScheduleLine({
    required this.salesOrderItem,
    required this.scheduleLineCategory,
    required this.requestedDeliveryDate,
    required this.confirmedQuantity,
    required this.deliveredQuantity,
    required this.openQuantity,
  });

  Map<String, dynamic> toJson() => {
        'SalesOrderItem': salesOrderItem,
        'ScheduleLineCategory': scheduleLineCategory,
        'RequestedDeliveryDate': requestedDeliveryDate,
        'ConfirmedQuantity': confirmedQuantity,
        'DeliveredQuantity': deliveredQuantity,
        'OpenQuantity': openQuantity,
      };
}

// ============================================================
// SAP BUYURTMA JAVOBI
// ============================================================

/// SAP Sales Order javobi
class SAPOrderResponse {
  final String salesOrder; // Sales Order Number
  final String salesOrderType; // Type
  final DateTime creationDate; // Creation Date
  final String createdByUser; // Created By
  final String totalNetAmount; // Total Net Amount
  final String transactionCurrency; // Currency
  final String overallDeliveryStatus; // Delivery Status
  final String overallOrderStatus; // Order Status
  final String overallBillingStatus; // Billing Status
  final String paymentTerms; // Payment Terms
  final String soldToParty; // Customer
  final String soldToPartyName; // Customer Name
  final String purchaseOrderNumber; // PO Number
  final DateTime requestedDeliveryDate; // Delivery Date
  final String deliveryBlock; // Delivery Block
  final String billingBlock; // Billing Block
  final String? salesOrderErrorMessage; // Error

  const SAPOrderResponse({
    required this.salesOrder,
    required this.salesOrderType,
    required this.creationDate,
    required this.createdByUser,
    required this.totalNetAmount,
    required this.transactionCurrency,
    required this.overallDeliveryStatus,
    required this.overallOrderStatus,
    required this.overallBillingStatus,
    required this.paymentTerms,
    required this.soldToParty,
    required this.soldToPartyName,
    required this.purchaseOrderNumber,
    required this.requestedDeliveryDate,
    required this.deliveryBlock,
    required this.billingBlock,
    this.salesOrderErrorMessage,
  });

  factory SAPOrderResponse.fromJson(Map<String, dynamic> json) {
    return SAPOrderResponse(
      salesOrder: json['SalesOrder'] ?? '',
      salesOrderType: json['SalesOrderType'] ?? '',
      creationDate: DateTime.parse(
          json['CreationDate'] ?? DateTime.now().toIso8601String()),
      createdByUser: json['CreatedByUser'] ?? '',
      totalNetAmount: json['TotalNetAmount'] ?? '0',
      transactionCurrency: json['TransactionCurrency'] ?? 'UZS',
      overallDeliveryStatus: json['OverallDeliveryStatus'] ?? '',
      overallOrderStatus: json['OverallOrderStatus'] ?? '',
      overallBillingStatus: json['OverallBillingStatus'] ?? '',
      paymentTerms: json['PaymentTerms'] ?? '',
      soldToParty: json['SoldToParty'] ?? '',
      soldToPartyName: json['SoldToPartyName'] ?? '',
      purchaseOrderNumber: json['PurchaseOrderNumber'] ?? '',
      requestedDeliveryDate: DateTime.parse(
          json['RequestedDeliveryDate'] ?? DateTime.now().toIso8601String()),
      deliveryBlock: json['DeliveryBlock'] ?? '',
      billingBlock: json['BillingBlock'] ?? '',
      salesOrderErrorMessage: json['SalesOrderErrorMessage'],
    );
  }

  bool get isSuccess => salesOrder.isNotEmpty && salesOrderErrorMessage == null;
  bool get isDelivered => overallDeliveryStatus == 'C'; // Complete
  bool get isFullyBilled => overallBillingStatus == 'C';
}

// ============================================================
// SAP QAYTARISH (Return Order)
// ============================================================

/// SAP Return Order (Qaytarish) - yuborish formati
class SAPReturnRequest {
  final String salesOrderType; // Order Type (ZRE, RE)
  final String salesOrganization; // Sales Org
  final String distributionChannel; // Dist Channel
  final String division; // Division
  final String soldToParty; // Customer
  final String purchaseOrderNumber; // PO Number
  final String customerReference; // Reference
  final String requestedDeliveryDate; // Return Date
  final String pricingDate; // Pricing Date
  final String currency; // Currency
  final String returnReason; // Return Reason
  final String returnReasonDescription; // Reason Description
  final String deliveryBlock; // Delivery Block
  final String billingBlock; // Billing Block
  final String headerText; // Header Text
  final String originalSalesOrder; // Original Order
  final List<SAPReturnItem> items; // Return Items
  final List<SAPOrderPartner> partners; // Partners

  const SAPReturnRequest({
    required this.salesOrderType,
    required this.salesOrganization,
    required this.distributionChannel,
    required this.division,
    required this.soldToParty,
    required this.purchaseOrderNumber,
    required this.customerReference,
    required this.requestedDeliveryDate,
    required this.pricingDate,
    required this.currency,
    required this.returnReason,
    required this.returnReasonDescription,
    required this.deliveryBlock,
    required this.billingBlock,
    required this.headerText,
    required this.originalSalesOrder,
    required this.items,
    required this.partners,
  });

  Map<String, dynamic> toJson() {
    return {
      'SalesOrderType': salesOrderType,
      'SalesOrganization': salesOrganization,
      'DistributionChannel': distributionChannel,
      'Division': division,
      'SoldToParty': soldToParty,
      'PurchaseOrderNumber': purchaseOrderNumber,
      'CustomerReference': customerReference,
      'RequestedDeliveryDate': requestedDeliveryDate,
      'PricingDate': pricingDate,
      'TransactionCurrency': currency,
      'ReturnReason': returnReason,
      'ReturnReasonDescription': returnReasonDescription,
      'DeliveryBlock': deliveryBlock,
      'BillingBlock': billingBlock,
      'HeaderText': headerText,
      'OriginalSalesOrder': originalSalesOrder,
      'to_Item': items.map((item) => item.toJson()).toList(),
      'to_Partner': partners.map((p) => p.toJson()).toList(),
    };
  }
}

/// SAP Qaytarish elementi
class SAPReturnItem {
  final String salesOrderItem; // Item Number
  final String material; // Material
  final String materialDescription; // Description
  final String requestedQuantity; // Return Quantity
  final String salesUnit; // Unit
  final String plant; // Plant
  final String itemCategory; // Item Category (REN)
  final String returnReason; // Return Reason
  final String returnReasonDescription; // Reason Description
  final String condition; // Condition (good, damaged, expired)
  final String batchNumber; // Batch
  final String netAmount; // Net Amount
  final String headerText; // Item Text

  const SAPReturnItem({
    required this.salesOrderItem,
    required this.material,
    required this.materialDescription,
    required this.requestedQuantity,
    required this.salesUnit,
    required this.plant,
    required this.itemCategory,
    required this.returnReason,
    required this.returnReasonDescription,
    required this.condition,
    required this.batchNumber,
    required this.netAmount,
    required this.headerText,
  });

  Map<String, dynamic> toJson() => {
        'SalesOrderItem': salesOrderItem,
        'Material': material,
        'MaterialDescription': materialDescription,
        'RequestedQuantity': requestedQuantity,
        'SalesUnit': salesUnit,
        'Plant': plant,
        'ItemCategory': itemCategory,
        'ReturnReason': returnReason,
        'ReturnReasonDescription': returnReasonDescription,
        'Condition': condition,
        'BatchNumber': batchNumber,
        'NetAmount': netAmount,
        'HeaderText': headerText,
      };
}

// ============================================================
// SAP BUYURTMA HOLATI (REAL VAQT)
// ============================================================

/// SAP Buyurtma holati (real vaqt)
class SAPOrderTracking {
  final String salesOrder; // Order Number
  final String salesOrderType; // Type
  final String overallProcessingStatus; // Processing Status
  final String overallDeliveryStatus; // Delivery Status
  final String overallBillingStatus; // Billing Status
  final String overallTotalCreditStatus; // Credit Status
  final String deliveryBlock; // Delivery Block
  final String billingBlock; // Billing Block
  final String totalNetAmount; // Total
  final String transactionCurrency; // Currency
  final DateTime? requestedDeliveryDate; // Requested Date
  final DateTime? actualDeliveryDate; // Actual Date
  final DateTime? billingDocumentDate; // Billing Date
  final String? deliveryDocument; // Delivery Doc
  final String? billingDocument; // Billing Doc
  final String? goodsIssueDate; // GI Date
  final String? proofOfDeliveryDate; // POD Date
  final List<SAPOrderTrackingItem> items; // Items
  final List<SAPOrderTrackingStatus> statusHistory; // Status History

  const SAPOrderTracking({
    required this.salesOrder,
    required this.salesOrderType,
    required this.overallProcessingStatus,
    required this.overallDeliveryStatus,
    required this.overallBillingStatus,
    required this.overallTotalCreditStatus,
    required this.deliveryBlock,
    required this.billingBlock,
    required this.totalNetAmount,
    required this.transactionCurrency,
    this.requestedDeliveryDate,
    this.actualDeliveryDate,
    this.billingDocumentDate,
    this.deliveryDocument,
    this.billingDocument,
    this.goodsIssueDate,
    this.proofOfDeliveryDate,
    required this.items,
    required this.statusHistory,
  });

  factory SAPOrderTracking.fromJson(Map<String, dynamic> json) {
    return SAPOrderTracking(
      salesOrder: json['SalesOrder'] ?? '',
      salesOrderType: json['SalesOrderType'] ?? '',
      overallProcessingStatus: json['OverallProcessingStatus'] ?? '',
      overallDeliveryStatus: json['OverallDeliveryStatus'] ?? '',
      overallBillingStatus: json['OverallBillingStatus'] ?? '',
      overallTotalCreditStatus: json['OverallTotalCreditStatus'] ?? '',
      deliveryBlock: json['DeliveryBlock'] ?? '',
      billingBlock: json['BillingBlock'] ?? '',
      totalNetAmount: json['TotalNetAmount'] ?? '0',
      transactionCurrency: json['TransactionCurrency'] ?? 'UZS',
      requestedDeliveryDate: json['RequestedDeliveryDate'] != null
          ? DateTime.parse(json['RequestedDeliveryDate'])
          : null,
      actualDeliveryDate: json['ActualDeliveryDate'] != null
          ? DateTime.parse(json['ActualDeliveryDate'])
          : null,
      billingDocumentDate: json['BillingDocumentDate'] != null
          ? DateTime.parse(json['BillingDocumentDate'])
          : null,
      deliveryDocument: json['DeliveryDocument'],
      billingDocument: json['BillingDocument'],
      goodsIssueDate: json['GoodsIssueDate'],
      proofOfDeliveryDate: json['ProofOfDeliveryDate'],
      items: (json['Items'] as List?)
              ?.map((i) => SAPOrderTrackingItem.fromJson(i))
              .toList() ??
          [],
      statusHistory: (json['StatusHistory'] as List?)
              ?.map((s) => SAPOrderTrackingStatus.fromJson(s))
              .toList() ??
          [],
    );
  }

  // Status helpers
  bool get isOpen => overallProcessingStatus == 'A';
  bool get isPartiallyProcessed => overallProcessingStatus == 'B';
  bool get isCompletelyProcessed => overallProcessingStatus == 'C';
  bool get isDelivered => overallDeliveryStatus == 'C';
  bool get isPartiallyDelivered => overallDeliveryStatus == 'B';
  bool get isBilled => overallBillingStatus == 'C';
  bool get isPartiallyBilled => overallBillingStatus == 'B';

  String get statusText {
    if (isCompletelyProcessed) return 'Tugallangan';
    if (isPartiallyProcessed) return 'Qisman tugallangan';
    if (isDelivered) return 'Yetkazilgan';
    if (isPartiallyDelivered) return 'Qisman yetkazilgan';
    if (isBilled) return 'Hisoblangan';
    return 'Jarayonda';
  }
}

/// SAP Buyurtma elementi holati
class SAPOrderTrackingItem {
  final String salesOrderItem;
  final String material;
  final String materialDescription;
  final String requestedQuantity;
  final String confirmedQuantity;
  final String deliveredQuantity;
  final String billedQuantity;
  final String openQuantity;
  final String deliveryStatus;
  final String billingStatus;

  const SAPOrderTrackingItem({
    required this.salesOrderItem,
    required this.material,
    required this.materialDescription,
    required this.requestedQuantity,
    required this.confirmedQuantity,
    required this.deliveredQuantity,
    required this.billedQuantity,
    required this.openQuantity,
    required this.deliveryStatus,
    required this.billingStatus,
  });

  factory SAPOrderTrackingItem.fromJson(Map<String, dynamic> json) {
    return SAPOrderTrackingItem(
      salesOrderItem: json['SalesOrderItem'] ?? '',
      material: json['Material'] ?? '',
      materialDescription: json['MaterialDescription'] ?? '',
      requestedQuantity: json['RequestedQuantity'] ?? '0',
      confirmedQuantity: json['ConfirmedQuantity'] ?? '0',
      deliveredQuantity: json['DeliveredQuantity'] ?? '0',
      billedQuantity: json['BilledQuantity'] ?? '0',
      openQuantity: json['OpenQuantity'] ?? '0',
      deliveryStatus: json['DeliveryStatus'] ?? '',
      billingStatus: json['BillingStatus'] ?? '',
    );
  }
}

/// SAP Buyurtma holati tarixi
class SAPOrderTrackingStatus {
  final DateTime date;
  final String status;
  final String statusDescription;
  final String? document;
  final String? user;

  const SAPOrderTrackingStatus({
    required this.date,
    required this.status,
    required this.statusDescription,
    this.document,
    this.user,
  });

  factory SAPOrderTrackingStatus.fromJson(Map<String, dynamic> json) {
    return SAPOrderTrackingStatus(
      date: DateTime.parse(json['Date']),
      status: json['Status'] ?? '',
      statusDescription: json['StatusDescription'] ?? '',
      document: json['Document'],
      user: json['User'],
    );
  }
}
