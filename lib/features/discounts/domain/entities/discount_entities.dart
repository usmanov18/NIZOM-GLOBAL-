import 'package:equatable/equatable.dart';

// ============================================================
// SKIDKA VA PROMO ENTITIES
// 1C va SAP dan yuklanadigan chegirmalar va aksiyalar
// ============================================================

/// Chegirma turlari
enum DiscountType {
  percent, // Foizli chegirma (10%)
  fixedAmount, // Summa chegirma (5000 so'm)
  buyXGetY, // X ta ol, Y ta ol (2+1)
  totalAmount, // Jami summadan chegirma
  firstOrder, // Birinchi buyurtma uchun
  seasonal, // Mavsumiy
  loyalty, // Sodiq mijoz
}

/// Promo holati
enum PromoStatus {
  active, // Faol
  scheduled, // Rejalangan
  expired, // Muddati o'tgan
  paused, // To'xtatilgan
  cancelled, // Bekor qilingan
}

// ============ CHEGIRMA (DISCOUNT) ============

/// Mahsulotga biriktirilgan chegirma
class ProductDiscount extends Equatable {
  factory ProductDiscount.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String externalId1C; // 1C dagi ID
  final String externalIdSAP; // SAP dagi ID
  final String name;
  final String description;
  final DiscountType type;

  // Chegirma qiymati
  final double percentValue; // Foiz (10 = 10%)
  final double fixedValue; // Summa (5000 so'm)

  // Qo'llash shartlari
  final double? minQuantity; // Min miqdor
  final double? maxQuantity; // Max miqdor
  final double? minAmount; // Min summa
  final double? maxAmount; // Max summa
  final String? priceGroupId; // Faqat shu narx guruhi uchun
  final List<String>? productIds; // Faqat shu mahsulotlar uchun
  final List<String>? categoryIds; // Faqat shu kategoriyalar uchun
  final List<String>? customerIds; // Faqat shu mijozlar uchun

  // Chegira limitlari
  final double? maxDiscountAmount; // Max chegirma summasi
  final int? maxUsageCount; // Max ishlatish soni
  final int currentUsageCount; // Joriy ishlatish

  // Vaqt
  final DateTime startDate;
  final DateTime endDate;
  final PromoStatus status;

  // Sinxronlash
  final DateTime lastSyncedAt;
  final String? syncError;

  const ProductDiscount({
    required this.id,
    required this.externalId1C,
    required this.externalIdSAP,
    required this.name,
    required this.description,
    required this.type,
    required this.percentValue,
    required this.fixedValue,
    this.minQuantity,
    this.maxQuantity,
    this.minAmount,
    this.maxAmount,
    this.priceGroupId,
    this.productIds,
    this.categoryIds,
    this.customerIds,
    this.maxDiscountAmount,
    this.maxUsageCount,
    required this.currentUsageCount,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.lastSyncedAt,
    this.syncError,
  });

  // Computed properties
  bool get isActive => status == PromoStatus.active;
  bool get isExpired => endDate.isBefore(DateTime.now());
  bool get isScheduled => startDate.isAfter(DateTime.now());
  bool get hasUsageLimit => maxUsageCount != null;
  bool get isUsageExceeded =>
      maxUsageCount != null && currentUsageCount >= maxUsageCount!;

  bool get canBeApplied {
    if (!isActive) return false;
    if (isExpired) return false;
    if (isUsageExceeded) return false;
    return true;
  }

  /// Chegirma summasini hisoblash
  double calculateDiscount(double basePrice, int quantity, double totalAmount) {
    if (!canBeApplied) return 0;

    // Miqdor tekshirish
    if (minQuantity != null && quantity < minQuantity!) return 0;
    if (maxQuantity != null && quantity > maxQuantity!) return 0;

    // Summa tekshirish
    if (minAmount != null && totalAmount < minAmount!) return 0;
    if (maxAmount != null && totalAmount > maxAmount!) return 0;

    double discount = 0;

    switch (type) {
      case DiscountType.percent:
        discount = basePrice * quantity * (percentValue / 100);
        break;
      case DiscountType.fixedAmount:
        discount = fixedValue * quantity;
        break;
      case DiscountType.buyXGetY:
        // X=2, Y=1 bo'lsa: 3 ta olsa 1 ta bepul
        final freeItems = quantity ~/ (minQuantity!.toInt() + 1);
        discount = basePrice * freeItems;
        break;
      case DiscountType.totalAmount:
        discount = totalAmount * (percentValue / 100);
        break;
      default:
        discount = basePrice * quantity * (percentValue / 100);
    }

    // Max chegirma limiti
    if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
      discount = maxDiscountAmount!;
    }

    return discount;
  }

  /// Narxni hisoblash (chegirma bilan)
  double calculateFinalPrice(double basePrice, int quantity) {
    final discount =
        calculateDiscount(basePrice, quantity, basePrice * quantity);
    return (basePrice * quantity) - discount;
  }

  @override
  List<Object?> get props =>
      [id, externalId1C, externalIdSAP, type, startDate, endDate];
}

// ============ PROMO (AKSIYA) ============

/// Aksiya/Promo entity
class Promotion extends Equatable {
  factory Promotion.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String externalId1C;
  final String externalIdSAP;
  final String name;
  final String description;
  final String? imageUrl;
  final String? bannerUrl;

  // Promo turi
  final String promoType; // discount, gift, bundle, loyalty
  final String promoCode; // PROMO2026

  // Qo'llash shartlari
  final List<PromoCondition> conditions;
  final List<PromoReward> rewards;

  // Cheklovlar
  final double? minOrderAmount;
  final double? maxOrderAmount;
  final int? maxTotalUsage;
  final int currentTotalUsage;
  final int? maxUsagePerCustomer;
  final List<String>? applicableCustomerGroups;
  final List<String>? applicableRegions;
  final List<String>? applicableProducts;
  final List<String>? applicableCategories;

  // Vaqt
  final DateTime startDate;
  final DateTime endDate;
  final PromoStatus status;

  // Sinxronlash
  final DateTime lastSyncedAt;
  final String source; // 1c, sap, manual

  const Promotion({
    required this.id,
    required this.externalId1C,
    required this.externalIdSAP,
    required this.name,
    required this.description,
    this.imageUrl,
    this.bannerUrl,
    required this.promoType,
    required this.promoCode,
    required this.conditions,
    required this.rewards,
    this.minOrderAmount,
    this.maxOrderAmount,
    this.maxTotalUsage,
    required this.currentTotalUsage,
    this.maxUsagePerCustomer,
    this.applicableCustomerGroups,
    this.applicableRegions,
    this.applicableProducts,
    this.applicableCategories,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.lastSyncedAt,
    required this.source,
  });

  bool get isActive =>
      status == PromoStatus.active &&
      startDate.isBefore(DateTime.now()) &&
      endDate.isAfter(DateTime.now());

  bool get isExpired => endDate.isBefore(DateTime.now());

  bool get hasUsageLimit => maxTotalUsage != null;
  bool get isUsageExceeded =>
      maxTotalUsage != null && currentTotalUsage >= maxTotalUsage!;

  bool canApply({
    required double orderAmount,
    required String customerGroup,
    required String region,
  }) {
    if (!isActive) return false;
    if (isUsageExceeded) return false;

    if (minOrderAmount != null && orderAmount < minOrderAmount!) return false;
    if (maxOrderAmount != null && orderAmount > maxOrderAmount!) return false;

    if (applicableCustomerGroups != null &&
        !applicableCustomerGroups!.contains(customerGroup)) {
      return false;
    }

    if (applicableRegions != null && !applicableRegions!.contains(region)) {
      return false;
    }

    return true;
  }

  @override
  List<Object?> get props => [id, promoCode, startDate, endDate, status];
}

/// Promo shartlari
class PromoCondition extends Equatable {
  factory PromoCondition.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String
      type; // min_quantity, min_amount, specific_product, specific_category
  final String operator; // gte, lte, eq, in
  final dynamic value;

  const PromoCondition({
    required this.type,
    required this.operator,
    required this.value,
  });

  bool evaluate({
    int? quantity,
    double? amount,
    String? productId,
    String? categoryId,
  }) {
    switch (type) {
      case 'min_quantity':
        return _compare(quantity?.toDouble(), operator, value.toDouble());
      case 'min_amount':
        return _compare(amount, operator, value.toDouble());
      case 'specific_product':
        if (value is List) return (value as List).contains(productId);
        return productId == value;
      case 'specific_category':
        if (value is List) return (value as List).contains(categoryId);
        return categoryId == value;
      default:
        return true;
    }
  }

  bool _compare(double? actual, String op, double expected) {
    if (actual == null) return false;
    switch (op) {
      case 'gte':
        return actual >= expected;
      case 'lte':
        return actual <= expected;
      case 'eq':
        return actual == expected;
      case 'gt':
        return actual > expected;
      case 'lt':
        return actual < expected;
      default:
        return false;
    }
  }

  @override
  List<Object?> get props => [type, operator, value];
}

/// Promo mukofotlari
class PromoReward extends Equatable {
  factory PromoReward.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String type; // discount_percent, discount_amount, free_product, gift
  final double? value;
  final String? productId;
  final int? quantity;

  const PromoReward({
    required this.type,
    this.value,
    this.productId,
    this.quantity,
  });

  @override
  List<Object?> get props => [type, value];
}

// ============ SKIDKA JADVALI (PRICE LIST) ============

/// Maxsus narxlar jadvali (1C/SAP dan)
class SpecialPrice extends Equatable {
  factory SpecialPrice.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String externalId1C;
  final String externalIdSAP;
  final String productId;
  final String productCode;
  final String productName;
  final String priceGroupId;
  final String priceGroupName;
  final double basePrice;
  final double specialPrice;
  final double discountPercent;
  final double discountAmount;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final String source; // 1c, sap
  final DateTime lastSyncedAt;

  const SpecialPrice({
    required this.id,
    required this.externalId1C,
    required this.externalIdSAP,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.priceGroupId,
    required this.priceGroupName,
    required this.basePrice,
    required this.specialPrice,
    required this.discountPercent,
    required this.discountAmount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.source,
    required this.lastSyncedAt,
  });

  bool get isActive =>
      startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());

  bool get isExpired => endDate.isBefore(DateTime.now());

  @override
  List<Object?> get props => [id, productId, priceGroupId, startDate, endDate];
}
