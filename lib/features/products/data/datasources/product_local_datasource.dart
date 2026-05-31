import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// PRODUCT LOCAL DATASOURCE - Offline mahsulotlar saqlash
// ============================================================

abstract class ProductLocalDataSource {
  // Products
  Future<void> cacheProducts(List<Map<String, dynamic>> products);
  Future<List<Map<String, dynamic>>> getCachedProducts({
    String? categoryId,
    String? search,
  });
  Future<void> saveProduct(Map<String, dynamic> product);
  Future<Map<String, dynamic>?> getProduct(String productId);
  Future<void> saveProductByBarcode(
      String barcode, Map<String, dynamic> product);
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode);

  // Categories
  Future<void> cacheCategories(List<Map<String, dynamic>> categories);
  Future<List<Map<String, dynamic>>> getCachedCategories();

  // Prices
  Future<void> cachePrices(List<Map<String, dynamic>> prices);
  Future<List<Map<String, dynamic>>> getCachedPrices({String? priceGroupId});

  // Stock
  Future<void> cacheStock(List<Map<String, dynamic>> stock);
  Future<List<Map<String, dynamic>>> getCachedStock({String? warehouseId});

  // Statistics
  Future<void> cacheStatistics(Map<String, dynamic> stats);
  Future<Map<String, dynamic>?> getCachedStatistics();

  // Sync
  Future<DateTime?> getLastSyncTime();
  Future<void> saveLastSyncTime();

  // Clear
  Future<void> clearAll();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String _productsBox = 'products';
  static const String _categoriesBox = 'product_categories';
  static const String _pricesBox = 'product_prices';
  static const String _stockBox = 'product_stock';
  static const String _statsBox = 'product_stats';

  @override
  Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    try {
      final box = await Hive.openBox(_productsBox);
      await box.put('products_list', jsonEncode(products));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Mahsulotlarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedProducts({
    String? categoryId,
    String? search,
  }) async {
    try {
      final box = await Hive.openBox(_productsBox);
      final data = box.get('products_list');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        var products = decoded.cast<Map<String, dynamic>>();

        if (categoryId != null) {
          products =
              products.where((p) => p['category_id'] == categoryId).toList();
        }
        if (search != null && search.isNotEmpty) {
          products = products
              .where((p) =>
                  p['name']
                      .toString()
                      .toLowerCase()
                      .contains(search.toLowerCase()) ||
                  p['code']
                      .toString()
                      .toLowerCase()
                      .contains(search.toLowerCase()) ||
                  (p['barcode'] ?? '').toString().contains(search))
              .toList();
        }

        return products;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveProduct(Map<String, dynamic> product) async {
    try {
      final box = await Hive.openBox(_productsBox);
      await box.put('product_${product['id']}', jsonEncode(product));
      if (product['barcode'] != null) {
        await box.put('barcode_${product['barcode']}', jsonEncode(product));
      }
    } catch (e) {
      throw CacheException(message: 'Mahsulotni saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      final box = await Hive.openBox(_productsBox);
      final data = box.get('product_$productId');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveProductByBarcode(
      String barcode, Map<String, dynamic> product) async {
    try {
      final box = await Hive.openBox(_productsBox);
      await box.put('barcode_$barcode', jsonEncode(product));
    } catch (e) {
      throw CacheException(message: 'Mahsulotni saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      final box = await Hive.openBox(_productsBox);
      final data = box.get('barcode_$barcode');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheCategories(List<Map<String, dynamic>> categories) async {
    try {
      final box = await Hive.openBox(_categoriesBox);
      await box.put('categories_list', jsonEncode(categories));
    } catch (e) {
      throw CacheException(message: 'Kategoriyalarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedCategories() async {
    try {
      final box = await Hive.openBox(_categoriesBox);
      final data = box.get('categories_list');
      if (data != null)
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cachePrices(List<Map<String, dynamic>> prices) async {
    try {
      final box = await Hive.openBox(_pricesBox);
      await box.put('prices_list', jsonEncode(prices));
    } catch (e) {
      throw CacheException(message: 'Narxlarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedPrices(
      {String? priceGroupId}) async {
    try {
      final box = await Hive.openBox(_pricesBox);
      final data = box.get('prices_list');
      if (data != null) {
        var prices = List<Map<String, dynamic>>.from(jsonDecode(data));
        if (priceGroupId != null) {
          prices =
              prices.where((p) => p['price_group_id'] == priceGroupId).toList();
        }
        return prices;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheStock(List<Map<String, dynamic>> stock) async {
    try {
      final box = await Hive.openBox(_stockBox);
      await box.put('stock_list', jsonEncode(stock));
    } catch (e) {
      throw CacheException(message: 'Ombor qoldiqlarini saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedStock(
      {String? warehouseId}) async {
    try {
      final box = await Hive.openBox(_stockBox);
      final data = box.get('stock_list');
      if (data != null) {
        var stock = List<Map<String, dynamic>>.from(jsonDecode(data));
        if (warehouseId != null) {
          stock = stock.where((s) => s['warehouse_id'] == warehouseId).toList();
        }
        return stock;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheStatistics(Map<String, dynamic> stats) async {
    try {
      final box = await Hive.openBox(_statsBox);
      await box.put('stats', jsonEncode(stats));
    } catch (e) {
      throw CacheException(message: 'Statistikani saqlashda xatolik');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedStatistics() async {
    try {
      final box = await Hive.openBox(_statsBox);
      final data = box.get('stats');
      if (data != null) return jsonDecode(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final box = await Hive.openBox(_productsBox);
      final time = box.get('cached_at');
      if (time != null) return DateTime.parse(time);
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveLastSyncTime() async {
    try {
      final box = await Hive.openBox(_productsBox);
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await Hive.openBox(_productsBox).then((b) => b.clear());
      await Hive.openBox(_categoriesBox).then((b) => b.clear());
      await Hive.openBox(_pricesBox).then((b) => b.clear());
      await Hive.openBox(_stockBox).then((b) => b.clear());
      await Hive.openBox(_statsBox).then((b) => b.clear());
    } catch (e) {
      throw CacheException(message: 'Tozalashda xatolik');
    }
  }
}
