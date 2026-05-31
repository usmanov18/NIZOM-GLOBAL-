import '../../../discounts/domain/entities/discount_entities.dart';
import '../entities/order_flow_entities.dart';

class PricingContext {
  final OrderCustomer customer;
  final OrderProduct product;
  final int quantity;
  final DateTime date;
  final List<ProductDiscount> discounts;
  final List<Promotion> promotions;
  final List<SpecialPrice> specialPrices;

  const PricingContext({
    required this.customer,
    required this.product,
    required this.quantity,
    required this.date,
    this.discounts = const [],
    this.promotions = const [],
    this.specialPrices = const [],
  });
}

class PricingResult {
  final String productId;
  final double basePrice;
  final double specialPrice;
  final double discountPercent;
  final double discountAmount;
  final double finalUnitPrice;
  final double lineSubtotal;
  final double lineDiscount;
  final double lineTotal;
  final String currency;
  final List<String> appliedRules;
  final List<String> warnings;

  const PricingResult({
    required this.productId,
    required this.basePrice,
    required this.specialPrice,
    required this.discountPercent,
    required this.discountAmount,
    required this.finalUnitPrice,
    required this.lineSubtotal,
    required this.lineDiscount,
    required this.lineTotal,
    required this.currency,
    required this.appliedRules,
    required this.warnings,
  });

  ProductPrice toProductPrice(
      {required String priceGroupId,
      required String productCode,
      required String productName}) {
    return ProductPrice(
      productId: productId,
      productCode: productCode,
      productName: productName,
      priceGroupId: priceGroupId,
      basePrice: basePrice,
      discountPercent: discountPercent,
      discountAmount: discountAmount,
      finalPrice: finalUnitPrice,
      currency: currency,
      hasPromotion: appliedRules.any((e) => e.startsWith('promotion:')),
      promotionName:
          appliedRules.where((e) => e.startsWith('promotion:')).isEmpty
              ? null
              : appliedRules
                  .firstWhere((e) => e.startsWith('promotion:'))
                  .replaceFirst('promotion:', ''),
    );
  }
}

/// Narx, maxsus narx, chegirma, promo qoidalarini bitta joyda hisoblaydi.
class PricingResolver {
  const PricingResolver._();

  static PricingResult resolve({
    required PricingContext context,
    required double fallbackBasePrice,
    String currency = 'UZS',
  }) {
    final applied = <String>[];
    final warnings = <String>[];

    double basePrice = fallbackBasePrice;
    double specialPrice = basePrice;

    // Maxsus narx ustuvor.
    final specialMatches = context.specialPrices.where((price) {
      final productOk = price.productId == context.product.id;
      final groupOk = price.priceGroupId == context.customer.priceGroupId;
      final dateOk = !context.date.isBefore(price.startDate) &&
          !context.date.isAfter(price.endDate);
      return productOk && groupOk && dateOk;
    }).toList();
    if (specialMatches.isNotEmpty) {
      specialMatches.sort((a, b) => a.specialPrice.compareTo(b.specialPrice));
      specialPrice = specialMatches.first.specialPrice;
      applied.add('special_price:${specialMatches.first.id}');
    }

    double discountPercent = 0;
    double discountAmount = 0;

    // Eng katta mos chegirma olinadi.
    final discountMatches = context.discounts.where((discount) {
      if (!discount.canBeApplied) return false;
      if (discount.priceGroupId != null &&
          discount.priceGroupId != context.customer.priceGroupId) return false;
      if (discount.productIds != null &&
          !discount.productIds!.contains(context.product.id)) return false;
      if (discount.categoryIds != null &&
          !discount.categoryIds!.contains(context.product.categoryId))
        return false;
      if (discount.minQuantity != null &&
          context.quantity < discount.minQuantity!) return false;
      return true;
    }).toList();

    for (final discount in discountMatches) {
      if (discount.type == DiscountType.percent) {
        if (discount.percentValue > discountPercent) {
          discountPercent = discount.percentValue;
          applied.add('discount:${discount.id}');
        }
      } else if (discount.type == DiscountType.fixedAmount) {
        if (discount.fixedValue > discountAmount) {
          discountAmount = discount.fixedValue;
          applied.add('discount:${discount.id}');
        }
      }
    }

    // Promo hozir warning/applied rule sifatida qayd etiladi.
    for (final promo in context.promotions) {
      if (promo.isActive &&
          (promo.applicableProducts?.contains(context.product.id) ?? false)) {
        applied.add('promotion:${promo.name}');
      }
    }

    final percentDiscountPerUnit = specialPrice * (discountPercent / 100);
    final perUnitDiscount = percentDiscountPerUnit + discountAmount;
    final finalUnitPrice =
        (specialPrice - perUnitDiscount).clamp(0, double.infinity).toDouble();

    if (finalUnitPrice <= 0) {
      warnings.add('Yakuniy narx 0 ga teng yoki manfiy bo‘lib qoldi');
    }

    final lineSubtotal = specialPrice * context.quantity;
    final lineDiscount = perUnitDiscount * context.quantity;
    final lineTotal = finalUnitPrice * context.quantity;

    return PricingResult(
      productId: context.product.id,
      basePrice: basePrice,
      specialPrice: specialPrice,
      discountPercent: discountPercent,
      discountAmount: discountAmount,
      finalUnitPrice: finalUnitPrice,
      lineSubtotal: lineSubtotal,
      lineDiscount: lineDiscount,
      lineTotal: lineTotal,
      currency: currency,
      appliedRules: applied,
      warnings: warnings,
    );
  }
}
