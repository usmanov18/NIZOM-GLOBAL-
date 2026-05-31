import '../entities/product_portfolio.dart';
import 'product_portfolio_policy.dart';

/// Mahsulot agentga qanday ko‘rinishi kerakligini bildiradi.
enum ProductAccessState {
  visible, // sotish mumkin
  disabled, // ko‘rinadi, lekin sotib bo‘lmaydi
  hidden, // umuman ko‘rsatilmaydi
}

class ProductAccessDecision {
  final ProductAccessState state;
  final String? reason;
  final List<String> matchedPortfolioIds;

  const ProductAccessDecision({
    required this.state,
    this.reason,
    this.matchedPortfolioIds = const [],
  });

  bool get canSell => state == ProductAccessState.visible;
  bool get isHidden => state == ProductAccessState.hidden;
  bool get isDisabled => state == ProductAccessState.disabled;
}

/// Product list chiqarishda markaziy access resolver.
/// UI bu classdan kelgan decision bo‘yicha cardni ko‘rsatadi/yashiradi/disabled qiladi.
class ProductAccessResolver {
  const ProductAccessResolver._();

  static ProductAccessDecision resolve({
    required String role,
    required String productId,
    required List<String> productPortfolioIds,
    required PortfolioAssignment assignment,
    required List<ProductPortfolio> portfolios,
    bool showRestrictedAsDisabled = false,
  }) {
    // Admin va supervisor uchun sotish/ko‘rish konteksti boshqacha.
    // Admin hammasini ko‘radi, agentga sotish uchun assignment shart.
    if (role == ProductPortfolioPolicy.admin) {
      return ProductAccessDecision(
        state: ProductAccessState.visible,
        matchedPortfolioIds: productPortfolioIds,
      );
    }

    if (assignment.deniedProductIds.contains(productId)) {
      return ProductAccessDecision(
        state: showRestrictedAsDisabled
            ? ProductAccessState.disabled
            : ProductAccessState.hidden,
        reason: 'Bu mahsulot siz uchun cheklangan',
        matchedPortfolioIds: productPortfolioIds,
      );
    }

    if (assignment.allowedProductIds.contains(productId)) {
      return ProductAccessDecision(
        state: ProductAccessState.visible,
        matchedPortfolioIds: productPortfolioIds,
      );
    }

    if (assignment.canSellOutsidePortfolio) {
      return ProductAccessDecision(
        state: ProductAccessState.visible,
        matchedPortfolioIds: productPortfolioIds,
      );
    }

    final allowedPortfolioIds = assignment.portfolioIds.toSet();
    final matched = productPortfolioIds
        .where((portfolioId) => allowedPortfolioIds.contains(portfolioId))
        .toList();

    if (matched.isNotEmpty) {
      return ProductAccessDecision(
        state: ProductAccessState.visible,
        matchedPortfolioIds: matched,
      );
    }

    return ProductAccessDecision(
      state: showRestrictedAsDisabled
          ? ProductAccessState.disabled
          : ProductAccessState.hidden,
      reason: 'Mahsulot sizga biriktirilgan portfellarga kirmaydi',
      matchedPortfolioIds: productPortfolioIds,
    );
  }
}
