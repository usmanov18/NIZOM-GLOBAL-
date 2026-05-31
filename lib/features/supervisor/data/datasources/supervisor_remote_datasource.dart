import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// SUPERVISOR REMOTE DATASOURCE
// ============================================================

abstract class SupervisorRemoteDataSource {
  Future<Map<String, dynamic>> getDashboard(String supervisorId);
  Future<List<Map<String, dynamic>>> getAgentsStatus(String supervisorId);
  Future<Map<String, dynamic>> getAgentDetail(String agentId);
  Future<List<Map<String, dynamic>>> getAgentRoute(
      String agentId, DateTime date);
  Future<List<Map<String, dynamic>>> getTasks(
      {required String supervisorId, String? agentId, String? status});
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateTask(
      String taskId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> getSchedule(String agentId);
  Future<Map<String, dynamic>> updateSchedule(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getStatistics(
      String supervisorId, DateTime from, DateTime to);
}

class SupervisorRemoteDataSourceImpl implements SupervisorRemoteDataSource {
  final Dio _dio;
  SupervisorRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getDashboard(String supervisorId) async {
    try {
      final response = await _dio.get('/supervisor/$supervisorId/dashboard');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Dashboard yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAgentsStatus(
      String supervisorId) async {
    try {
      final response = await _dio.get('/supervisor/$supervisorId/agents');
      if (response.statusCode == 200)
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      throw ServerException(message: 'Agentlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getAgentDetail(String agentId) async {
    try {
      final response = await _dio.get('/agents/$agentId/detail');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Agent topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAgentRoute(
      String agentId, DateTime date) async {
    try {
      final response =
          await _dio.get('/agents/$agentId/route', queryParameters: {
        'date': date.toIso8601String().substring(0, 10),
      });
      if (response.statusCode == 200)
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      throw ServerException(message: 'Marshrut yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTasks(
      {required String supervisorId, String? agentId, String? status}) async {
    try {
      final queryParams = <String, dynamic>{'supervisor_id': supervisorId};
      if (agentId != null) queryParams['agent_id'] = agentId;
      if (status != null) queryParams['status'] = status;

      final response =
          await _dio.get('/supervisor/tasks', queryParameters: queryParams);
      if (response.statusCode == 200)
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      throw ServerException(message: 'Vazifalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/supervisor/tasks', data: data);
      if (response.statusCode == 201) return response.data;
      throw ServerException(message: 'Vazifa yaratilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> updateTask(
      String taskId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/supervisor/tasks/$taskId', data: data);
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Vazifa yangilanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getSchedule(String agentId) async {
    try {
      final response = await _dio.get('/agents/$agentId/schedule');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Jadval yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> updateSchedule(Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('/agents/${data['agent_id']}/schedule', data: data);
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Jadval yangilanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getStatistics(
      String supervisorId, DateTime from, DateTime to) async {
    try {
      final response = await _dio
          .get('/supervisor/$supervisorId/statistics', queryParameters: {
        'from': from.toIso8601String().substring(0, 10),
        'to': to.toIso8601String().substring(0, 10),
      });
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Statistika yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }
}
