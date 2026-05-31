import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/order_flow_entities.dart';
import '../../domain/entities/order_catalog_product.dart';

class OrderCatalogRemoteDataSource {
  final Dio dio;

  OrderCatalogRemoteDataSource(this.dio);

  Future<List<OrderCustomer>> getCustomers({String? search}) async {
    final response = await dio.get(ApiEndpoints.customers, queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final list = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    return list.map(_customerFromJson).toList();
  }

  Future<List<OrderCatalogProduct>> getProducts(
      {String? search, String? portfolioId, String? assortment}) async {
    final response = await dio.get(ApiEndpoints.products, queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (portfolioId != null && portfolioId != 'all')
        'portfolioId': portfolioId,
      if (assortment != null && assortment != 'all')
        'assortmentType': assortment,
      'onlyAllowedForUser': true,
    });
    final list = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    return list.map(_productFromJson).toList();
  }

  Future<int> getProductStock(
      {required String productId, required String warehouseId}) async {
    final response =
        await dio.get(ApiEndpoints.productStock(productId), queryParameters: {
      'warehouseId': warehouseId,
    });
    return response.data['availableQuantity'] ?? response.data['stock'] ?? 0;
  }

  OrderCustomer _customerFromJson(Map<String, dynamic> json) => OrderCustomer(
        id: json['id'] ?? '',
        code: json['code'] ?? '',
        name: json['name'] ?? json['customerName'] ?? '',
        legalName: json['legalName'] ?? json['legal_name'] ?? '',
        inn: json['inn'] ?? json['taxNumber'] ?? '',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
        contactPerson: json['contactPerson'],
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        agentId: json['agentId'] ?? json['agent_id'] ?? '',
        priceGroupId: json['priceGroupId'] ?? json['price_group_id'] ?? '',
        paymentTerms: json['paymentTerms'] ?? 'NET30',
        creditLimit: (json['creditLimit'] ?? 0).toDouble(),
        currentDebt: (json['currentDebt'] ?? 0).toDouble(),
        availableCredit: (json['availableCredit'] ?? 0).toDouble(),
        paymentDelayDays: json['paymentDelayDays'] ?? 30,
        isActive: json['isActive'] ?? true,
        isBlocked: json['isBlocked'] ?? false,
        blockReason: json['blockReason'],
        lastOrderAmount: (json['lastOrderAmount'] ?? 0).toDouble(),
      );

  String? _firstPortfolioId(Map<String, dynamic> json) {
    final ids = json['portfolioIds'];
    if (ids is List && ids.isNotEmpty) return ids.first.toString();
    return null;
  }

  OrderCatalogProduct _productFromJson(Map<String, dynamic> json) =>
      OrderCatalogProduct(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        category: json['categoryName'] ?? json['category'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        stock: json['stock'] ?? json['availableQuantity'] ?? 0,
        stockByWarehouse: json['stockByWarehouse'] == null
            ? const {}
            : Map<String, int>.from(json['stockByWarehouse']),
        portfolioId: _firstPortfolioId(json) ?? json['portfolioId'] ?? '',
        assortment: json['assortmentType'] ?? json['assortment'] ?? 'optional',
        source: json['sourceSystem'] ?? json['source'] ?? 'remote',
        brand: json['brand'] ?? '',
      );
}
