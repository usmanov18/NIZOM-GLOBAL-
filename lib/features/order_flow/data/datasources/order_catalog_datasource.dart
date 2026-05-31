import '../../domain/entities/order_flow_entities.dart';
import '../../domain/entities/order_catalog_product.dart';
import 'order_seed_catalog_datasource.dart';

abstract class OrderCatalogDataSource {
  Future<List<OrderCustomer>> getCustomers({String? search});
  Future<List<OrderCatalogProduct>> getProducts(
      {String? search, String? portfolioId, String? assortment});
  Future<int> getProductStock(
      {required String productId, required String warehouseId});
}

class OrderSeedCatalogDataSourceImpl implements OrderCatalogDataSource {
  @override
  Future<List<OrderCustomer>> getCustomers({String? search}) async {
    final query = search?.trim().toLowerCase() ?? '';
    final customers = OrderSeedCatalogDataSource.seedCustomers();
    if (query.isEmpty) return customers;
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
          customer.code.toLowerCase().contains(query) ||
          customer.address.toLowerCase().contains(query) ||
          customer.phone.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Future<List<OrderCatalogProduct>> getProducts(
      {String? search, String? portfolioId, String? assortment}) async {
    final query = search?.trim().toLowerCase() ?? '';
    return OrderSeedCatalogDataSource.seedProducts().where((product) {
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

  @override
  Future<int> getProductStock(
      {required String productId, required String warehouseId}) async {
    OrderCatalogProduct? product;
    for (final item in OrderSeedCatalogDataSource.seedProducts()) {
      if (item.id == productId) {
        product = item;
        break;
      }
    }
    if (product == null) return 0;
    return product.stockByWarehouse[warehouseId] ?? product.stock;
  }
}
