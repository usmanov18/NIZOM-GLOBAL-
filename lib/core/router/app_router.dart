import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Splash & Auth
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';

// Shell
import '../../features/common/presentation/screens/main_shell.dart';

// Agent
import '../../features/agent/presentation/screens/agent_home_screen.dart';
import '../../features/profile/presentation/screens/agent_profile_screen.dart';
import '../../features/customers/presentation/screens/agent_customers_screen.dart';
import '../../features/customers/presentation/screens/customer_detail_screen.dart';
import '../../features/customers/presentation/screens/customer_debt_screen.dart';

// Orders
import '../../features/order_flow/presentation/screens/create_order_screen.dart';
import '../../features/order_flow/presentation/screens/cart_screen.dart';
import '../../features/order_flow/presentation/screens/order_confirmation_screen.dart';
import '../../features/order_flow/presentation/screens/order_status_screen.dart';
import '../../features/order_flow/presentation/screens/order_timeline_screen.dart';
import '../../features/order_flow/presentation/screens/return_order_screen.dart';
import '../../features/order_flow/domain/entities/order_flow_entities.dart';
import '../../features/order_sync/presentation/screens/order_sync_screen.dart';
import '../../features/order_sync/presentation/screens/order_comparison_screen.dart';
import '../../features/history/presentation/screens/order_history_screen.dart';

// Delivery
import '../../features/delivery/presentation/screens/driver_home_screen.dart';
import '../../features/delivery/presentation/screens/delivery_confirmation_screen.dart';

// Products
import '../../features/products/presentation/screens/product_management_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/barcode_scanner_screen.dart';
import '../../features/products/presentation/screens/stock_alerts_screen.dart';

// Payments
import '../../features/payments/presentation/screens/payment_collection_screen.dart';

// Reports
import '../../features/reports/presentation/screens/daily_report_screen.dart';
import '../../features/reports/presentation/screens/report_builder_screen.dart';

// Visits
import '../../features/visits/presentation/screens/visit_planning_screen.dart';

// Notifications
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';

// Chat
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_detail_screen.dart';

// Tracking
import '../../features/tracking/presentation/screens/live_tracking_screen.dart';

// Tasks
import '../../features/tasks/presentation/screens/task_management_screen.dart';

// Inventory
import '../../features/inventory/presentation/screens/inventory_scan_screen.dart';

// Documents
import '../../features/documents/presentation/screens/document_list_screen.dart';

// Training
import '../../features/training/presentation/screens/training_list_screen.dart';

// Feedback
import '../../features/feedback/presentation/screens/customer_feedback_screen.dart';

// Competitors
import '../../features/competitors/presentation/screens/competitor_analysis_screen.dart';

// Map
import '../../features/map/presentation/screens/agent_map_screen.dart';

// Admin
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_agents_screen.dart';
import '../../features/admin/presentation/screens/agent_restrictions_screen.dart';
import '../../features/admin/presentation/screens/discount_policy_screen.dart';
import '../../features/admin/presentation/screens/system_settings_screen.dart';
import '../../features/admin/presentation/screens/system_monitor_screen.dart';
import '../../features/admin/presentation/screens/feature_settings_screen.dart';
import '../../features/admin/presentation/screens/admin_portfolio_assignment_screen.dart';
import '../../features/admin/presentation/screens/portfolio_audit_screen.dart';
import '../../features/admin/presentation/screens/territory_assignment_monitor_screen.dart';
import '../../features/admin/presentation/screens/failed_sync_dashboard_screen.dart';
import '../../features/admin/presentation/screens/operational_reports_screen.dart';
import '../../shared/widgets/role_guard.dart';

// Supervisor
import '../../features/supervisor/presentation/screens/supervisor_dashboard_screen.dart';

// ============================================================
// APP ROUTER - Professional Navigation
// ============================================================

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();
  static final _shellKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    routes: [
      // ==================== AUTH ====================
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

      // ==================== AGENT ====================
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => MainShell(role: 'agent', child: child),
        routes: [
          GoRoute(
              path: '/agent/home',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: AgentHomeScreen())),
          GoRoute(
              path: '/agent/customers',
              pageBuilder: (_, __) => const NoTransitionPage(
                  child: RoleGuard(
                      allowedRoles: ['admin', 'agent', 'supervisor', 'manager'],
                      requiredFeature: 'customers.view',
                      message: 'Mijozlarni ko‘rish huquqi yo‘q.',
                      child: AgentCustomersScreen()))),
          GoRoute(
              path: '/agent/orders',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: OrderHistoryScreen())),
          GoRoute(
              path: '/agent/visits',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: VisitPlanningScreen())),
          GoRoute(
              path: '/agent/more',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: AgentProfileScreen())),
        ],
      ),

      // ==================== DELIVERY ====================
      ShellRoute(
        builder: (_, __, child) => MainShell(role: 'delivery', child: child),
        routes: [
          GoRoute(
              path: '/delivery/home',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: DriverHomeScreen())),
          GoRoute(
              path: '/delivery/map',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: AgentMapScreen())),
          GoRoute(
              path: '/delivery/route',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: AgentMapScreen())),
          GoRoute(
              path: '/delivery/more',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: AgentProfileScreen())),
        ],
      ),

      // ==================== SUPERVISOR ====================
      ShellRoute(
        builder: (_, __, child) => MainShell(role: 'supervisor', child: child),
        routes: [
          GoRoute(
              path: '/supervisor/home',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: SupervisorDashboardScreen())),
          GoRoute(
              path: '/supervisor/agents',
              pageBuilder: (_, __) => const NoTransitionPage(
                  child: RoleGuard(
                      allowedRoles: ['admin', 'supervisor', 'manager'],
                      requiredFeature: 'portfolio.view',
                      message: 'Agentlarni ko‘rish huquqi yo‘q.',
                      child: AdminAgentsScreen()))),
          GoRoute(
              path: '/supervisor/map',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: LiveTrackingScreen())),
        ],
      ),

      // ==================== ADMIN ====================
      ShellRoute(
        builder: (_, __, child) => MainShell(role: 'admin', child: child),
        routes: [
          GoRoute(
              path: '/admin/home',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: AdminDashboardScreen())),
          GoRoute(
              path: '/admin/agents',
              pageBuilder: (_, __) => const NoTransitionPage(
                  child: RoleGuard(
                      allowedRoles: ['admin', 'supervisor', 'manager'],
                      requiredFeature: 'portfolio.view',
                      message: 'Agentlarni ko‘rish huquqi yo‘q.',
                      child: AdminAgentsScreen()))),
          GoRoute(
              path: '/admin/products',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: ProductManagementScreen())),
          GoRoute(
              path: '/admin/settings',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: SystemSettingsScreen())),
        ],
      ),

      // ==================== FULL SCREEN ====================
      GoRoute(
          path: '/orders/create',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const RoleGuard(
              allowedRoles: ['admin', 'agent'],
              requiredFeature: 'orders.create',
              message: 'Buyurtma yaratish huquqi yo‘q.',
              child: CreateOrderScreen())),
      GoRoute(
          path: '/orders/cart',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const CartScreen()),
      GoRoute(
          path: '/orders/confirm',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const OrderConfirmationScreen()),
      GoRoute(
          path: '/orders/status',
          parentNavigatorKey: _rootKey,
          builder: (_, state) =>
              OrderStatusScreen(order: state.extra as Order)),
      GoRoute(
          path: '/orders/timeline',
          parentNavigatorKey: _rootKey,
          builder: (_, state) => OrderTimelineScreen(
              orderId: state.uri.queryParameters['id'] ?? '',
              orderNumber: state.uri.queryParameters['number'] ?? '')),
      GoRoute(
          path: '/orders/return',
          parentNavigatorKey: _rootKey,
          builder: (_, state) => ReturnOrderScreen(
              orderId: state.uri.queryParameters['id'] ?? '',
              orderNumber: state.uri.queryParameters['number'] ?? '',
              customerName: state.uri.queryParameters['customer'] ?? '')),
      GoRoute(
          path: '/orders/history',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const RoleGuard(
              allowedRoles: ['admin', 'agent', 'supervisor', 'manager'],
              requiredFeature: 'orders.sync',
              message: 'Buyurtmalarni ko‘rish/sync huquqi yo‘q.',
              child: OrderHistoryScreen())),
      GoRoute(
          path: '/orders/sync',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const OrderSyncScreen()),
      GoRoute(
          path: '/orders/compare',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const OrderComparisonScreen()),
      GoRoute(
          path: '/customers/detail',
          parentNavigatorKey: _rootKey,
          builder: (_, state) => CustomerDetailScreen(
              customerId: state.uri.queryParameters['id'] ?? '')),
      GoRoute(
          path: '/customers/debt',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const CustomerDebtScreen()),
      GoRoute(
          path: '/products/detail',
          parentNavigatorKey: _rootKey,
          builder: (_, state) => ProductDetailScreen(
              productId: state.uri.queryParameters['id'] ?? '')),
      GoRoute(
          path: '/products/barcode',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const BarcodeScannerScreen()),
      GoRoute(
          path: '/products/stock',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const StockAlertsScreen()),
      GoRoute(
          path: '/delivery/confirm',
          parentNavigatorKey: _rootKey,
          builder: (_, state) => DeliveryConfirmationScreen(
              deliveryId: state.uri.queryParameters['id'] ?? '',
              orderNumber: state.uri.queryParameters['order'] ?? '',
              customerName: state.uri.queryParameters['customer'] ?? '',
              totalAmount:
                  double.tryParse(state.uri.queryParameters['amount'] ?? '0') ??
                      0)),
      GoRoute(
          path: '/payments/collect',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const PaymentCollectionScreen()),
      GoRoute(
          path: '/reports/daily',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const DailyReportScreen()),
      GoRoute(
          path: '/reports/builder',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const ReportBuilderScreen()),
      GoRoute(
          path: '/chat',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const ChatListScreen()),
      GoRoute(
          path: '/chat/detail',
          parentNavigatorKey: _rootKey,
          builder: (_, state) => ChatDetailScreen(
              chatId: state.uri.queryParameters['id'] ?? '',
              chatName: state.uri.queryParameters['name'] ?? 'Chat',
              isOnline: state.uri.queryParameters['online'] == 'true')),
      GoRoute(
          path: '/tracking',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const LiveTrackingScreen()),
      GoRoute(
          path: '/tasks',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const TaskManagementScreen()),
      GoRoute(
          path: '/inventory/scan',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const InventoryScanScreen()),
      GoRoute(
          path: '/documents',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const DocumentListScreen()),
      GoRoute(
          path: '/training',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const TrainingListScreen()),
      GoRoute(
          path: '/feedback',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const CustomerFeedbackScreen()),
      GoRoute(
          path: '/competitors',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const CompetitorAnalysisScreen()),
      GoRoute(
          path: '/notifications',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const NotificationsScreen()),
      GoRoute(
          path: '/notifications/settings',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const NotificationSettingsScreen()),
      GoRoute(
          path: '/admin/restrictions',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const AgentRestrictionsScreen()),
      GoRoute(
          path: '/admin/discounts',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const DiscountPolicyScreen()),
      GoRoute(
          path: '/admin/features',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const FeatureSettingsScreen()),
      GoRoute(
          path: '/admin/portfolios',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const RoleGuard(
              allowedRoles: ['admin'],
              requiredFeature: 'portfolio.manage',
              message: 'Portfolio ruxsatlarini faqat admin boshqaradi.',
              child: AdminPortfolioAssignmentScreen())),
      GoRoute(
          path: '/admin/portfolio-audit',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const RoleGuard(
              allowedRoles: ['admin'],
              requiredFeature: 'audit.view',
              message: 'Portfolio auditni faqat admin ko‘ra oladi.',
              child: PortfolioAuditScreen())),
      GoRoute(
          path: '/admin/territory-monitor',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const RoleGuard(
              allowedRoles: ['admin'],
              requiredFeature: 'territory.monitor',
              message: 'Territory monitor faqat admin uchun.',
              child: TerritoryAssignmentMonitorScreen())),
      GoRoute(
          path: '/admin/sync-monitor',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const FailedSyncDashboardScreen()),
      GoRoute(
          path: '/admin/operational-reports',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const OperationalReportsScreen()),
      GoRoute(
          path: '/admin/monitor',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const SystemMonitorScreen()),
    ],
  );
}
