import 'dart:convert';
import 'package:hive/hive.dart';

import '../../domain/entities/order_flow_entities.dart';
import '../../domain/entities/order_catalog_product.dart';

class OrderCatalogLocalDataSource {
  static const _boxName = 'order_catalog_cache';

  Future<void> cacheCustomers(List<OrderCustomer> customers) async {
    final box = await Hive.openBox(_boxName);
    await box.put(
        'customers', jsonEncode(customers.map(_customerToJson).toList()));
    await box.put('customers_cached_at', DateTime.now().toIso8601String());
  }

  Future<List<OrderCustomer>> getCachedCustomers({String? search}) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('customers');
    if (raw == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    final customers = list.map(_customerFromJson).toList();
    final query = search?.trim().toLowerCase() ?? '';
    if (query.isEmpty) return customers;
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
          customer.code.toLowerCase().contains(query) ||
          customer.address.toLowerCase().contains(query) ||
          customer.phone.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> cacheProducts(List<OrderCatalogProduct> products) async {
    final box = await Hive.openBox(_boxName);
    await box.put(
        'products', jsonEncode(products.map(_productToJson).toList()));
    await box.put('products_cached_at', DateTime.now().toIso8601String());
  }

  Future<List<OrderCatalogProduct>> getCachedProducts(
      {String? search, String? portfolioId, String? assortment}) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('products');
    if (raw == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    final query = search?.trim().toLowerCase() ?? '';
    return list.map(_productFromJson).where((product) {
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.id.toLowerCase().contains(query);
      final matchesPortfolio = portfolioId == null ||
          portfolioId == 'all' ||
          product.portfolioId == portfolioId;
      final matchesAssortment = assortment == null ||
          assortment == 'all' ||
          product.assortment == assortment;
      return matchesSearch && matchesPortfolio && matchesAssortment;
    }).toList();
  }

  Future<DateTime?> getCustomersCachedAt() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('customers_cached_at');
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<DateTime?> getProductsCachedAt() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('products_cached_at');
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Map<String, dynamic> _customerToJson(OrderCustomer c) => {
        'id': c.id,
        'code': c.code,
        'name': c.name,
        'legalName': c.legalName,
        'inn': c.inn,
        'address': c.address,
        'phone': c.phone,
        'email': c.email,
        'contactPerson': c.contactPerson,
        'latitude': c.latitude,
        'longitude': c.longitude,
        'agentId': c.agentId,
        'priceGroupId': c.priceGroupId,
        'paymentTerms': c.paymentTerms,
        'creditLimit': c.creditLimit,
        'currentDebt': c.currentDebt,
        'availableCredit': c.availableCredit,
        'paymentDelayDays': c.paymentDelayDays,
        'isActive': c.isActive,
        'isBlocked': c.isBlocked,
        'blockReason': c.blockReason,
        'lastOrderDate': c.lastOrderDate?.toIso8601String(),
        'lastOrderAmount': c.lastOrderAmount,
        'notes': c.notes,
      };

  OrderCustomer _customerFromJson(Map<String, dynamic> json) => OrderCustomer(
        id: json['id'] ?? '',
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        legalName: json['legalName'] ?? '',
        inn: json['inn'] ?? '',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
        contactPerson: json['contactPerson'],
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        agentId: json['agentId'] ?? '',
        priceGroupId: json['priceGroupId'] ?? '',
        paymentTerms: json['paymentTerms'] ?? 'NET30',
        creditLimit: (json['creditLimit'] ?? 0).toDouble(),
        currentDebt: (json['currentDebt'] ?? 0).toDouble(),
        availableCredit: (json['availableCredit'] ?? 0).toDouble(),
        paymentDelayDays: json['paymentDelayDays'] ?? 30,
        isActive: json['isActive'] ?? true,
        isBlocked: json['isBlocked'] ?? false,
        blockReason: json['blockReason'],
        lastOrderDate: DateTime.tryParse(json['lastOrderDate'] ?? ''),
        lastOrderAmount: (json['lastOrderAmount'] ?? 0).toDouble(),
        notes: json['notes'],
      );

  Map<String, dynamic> _productToJson(OrderCatalogProduct p) => {
        'id': p.id,
        'name': p.name,
        'category': p.category,
        'price': p.price,
        'stock': p.stock,
        'stockByWarehouse': p.stockByWarehouse,
        'portfolioId': p.portfolioId,
        'assortment': p.assortment,
        'source': p.source,
        'brand': p.brand,
      };

  OrderCatalogProduct _productFromJson(Map<String, dynamic> json) =>
      OrderCatalogProduct(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        stock: json['stock'] ?? 0,
        stockByWarehouse: Map<String, int>.from(json['stockByWarehouse'] ?? {}),
        portfolioId: json['portfolioId'] ?? '',
        assortment: json['assortment'] ?? 'optional',
        source: json['source'] ?? 'local',
        brand: json['brand'] ?? '',
      );
}
