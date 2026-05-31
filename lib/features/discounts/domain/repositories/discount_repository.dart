import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/discount_entities.dart';
import 'package:equatable/equatable.dart';

// ============================================================
// DISCOUNT REPOSITORY - Skidka va Promo
// ============================================================

abstract class DiscountRepository {
  // ============ CHEGIRMALAR ============

  /// Barcha faol chegirmalarni olish (1C/SAP dan)
  Future<Either<Failure, List<ProductDiscount>>> getActiveDiscounts({
    String? priceGroupId,
    String? productId,
    String? categoryId,
  });

  /// Mahsulotga qo'llanadigan chegirmalarni olish
  Future<Either<Failure, List<ProductDiscount>>> getDiscountsForProduct({
    required String productId,
    required String priceGroupId,
    required double quantity,
    required double amount,
  });

  /// Chegirma tafsilotlari
  Future<Either<Failure, ProductDiscount>> getDiscountById(String id);

  // ============ PROMOLAR ============

  /// Barcha faol promolarni olish
  Future<Either<Failure, List<Promotion>>> getActivePromotions({
    String? customerGroup,
    String? region,
  });

  /// Promo tafsilotlari
  Future<Either<Failure, Promotion>> getPromotionById(String id);

  /// Promo kodni tekshirish
  Future<Either<Failure, Promotion>> validatePromoCode(String code);

  /// Promo ishlatish
  Future<Either<Failure, bool>> applyPromotion({
    required String promotionId,
    required String orderId,
    required String customerId,
  });

  // ============ MAXSUS NARXLAR ============

  /// Mahsulot maxsus narxlarini olish
  Future<Either<Failure, List<SpecialPrice>>> getSpecialPrices({
    required String priceGroupId,
    List<String>? productIds,
  });

  /// Bitta mahsulot maxsus narxi
  Future<Either<Failure, SpecialPrice?>> getSpecialPrice({
    required String productId,
    required String priceGroupId,
  });

  // ============ SINXRONLASH ============

  /// 1C dan chegirmalarni yuklash
  Future<Either<Failure, List<ProductDiscount>>> syncDiscountsFrom1C({
    DateTime? sinceDate,
  });

  /// SAP dan chegirmalarni yuklash
  Future<Either<Failure, List<ProductDiscount>>> syncDiscountsFromSAP({
    DateTime? sinceDate,
  });

  /// 1C dan promolarni yuklash
  Future<Either<Failure, List<Promotion>>> syncPromotionsFrom1C({
    DateTime? sinceDate,
  });

  /// SAP dan promolarni yuklash
  Future<Either<Failure, List<Promotion>>> syncPromotionsFromSAP({
    DateTime? sinceDate,
  });

  /// 1C dan maxsus narxlarni yuklash
  Future<Either<Failure, List<SpecialPrice>>> syncSpecialPricesFrom1C({
    String? priceGroupId,
  });

  /// SAP dan maxsus narxlarni yuklash
  Future<Either<Failure, List<SpecialPrice>>> syncSpecialPricesFromSAP({
    String? priceGroupId,
  });

  /// Barcha chegirma ma'lumotlarini sinxronlash
  Future<Either<Failure, DiscountSyncResult>> syncAllDiscounts();

  /// Oxirgi sinxronlash vaqti
  Future<Either<Failure, DateTime?>> getLastSyncTime();

  /// Local cache dan olish
  Future<Either<Failure, List<ProductDiscount>>> getCachedDiscounts();
  Future<Either<Failure, List<Promotion>>> getCachedPromotions();
  Future<Either<Failure, List<SpecialPrice>>> getCachedSpecialPrices();
}

/// Sinxronlash natijasi
class DiscountSyncResult extends Equatable {
  final int discountsSynced;
  final int promotionsSynced;
  final int specialPricesSynced;
  final List<String> errors;
  final DateTime completedAt;

  const DiscountSyncResult({
    required this.discountsSynced,
    required this.promotionsSynced,
    required this.specialPricesSynced,
    required this.errors,
    required this.completedAt,
  });

  int get totalSynced =>
      discountsSynced + promotionsSynced + specialPricesSynced;
  bool get hasErrors => errors.isNotEmpty;

  @override
  List<Object?> get props =>
      [discountsSynced, promotionsSynced, specialPricesSynced];
}
