import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../dio_client_factory.dart';

class SAPAPIClient {
  final Dio _dio;
  final String baseUrl;
  final String username;
  final String password;
  String? _csrfToken;

  SAPAPIClient({
    required this.baseUrl,
    required this.username,
    required this.password,
  }) : _dio = DioClientFactory.create(baseUrl: baseUrl);

  Future<Either<Failure, String>> fetchCSRFToken() async {
    try {
      final credentials = base64Encode(utf8.encode('$username:$password'));
      final response = await _dio.get('/API_SALES_ORDER_SRV/\$metadata',
          options: Options(headers: {
            'Authorization': 'Basic $credentials',
            'x-csrf-token': 'Fetch'
          }));
      _csrfToken = response.headers.value('x-csrf-token');
      if (_csrfToken != null) {
        _dio.options.headers['x-csrf-token'] = _csrfToken;
        return Right(_csrfToken!);
      }
      return const Left(AuthFailure(message: 'SAP CSRF xatosi'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getStockBalance(
      {required String plant, String? material}) async {
    try {
      final filter =
          "Plant eq '$plant'${material != null ? " and Material eq '$material'" : ""}";
      final response = await _dio.get(
          '/API_MATERIAL_STOCK_SRV/A_MatlStockLevel',
          queryParameters: {r'$filter': filter});
      return Right(
          List<Map<String, dynamic>>.from(response.data['d']['results'] ?? []));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> createOrder(
      Map<String, dynamic> data) async {
    try {
      if (_csrfToken == null) await fetchCSRFToken();
      final response =
          await _dio.post('/API_SALES_ORDER_SRV/A_SalesOrder', data: data);
      return Right(
          Map<String, dynamic>.from(response.data['d'] ?? response.data));
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

  Future<Either<Failure, List<Map<String, dynamic>>>> getAgentCustomers(
      {String? agentCode,
      String? salesPerson,
      int top = 100,
      int skip = 0,
      DateTime? lastSyncTime,
      DateTime? sinceDate}) async {
    try {
      final response = await _dio.get('/API_BUSINESS_PARTNER/A_BusinessPartner',
          queryParameters: {r'$top': top, r'$skip': skip});
      final data = response.data;
      return Right(List<Map<String, dynamic>>.from(data is Map
          ? (data['d']?['results'] ?? data['value'] ?? const [])
          : (data ?? const [])));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getCustomerDetails(
      String customerNumber) async {
    try {
      final response = await _dio
          .get('/API_BUSINESS_PARTNER/A_BusinessPartner/$customerNumber');
      return Right(Map<String, dynamic>.from(response.data is Map
          ? (response.data['d'] ?? response.data)
          : <String, dynamic>{}));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getOrderDetails(
      String salesOrder) async {
    try {
      final response =
          await _dio.get('/API_SALES_ORDER_SRV/A_SalesOrder/$salesOrder');
      return Right(Map<String, dynamic>.from(response.data is Map
          ? (response.data['d'] ?? response.data)
          : <String, dynamic>{}));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getProducts(
      {String? categoryId,
      String? search,
      String? productGroup,
      int top = 100,
      int skip = 0,
      int? page,
      int? limit,
      DateTime? lastSyncTime,
      DateTime? sinceDate}) async {
    try {
      final response =
          await _dio.get('/API_PRODUCT_SRV/A_Product', queryParameters: {
        r'$top': limit ?? top,
        r'$skip': page == null ? skip : ((page - 1) * (limit ?? top))
      });
      final data = response.data;
      return Right(List<Map<String, dynamic>>.from(data is Map
          ? (data['d']?['results'] ?? data['value'] ?? const [])
          : (data ?? const [])));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getPriceList(
      {String? salesOrganization,
      String? distributionChannel,
      String? priceGroupId,
      String? material,
      DateTime? lastSyncTime,
      DateTime? sinceDate}) async {
    try {
      final response = await _dio
          .get('/API_PRICE_SRV/A_PriceConditionRecord', queryParameters: {
        if (salesOrganization != null) 'salesOrganization': salesOrganization,
        if (distributionChannel != null)
          'distributionChannel': distributionChannel,
        if (priceGroupId != null) 'priceGroupId': priceGroupId,
      });
      final data = response.data;
      return Right(List<Map<String, dynamic>>.from(data is Map
          ? (data['d']?['results'] ?? data['value'] ?? const [])
          : (data ?? const [])));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
