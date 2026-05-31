import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// VISIT REMOTE DATASOURCE
// ============================================================

abstract class VisitRemoteDataSource {
  Future<List<Map<String, dynamic>>> getVisits({
    required String agentId,
    DateTime? date,
    String? status,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getVisitById(String visitId);
  Future<Map<String, dynamic>> createVisit(Map<String, dynamic> data);
  Future<Map<String, dynamic>> checkIn(String visitId, double lat, double lng);
  Future<Map<String, dynamic>> checkOut(
      String visitId, Map<String, dynamic> data);
  Future<bool> cancelVisit(String visitId, String reason);
  Future<Map<String, dynamic>> rescheduleVisit(
      String visitId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> getStatistics(
      String agentId, DateTime from, DateTime to);
  Future<List<Map<String, dynamic>>> getWeeklyPlan(
      String agentId, DateTime weekStart);
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final Dio _dio;
  VisitRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Map<String, dynamic>>> getVisits({
    required String agentId,
    DateTime? date,
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
      if (date != null)
        queryParams['date'] = date.toIso8601String().substring(0, 10);
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get('/visits', queryParameters: queryParams);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Tashriflar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getVisitById(String visitId) async {
    try {
      final response = await _dio.get('/visits/$visitId');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Tashrif topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> createVisit(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/visits', data: data);
      if (response.statusCode == 201) return response.data;
      throw ServerException(message: 'Tashrif yaratilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> checkIn(
      String visitId, double lat, double lng) async {
    try {
      final response = await _dio.post('/visits/$visitId/check-in', data: {
        'latitude': lat,
        'longitude': lng,
        'timestamp': DateTime.now().toIso8601String(),
      });
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Check-in xatosi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> checkOut(
      String visitId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/visits/$visitId/check-out', data: {
        ...data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Check-out xatosi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<bool> cancelVisit(String visitId, String reason) async {
    try {
      final response = await _dio.post('/visits/$visitId/cancel', data: {
        'reason': reason,
      });
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> rescheduleVisit(
      String visitId, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/visits/$visitId/reschedule', data: data);
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Qayta rejalashtirish xatosi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getStatistics(
      String agentId, DateTime from, DateTime to) async {
    try {
      final response = await _dio.get('/visits/statistics', queryParameters: {
        'agent_id': agentId,
        'from': from.toIso8601String().substring(0, 10),
        'to': to.toIso8601String().substring(0, 10),
      });
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Statistika yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWeeklyPlan(
      String agentId, DateTime weekStart) async {
    try {
      final response = await _dio.get('/visits/weekly-plan', queryParameters: {
        'agent_id': agentId,
        'week_start': weekStart.toIso8601String().substring(0, 10),
      });
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Haftalik reja yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }
}
