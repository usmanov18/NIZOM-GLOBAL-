import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';

// ============================================================
// PRODUCT REMOTE DATASOURCE - 1C/SAP dan mahsulotlar
// ============================================================

abstract class ProductRemoteDataSource {
  /// Mahsulotlar katalogi
  Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    String? search,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    bool? hasDiscount,
    String? sortBy,
    bool ascending = true,
    int page = 1,
    int limit = 50,
  });

  /// Mahsulot tafsilotlari
  Future<Map<String, dynamic>> getProductById(String productId);

  /// Barcode bo'yicha qidirish
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode);

  /// Kategoriyalar
  Future<List<Map<String, dynamic>>> getCategories();

  /// Narx jadvallari
  Future<List<Map<String, dynamic>>> getPriceLists();

  /// Narx jadvali elementlari
  Future<List<Map<String, dynamic>>> getPriceListItems(String priceListId);

  /// Mahsulot narxi
  Future<Map<String, dynamic>> getProductPrice({
    required String productId,
    required String priceGroupId,
  });

  /// Omborlar
  Future<List<Map<String, dynamic>>> getWarehouses();

  /// Ombor qoldiqlari
  Future<List<Map<String, dynamic>>> getStockBalance({
    String? warehouseId,
    String? productId,
    String? categoryId,
    bool? lowStock,
    bool? outOfStock,
  });

  /// 1C dan mahsulotlarni yuklash
  Future<List<Map<String, dynamic>>> syncProductsFrom1C({
    DateTime? sinceDate,
    String? categoryId,
    int top = 500,
    int skip = 0,
  });

  /// SAP dan mahsulotlarni yuklash
  Future<List<Map<String, dynamic>>> syncProductsFromSAP({
    DateTime? sinceDate,
    String? materialGroup,
    int top = 500,
    int skip = 0,
  });

  /// 1C dan kategoriyalarni yuklash
  Future<List<Map<String, dynamic>>> syncCategoriesFrom1C();

  /// SAP dan kategoriyalarni yuklash
  Future<List<Map<String, dynamic>>> syncCategoriesFromSAP();

  /// 1C dan narxlarni yuklash
  Future<List<Map<String, dynamic>>> syncPricesFrom1C({String? priceGroupId});

  /// SAP dan narxlarni yuklash
  Future<List<Map<String, dynamic>>> syncPricesFromSAP({String? priceGroupId});

  /// 1C dan ombor qoldiqlarini yuklash
  Future<List<Map<String, dynamic>>> syncStockFrom1C({String? warehouseId});

  /// SAP dan ombor qoldiqlarini yuklash
  Future<List<Map<String, dynamic>>> syncStockFromSAP({String? warehouseId});

  /// Yangi mahsulot yaratish
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data);

  /// Mahsulotni yangilash
  Future<Map<String, dynamic>> updateProduct(
    String productId,
    Map<String, dynamic> data,
  );

  /// Mahsulotni o'chirish
  Future<bool> deactivateProduct(String productId);

  /// CSV import
  Future<int> importFromCSV(String filePath);

  /// CSV export
  Future<String> exportToCSV({String? categoryId, bool? activeOnly});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio _dio;
  final Dio _oneCDio;
  final Dio _sapDio;

  ProductRemoteDataSourceImpl({
    required Dio dio,
    required Dio oneCDio,
    required Dio sapDio,
  })  : _dio = dio,
        _oneCDio = oneCDio,
        _sapDio = sapDio;

  @override
  Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    String? search,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    bool? hasDiscount,
    String? sortBy,
    bool ascending = true,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null) queryParams['search'] = search;
      if (brand != null) queryParams['brand'] = brand;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (inStock != null) queryParams['in_stock'] = inStock;
      if (hasDiscount != null) queryParams['has_discount'] = hasDiscount;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      queryParams['ascending'] = ascending;

      final response = await _dio.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Mahsulotlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      final response = await _dio.get(ApiEndpoints.productById(productId));
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Mahsulot topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.products,
        queryParameters: {'barcode': barcode},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        if (data.isNotEmpty) return data.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get(ApiEndpoints.productCategories);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Kategoriyalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPriceLists() async {
    try {
      final response = await _dio.get('/products/price-lists');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Narx jadvallari yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPriceListItems(
      String priceListId) async {
    try {
      final response =
          await _dio.get('/products/price-lists/$priceListId/items');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Narx elementlari yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductPrice({
    required String productId,
    required String priceGroupId,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.productPrice(productId),
        queryParameters: {'price_group_id': priceGroupId},
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Narx topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWarehouses() async {
    try {
      final response = await _dio.get(ApiEndpoints.warehouses);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Omborlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStockBalance({
    String? warehouseId,
    String? productId,
    String? categoryId,
    bool? lowStock,
    bool? outOfStock,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (warehouseId != null) queryParams['warehouse_id'] = warehouseId;
      if (productId != null) queryParams['product_id'] = productId;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (lowStock != null) queryParams['low_stock'] = lowStock;
      if (outOfStock != null) queryParams['out_of_stock'] = outOfStock;

      final response = await _dio.get(
        ApiEndpoints.stock,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Ombor qoldiqlari yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncProductsFrom1C({
    DateTime? sinceDate,
    String? categoryId,
    int top = 500,
    int skip = 0,
  }) async {
    try {
      final filters = <String>['DeletionMark eq false'];
      if (sinceDate != null) {
        filters.add("Modified gt datetime'${sinceDate.toIso8601String()}'");
      }
      if (categoryId != null) {
        filters.add("ProductCategory_Key eq guid'$categoryId'");
      }

      final response = await _oneCDio.get(
        '/catalog/Products',
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
      throw ServerException(message: '1C dan mahsulotlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '1C server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncProductsFromSAP({
    DateTime? sinceDate,
    String? materialGroup,
    int top = 500,
    int skip = 0,
  }) async {
    try {
      final filters = <String>['IsMarkedForDeletion eq false'];
      if (materialGroup != null) {
        filters.add("MaterialGroup eq '$materialGroup'");
      }

      final response = await _sapDio.get(
        '/API_PRODUCT_SRV/A_Product',
        queryParameters: {
          if (filters.isNotEmpty) r'$filter': filters.join(' and '),
          r'$orderby': 'MaterialDescription asc',
          r'$top': top,
          r'$skip': skip,
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['d']['results'] ?? []);
      }
      throw ServerException(message: 'SAP dan mahsulotlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'SAP server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncCategoriesFrom1C() async {
    try {
      final response = await _oneCDio.get(
        '/catalog/ProductCategories',
        queryParameters: {r'$format': 'json'},
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['value'] ?? []);
      }
      throw ServerException(message: '1C dan kategoriyalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '1C server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncCategoriesFromSAP() async {
    try {
      final response = await _sapDio.get(
        '/API_PRODUCT_SRV/A_ProductGroupType',
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['d']['results'] ?? []);
      }
      throw ServerException(message: 'SAP dan kategoriyalar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'SAP server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncPricesFrom1C(
      {String? priceGroupId}) async {
    try {
      final filters = <String>[];
      if (priceGroupId != null) {
        filters.add("PriceGroup_Key eq guid'$priceGroupId'");
      }

      final response = await _oneCDio.get(
        '/infoRegister/Prices',
        queryParameters: {
          if (filters.isNotEmpty) r'$filter': filters.join(' and '),
          r'$format': 'json',
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['value'] ?? []);
      }
      throw ServerException(message: '1C dan narxlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '1C server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncPricesFromSAP(
      {String? priceGroupId}) async {
    try {
      final response = await _sapDio.get(
        '/API_PRICING_CONDITION_SRV/A_PricingCondition',
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['d']['results'] ?? []);
      }
      throw ServerException(message: 'SAP dan narxlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'SAP server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncStockFrom1C(
      {String? warehouseId}) async {
    try {
      final filters = <String>[];
      if (warehouseId != null) {
        filters.add("Warehouse_Key eq guid'$warehouseId'");
      }

      final response = await _oneCDio.get(
        '/accumulationRegister/StockBalance',
        queryParameters: {
          if (filters.isNotEmpty) r'$filter': filters.join(' and '),
          r'$format': 'json',
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['value'] ?? []);
      }
      throw ServerException(message: '1C dan qoldiqlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '1C server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> syncStockFromSAP(
      {String? warehouseId}) async {
    try {
      final filters = <String>[];
      if (warehouseId != null) {
        filters.add("Plant eq '$warehouseId'");
      }

      final response = await _sapDio.get(
        '/API_MATERIAL_STOCK_SRV/A_MatlStockLevel',
        queryParameters: {
          if (filters.isNotEmpty) r'$filter': filters.join(' and '),
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['d']['results'] ?? []);
      }
      throw ServerException(message: 'SAP dan qoldiqlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'SAP server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.products, data: data);
      if (response.statusCode == 201) return response.data;
      throw ServerException(message: 'Mahsulot yaratilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.productById(productId),
        data: data,
      );
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Mahsulot yangilanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<bool> deactivateProduct(String productId) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.productById(productId),
        data: {'is_active': false},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<int> importFromCSV(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists())
        throw ServerException(message: 'CSV fayl topilmadi');
      final lines = await file.readAsLines();
      if (lines.isEmpty) return 0;
      return lines.skip(1).where((line) => line.trim().isNotEmpty).length;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Import xatosi');
    }
  }

  @override
  Future<String> exportToCSV({String? categoryId, bool? activeOnly}) async {
    try {
      final products =
          await getProducts(categoryId: categoryId, inStock: activeOnly);
      final path =
          '/tmp/nizom_global_products_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      final buffer = StringBuffer('id,code,name,category,price,stock\n');
      for (final item in products) {
        buffer.writeln([
          item['id'] ?? item['Ref_Key'] ?? '',
          item['code'] ?? item['Code'] ?? '',
          _csv(item['name'] ?? item['Description'] ?? ''),
          _csv(item['category_name'] ??
              item['ProductCategory_Description'] ??
              ''),
          item['price'] ?? item['Price'] ?? '',
          item['stock'] ?? item['Stock'] ?? '',
        ].join(','));
      }
      await file.writeAsString(buffer.toString());
      return path;
    } catch (e) {
      throw ServerException(message: 'Export xatosi');
    }
  }

  String _csv(dynamic value) {
    final text = value.toString().replaceAll('"', '""');
    return '"$text"';
  }
}
