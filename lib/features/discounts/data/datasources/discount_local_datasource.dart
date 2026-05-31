import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';

// ============================================================
// DISCOUNT LOCAL DATASOURCE - Offline chegirmalar saqlash
// ============================================================

abstract class DiscountLocalDataSource {
  Future<void> cacheDiscounts(List<Map<String, dynamic>> discounts);
  Future<List<Map<String, dynamic>>> getCachedDiscounts({String? priceGroupId});
  Future<void> cachePromotions(List<Map<String, dynamic>> promotions);
  Future<List<Map<String, dynamic>>> getCachedPromotions();
  Future<void> cacheSpecialPrices(List<Map<String, dynamic>> prices);
  Future<List<Map<String, dynamic>>> getCachedSpecialPrices(
      {String? priceGroupId});
  Future<DateTime?> getLastSyncTime();
  Future<void> saveLastSyncTime();
  Future<void> clearAll();
}

class DiscountLocalDataSourceImpl implements DiscountLocalDataSource {
  static const String _discountsBox = 'discounts';
  static const String _promotionsBox = 'promotions';
  static const String _specialPricesBox = 'special_prices';

  @override
  Future<void> cacheDiscounts(List<Map<String, dynamic>> discounts) async {
    try {
      final box = await Hive.openBox(_discountsBox);
      await box.put('discounts_list', jsonEncode(discounts));
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Chegirmalarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedDiscounts(
      {String? priceGroupId}) async {
    try {
      final box = await Hive.openBox(_discountsBox);
      final data = box.get('discounts_list');
      if (data != null) {
        var discounts = List<Map<String, dynamic>>.from(jsonDecode(data));
        if (priceGroupId != null) {
          discounts = discounts
              .where((d) => d['price_group_id'] == priceGroupId)
              .toList();
        }
        return discounts;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cachePromotions(List<Map<String, dynamic>> promotions) async {
    try {
      final box = await Hive.openBox(_promotionsBox);
      await box.put('promotions_list', jsonEncode(promotions));
    } catch (e) {
      throw CacheException(message: 'Promolarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedPromotions() async {
    try {
      final box = await Hive.openBox(_promotionsBox);
      final data = box.get('promotions_list');
      if (data != null)
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheSpecialPrices(List<Map<String, dynamic>> prices) async {
    try {
      final box = await Hive.openBox(_specialPricesBox);
      await box.put('special_prices_list', jsonEncode(prices));
    } catch (e) {
      throw CacheException(message: 'Maxsus narxlarni saqlashda xatolik');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedSpecialPrices(
      {String? priceGroupId}) async {
    try {
      final box = await Hive.openBox(_specialPricesBox);
      final data = box.get('special_prices_list');
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
  Future<DateTime?> getLastSyncTime() async {
    try {
      final box = await Hive.openBox(_discountsBox);
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
      final box = await Hive.openBox(_discountsBox);
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await Hive.openBox(_discountsBox).then((b) => b.clear());
      await Hive.openBox(_promotionsBox).then((b) => b.clear());
      await Hive.openBox(_specialPricesBox).then((b) => b.clear());
    } catch (e) {
      throw CacheException(message: 'Tozalashda xatolik');
    }
  }
}
