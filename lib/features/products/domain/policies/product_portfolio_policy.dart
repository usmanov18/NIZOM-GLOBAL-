import '../../../../core/security/role_permission_policy.dart';
import '../entities/product_portfolio.dart';

/// Portfolio/assortiment bo‘yicha markaziy biznes qoidalar.
/// Qoidalar UI yoki datasource ichida tarqalib ketmasligi uchun shu yerda saqlanadi.
class ProductPortfolioPolicy {
  const ProductPortfolioPolicy._();

  static const admin = 'admin';
  static const supervisor = 'supervisor';
  static const manager = 'manager';
  static const agent = 'agent';
  static const delivery = 'delivery';

  /// Portfolio assignment create/update faqat admin.
  static bool canManageAssignments(String role) =>
      RolePermissionPolicy.canManagePortfolios(role);

  /// Supervisor boshqara olmaydi, ammo read-only ko‘radi.
  static bool canViewAssignments(String role) =>
      RolePermissionPolicy.isAdmin(role) ||
      RolePermissionPolicy.isSupervisor(role) ||
      RolePermissionPolicy.isManager(role);

  /// Portfeldan tashqari sotish huquqi default kimlarga berilishi mumkin.
  static bool defaultCanSellOutsidePortfolio(String role) =>
      RolePermissionPolicy.isAdmin(role) ||
      RolePermissionPolicy.isSupervisor(role);

  /// Role bo‘yicha demo/default portfellar.
  /// Real backend kelganda ham fallback sifatida ishlaydi.
  static List<String> defaultPortfolioIdsForRole(String role) {
    switch (role) {
      case admin:
      case supervisor:
        return const ['pf_beverages', 'pf_snacks', 'pf_energy_premium'];
      case manager:
        return const ['pf_beverages', 'pf_snacks'];
      case delivery:
        return const ['pf_beverages'];
      case agent:
      default:
        return const ['pf_beverages', 'pf_snacks'];
    }
  }

  /// Assignment biznes-validatsiyasi.
  static List<String> validateAssignment({
    required String actorRole,
    required PortfolioAssignment assignment,
  }) {
    final errors = <String>[];

    if (!canManageAssignments(actorRole)) {
      errors.add('Portfolio ruxsatlarini faqat admin boshqarishi mumkin');
    }

    if (assignment.userId.trim().isEmpty) {
      errors.add('Foydalanuvchi ID bo‘sh bo‘lishi mumkin emas');
    }

    if (assignment.userRole.trim().isEmpty) {
      errors.add('Foydalanuvchi roli ko‘rsatilmagan');
    }

    if (assignment.portfolioIds.isEmpty &&
        !assignment.canSellOutsidePortfolio) {
      errors.add(
          'Kamida bitta portfolio tanlang yoki portfeldan tashqari sotishga ruxsat bering');
    }

    if (assignment.userRole == supervisor && !canViewAssignments(supervisor)) {
      errors.add(
          'Supervisor uchun portfolio ko‘rish ruxsati noto‘g‘ri sozlangan');
    }

    return errors;
  }

  /// Mahsulot role/assignment bo‘yicha sotilishi mumkinmi.
  static bool canSellProduct({
    required PortfolioAssignment assignment,
    required String productId,
    required List<ProductPortfolio> portfolios,
  }) {
    return assignment.canAccessProduct(productId, portfolios);
  }
}
