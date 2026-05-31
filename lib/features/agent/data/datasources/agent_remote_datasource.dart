import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';

// ============================================================
// AGENT REMOTE DATASOURCE - 1C/SAP API dan ma'lumot olish
// ============================================================

abstract class AgentRemoteDataSource {
  Future<Map<String, dynamic>> getDashboard(String agentId);
  Future<List<Map<String, dynamic>>> getOrders({
    required String agentId,
    String? status,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getOrderDetails(String orderId);
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData);
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
    String? comment,
  });
  Future<List<Map<String, dynamic>>> getCustomers({
    required String agentId,
    String? search,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getCustomerDetails(String customerId);
  Future<List<Map<String, dynamic>>> getVisits({
    required String agentId,
    DateTime? date,
    String? status,
  });
  Future<Map<String, dynamic>> checkInVisit({
    required String visitId,
    required double latitude,
    required double longitude,
  });
  Future<Map<String, dynamic>> checkOutVisit({
    required String visitId,
    String? notes,
    double? orderAmount,
  });
  Future<Map<String, dynamic>> getKPI({
    required String agentId,
    required String period,
  });
  Future<Map<String, dynamic>> getDailyReport({
    required String agentId,
    required DateTime date,
  });
}

class AgentRemoteDataSourceImpl implements AgentRemoteDataSource {
  final Dio _dio;

  AgentRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getDashboard(String agentId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.agentDashboard}/$agentId',
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      throw ServerException(message: 'Dashboard yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrders({
    required String agentId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'agent_id': agentId,
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        ApiEndpoints.agentOrders,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }

      throw ServerException(message: 'Buyurtmalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.orderById(orderId),
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      throw ServerException(message: 'Buyurtma topilmadi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.orders,
        data: orderData,
      );

      if (response.statusCode == 201) {
        return response.data;
      }

      throw ServerException(message: 'Buyurtma yaratilmadi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
    String? comment,
  }) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.orderStatus(orderId),
        data: {
          'status': status,
          if (comment != null) 'comment': comment,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      throw ServerException(message: 'Holat yangilanmadi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomers({
    required String agentId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'agent_id': agentId,
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        ApiEndpoints.agentClients,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }

      throw ServerException(message: 'Mijozlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getCustomerDetails(String customerId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.customerById(customerId),
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      throw ServerException(message: 'Mijoz topilmadi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getVisits({
    required String agentId,
    DateTime? date,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'agent_id': agentId,
      };

      if (date != null) {
        queryParams['date'] = date.toIso8601String().substring(0, 10);
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        ApiEndpoints.agentVisits,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }

      throw ServerException(message: 'Tashriflar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> checkInVisit({
    required String visitId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.visitCheckIn,
        data: {
          'visit_id': visitId,
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      throw ServerException(message: 'Check-in xatosi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> checkOutVisit({
    required String visitId,
    String? notes,
    double? orderAmount,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.visitCheckOut,
        data: {
          'visit_id': visitId,
          'timestamp': DateTime.now().toIso8601String(),
          if (notes != null) 'notes': notes,
          if (orderAmount != null) 'order_amount': orderAmount,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      throw ServerException(message: 'Check-out xatosi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getKPI({
    required String agentId,
    required String period,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.agentKPI,
        queryParameters: {
          'agent_id': agentId,
          'period': period,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      throw ServerException(message: 'KPI yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getDailyReport({
    required String agentId,
    required DateTime date,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.agentDailyReport(date.toIso8601String().substring(0, 10)),
        queryParameters: {'agent_id': agentId},
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      throw ServerException(message: 'Hisobot yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Server xatosi',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
