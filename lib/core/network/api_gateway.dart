import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/tenant/tenant_service.dart';

// ============================================================
// API GATEWAY - Barcha API lar uchun bitta kirish nuqtasi
// ============================================================

class ApiGateway {
  static final ApiGateway _instance = ApiGateway._internal();
  factory ApiGateway() => _instance;
  ApiGateway._internal();

  late Dio _dio;
  final TenantService _tenantService = TenantService();

  // Rate limiting
  final Map<String, int> _requestCounts = {};
  final Map<String, DateTime> _lastRequestTime = {};
  static const int _maxRequestsPerMinute = 60;

  // ============ INIT ============

  void initialize() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(_tenantService),
      _LoggingInterceptor(),
      _RetryInterceptor(),
    ]);
  }

  // ============ REQUEST METHODS ============

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    _checkRateLimit(path);
    return _dio.get(
      '${_tenantService.getBaseUrl()}$path',
      queryParameters: queryParams,
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    _checkRateLimit(path);
    return _dio.post(
      '${_tenantService.getBaseUrl()}$path',
      data: data,
    );
  }

  Future<Response> put(String path, {dynamic data}) async {
    _checkRateLimit(path);
    return _dio.put(
      '${_tenantService.getBaseUrl()}$path',
      data: data,
    );
  }

  Future<Response> patch(String path, {dynamic data}) async {
    _checkRateLimit(path);
    return _dio.patch(
      '${_tenantService.getBaseUrl()}$path',
      data: data,
    );
  }

  Future<Response> delete(String path) async {
    _checkRateLimit(path);
    return _dio.delete('${_tenantService.getBaseUrl()}$path');
  }

  // ============ RATE LIMITING ============

  void _checkRateLimit(String path) {
    final now = DateTime.now();
    final lastTime = _lastRequestTime[path];

    if (lastTime != null && now.difference(lastTime).inMinutes < 1) {
      final count = (_requestCounts[path] ?? 0) + 1;
      if (count > _maxRequestsPerMinute) {
        throw Exception('Rate limit exceeded for $path');
      }
      _requestCounts[path] = count;
    } else {
      _requestCounts[path] = 1;
      _lastRequestTime[path] = now;
    }
  }
}

// ============ INTERCEPTORS ============

class _AuthInterceptor extends Interceptor {
  final TenantService tenantService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  _AuthInterceptor(this.tenantService);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Tenant ID header
    if (tenantService.tenantId != null) {
      options.headers['X-Tenant-ID'] = tenantService.tenantId;
    }

    final token = await _storage.read(key: 'access_token') ??
        await _storage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler) {
    debugPrint('🌐 REQUEST: ${options.method} ${options.uri}');
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ ERROR: ${err.message} ${err.requestOptions.uri}');
    handler.next(err);
  }
}

class _RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        // Exponential backoff
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));

        try {
          final dio = Dio();
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Retry failed
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode == 500) ||
        (err.response?.statusCode == 502) ||
        (err.response?.statusCode == 503);
  }
}
