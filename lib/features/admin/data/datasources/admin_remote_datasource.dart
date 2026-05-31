import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// ADMIN REMOTE DATASOURCE
// ============================================================

abstract class AdminRemoteDataSource {
  Future<Map<String, dynamic>> getDashboard();
  Future<Map<String, dynamic>> getSystemSettings();
  Future<Map<String, dynamic>> updateSystemSettings(
      Map<String, dynamic> settings);
  Future<bool> testConnection(String system);
  Future<List<Map<String, dynamic>>> getAllAgents(
      {String? status, String? search});
  Future<Map<String, dynamic>> getAgentById(String agentId);
  Future<Map<String, dynamic>> createAgent(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateAgent(
      String agentId, Map<String, dynamic> data);
  Future<bool> blockAgent(String agentId, String reason);
  Future<bool> unblockAgent(String agentId);
  Future<bool> resetAgentPassword(String agentId);
  Future<List<Map<String, dynamic>>> getAllRestrictions();
  Future<Map<String, dynamic>> getAgentRestrictions(String agentId);
  Future<Map<String, dynamic>> updateRestrictions(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getDiscountPolicy();
  Future<Map<String, dynamic>> updateDiscountPolicy(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getSystemHealth();
  Future<List<Map<String, dynamic>>> getActiveAlerts();
  Future<bool> acknowledgeAlert(String alertId);
  Future<List<Map<String, dynamic>>> getAuditLog(
      {String? userId, String? action, int page = 1});
  Future<Map<String, dynamic>> getSalesReport(
      {required String fromDate, required String toDate});
  Future<Map<String, dynamic>> getAgentPerformance(String agentId,
      {required String fromDate, required String toDate});
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio _dio;
  AdminRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dio.get('/admin/dashboard');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Dashboard yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final response = await _dio.get('/admin/settings');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Sozlamalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> updateSystemSettings(
      Map<String, dynamic> settings) async {
    try {
      final response = await _dio.put('/admin/settings', data: settings);
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Sozlamalar yangilanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<bool> testConnection(String system) async {
    try {
      final response =
          await _dio.post('/admin/test-connection', data: {'system': system});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllAgents(
      {String? status, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;
      final response =
          await _dio.get('/admin/agents', queryParameters: queryParams);
      if (response.statusCode == 200)
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      throw ServerException(message: 'Agentlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getAgentById(String agentId) async {
    try {
      final response = await _dio.get('/admin/agents/$agentId');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Agent topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> createAgent(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/agents', data: data);
      if (response.statusCode == 201) return response.data;
      throw ServerException(message: 'Agent yaratilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> updateAgent(
      String agentId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/agents/$agentId', data: data);
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Agent yangilanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<bool> blockAgent(String agentId, String reason) async {
    try {
      final response = await _dio
          .post('/admin/agents/$agentId/block', data: {'reason': reason});
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<bool> unblockAgent(String agentId) async {
    try {
      final response = await _dio.post('/admin/agents/$agentId/unblock');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<bool> resetAgentPassword(String agentId) async {
    try {
      final response = await _dio.post('/admin/agents/$agentId/reset-password');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRestrictions() async {
    try {
      final response = await _dio.get('/admin/restrictions');
      if (response.statusCode == 200)
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      throw ServerException(message: 'Cheklovlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getAgentRestrictions(String agentId) async {
    try {
      final response = await _dio.get('/admin/restrictions/$agentId');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Cheklovlar topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> updateRestrictions(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/restrictions', data: data);
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Cheklovlar yangilanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getDiscountPolicy() async {
    try {
      final response = await _dio.get('/admin/discount-policy');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Siyosat yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> updateDiscountPolicy(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/discount-policy', data: data);
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Siyosat yangilanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final response = await _dio.get('/admin/system/health');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Tizim holati yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveAlerts() async {
    try {
      final response = await _dio.get('/admin/system/alerts');
      if (response.statusCode == 200)
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      throw ServerException(message: 'Ogohlantirishlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<bool> acknowledgeAlert(String alertId) async {
    try {
      final response =
          await _dio.post('/admin/system/alerts/$alertId/acknowledge');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAuditLog(
      {String? userId, String? action, int page = 1}) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (userId != null) queryParams['user_id'] = userId;
      if (action != null) queryParams['action'] = action;
      final response =
          await _dio.get('/admin/audit-log', queryParameters: queryParams);
      if (response.statusCode == 200)
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      throw ServerException(message: 'Audit log yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getSalesReport(
      {required String fromDate, required String toDate}) async {
    try {
      final response = await _dio.get('/admin/reports/sales',
          queryParameters: {'from': fromDate, 'to': toDate});
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Hisobot yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getAgentPerformance(String agentId,
      {required String fromDate, required String toDate}) async {
    try {
      final response = await _dio.get('/admin/reports/agents/$agentId',
          queryParameters: {'from': fromDate, 'to': toDate});
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Hisobot yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }
}
