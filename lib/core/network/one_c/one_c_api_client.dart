import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../dio_client_factory.dart';

class OneCAPIClient {
  final Dio _dio;
  final String baseUrl;
  final String username;
  final String password;

  OneCAPIClient({
    required this.baseUrl,
    required this.username,
    required this.password,
  }) : _dio = DioClientFactory.create(baseUrl: baseUrl);

  Future<Either<Failure, String>> authenticate() async {
    try {
      final credentials = base64Encode(utf8.encode('$username:$password'));
      final response = await _dio.post('/auth/token',
          options: Options(headers: {'Authorization': 'Basic $credentials'}));
      if (response.statusCode == 200) {
        final token = response.data['session_id'];
        _dio.options.headers['Authorization'] = 'Bearer $token';
        return Right(token);
      }
      return const Left(AuthFailure(message: '1C autentifikatsiya xatosi'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getAgentCustomers({
    String? agentCode,
    String? salesPerson,
    int top = 100,
    int skip = 0,
    DateTime? lastSyncTime,
    DateTime? sinceDate, // Delta Sync parametri
  }) async {
    try {
      final effectiveAgentCode = agentCode ?? salesPerson ?? '';
      final filters = <String>[
        if (effectiveAgentCode.isNotEmpty) "Agent/Code eq '$effectiveAgentCode'"
      ];

      // Delta Sync: Faqat o'zgarganlarni so'raymiz
      final effectiveSyncTime = lastSyncTime ?? sinceDate;
      if (effectiveSyncTime != null) {
        final dateStr = effectiveSyncTime.toIso8601String();
        filters.add("ModifiedDate gt datetime'$dateStr'");
      }

      final response =
          await _dio.get('/catalog/Counterparties', queryParameters: {
        r'$filter': filters.join(' and '),
        r'$top': top,
        r'$skip': skip,
        r'$format': 'json',
      });

      // Telemetry: track speed
      return Right(
          List<Map<String, dynamic>>.from(response.data['value'] ?? []));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> createOrder(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/document/Orders', data: data);
      return Right(Map<String, dynamic>.from(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Either<Failure, Map<String, dynamic>>> getAgentProfile(
      String agentCode) async {
    try {
      final response = await _dio.get('/catalog/Agents/$agentCode');
      return Right(Map<String, dynamic>.from(
          response.data is Map ? response.data : <String, dynamic>{}));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getCustomerDetails(
      String customerId) async {
    try {
      final response = await _dio.get('/catalog/Counterparties/$customerId');
      return Right(Map<String, dynamic>.from(
          response.data is Map ? response.data : <String, dynamic>{}));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getOrderDetails(
      String orderId) async {
    try {
      final response = await _dio.get('/document/Orders/$orderId');
      return Right(Map<String, dynamic>.from(
          response.data is Map ? response.data : <String, dynamic>{}));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getProducts({
    String? categoryId,
    String? search,
    int top = 100,
    int skip = 0,
    int? page,
    int? limit,
    DateTime? lastSyncTime,
    DateTime? sinceDate,
  }) async {
    try {
      final response = await _dio.get('/catalog/Products', queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (search != null) 'search': search,
        r'$top': limit ?? top,
        r'$skip': page == null ? skip : ((page - 1) * (limit ?? top)),
      });
      final data = response.data;
      return Right(List<Map<String, dynamic>>.from(data is Map
          ? (data['value'] ?? data['items'] ?? const [])
          : (data ?? const [])));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getProductPrice({
    required String productRefKey,
    required String priceGroupRefKey,
  }) async {
    try {
      final response =
          await _dio.get('/catalog/ProductPrices', queryParameters: {
        'productRefKey': productRefKey,
        'priceGroupRefKey': priceGroupRefKey,
      });
      final data = response.data;
      if (data is Map &&
          data['value'] is List &&
          (data['value'] as List).isNotEmpty) {
        return Right(Map<String, dynamic>.from((data['value'] as List).first));
      }
      return Right(
          Map<String, dynamic>.from(data is Map ? data : <String, dynamic>{}));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getStockBalance({
    required String warehouseRefKey,
    String? productRefKey,
    DateTime? lastSyncTime,
    DateTime? sinceDate,
  }) async {
    try {
      final response =
          await _dio.get('/register/StockBalance', queryParameters: {
        'warehouseRefKey': warehouseRefKey,
        if (productRefKey != null) 'productRefKey': productRefKey,
      });
      final data = response.data;
      return Right(List<Map<String, dynamic>>.from(data is Map
          ? (data['value'] ?? data['items'] ?? const [])
          : (data ?? const [])));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getSpecialPrices(
      {String? priceGroupId,
      DateTime? lastSyncTime,
      DateTime? sinceDate}) async {
    try {
      final response = await _dio.get('/catalog/SpecialPrices',
          queryParameters: {
            if (priceGroupId != null) 'priceGroupId': priceGroupId
          });
      final data = response.data;
      return Right(List<Map<String, dynamic>>.from(
          data is Map ? (data['value'] ?? const []) : (data ?? const [])));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getActiveDiscounts(
      {String? productId,
      String? customerId,
      String? priceGroupRefKey,
      DateTime? lastSyncTime,
      DateTime? sinceDate}) async {
    try {
      final response = await _dio.get('/catalog/Discounts', queryParameters: {
        if (productId != null) 'productId': productId,
        if (customerId != null) 'customerId': customerId
      });
      final data = response.data;
      return Right(List<Map<String, dynamic>>.from(
          data is Map ? (data['value'] ?? const []) : (data ?? const [])));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getActivePromotions(
      {DateTime? lastSyncTime, DateTime? sinceDate}) async {
    try {
      final response = await _dio.get('/catalog/Promotions');
      final data = response.data;
      return Right(List<Map<String, dynamic>>.from(
          data is Map ? (data['value'] ?? const []) : (data ?? const [])));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
