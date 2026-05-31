import 'package:equatable/equatable.dart';

/// Buyurtma katalogida ko'rsatiladigan mahsulot view modeli.
///
/// Bu entity data source va presentation qatlamlari orasida neutral tip sifatida
/// ishlatiladi. U 1C/SAP/API/local cache formatlaridan mustaqil.
class OrderCatalogProduct extends Equatable {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final Map<String, int> stockByWarehouse;
  final String portfolioId;
  final String assortment;
  final String source;
  final String brand;

  const OrderCatalogProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.stockByWarehouse = const {},
    required this.portfolioId,
    required this.assortment,
    required this.source,
    required this.brand,
  });

  factory OrderCatalogProduct.fromJson(Map<String, dynamic> json) {
    return OrderCatalogProduct(
      id: (json['id'] ??
              json['product_id'] ??
              json['Ref_Key'] ??
              json['Material'] ??
              '')
          .toString(),
      name: (json['name'] ??
              json['product_name'] ??
              json['Description'] ??
              json['MaterialDescription'] ??
              '')
          .toString(),
      category: (json['category'] ??
              json['category_name'] ??
              json['ProductCategory_Description'] ??
              json['MaterialGroupName'] ??
              '')
          .toString(),
      price: (json['price'] ??
              json['base_price'] ??
              json['BasePrice'] ??
              json['StandardPrice'] ??
              0)
          .toDouble(),
      stock: (json['stock'] ??
              json['available_quantity'] ??
              json['AvailableQuantity'] ??
              json['StockQuantity'] ??
              0)
          .toInt(),
      stockByWarehouse: json['stockByWarehouse'] is Map
          ? Map<String, int>.from(json['stockByWarehouse'])
          : json['stock_by_warehouse'] is Map
              ? Map<String, int>.from(json['stock_by_warehouse'])
              : const {},
      portfolioId:
          (json['portfolio_id'] ?? json['portfolioId'] ?? 'all').toString(),
      assortment: (json['assortment'] ?? 'optional').toString(),
      source: (json['source'] ?? json['sync_source'] ?? 'api').toString(),
      brand: (json['brand'] ?? json['Brand'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'stockByWarehouse': stockByWarehouse,
        'portfolioId': portfolioId,
        'assortment': assortment,
        'source': source,
        'brand': brand,
      };

  @override
  List<Object?> get props => [id, price, stock, portfolioId, assortment];
}
