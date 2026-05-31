import '../entities/order_flow_entities.dart';

/// Stock qarori.
enum StockDecisionState {
  available,
  limited,
  outOfStock,
  blocked,
}

class ProductStockDecision {
  final StockDecisionState state;
  final int requestedQuantity;
  final int availableQuantity;
  final int allowedQuantity;
  final bool canAddToCart;
  final bool canIncreaseQuantity;
  final bool requiresWarning;
  final String? message;

  const ProductStockDecision({
    required this.state,
    required this.requestedQuantity,
    required this.availableQuantity,
    required this.allowedQuantity,
    required this.canAddToCart,
    required this.canIncreaseQuantity,
    required this.requiresWarning,
    this.message,
  });

  bool get isEnough => state == StockDecisionState.available;
}

/// Warehouse stock/partial order policy.
class ProductStockResolver {
  const ProductStockResolver._();

  static ProductStockDecision resolve({
    required int requestedQuantity,
    required int availableQuantity,
    bool allowPartialOrder = true,
    bool blockOutOfStock = true,
  }) {
    if (availableQuantity <= 0) {
      return ProductStockDecision(
        state: blockOutOfStock
            ? StockDecisionState.blocked
            : StockDecisionState.outOfStock,
        requestedQuantity: requestedQuantity,
        availableQuantity: availableQuantity,
        allowedQuantity: 0,
        canAddToCart: false,
        canIncreaseQuantity: false,
        requiresWarning: true,
        message: 'Tanlangan skladda mahsulot qoldig‘i yo‘q',
      );
    }

    if (requestedQuantity <= availableQuantity) {
      return ProductStockDecision(
        state: StockDecisionState.available,
        requestedQuantity: requestedQuantity,
        availableQuantity: availableQuantity,
        allowedQuantity: requestedQuantity,
        canAddToCart: true,
        canIncreaseQuantity: requestedQuantity < availableQuantity,
        requiresWarning: false,
      );
    }

    return ProductStockDecision(
      state: StockDecisionState.limited,
      requestedQuantity: requestedQuantity,
      availableQuantity: availableQuantity,
      allowedQuantity: allowPartialOrder ? availableQuantity : 0,
      canAddToCart: allowPartialOrder && availableQuantity > 0,
      canIncreaseQuantity: false,
      requiresWarning: true,
      message: allowPartialOrder
          ? 'Tanlangan skladda faqat $availableQuantity dona bor. Miqdor qoldiqqa moslanadi.'
          : 'Tanlangan skladda yetarli qoldiq yo‘q',
    );
  }

  static ProductStockDecision fromStockEntity({
    required int requestedQuantity,
    required ProductStock stock,
    bool allowPartialOrder = true,
  }) {
    return resolve(
      requestedQuantity: requestedQuantity,
      availableQuantity: stock.actualQuantity.toInt(),
      allowPartialOrder: allowPartialOrder,
    );
  }
}
