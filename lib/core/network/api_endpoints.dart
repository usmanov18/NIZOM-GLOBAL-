/// Barcha API endpoint lar markazlashtirilgan
class ApiEndpoints {
  ApiEndpoints._();

  // ============ AUTH ============
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String sendOTP = '/auth/phone/send-otp';
  static const String verifyOTP = '/auth/phone/verify';
  static const String resetPassword = '/auth/password/reset';
  static const String changePassword = '/auth/password/change';
  static const String ssoCallback = '/auth/sso/callback';
  static const String userProfile = '/auth/profile';

  // ============ USERS ============
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static String userStatus(String id) => '/users/$id/status';
  static String userResetPassword(String id) => '/users/$id/reset-password';
  static String userPermissions(String id) => '/users/$id/permissions';

  // ============ AGENTS ============
  static const String agentDashboard = '/agent/dashboard';
  static const String agentOrders = '/agent/orders';
  static const String agentClients = '/agent/clients';
  static const String agentRoute = '/agent/route';
  static const String agentKPI = '/agent/kpi';
  static const String agentVisits = '/agent/visits';
  static String agentDailyReport(String date) =>
      '/agent/reports/daily?date=$date';

  // ============ DELIVERY ============
  static const String deliveryDashboard = '/delivery/dashboard';
  static const String deliveryOrders = '/delivery/orders';
  static const String deliveryRoute = '/delivery/route';
  static const String deliveryLocation = '/delivery/location';
  static String deliveryConfirm(String orderId) => '/delivery/$orderId/confirm';
  static String deliveryStatus(String orderId) => '/delivery/$orderId/status';

  // ============ ORDERS ============
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';
  static String orderItems(String id) => '/orders/$id/items';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderConfirm(String id) => '/orders/$id/confirm';

  // ============ PRODUCTS ============
  static const String products = '/products';
  static const String productCategories = '/products/categories';
  static String productById(String id) => '/products/$id';
  static String productPrice(String id) => '/products/$id/price';
  static String productStock(String id) => '/products/$id/stock';

  // ============ PRODUCT PORTFOLIOS / ASSORTMENT ============
  static const String productPortfolios = '/products/portfolios';
  static String productPortfolioById(String id) => '/products/portfolios/$id';
  static const String productAssortments = '/products/assortments';
  static String userPortfolioAssignment(String userId) =>
      '/users/$userId/portfolio-assignment';
  static String rolePortfolioAssignments(String role) =>
      '/portfolio-assignments?role=$role';
  static const String portfolioAudit = '/portfolio-audit';
  static String userPortfolioAudit(String userId) =>
      '/users/$userId/portfolio-audit';

  // ============ CUSTOMERS ============
  static const String customers = '/customers';
  static String customerById(String id) => '/customers/$id';
  static String customerOrders(String id) => '/customers/$id/orders';
  static String customerPayments(String id) => '/customers/$id/payments';
  static String customerBalance(String id) => '/customers/$id/balance';

  // ============ CASHBOX ============
  static const String cashboxBalance = '/cashbox/balance';
  static const String cashboxPayments = '/cashbox/payments';
  static const String cashboxExpenses = '/cashbox/expenses';
  static const String cashboxReport = '/cashbox/report';
  static const String cashboxClose = '/cashbox/close';

  // ============ VISITS ============
  static const String visits = '/visits';
  static String visitById(String id) => '/visits/$id';
  static const String visitPlan = '/visits/plan';
  static const String visitCheckIn = '/visits/check-in';
  static const String visitCheckOut = '/visits/check-out';

  // ============ REPORTS ============
  static const String salesReport = '/reports/sales';
  static const String customersReport = '/reports/customers';
  static const String agentsReport = '/reports/agents';
  static const String productsReport = '/reports/products';
  static const String debtsReport = '/reports/debts';
  static const String deliveryReport = '/reports/delivery';

  // ============ WAREHOUSE ============
  static const String warehouses = '/warehouses';
  static const String stock = '/stock';
  static String stockByWarehouse(String id) => '/stock/warehouse/$id';
  static const String stockMovements = '/stock/movements';

  // ============ SYNC ============
  static const String syncOrders = '/sync/orders';
  static const String syncProducts = '/sync/products';
  static const String syncCustomers = '/sync/customers';
  static const String syncLastUpdate = '/sync/last-update';
}
