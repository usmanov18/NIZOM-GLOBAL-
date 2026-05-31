import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Config
import '../config/app_config_service.dart';
import '../network/network_info.dart';
import '../network/dio_client_factory.dart';
import '../network/one_c/one_c_api_client.dart';
import '../network/sap/sap_api_client.dart';
import '../config/env_config.dart';

// Services
import '../services/auth/auth_service.dart';
import '../services/offline/hive_service.dart';
import '../services/firebase/firebase_service.dart';
import '../services/location/location_service.dart';
import '../services/notification/push_notification_service.dart';
import '../services/notification/notification_repository.dart';
import '../services/notification/notification_bloc.dart';
import '../services/payment/payment_service.dart';
import '../services/printer/printer_service.dart';
import '../services/route/route_service.dart';
import '../services/voice/voice_service.dart';
import '../services/websocket/websocket_service.dart';
import '../services/territory_assignment/territory_assignment_service.dart';
import '../services/territory_assignment/territory_assignment_remote_datasource.dart';
import '../services/territory_assignment/territory_assignment_local_datasource.dart';
import '../services/analytics/analytics_service.dart';
import '../services/ai/ai_service.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/currency/currency_service.dart';
import '../services/signature/signature_service.dart';
import '../services/export/export_service.dart';
import '../services/sync/sync_scheduler_service.dart';
import '../services/sync/delta_sync_service.dart';
import '../services/sync/conflict_resolution_service.dart';
import '../services/sync/batch_operation_service.dart';
import '../services/sync/webhook_handler.dart';
import '../services/sync/system_sync_bloc.dart';
import '../services/sync_queue/sync_queue_local_datasource.dart';
import '../services/sync_queue/sync_queue_service.dart';
import '../services/sync_queue/sync_worker_service.dart';
import '../services/sync_queue/sync_auto_scheduler_service.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Agent
import '../../features/agent/data/datasources/agent_remote_datasource.dart';
import '../../features/agent/data/datasources/agent_local_datasource.dart';
import '../../features/agent/data/repositories/agent_repository_impl.dart';
import '../../features/agent/domain/repositories/agent_repository.dart';
import '../../features/agent/presentation/bloc/agent_bloc.dart';
import '../../features/agent/presentation/bloc/agent_dashboard_bloc.dart';
import '../../features/agent/domain/usecases/get_agent_dashboard.dart';
import '../../features/agent/domain/usecases/get_agent_orders.dart';
import '../../features/agent/domain/usecases/create_agent_order.dart'
    as agent_usecases;

// Delivery
import '../../features/delivery/data/datasources/delivery_remote_datasource.dart';
import '../../features/delivery/data/datasources/delivery_local_datasource.dart';
import '../../features/delivery/data/repositories/delivery_repository_impl.dart';
import '../../features/delivery/domain/repositories/delivery_repository.dart';
import '../../features/delivery/presentation/bloc/delivery_bloc.dart';

// Order Flow
import '../../features/order_flow/data/datasources/order_local_datasource.dart';
import '../../features/order_flow/data/repositories/order_flow_repository_impl.dart';
import '../../features/order_flow/data/datasources/order_catalog_datasource.dart';
import '../../features/order_flow/data/datasources/order_catalog_local_datasource.dart';
import '../../features/order_flow/data/datasources/order_catalog_remote_datasource.dart';
import '../../features/order_flow/data/repositories/order_catalog_repository_impl.dart';
import '../../features/order_flow/domain/repositories/order_catalog_repository.dart';
import '../../features/order_flow/domain/repositories/order_flow_repository.dart';
import '../../features/order_flow/domain/usecases/create_order_usecase.dart';
import '../../features/order_flow/domain/usecases/sync_order_usecase.dart';
import '../../features/order_flow/presentation/bloc/order_flow_bloc.dart';

// Admin
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/datasources/admin_local_datasource.dart';
import '../../features/admin/data/datasources/sales_user_profile_local_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/data/repositories/conflict_repository_impl.dart';
import '../../features/admin/data/repositories/feature_settings_repository_impl.dart';
import '../../features/admin/domain/repositories/feature_settings_repository.dart';
import '../../features/admin/presentation/bloc/feature_settings_bloc.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/repositories/conflict_repository.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../features/admin/presentation/bloc/conflict_bloc.dart';

// Supervisor
import '../../features/supervisor/data/datasources/supervisor_remote_datasource.dart';
import '../../features/supervisor/data/datasources/supervisor_local_datasource.dart';
import '../../features/supervisor/data/repositories/supervisor_repository_impl.dart';
import '../../features/supervisor/domain/repositories/supervisor_repository.dart';
import '../../features/supervisor/presentation/bloc/supervisor_bloc.dart';

// Customers
import '../../features/customers/data/datasources/customer_remote_datasource.dart';
import '../../features/customers/data/datasources/customer_local_datasource.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';

// Products
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/data/datasources/product_portfolio_remote_datasource.dart';
import '../../features/products/data/datasources/product_portfolio_local_datasource.dart';
import '../../features/products/data/repositories/product_portfolio_repository_impl.dart';
import '../../features/products/domain/repositories/product_portfolio_repository.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../../features/products/presentation/cubit/product_management_cubit.dart';

// Discounts
import '../../features/discounts/data/datasources/discount_remote_datasource.dart';
import '../../features/discounts/data/datasources/discount_local_datasource.dart';
import '../../features/discounts/data/repositories/discount_repository_impl.dart';
import '../../features/discounts/domain/repositories/discount_repository.dart';

// Tracking
import '../../features/tracking/presentation/bloc/tracking_bloc.dart';

// Tasks
import '../../features/tasks/presentation/bloc/task_bloc.dart';

// Visits
import '../../features/visits/data/datasources/visit_remote_datasource.dart';
import '../../features/visits/data/repositories/visit_repository_impl.dart';
import '../../features/visits/domain/repositories/visit_repository.dart';
import '../../features/visits/presentation/bloc/visit_bloc.dart';

// Reports
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/presentation/bloc/report_bloc.dart';
import '../../features/reports/data/services/operational_report_service.dart';

// Inventory
import '../../features/inventory/data/datasources/inventory_remote_datasource.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';

// Chat
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

// Competitors
import '../../features/competitors/data/repositories/competitor_repository_impl.dart';
import '../../features/competitors/domain/repositories/competitor_repository.dart';

// Training
import '../../features/training/data/repositories/training_repository_impl.dart';
import '../../features/training/domain/repositories/training_repository.dart';

// Sync
import '../../features/sync/presentation/bloc/sync_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ============ EXTERNAL ============
  getIt.registerLazySingleton(() => DioClientFactory.create());
  getIt.registerLazySingleton<OneCAPIClient>(() =>
      OneCAPIClient(baseUrl: EnvConfig.oneCUrl, username: '', password: ''));
  getIt.registerLazySingleton<SAPAPIClient>(() =>
      SAPAPIClient(baseUrl: EnvConfig.sapUrl, username: '', password: ''));
  getIt.registerLazySingleton(() => Connectivity());
  getIt.registerLazySingleton(() => const FlutterSecureStorage());

  // ============ CONFIG ============
  final appConfig = await AppConfigService.getInstance();
  getIt.registerSingleton<AppConfigService>(appConfig);

  // ============ CORE SERVICES ============
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<HiveService>(() => HiveService());
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<PushNotificationService>(
      () => PushNotificationService());
  getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl());
  getIt.registerFactory(() =>
      NotificationBloc(notificationService: getIt(), repository: getIt()));
  getIt.registerLazySingleton<PaymentService>(() => PaymentService());
  getIt.registerLazySingleton<PrinterService>(() => PrinterService());
  getIt.registerLazySingleton<RouteService>(() => RouteService());
  getIt.registerLazySingleton<VoiceService>(() => VoiceService());
  getIt.registerLazySingleton<WebSocketService>(() => WebSocketService());
  getIt.registerLazySingleton<TerritoryAssignmentLocalDataSource>(
      () => TerritoryAssignmentLocalDataSource());
  getIt.registerLazySingleton<TerritoryAssignmentRemoteDataSource>(() =>
      TerritoryAssignmentRemoteDataSource(
          oneCClient: getIt(), sapClient: getIt()));
  getIt.registerLazySingleton<TerritoryAssignmentService>(() =>
      TerritoryAssignmentService(
          remoteDataSource: getIt(), localDataSource: getIt()));
  getIt.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  getIt.registerLazySingleton<AIService>(() => AIService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<CurrencyService>(() => CurrencyService());
  getIt.registerLazySingleton<SignatureService>(() => SignatureService());
  getIt.registerLazySingleton<ExportService>(() => ExportService());

  // Sync services
  getIt.registerLazySingleton<SyncSchedulerService>(
      () => SyncSchedulerService());
  getIt.registerLazySingleton<DeltaSyncService>(() => DeltaSyncService());
  getIt.registerLazySingleton<ConflictResolutionService>(
      () => ConflictResolutionService());
  getIt.registerLazySingleton<BatchOperationService>(
      () => BatchOperationService());
  getIt.registerLazySingleton<WebhookHandler>(() => WebhookHandler());
  getIt.registerLazySingleton<SyncQueueLocalDataSource>(
      () => SyncQueueLocalDataSource());
  getIt
      .registerLazySingleton<SyncQueueService>(() => SyncQueueService(getIt()));
  getIt.registerLazySingleton<SyncWorkerService>(
      () => SyncWorkerService(queueService: getIt(), orderRepository: getIt()));
  getIt.registerLazySingleton<SyncAutoSchedulerService>(() =>
      SyncAutoSchedulerService(
          workerService: getIt(), connectivityService: getIt()));

  // ============ AUTH ============
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
      salesUserProfileLocalDataSource: getIt()));
  getIt.registerFactory(() => AuthBloc(repository: getIt()));

  // ============ AGENT ============
  getIt.registerLazySingleton<AgentRemoteDataSource>(
      () => AgentRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<AgentLocalDataSource>(
      () => AgentLocalDataSourceImpl());
  getIt.registerLazySingleton<AgentRepository>(() => AgentRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt()));
  getIt.registerLazySingleton(() => GetAgentDashboard(getIt()));
  getIt.registerLazySingleton(() => GetAgentOrders(getIt()));
  getIt.registerLazySingleton(() => agent_usecases.CreateAgentOrder(getIt()));
  getIt.registerFactory(() => AgentBloc(repository: getIt()));
  getIt.registerFactory(() => AgentDashboardBloc(
        getDashboard: getIt(),
        getOrders: getIt(),
        createOrder: getIt<agent_usecases.CreateAgentOrder>(),
        repository: getIt(),
      ));

  // ============ DELIVERY ============
  getIt.registerLazySingleton<DeliveryRemoteDataSource>(
      () => DeliveryRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<DeliveryLocalDataSource>(
      () => DeliveryLocalDataSourceImpl());
  getIt.registerLazySingleton<DeliveryRepository>(() => DeliveryRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt()));
  getIt.registerFactory(() => DeliveryBloc(repository: getIt()));

  // ============ ORDER FLOW ============
  getIt.registerLazySingleton<OrderLocalDataSource>(
      () => OrderLocalDataSource());
  getIt.registerLazySingleton<OrderCatalogDataSource>(
      () => OrderSeedCatalogDataSourceImpl());
  getIt.registerLazySingleton<OrderCatalogLocalDataSource>(
      () => OrderCatalogLocalDataSource());
  getIt.registerLazySingleton<OrderCatalogRemoteDataSource>(
      () => OrderCatalogRemoteDataSource(getIt()));
  getIt.registerLazySingleton<OrderCatalogRepository>(
      () => OrderCatalogRepositoryImpl(
            fallbackDataSource: getIt(),
            localDataSource: getIt(),
            remoteDataSource: getIt(),
            networkInfo: getIt(),
          ));
  getIt.registerLazySingleton<OrderFlowRepository>(() =>
      OrderFlowRepositoryImpl(
          oneCClient: getIt(),
          sapClient: getIt(),
          localDataSource: getIt(),
          syncQueueService: getIt(),
          isOnline: true));
  getIt.registerLazySingleton(() => CreateOrderUseCase(getIt()));
  getIt.registerLazySingleton(() => SyncOrderToAllSystemsUseCase(getIt()));
  getIt.registerLazySingleton(() => SyncAllPendingOrdersUseCase(getIt()));
  getIt.registerFactory(() => OrderFlowBloc(
      repository: getIt(),
      createOrder: getIt(),
      syncOrder: getIt(),
      syncAll: getIt()));

  // ============ ADMIN ============
  getIt.registerLazySingleton<ConflictRepository>(
      () => ConflictRepositoryImpl());
  getIt.registerFactory(() => ConflictBloc(getIt()));
  getIt.registerLazySingleton<AdminRemoteDataSource>(
      () => AdminRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<AdminLocalDataSource>(
      () => AdminLocalDataSourceImpl());
  getIt.registerLazySingleton<SalesUserProfileLocalDataSource>(
      () => SalesUserProfileLocalDataSourceImpl());
  getIt.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt()));
  getIt.registerLazySingleton<FeatureSettingsRepository>(
      () => FeatureSettingsRepositoryImpl());
  getIt.registerFactory(() => FeatureSettingsBloc(repository: getIt()));
  getIt.registerFactory(() => AdminBloc(repository: getIt()));

  // ============ SUPERVISOR ============
  getIt.registerLazySingleton<SupervisorRemoteDataSource>(
      () => SupervisorRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<SupervisorLocalDataSource>(
      () => SupervisorLocalDataSourceImpl());
  getIt.registerLazySingleton<SupervisorRepository>(() =>
      SupervisorRepositoryImpl(
          remoteDataSource: getIt(),
          localDataSource: getIt(),
          networkInfo: getIt()));
  getIt.registerFactory(() => SupervisorBloc());

  // ============ CUSTOMERS ============
  getIt.registerLazySingleton<CustomerRemoteDataSource>(() =>
      CustomerRemoteDataSourceImpl(
          dio: getIt(), oneCDio: getIt(), sapDio: getIt()));
  getIt.registerLazySingleton<CustomerLocalDataSource>(
      () => CustomerLocalDataSourceImpl());
  getIt.registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt()));

  // ============ PRODUCTS ============
  getIt.registerLazySingleton<ProductRemoteDataSource>(() =>
      ProductRemoteDataSourceImpl(
          dio: getIt(), oneCDio: getIt(), sapDio: getIt()));
  getIt.registerLazySingleton<ProductLocalDataSource>(
      () => ProductLocalDataSourceImpl());
  getIt.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt()));
  getIt.registerLazySingleton<ProductPortfolioRemoteDataSource>(
      () => ProductPortfolioRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<ProductPortfolioLocalDataSource>(
      () => ProductPortfolioLocalDataSourceImpl());
  getIt.registerLazySingleton<ProductPortfolioRepository>(
      () => ProductPortfolioRepositoryImpl(
            remoteDataSource: getIt(),
            localDataSource: getIt(),
            networkInfo: getIt(),
          ));
  getIt.registerFactory(() => ProductBloc(repository: getIt()));
  getIt.registerFactory(() => ProductManagementCubit(repository: getIt()));

  // ============ DISCOUNTS ============
  getIt.registerLazySingleton<DiscountRemoteDataSource>(() =>
      DiscountRemoteDataSourceImpl(
          dio: getIt(), oneCDio: getIt(), sapDio: getIt()));
  getIt.registerLazySingleton<DiscountLocalDataSource>(
      () => DiscountLocalDataSourceImpl());
  getIt.registerLazySingleton<DiscountRepository>(() => DiscountRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt()));

  // ============ VISITS ============
  getIt.registerLazySingleton<VisitRemoteDataSource>(
      () => VisitRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<VisitRepository>(() =>
      VisitRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()));
  getIt.registerFactory(() => VisitBloc(repository: getIt()));

  // ============ REPORTS ============
  getIt.registerLazySingleton<ReportRemoteDataSource>(
      () => ReportRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<ReportRepository>(
      () => ReportRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerFactory(() => ReportBloc(repository: getIt()));
  getIt.registerLazySingleton<OperationalReportService>(
      () => OperationalReportService(
            orderLocalDataSource: getIt(),
            syncQueueService: getIt(),
            profileLocalDataSource: getIt(),
            portfolioRepository: getIt(),
          ));

  // ============ INVENTORY ============
  getIt.registerLazySingleton<InventoryRemoteDataSource>(
      () => InventoryRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<InventoryRepository>(
      () => InventoryRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerFactory(() => InventoryBloc(repository: getIt()));

  // ============ CHAT ============
  getIt.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<ChatRepository>(() =>
      ChatRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()));
  getIt.registerFactory(() => ChatBloc());

  // ============ COMPETITORS ============
  getIt.registerLazySingleton<CompetitorRepository>(
      () => CompetitorRepositoryImpl());

  // ============ TRAINING ============
  getIt.registerLazySingleton<TrainingRepository>(
      () => TrainingRepositoryImpl());

  // ============ TRACKING & TASKS ============
  getIt.registerFactory(() => TrackingBloc());
  getIt.registerFactory(() => TaskBloc());

  // ============ SYNC ============
  getIt.registerFactory(() => SyncBloc(customerRepository: getIt(), discountRepository: getIt()));
  getIt.registerFactory(() => SystemSyncBloc(
      scheduler: getIt(),
      deltaSync: getIt(),
      conflictResolution: getIt(),
      batchOperation: getIt()));
}
