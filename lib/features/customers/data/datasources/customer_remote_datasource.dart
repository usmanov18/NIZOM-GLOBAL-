import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';

// ============================================================
// CUSTOMER REMOTE DATASOURCE - 1C/SAP API dan mijozlar
// ============================================================

abstract class CustomerRemoteDataSource {
  /// Agent biriktirilgan mijozlar
  Future<List<Map<String, dynamic>>> getAgentCustomers({
    required String agentId,
    String? search,
    String? regionId,
    bool? isActive,
    bool? hasDebt,
    int page = 1,
    int limit = 50,
  });

  /// Mijoz tafsilotlari
  Future<Map<String, dynamic>> getCustomerById(String customerId);

  /// 1C dan mijozlarni yuklash
  Future<List<Map<String, dynamic>>> syncCustomersFrom1C({
    required String agentCode,
    DateTime? sinceDate,
    int top = 500,
    int skip = 0,
  });

  /// SAP dan mijozlarni yuklash
  Future<List<Map<String, dynamic>>> syncCustomersFromSAP({
    required String salesPerson,
    DateTime? sinceDate,
    int top = 500,
    int skip = 0,
  });

  /// Yangi mijoz yaratish
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> data);

  /// Mijozni yangilash
  Future<Map<String, dynamic>> updateCustomer(
    String customerId,
    Map<String, dynamic> data,
  );

  /// Mijoz buyurtmalari
  Future<List<Map<String, dynamic>>> getCustomerOrders({
    required String customerId,
    int limit = 20,
  });

  /// Mijoz to'lovlari
  Future<List<Map<String, dynamic>>> getCustomerPayments({
    required String customerId,
    int limit = 20,
  });

  /// Mijoz qarzdorligi
  Future<Map<String, dynamic>> getCustomerDebt(String customerId);

  /// Agent profilini olish
  Future<Map<String, dynamic>> getAgentProfile(String agentId);

  /// 1C dan agent profilini olish
  Future<Map<String, dynamic>> syncAgentProfileFrom1C(String agentCode);

  /// SAP dan agent profilini olish
  Future<Map<String, dynamic>> syncAgentProfileFromSAP(String personnelNumber);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final Dio _dio;
  final Dio _oneCDio;
  final Dio _sapDio;

  CustomerRemoteDataSourceImpl({
    required Dio dio,
    required Dio oneCDio,
    required Dio sapDio,
  })  : _dio = dio,
        _oneCDio = oneCDio,
        _sapDio = sapDio;

  @override
  Future<List<Map<String, dynamic>>> getAgentCustomers({
    required String agentId,
    String? search,
    String? regionId,
    bool? isActive,
    bool? hasDebt,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'agent_id': agentId,
        'page': page,
        'limit': limit,
      };
      if (search != null) queryParams['search'] = search;
      if (regionId != null) queryParams['region_id'] = regionId;
      if (isActive != null) queryParams['is_active'] = isActive;
      if (hasDebt != null) queryParams['has_debt'] = hasDebt;

      final response = await _dio.get(
        ApiEndpoints.customers,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Mijozlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getCustomerById(String customerId) async {
    try {
      final response = await _dio.get(ApiEndpoints.customerById(customerId));
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Mijoz topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncCustomersFrom1C({
    required String agentCode,
    DateTime? sinceDate,
    int top = 500,
    int skip = 0,
  }) async {
    try {
      final filters = <String>["Agent/Code eq '$agentCode'"];
      if (sinceDate != null) {
        filters.add("Modified gt datetime'${sinceDate.toIso8601String()}'");
      }

      final response = await _oneCDio.get(
        '/catalog/Counterparties',
        queryParameters: {
          r'$filter': filters.join(' and '),
          r'$orderby': 'Description asc',
          r'$top': top,
          r'$skip': skip,
          r'$format': 'json',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['value'] ?? []);
      }
      throw ServerException(message: '1C dan mijozlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '1C server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncCustomersFromSAP({
    required String salesPerson,
    DateTime? sinceDate,
    int top = 500,
    int skip = 0,
  }) async {
    try {
      final filters = <String>["SalesPerson eq '$salesPerson'"];
      if (sinceDate != null) {
        filters.add(
            "LastChangedDateTime ge datetimeoffset'${sinceDate.toIso8601String()}'");
      }

      final response = await _sapDio.get(
        '/API_BUSINESS_PARTNER/A_Customer',
        queryParameters: {
          if (filters.isNotEmpty) r'$filter': filters.join(' and '),
          r'$orderby': 'CustomerName asc',
          r'$top': top,
          r'$skip': skip,
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['d']['results'] ?? []);
      }
      throw ServerException(message: 'SAP dan mijozlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'SAP server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.customers, data: data);
      if (response.statusCode == 201) return response.data;
      throw ServerException(message: 'Mijoz yaratilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> updateCustomer(
    String customerId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.customerById(customerId),
        data: data,
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Mijoz yangilanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerOrders({
    required String customerId,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.customerOrders(customerId),
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Buyurtmalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerPayments({
    required String customerId,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.customerPayments(customerId),
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'To\'lovlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getCustomerDebt(String customerId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.customerBalance(customerId),
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Qarzdorlik yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getAgentProfile(String agentId) async {
    try {
      final response = await _dio.get('/agents/$agentId/profile');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Agent profili yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> syncAgentProfileFrom1C(String agentCode) async {
    try {
      final response = await _oneCDio.get(
        '/catalog/Agents',
        queryParameters: {
          r'$filter': "Code eq '$agentCode'",
          r'$format': 'json',
        },
      );
      if (response.statusCode == 200) {
        final results = response.data['value'] ?? [];
        if (results.isNotEmpty) return results.first;
      }
      throw ServerException(message: '1C dan agent topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '1C server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> syncAgentProfileFromSAP(
      String personnelNumber) async {
    try {
      final response = await _sapDio.get(
        '/API_WORKFORCE_EMPLOYMENT_SRV/A_Employment',
        queryParameters: {
          r'$filter': "PersonnelNumber eq '$personnelNumber'",
        },
      );
      if (response.statusCode == 200) {
        final results = response.data['d']['results'] ?? [];
        if (results.isNotEmpty) return results.first;
      }
      throw ServerException(message: 'SAP dan agent topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'SAP server xatosi');
    }
  }
}
