/// Ilova bo‘yicha role/permission qoidalari markaziy policy.
/// UI, route guard va service qatlamlar shu policyga tayanishi kerak.
class RolePermissionPolicy {
  RolePermissionPolicy._();

  static const admin = 'admin';
  static const supervisor = 'supervisor';
  static const manager = 'manager';
  static const agent = 'agent';
  static const delivery = 'delivery';

  static bool isAdmin(String role) => role == admin;
  static bool isSupervisor(String role) => role == supervisor;
  static bool isManager(String role) => role == manager;
  static bool isAgent(String role) => role == agent;
  static bool isDelivery(String role) => role == delivery;

  // ============ ADMIN CONFIGURATION ============

  static bool canManageUsers(String role) => isAdmin(role);
  static bool canManagePortfolios(String role) => isAdmin(role);
  static bool canManageWarehouseAssignments(String role) => isAdmin(role);
  static bool canViewAudit(String role) => isAdmin(role);
  static bool canViewTerritoryMonitor(String role) => isAdmin(role);
  static bool canManageSystemSettings(String role) => isAdmin(role);

  // ============ SUPERVISION ============

  static bool canViewAgents(String role) =>
      isAdmin(role) || isSupervisor(role) || isManager(role);

  static bool canViewAgentPortfolios(String role) =>
      isAdmin(role) || isSupervisor(role) || isManager(role);

  static bool canCreateTasks(String role) =>
      isAdmin(role) || isSupervisor(role) || isManager(role);

  static bool canViewReports(String role) =>
      isAdmin(role) || isSupervisor(role) || isManager(role);

  // ============ SALES ============

  static bool canCreateOrder(String role) => isAgent(role) || isAdmin(role);
  static bool canSyncOrders(String role) => isAgent(role) || isAdmin(role);
  static bool canCollectPayments(String role) => isAgent(role) || isAdmin(role);
  static bool canViewCustomers(String role) =>
      isAgent(role) || isAdmin(role) || isSupervisor(role) || isManager(role);

  // ============ DELIVERY ============

  static bool canViewDeliveryOrders(String role) =>
      isDelivery(role) || isAdmin(role);
  static bool canUpdateDeliveryStatus(String role) =>
      isDelivery(role) || isAdmin(role);

  // ============ GENERIC FEATURE CHECK ============

  static bool canAccessFeature(String role, String feature) {
    switch (feature) {
      case 'users.manage':
        return canManageUsers(role);
      case 'portfolio.manage':
        return canManagePortfolios(role);
      case 'portfolio.view':
        return canViewAgentPortfolios(role);
      case 'warehouse.assign':
        return canManageWarehouseAssignments(role);
      case 'audit.view':
        return canViewAudit(role);
      case 'territory.monitor':
        return canViewTerritoryMonitor(role);
      case 'orders.create':
        return canCreateOrder(role);
      case 'orders.sync':
        return canSyncOrders(role);
      case 'customers.view':
        return canViewCustomers(role);
      case 'delivery.update':
        return canUpdateDeliveryStatus(role);
      case 'reports.view':
        return canViewReports(role);
      default:
        return false;
    }
  }

  static String roleLabel(String role) {
    switch (role) {
      case admin:
        return 'Admin';
      case supervisor:
        return 'Supervisor';
      case manager:
        return 'Menejer';
      case agent:
        return 'Agent';
      case delivery:
        return 'Yetkazuvchi';
      default:
        return role;
    }
  }
}
