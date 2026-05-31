import '../../domain/entities/order_flow_entities.dart';

/// Order sync payloadlarni backend/1C/SAP formatlariga ajratib tayyorlaydi.
/// Repository ichida mapping chalkashib ketmasligi uchun alohida qatlam.
class OrderSyncPayloadMapper {
  const OrderSyncPayloadMapper._();

  static Map<String, dynamic> generic(Order order) {
    return {
      'orderId': order.id,
      'orderNumber': order.orderNumber,
      'customerId': order.customerId,
      'customerCode': order.customerCode,
      'customerName': order.customerName,
      'warehouseId': order.warehouseId,
      'totalAmount': order.totalAmount,
      'currency': order.currency,
      'paymentMethod': order.paymentMethod,
      'status': order.status.name,
      'metadata': order.metadata,
      'territory': territory(order),
      'pricingSnapshots': pricingSnapshots(order),
      'oneC': oneC(order),
      'sap': sap(order),
      'items': order.items
          .map((item) => {
                'productId': item.productId,
                'productCode': item.productCode,
                'productName': item.productName,
                'quantity': item.quantity,
                'unitPrice': item.unitPrice,
                'discountPercent': item.discountPercent,
                'discountAmount': item.discountAmount,
                'total': item.totalWithDiscount,
                'pricing': pricingSnapshotFor(order, item.productId),
              })
          .toList(),
      'createdAt': order.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> oneC(Order order) {
    return {
      'Date': order.createdAt.toIso8601String(),
      'Number': order.orderNumber,
      'Customer': {'Code': order.customerCode, 'Ref_Key': order.customerId},
      'Agent': {'Code': order.agentCode, 'Ref_Key': order.agentId},
      'Warehouse': {'Code': order.warehouseId, 'Ref_Key': order.warehouseId},
      'Items': order.items
          .map((item) => {
                'Product': {
                  'Code': item.productCode,
                  'Ref_Key': item.productId
                },
                'Quantity': item.quantity,
                'UnitPrice': item.unitPrice,
                'DiscountPercent': item.discountPercent,
                'DiscountAmount': item.discountAmount,
                'Amount': item.totalWithDiscount,
                'PricingSnapshot': pricingSnapshotFor(order, item.productId),
              })
          .toList(),
      'DocumentAmount': order.totalAmount,
      'Currency': order.currency,
      'PaymentMethod': order.paymentMethod,
      'Territory': territory(order),
      'Metadata': order.metadata,
      'Comment': order.notes ?? '',
    };
  }

  static Map<String, dynamic> sap(Order order) {
    return {
      'OrderType': 'ZOR',
      'SalesOrganization': '1000',
      'DistributionChannel': '10',
      'Division': '00',
      'SoldToParty': order.customerCode,
      'PurchaseOrderNumber': order.orderNumber,
      'RequestedDeliveryDate':
          order.deliveryDate?.toIso8601String().substring(0, 10),
      'YY1_TerritorySource': order.metadata?['territorySource'],
      'YY1_SelectedWarehouse': order.warehouseId,
      'YY1_WarehouseResolution': territory(order),
      'to_Item': order.items.map((item) {
        final pricing = pricingSnapshotFor(order, item.productId);
        return {
          'Material': item.productCode,
          'RequestedQuantity': '${item.quantity}',
          'Plant': order.warehouseId,
          'YY1_BasePrice': pricing?['basePrice'],
          'YY1_FinalPrice': pricing?['finalUnitPrice'],
          'YY1_DiscountAmount': pricing?['lineDiscount'],
          'YY1_PricingRules': pricing?['appliedRules']?.toString(),
        };
      }).toList(),
    };
  }

  static Map<String, dynamic> territory(Order order) {
    final metadata = order.metadata ?? {};
    return {
      'source': metadata['territorySource'],
      'hasDirectRegionMatch': metadata['hasDirectRegionMatch'],
      'resolutionWarning': metadata['resolutionWarning'],
      'resolvedAt': metadata['resolvedAt'],
      'selectedWarehouseId':
          metadata['selectedWarehouseId'] ?? order.warehouseId,
      'selectedWarehouseName': metadata['selectedWarehouseName'],
      'availableWarehouseIds': metadata['availableWarehouseIds'] ?? [],
      'agentAllowedWarehouseIds': metadata['agentAllowedWarehouseIds'] ?? [],
      'customerServiceWarehouseIds':
          metadata['customerServiceWarehouseIds'] ?? [],
    };
  }

  static List<Map<String, dynamic>> pricingSnapshots(Order order) {
    final snapshots = order.metadata?['pricingSnapshots'];
    if (snapshots is! List) return const [];
    return snapshots
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Map<String, dynamic>? pricingSnapshotFor(
      Order order, String productId) {
    for (final item in pricingSnapshots(order)) {
      if (item['productId'] == productId) return item;
    }
    return null;
  }
}
