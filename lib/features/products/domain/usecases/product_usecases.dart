import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_entities.dart';
import '../repositories/product_repository.dart';

// ============================================================
// PRODUCT USECASES
// ============================================================

class GetProducts implements UseCase<List<Product>, GetProductsParams> {
  final ProductRepository repository;
  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) {
    return repository.getProducts(
      categoryId: params.categoryId,
      search: params.search,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetProductById implements UseCase<Product, String> {
  final ProductRepository repository;
  GetProductById(this.repository);

  @override
  Future<Either<Failure, Product>> call(String id) {
    return repository.getProductById(id);
  }
}

class GetProductByBarcode implements UseCase<Product?, String> {
  final ProductRepository repository;
  GetProductByBarcode(this.repository);

  @override
  Future<Either<Failure, Product?>> call(String barcode) {
    return repository.getProductByBarcode(barcode);
  }
}

class GetCategories implements UseCase<List<ProductCategory>, NoParams> {
  final ProductRepository repository;
  GetCategories(this.repository);

  @override
  Future<Either<Failure, List<ProductCategory>>> call(NoParams params) {
    return repository.getCategories();
  }
}

class SyncProductsFrom1C implements UseCase<ProductSyncResult, DateTime?> {
  final ProductRepository repository;
  SyncProductsFrom1C(this.repository);

  @override
  Future<Either<Failure, ProductSyncResult>> call(DateTime? sinceDate) {
    return repository.syncProductsFrom1C(sinceDate: sinceDate);
  }
}

class SyncProductsFromSAP implements UseCase<ProductSyncResult, DateTime?> {
  final ProductRepository repository;
  SyncProductsFromSAP(this.repository);

  @override
  Future<Either<Failure, ProductSyncResult>> call(DateTime? sinceDate) {
    return repository.syncProductsFromSAP(sinceDate: sinceDate);
  }
}

class SyncAllProducts implements UseCase<ProductSyncResult, NoParams> {
  final ProductRepository repository;
  SyncAllProducts(this.repository);

  @override
  Future<Either<Failure, ProductSyncResult>> call(NoParams params) {
    return repository.syncAllProducts();
  }
}

class GetProductStatistics implements UseCase<ProductStatistics, NoParams> {
  final ProductRepository repository;
  GetProductStatistics(this.repository);

  @override
  Future<Either<Failure, ProductStatistics>> call(NoParams params) {
    return repository.getStatistics();
  }
}

class GetStockBalance implements UseCase<List<StockItem>, GetStockParams> {
  final ProductRepository repository;
  GetStockBalance(this.repository);

  @override
  Future<Either<Failure, List<StockItem>>> call(GetStockParams params) {
    return repository.getStockBalance(
      warehouseId: params.warehouseId,
      productId: params.productId,
      lowStock: params.lowStock,
    );
  }
}

// ============ PARAMS ============

class GetProductsParams extends Equatable {
  final String? categoryId;
  final String? search;
  final int page;
  final int limit;

  const GetProductsParams({
    this.categoryId,
    this.search,
    this.page = 1,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [categoryId, search, page];
}

class GetStockParams extends Equatable {
  final String? warehouseId;
  final String? productId;
  final bool? lowStock;

  const GetStockParams({this.warehouseId, this.productId, this.lowStock});

  @override
  List<Object?> get props => [warehouseId, productId];
}
