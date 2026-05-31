import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_constants.dart';

class DioClientFactory {
  static bool _isSystemFrozen = false; // Memory cache
  static Timer? _frozenSyncTimer;

  static void startFrozenStatusWatcher(FlutterSecureStorage storage) {
    _frozenSyncTimer =
        Timer.periodic(const Duration(seconds: 30), (timer) async {
      final status = await storage.read(key: 'is_system_frozen');
      _isSystemFrozen = status == 'true';
    });
  }

  static Dio create({FlutterSecureStorage? storage, String? baseUrl}) {
    final secureStorage = storage ?? const FlutterSecureStorage();
    if (_frozenSyncTimer == null) startFrozenStatusWatcher(secureStorage);

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: Duration(seconds: AppConstants.httpTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConstants.httpTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    ));

    dio.interceptors.addAll([
      _EnterpriseHeadersInterceptor(secureStorage),
    ]);

    return dio;
  }
}

class _EnterpriseHeadersInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  _EnterpriseHeadersInterceptor(this.storage);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 🛡 Optimized Kill-switch check from RAM
    if (DioClientFactory._isSystemFrozen) {
      return handler.reject(DioException(
        requestOptions: options,
        error: 'System Frozen',
        type: DioExceptionType.cancel,
      ));
    }
    handler.next(options);
  }
}
