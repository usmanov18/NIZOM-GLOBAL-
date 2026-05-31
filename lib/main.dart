import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/services/offline/hive_service.dart';
import 'core/services/firebase/firebase_service.dart';
import 'core/services/connectivity/connectivity_service.dart';
import 'core/services/sync_queue/sync_auto_scheduler_service.dart';
import 'core/localization/app_localizations.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/admin/presentation/bloc/feature_settings_bloc.dart';
import 'features/admin/presentation/bloc/conflict_bloc.dart';
import 'features/agent/presentation/bloc/agent_bloc.dart';
import 'features/agent/presentation/bloc/agent_dashboard_bloc.dart';
import 'features/delivery/presentation/bloc/delivery_bloc.dart';
import 'features/order_flow/presentation/bloc/order_flow_bloc.dart';
import 'features/tracking/presentation/bloc/tracking_bloc.dart';
import 'features/supervisor/presentation/bloc/supervisor_bloc.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/products/presentation/cubit/product_management_cubit.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'core/services/notification/notification_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/sync/presentation/bloc/sync_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init
  await Hive.initFlutter();
  await HiveService.init();

  // DI
  await configureDependencies();

  // Services init
  try {
    await getIt<FirebaseService>().initialize();
    await getIt<ConnectivityService>().initialize();
    await getIt<SyncAutoSchedulerService>().start();
  } catch (e) {
    debugPrint('Service init error: $e');
  }

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const NizomGlobalApp());
}

class NizomGlobalApp extends StatelessWidget {
  const NizomGlobalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<AdminBloc>(create: (_) => getIt<AdminBloc>()),
        BlocProvider<ConflictBloc>(create: (_) => getIt<ConflictBloc>()),
        BlocProvider<AgentBloc>(create: (_) => getIt<AgentBloc>()),
        BlocProvider<AgentDashboardBloc>(
            create: (_) => getIt<AgentDashboardBloc>()),
        BlocProvider<DeliveryBloc>(create: (_) => getIt<DeliveryBloc>()),
        BlocProvider<OrderFlowBloc>(create: (_) => getIt<OrderFlowBloc>()),
        BlocProvider<SyncBloc>(create: (_) => getIt<SyncBloc>()),
        BlocProvider<ProductBloc>(create: (_) => getIt<ProductBloc>()),
        BlocProvider<ProductManagementCubit>(
            create: (_) => getIt<ProductManagementCubit>()),
        BlocProvider<SupervisorBloc>(create: (_) => getIt<SupervisorBloc>()),
        BlocProvider<TrackingBloc>(create: (_) => getIt<TrackingBloc>()),
        BlocProvider<FeatureSettingsBloc>(
            create: (_) => getIt<FeatureSettingsBloc>()),
        BlocProvider<TaskBloc>(create: (_) => getIt<TaskBloc>()),
        BlocProvider<NotificationBloc>(
            create: (_) => getIt<NotificationBloc>()),
        BlocProvider<ChatBloc>(create: (_) => getIt<ChatBloc>()),
      ],
      child: MaterialApp.router(
        title: 'NIZOM GLOBAL',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
