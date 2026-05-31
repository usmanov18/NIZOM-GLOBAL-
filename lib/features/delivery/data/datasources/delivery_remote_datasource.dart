import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// DELIVERY REMOTE DATASOURCE - Server bilan ishlash
// ============================================================

abstract class DeliveryRemoteDataSource {
  // Dashboard
  Future<Map<String, dynamic>> getDriverStatus(String driverId);

  // Deliveries
  Future<List<Map<String, dynamic>>> getDeliveries({
    required String driverId,
    String? status,
    DateTime? date,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getDeliveryDetails(String deliveryId);

  // Actions
  Future<Map<String, dynamic>> pickOrder({
    required String deliveryId,
    List<Map<String, dynamic>>? pickedItems,
  });
  Future<Map<String, dynamic>> depart({
    required String deliveryId,
    required double latitude,
    required double longitude,
  });
  Future<Map<String, dynamic>> arrive({
    required String deliveryId,
    required double latitude,
    required double longitude,
  });
  Future<Map<String, dynamic>> confirmDelivery(
      Map<String, dynamic> confirmation);
  Future<Map<String, dynamic>> markAsFailed({
    required String deliveryId,
    required String reason,
    String? notes,
    required double latitude,
    required double longitude,
  });
  Future<Map<String, dynamic>> markAsReturned({
    required String deliveryId,
    required List<Map<String, dynamic>> returnedItems,
    required String returnReason,
    String? notes,
  });

  // Route
  Future<Map<String, dynamic>> getRoute({
    required String driverId,
    required DateTime date,
  });
  Future<Map<String, dynamic>> optimizeRoute({
    required String driverId,
    required List<String> deliveryIds,
  });
  Future<Map<String, dynamic>> startRoute({
    required String routeId,
    required double latitude,
    required double longitude,
  });
  Future<Map<String, dynamic>> completeRoute(String routeId);

  // GPS
  Future<bool> sendLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    double? altitude,
    double? accuracy,
    double? speed,
    double? heading,
  });
  Future<List<Map<String, dynamic>>> getDailyTrack({
    required String driverId,
    required DateTime date,
  });
  Future<List<Map<String, dynamic>>> getAllDriversStatus();

  // Sync
  Future<Map<String, dynamic>> syncDeliveryTo1C(String deliveryId);
  Future<Map<String, dynamic>> syncDeliveryToSAP(String deliveryId);
  Future<List<Map<String, dynamic>>> getPendingSyncDeliveries();
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final Dio _dio;

  DeliveryRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getDriverStatus(String driverId) async {
    try {
      final response = await _dio.get('/delivery/drivers/$driverId/status');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Haydovchi holati yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(
          message: e.message ?? 'Server xatosi',
          statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDeliveries({
    required String driverId,
    String? status,
    DateTime? date,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'driver_id': driverId,
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;
      if (date != null)
        queryParams['date'] = date.toIso8601String().substring(0, 10);

      final response =
          await _dio.get('/delivery/orders', queryParameters: queryParams);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Yetkazishlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getDeliveryDetails(String deliveryId) async {
    try {
      final response = await _dio.get('/delivery/orders/$deliveryId');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Yetkazish topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> pickOrder({
    required String deliveryId,
    List<Map<String, dynamic>>? pickedItems,
  }) async {
    try {
      final response = await _dio.post(
        '/delivery/orders/$deliveryId/pick',
        data: {
          'timestamp': DateTime.now().toIso8601String(),
          if (pickedItems != null) 'items': pickedItems,
        },
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Buyurtma olishda xatolik');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> depart({
    required String deliveryId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/delivery/orders/$deliveryId/depart',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Yo\'lga chiqishda xatolik');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> arrive({
    required String deliveryId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/delivery/orders/$deliveryId/arrive',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Yetib kelishda xatolik');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> confirmDelivery(
      Map<String, dynamic> confirmation) async {
    try {
      final response = await _dio.post(
        '/delivery/confirm',
        data: confirmation,
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Yetkazish tasdiqlanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> markAsFailed({
    required String deliveryId,
    required String reason,
    String? notes,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/delivery/orders/$deliveryId/fail',
        data: {
          'reason': reason,
          'notes': notes,
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Xatolik belgilanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> markAsReturned({
    required String deliveryId,
    required List<Map<String, dynamic>> returnedItems,
    required String returnReason,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/delivery/orders/$deliveryId/return',
        data: {
          'items': returnedItems,
          'reason': returnReason,
          'notes': notes,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Qaytarish belgilanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getRoute({
    required String driverId,
    required DateTime date,
  }) async {
    try {
      final response = await _dio.get(
        '/delivery/routes/$driverId',
        queryParameters: {'date': date.toIso8601String().substring(0, 10)},
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Marshrut yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> optimizeRoute({
    required String driverId,
    required List<String> deliveryIds,
  }) async {
    try {
      final response = await _dio.post(
        '/delivery/routes/optimize',
        data: {
          'driver_id': driverId,
          'delivery_ids': deliveryIds,
        },
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Marshrut optimallashtirilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> startRoute({
    required String routeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/delivery/routes/$routeId/start',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Marshrut boshlanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> completeRoute(String routeId) async {
    try {
      final response = await _dio.post('/delivery/routes/$routeId/complete');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Marshrut tugatilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<bool> sendLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    double? altitude,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    try {
      final response = await _dio.post(
        '/delivery/location',
        data: {
          'driver_id': driverId,
          'latitude': latitude,
          'longitude': longitude,
          'altitude': altitude,
          'accuracy': accuracy,
          'speed': speed,
          'heading': heading,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyTrack({
    required String driverId,
    required DateTime date,
  }) async {
    try {
      final response = await _dio.get(
        '/delivery/tracks/$driverId',
        queryParameters: {'date': date.toIso8601String().substring(0, 10)},
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Marshrut tarixi yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllDriversStatus() async {
    try {
      final response = await _dio.get('/delivery/drivers/status');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Haydovchilar holati yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> syncDeliveryTo1C(String deliveryId) async {
    try {
      final response = await _dio.post('/delivery/$deliveryId/sync/1c');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: '1C ga sinxronlash muvaffaqiyatsiz');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> syncDeliveryToSAP(String deliveryId) async {
    try {
      final response = await _dio.post('/delivery/$deliveryId/sync/sap');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'SAP ga sinxronlash muvaffaqiyatsiz');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncDeliveries() async {
    try {
      final response = await _dio.get('/delivery/pending-sync');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Sinxronlash buyurtmalari yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }
}
