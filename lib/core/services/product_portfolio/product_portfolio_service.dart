import 'dart:convert';
import 'package:hive/hive.dart';

import '../../../features/products/domain/entities/product_portfolio.dart';

/// Portfolio/assortiment ruxsatlarini boshqarish xizmati.
///
/// DEPRECATED: yangi kodlarda `ProductPortfolioRepository` ishlating.
/// Bu service vaqtincha backward compatibility uchun qoldirildi.
@Deprecated('Use ProductPortfolioRepository instead')
class ProductPortfolioService {
  static const _boxName = 'product_portfolios';

  Future<List<ProductPortfolio>> getPortfolios() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('portfolios');
    if (raw == null) return demoPortfolios;
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    return list.map(ProductPortfolio.fromJson).toList();
  }

  Future<void> savePortfolios(List<ProductPortfolio> portfolios) async {
    final box = await Hive.openBox(_boxName);
    await box.put(
        'portfolios', jsonEncode(portfolios.map((e) => e.toJson()).toList()));
  }

  Future<PortfolioAssignment> getAssignmentForUser(
      String userId, String role) async {
    final box = await Hive.openBox(_boxName);
    final key = 'assignment_${role}_$userId';
    final raw = box.get(key);
    if (raw == null) return demoAssignmentFor(userId, role);
    return PortfolioAssignment.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw)));
  }

  Future<void> saveAssignment(PortfolioAssignment assignment) async {
    final box = await Hive.openBox(_boxName);
    final key = 'assignment_${assignment.userRole}_${assignment.userId}';
    await box.put(key, jsonEncode(assignment.toJson()));
  }

  Future<List<ProductPortfolio>> getAssignedPortfolios(
      String userId, String role) async {
    final portfolios = await getPortfolios();
    final assignment = await getAssignmentForUser(userId, role);
    return portfolios
        .where((portfolio) => assignment.portfolioIds.contains(portfolio.id))
        .where((portfolio) => portfolio.isActive && portfolio.isCurrentlyValid)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  Future<bool> canUserSellProduct({
    required String userId,
    required String role,
    required String productId,
  }) async {
    final portfolios = await getPortfolios();
    final assignment = await getAssignmentForUser(userId, role);
    return assignment.canAccessProduct(productId, portfolios);
  }

  bool canManagePortfolios(String role) => role == 'admin';

  Future<void> saveAssignmentAs({
    required String actorRole,
    required PortfolioAssignment assignment,
  }) async {
    if (!canManagePortfolios(actorRole)) {
      throw Exception('Portfolio ruxsatlarini faqat admin boshqarishi mumkin');
    }
    await saveAssignment(assignment);
  }

  List<ProductPortfolio> get demoPortfolios => const [
        ProductPortfolio(
          id: 'pf_beverages',
          code: 'BEV-001',
          name: 'Ichimliklar portfeli',
          description: 'Gazli ichimliklar, suv va choylar',
          sourceSystem: ProductSourceSystem.oneC,
          assortmentType: AssortmentType.mandatory,
          categoryIds: ['cat_drinks', 'cat_water'],
          productIds: [
            'prod_1',
            'prod_2',
            'prod_3',
            'prod_4',
            'prod_5',
            'prod_9'
          ],
          brands: ['Coca-Cola', 'Fanta', 'Sprite', 'Pepsi', 'Lipton'],
          channels: ['retail', 'wholesale'],
          priority: 1,
        ),
        ProductPortfolio(
          id: 'pf_snacks',
          code: 'SNK-001',
          name: 'Snack va qandolat',
          description: 'Chips, saqich, shokolad va impulse goods',
          sourceSystem: ProductSourceSystem.sap,
          assortmentType: AssortmentType.recommended,
          categoryIds: ['cat_snacks', 'cat_confectionery'],
          productIds: ['prod_6', 'prod_7', 'prod_8'],
          brands: ['Lays', 'Orbit', 'Milka'],
          channels: ['retail'],
          priority: 2,
        ),
        ProductPortfolio(
          id: 'pf_energy_premium',
          code: 'ENR-PRM',
          name: 'Premium va energetiklar',
          description: 'Energetik ichimliklar va premium SKUlar',
          sourceSystem: ProductSourceSystem.mixed,
          assortmentType: AssortmentType.optional,
          categoryIds: ['cat_energy'],
          productIds: ['prod_10'],
          brands: ['Red Bull'],
          channels: ['retail', 'horeca'],
          priority: 3,
        ),
      ];

  PortfolioAssignment demoAssignmentFor(String userId, String role) {
    final portfolioIds = switch (role) {
      'admin' => ['pf_beverages', 'pf_snacks', 'pf_energy_premium'],
      'supervisor' => ['pf_beverages', 'pf_snacks', 'pf_energy_premium'],
      'manager' => ['pf_beverages', 'pf_snacks'],
      'delivery' => ['pf_beverages'],
      _ => ['pf_beverages', 'pf_snacks'],
    };

    return PortfolioAssignment(
      id: 'demo_assignment_${role}_$userId',
      userId: userId,
      userRole: role,
      portfolioIds: portfolioIds,
      canSellOutsidePortfolio: role == 'admin' || role == 'supervisor',
      assignedAt: DateTime.now(),
      assignedBy: 'system',
    );
  }
}
