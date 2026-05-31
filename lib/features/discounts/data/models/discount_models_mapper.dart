import '../../domain/entities/discount_entities.dart';

class ProductDiscountMapper {
  static ProductDiscount fromJson(Map<String, dynamic> json) {
    return ProductDiscount(
      id: json['id'] ?? '',
      externalId1C: json['externalId1C'] ?? '',
      externalIdSAP: json['externalIdSAP'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: DiscountType.values.firstWhere(
        (e) => e.toString() == 'DiscountType.${json['type']}',
        orElse: () => DiscountType.percent,
      ),
      percentValue: json['percentValue']?.toDouble() ?? 0.0,
      fixedValue: json['fixedValue']?.toDouble() ?? 0.0,
      minQuantity: json['minQuantity']?.toDouble(),
      maxQuantity: json['maxQuantity']?.toDouble(),
      minAmount: json['minAmount']?.toDouble(),
      maxAmount: json['maxAmount']?.toDouble(),
      priceGroupId: json['priceGroupId'],
      productIds:
          (json['productIds'] as List?)?.map((e) => e as String).toList(),
      categoryIds:
          (json['categoryIds'] as List?)?.map((e) => e as String).toList(),
      customerIds:
          (json['customerIds'] as List?)?.map((e) => e as String).toList(),
      maxDiscountAmount: json['maxDiscountAmount']?.toDouble(),
      maxUsageCount: json['maxUsageCount'],
      currentUsageCount: json['currentUsageCount'] ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
      status: PromoStatus.values.firstWhere(
        (e) => e.toString() == 'PromoStatus.${json['status']}',
        orElse: () => PromoStatus.active,
      ),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : DateTime.now(),
    );
  }
}

class PromotionMapper {
  static Promotion fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? '',
      externalId1C: json['externalId1C'] ?? '',
      externalIdSAP: json['externalIdSAP'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      bannerUrl: json['bannerUrl'],
      promoType: json['promoType'] ?? 'discount',
      promoCode: json['promoCode'] ?? '',
      conditions: (json['conditions'] as List?)
              ?.map((e) => PromotionConditionMapper.fromJson(e))
              .toList() ??
          [],
      rewards: (json['rewards'] as List?)
              ?.map((e) => PromoRewardMapper.fromJson(e))
              .toList() ??
          [],
      minOrderAmount: json['minOrderAmount']?.toDouble(),
      maxOrderAmount: json['maxOrderAmount']?.toDouble(),
      maxTotalUsage: json['maxTotalUsage'],
      currentTotalUsage: json['currentTotalUsage'] ?? 0,
      maxUsagePerCustomer: json['maxUsagePerCustomer'],
      applicableCustomerGroups: (json['applicableCustomerGroups'] as List?)
          ?.map((e) => e as String)
          .toList(),
      applicableRegions: (json['applicableRegions'] as List?)
          ?.map((e) => e as String)
          .toList(),
      applicableProducts: (json['applicableProducts'] as List?)
          ?.map((e) => e as String)
          .toList(),
      applicableCategories: (json['applicableCategories'] as List?)
          ?.map((e) => e as String)
          .toList(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
      status: PromoStatus.values.firstWhere(
        (e) => e.toString() == 'PromoStatus.${json['status']}',
        orElse: () => PromoStatus.active,
      ),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : DateTime.now(),
      source: json['source'] ?? 'manual',
    );
  }
}

class PromotionConditionMapper {
  static PromoCondition fromJson(Map<String, dynamic> json) {
    return PromoCondition(
      type: json['type'] ?? '',
      operator: json['operator'] ?? '>=',
      value: json['value'],
    );
  }
}

class PromoRewardMapper {
  static PromoReward fromJson(Map<String, dynamic> json) {
    return PromoReward(
      type: json['type'] ?? '',
      value: json['value']?.toDouble(),
      productId: json['productId'],
      quantity: json['quantity']?.toInt(),
    );
  }
}

class SpecialPriceMapper {
  static SpecialPrice fromJson(Map<String, dynamic> json) {
    return SpecialPrice(
      id: json['id'] ?? '',
      externalId1C: json['externalId1C'] ?? '',
      externalIdSAP: json['externalIdSAP'] ?? '',
      productId: json['productId'] ?? '',
      productCode: json['productCode'] ?? '',
      productName: json['productName'] ?? '',
      priceGroupId: json['priceGroupId'] ?? '',
      priceGroupName: json['priceGroupName'] ?? '',
      basePrice: json['basePrice']?.toDouble() ?? 0.0,
      specialPrice: json['specialPrice']?.toDouble() ?? 0.0,
      discountPercent: json['discountPercent']?.toDouble() ?? 0.0,
      discountAmount: json['discountAmount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'UZS',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
      source: json['source'] ?? 'manual',
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : DateTime.now(),
    );
  }
}
