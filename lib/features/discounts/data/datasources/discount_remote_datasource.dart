import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// DISCOUNT REMOTE DATASOURCE - 1C/SAP dan chegirmalar
// ============================================================

abstract class DiscountRemoteDataSource {
  /// Faol chegirmalar
  Future<List<Map<String, dynamic>>> getActiveDiscounts({
    String? priceGroupId,
    String? productId,
    String? categoryId,
  });

  /// Mahsulotga qo'llanadigan chegirmalar
  Future<List<Map<String, dynamic>>> getDiscountsForProduct({
    required String productId,
    required String priceGroupId,
    required double quantity,
    required double amount,
  });

  /// Chegirma tafsilotlari
  Future<Map<String, dynamic>> getDiscountById(String id);

  /// Faol promolar
  Future<List<Map<String, dynamic>>> getActivePromotions({
    String? customerGroup,
    String? region,
  });

  /// Promo tafsilotlari
  Future<Map<String, dynamic>> getPromotionById(String id);

  /// Promo kodni tekshirish
  Future<Map<String, dynamic>> validatePromoCode(String code);

  /// Maxsus narxlar
  Future<List<Map<String, dynamic>>> getSpecialPrices({
    required String priceGroupId,
    List<String>? productIds,
  });

  /// 1C dan chegirmalarni yuklash
  Future<List<Map<String, dynamic>>> syncDiscountsFrom1C({DateTime? sinceDate});

  /// SAP dan chegirmalarni yuklash
  Future<List<Map<String, dynamic>>> syncDiscountsFromSAP(
      {DateTime? sinceDate});

  /// 1C dan promolarni yuklash
  Future<List<Map<String, dynamic>>> syncPromotionsFrom1C(
      {DateTime? sinceDate});

  /// SAP dan promolarni yuklash
  Future<List<Map<String, dynamic>>> syncPromotionsFromSAP(
      {DateTime? sinceDate});

  /// 1C dan maxsus narxlarni yuklash
  Future<List<Map<String, dynamic>>> syncSpecialPricesFrom1C(
      {String? priceGroupId});

  /// SAP dan maxsus narxlarni yuklash
  Future<List<Map<String, dynamic>>> syncSpecialPricesFromSAP(
      {String? priceGroupId});
}

class DiscountRemoteDataSourceImpl implements DiscountRemoteDataSource {
  final Dio _dio;
  final Dio _oneCDio;
  final Dio _sapDio;

  DiscountRemoteDataSourceImpl({
    required Dio dio,
    required Dio oneCDio,
    required Dio sapDio,
  })  : _dio = dio,
        _oneCDio = oneCDio,
        _sapDio = sapDio;

  @override
  Future<List<Map<String, dynamic>>> getActiveDiscounts({
    String? priceGroupId,
    String? productId,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (priceGroupId != null) queryParams['price_group_id'] = priceGroupId;
      if (productId != null) queryParams['product_id'] = productId;
      if (categoryId != null) queryParams['category_id'] = categoryId;

      final response =
          await _dio.get('/discounts', queryParameters: queryParams);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Chegirmalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDiscountsForProduct({
    required String productId,
    required String priceGroupId,
    required double quantity,
    required double amount,
  }) async {
    try {
      final response = await _dio.get(
        '/discounts/product/$productId',
        queryParameters: {
          'price_group_id': priceGroupId,
          'quantity': quantity,
          'amount': amount,
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Chegirmalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getDiscountById(String id) async {
    try {
      final response = await _dio.get('/discounts/$id');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Chegirma topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getActivePromotions({
    String? customerGroup,
    String? region,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (customerGroup != null) queryParams['customer_group'] = customerGroup;
      if (region != null) queryParams['region'] = region;

      final response =
          await _dio.get('/promotions', queryParameters: queryParams);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Promolar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getPromotionById(String id) async {
    try {
      final response = await _dio.get('/promotions/$id');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Promo topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> validatePromoCode(String code) async {
    try {
      final response =
          await _dio.post('/promotions/validate', data: {'code': code});
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Promo kod noto\'g\'ri');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSpecialPrices({
    required String priceGroupId,
    List<String>? productIds,
  }) async {
    try {
      final response = await _dio.get(
        '/prices/special',
        queryParameters: {
          'price_group_id': priceGroupId,
          if (productIds != null) 'product_ids': productIds.join(','),
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Maxsus narxlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncDiscountsFrom1C(
      {DateTime? sinceDate}) async {
    try {
      final filters = <String>['IsActive eq true'];
      if (sinceDate != null) {
        filters.add("Modified gt datetime'${sinceDate.toIso8601String()}'");
      }

      final response = await _oneCDio.get(
        '/catalog/Discounts',
        queryParameters: {
          r'$filter': filters.join(' and '),
          r'$format': 'json',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['value'] ?? []);
      }
      throw ServerException(message: '1C dan chegirmalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '1C server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncDiscountsFromSAP(
      {DateTime? sinceDate}) async {
    try {
      final response = await _sapDio.get(
        '/API_PRICING_CONDITION_SRV/A_PricingCondition',
        queryParameters: {
          r'$filter': "ConditionType eq 'ZDIS'",
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['d']['results'] ?? []);
      }
      throw ServerException(message: 'SAP dan chegirmalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'SAP server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncPromotionsFrom1C(
      {DateTime? sinceDate}) async {
    try {
      final response = await _oneCDio.get(
        '/catalog/Promotions',
        queryParameters: {r'$format': 'json'},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['value'] ?? []);
      }
      throw ServerException(message: '1C dan promolar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '1C server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncPromotionsFromSAP(
      {DateTime? sinceDate}) async {
    try {
      return [];
    } catch (e) {
      throw ServerException(message: 'SAP dan promolar yuklanmadi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncSpecialPricesFrom1C(
      {String? priceGroupId}) async {
    try {
      final response = await _oneCDio.get(
        '/catalog/SpecialPrices',
        queryParameters: {r'$format': 'json'},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['value'] ?? []);
      }
      throw ServerException(message: '1C dan maxsus narxlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '1C server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncSpecialPricesFromSAP(
      {String? priceGroupId}) async {
    try {
      return [];
    } catch (e) {
      throw ServerException(message: 'SAP dan maxsus narxlar yuklanmadi');
    }
  }
}
