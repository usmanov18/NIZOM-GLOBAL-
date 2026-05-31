import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/errors/failures.dart';
import '../entities/order_catalog_product.dart';
import '../entities/order_flow_entities.dart';

abstract class OrderCatalogRepository {
  Future<Either<Failure, List<OrderCustomer>>> getCustomers({String? search});

  Future<Either<Failure, List<OrderCatalogProduct>>> getProducts({
    String? search,
    String? portfolioId,
    String? assortment,
  });

  Future<Either<Failure, int>> getProductStock({
    required String productId,
    required String warehouseId,
  });
}
