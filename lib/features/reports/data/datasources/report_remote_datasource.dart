import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// REPORT REMOTE DATASOURCE
// ============================================================

abstract class ReportRemoteDataSource {
  Future<Map<String, dynamic>> getSalesReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? agentId,
    String? regionId,
  });
  Future<Map<String, dynamic>> getDailyReport(String agentId, DateTime date);
  Future<Map<String, dynamic>> getAgentReport(
      String agentId, DateTime from, DateTime to);
  Future<List<Map<String, dynamic>>> getCustomerReport(
      DateTime from, DateTime to,
      {String? segment});
  Future<List<Map<String, dynamic>>> getProductReport(
      DateTime from, DateTime to,
      {String? categoryId});
  Future<Map<String, dynamic>> getPaymentReport(DateTime from, DateTime to);
  Future<Map<String, dynamic>> getDeliveryReport(DateTime from, DateTime to);
  Future<String> exportReport(Map<String, dynamic> params);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final Dio _dio;
  ReportRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getSalesReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? agentId,
    String? regionId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'from': fromDate.toIso8601String().substring(0, 10),
        'to': toDate.toIso8601String().substring(0, 10),
      };
      if (agentId != null) queryParams['agent_id'] = agentId;
      if (regionId != null) queryParams['region_id'] = regionId;

      final response =
          await _dio.get('/reports/sales', queryParameters: queryParams);
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Hisobot yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getDailyReport(
      String agentId, DateTime date) async {
    try {
      final response = await _dio.get('/reports/daily', queryParameters: {
        'agent_id': agentId,
        'date': date.toIso8601String().substring(0, 10),
      });
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Kunlik hisobot yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getAgentReport(
      String agentId, DateTime from, DateTime to) async {
    try {
      final response =
          await _dio.get('/reports/agents/$agentId', queryParameters: {
        'from': from.toIso8601String().substring(0, 10),
        'to': to.toIso8601String().substring(0, 10),
      });
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Agent hisoboti yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerReport(
      DateTime from, DateTime to,
      {String? segment}) async {
    try {
      final queryParams = <String, dynamic>{
        'from': from.toIso8601String().substring(0, 10),
        'to': to.toIso8601String().substring(0, 10),
      };
      if (segment != null) queryParams['segment'] = segment;

      final response =
          await _dio.get('/reports/customers', queryParameters: queryParams);
      if (response.statusCode == 200)
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      throw ServerException(message: 'Mijoz hisoboti yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProductReport(
      DateTime from, DateTime to,
      {String? categoryId}) async {
    try {
      final queryParams = <String, dynamic>{
        'from': from.toIso8601String().substring(0, 10),
        'to': to.toIso8601String().substring(0, 10),
      };
      if (categoryId != null) queryParams['category_id'] = categoryId;

      final response =
          await _dio.get('/reports/products', queryParameters: queryParams);
      if (response.statusCode == 200)
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      throw ServerException(message: 'Mahsulot hisoboti yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getPaymentReport(
      DateTime from, DateTime to) async {
    try {
      final response = await _dio.get('/reports/payments', queryParameters: {
        'from': from.toIso8601String().substring(0, 10),
        'to': to.toIso8601String().substring(0, 10),
      });
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'To\'lov hisoboti yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getDeliveryReport(
      DateTime from, DateTime to) async {
    try {
      final response = await _dio.get('/reports/delivery', queryParameters: {
        'from': from.toIso8601String().substring(0, 10),
        'to': to.toIso8601String().substring(0, 10),
      });
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Yetkazish hisoboti yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<String> exportReport(Map<String, dynamic> params) async {
    try {
      final response = await _dio.post('/reports/export', data: params);
      if (response.statusCode == 200) return response.data['file_url'] ?? '';
      throw ServerException(message: 'Export xatoligi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }
}
