import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/logger/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // 2026 Tracking: State transitions
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.e(
        '❌ BLoC Error [${bloc.runtimeType}]: $error', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
