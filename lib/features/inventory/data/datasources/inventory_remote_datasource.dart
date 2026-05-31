import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// INVENTORY REMOTE DATASOURCE
// ============================================================

abstract class InventoryRemoteDataSource {
  Future<List<Map<String, dynamic>>> getInventories({
    String? warehouseId,
    String? status,
    int page = 1,
  });
  Future<Map<String, dynamic>> getInventoryById(String id);
  Future<Map<String, dynamic>> startInventory(Map<String, dynamic> data);
  Future<Map<String, dynamic>> countItem(
      String inventoryId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> completeInventory(String id);
  Future<Map<String, dynamic>> submitInventory(String id);
  Future<Map<String, dynamic>> getResults(String id);
  Future<bool> syncTo1C(String id);
  Future<bool> syncToSAP(String id);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final Dio _dio;
  InventoryRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Map<String, dynamic>>> getInventories({
    String? warehouseId,
    String? status,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (warehouseId != null) queryParams['warehouse_id'] = warehouseId;
      if (status != null) queryParams['status'] = status;

      final response =
          await _dio.get('/inventory', queryParameters: queryParams);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Inventarizatsiyalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryById(String id) async {
    try {
      final response = await _dio.get('/inventory/$id');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Inventarizatsiya topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> startInventory(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/inventory', data: data);
      if (response.statusCode == 201) return response.data;
      throw ServerException(message: 'Inventarizatsiya boshlanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> countItem(
      String inventoryId, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/inventory/$inventoryId/count', data: data);
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Sanash xatoligi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> completeInventory(String id) async {
    try {
      final response = await _dio.post('/inventory/$id/complete');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Tugatish xatoligi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> submitInventory(String id) async {
    try {
      final response = await _dio.post('/inventory/$id/submit');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Yuborish xatoligi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getResults(String id) async {
    try {
      final response = await _dio.get('/inventory/$id/results');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Natijalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<bool> syncTo1C(String id) async {
    try {
      final response = await _dio.post('/inventory/$id/sync/1c');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> syncToSAP(String id) async {
    try {
      final response = await _dio.post('/inventory/$id/sync/sap');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
