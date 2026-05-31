import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product_entities.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';

// ============================================================
// PRODUCT REPOSITORY IMPLEMENTATION
// ============================================================

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts({
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
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getProducts(
          categoryId: categoryId,
          search: search,
          brand: brand,
          minPrice: minPrice,
          maxPrice: maxPrice,
          inStock: inStock,
          hasDiscount: hasDiscount,
          sortBy: sortBy,
          ascending: ascending,
          page: page,
          limit: limit,
        );
        final products = data.map((d) => _productFromMap(d)).toList();
        if (page == 1) await localDataSource.cacheProducts(data);
        return Right(products);
      } else {
        final cached = await localDataSource.getCachedProducts(
          categoryId: categoryId,
          search: search,
        );
        return Right(cached.map((d) => _productFromMap(d)).toList());
      }
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String productId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getProductById(productId);
        await localDataSource.saveProduct(data);
        return Right(_productFromMap(data));
      } else {
        final cached = await localDataSource.getProduct(productId);
        if (cached != null) return Right(_productFromMap(cached));
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductByBarcode(String barcode) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getProductByBarcode(barcode);
        if (data != null) {
          await localDataSource.saveProductByBarcode(barcode, data);
          return Right(_productFromMap(data));
        }
        return const Right(null);
      } else {
        final cached = await localDataSource.getProductByBarcode(barcode);
        if (cached != null) return Right(_productFromMap(cached));
        return const Right(null);
      }
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getCategories({
    String? parentId,
    bool? isActive,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getCategories();
        await localDataSource.cacheCategories(data);
        return Right(data.map((d) => ProductCategory.fromJson(d)).toList());
      } else {
        final cached = await localDataSource.getCachedCategories();
        return Right(cached.map((d) => ProductCategory.fromJson(d)).toList());
      }
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProductCategory>> getCategoryById(
    String categoryId,
  ) async {
    try {
      final categories = await getCategories();
      return categories.fold((failure) => Left(failure), (cats) {
        final cat = cats.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => throw Exception(),
        );
        return Right(cat);
      });
    } catch (e) {
      return const Left(NotFoundFailure(resource: 'Kategoriya'));
    }
  }

  @override
  Future<Either<Failure, ProductCategory>> createCategory(
    ProductCategory category,
  ) async {
    try {
      return Right(category);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProductCategory>> updateCategory(
    ProductCategory category,
  ) async {
    try {
      return Right(category);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PriceList>>> getPriceLists() async {
    try {
      final data = await remoteDataSource.getPriceLists();
      return Right(data.map((d) => PriceList.fromJson(d)).toList());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PriceListItem>>> getPriceListItems(
    String priceListId,
  ) async {
    try {
      final data = await remoteDataSource.getPriceListItems(priceListId);
      return Right(data.map((d) => PriceListItem.fromJson(d)).toList());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, double>> getProductPrice({
    required String productId,
    required String priceGroupId,
  }) async {
    try {
      final data = await remoteDataSource.getProductPrice(
        productId: productId,
        priceGroupId: priceGroupId,
      );
      return Right((data['price'] ?? 0).toDouble());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> updatePrices({
    required String priceListId,
    required List<PriceUpdateItem> items,
  }) async {
    try {
      return const Right(true);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Warehouse>>> getWarehouses() async {
    try {
      final data = await remoteDataSource.getWarehouses();
      return Right(data.map((d) => Warehouse.fromJson(d)).toList());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<StockItem>>> getStockBalance({
    String? warehouseId,
    String? productId,
    String? categoryId,
    bool? lowStock,
    bool? outOfStock,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getStockBalance(
          warehouseId: warehouseId,
          productId: productId,
          categoryId: categoryId,
          lowStock: lowStock,
          outOfStock: outOfStock,
        );
        await localDataSource.cacheStock(data);
        return Right(data.map((d) => StockItem.fromJson(d)).toList());
      } else {
        final cached = await localDataSource.getCachedStock(
          warehouseId: warehouseId,
        );
        return Right(cached.map((d) => StockItem.fromJson(d)).toList());
      }
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<StockItem>>> getProductStock(
    String productId,
  ) async {
    try {
      final data = await remoteDataSource.getStockBalance(productId: productId);
      return Right(data.map((d) => StockItem.fromJson(d)).toList());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProductSyncResult>> syncProductsFrom1C({
    DateTime? sinceDate,
    String? categoryId,
  }) async {
    try {
      final startTime = DateTime.now();
      final data = await remoteDataSource.syncProductsFrom1C(
        sinceDate: sinceDate,
        categoryId: categoryId,
      );
      await localDataSource.cacheProducts(data);
      await localDataSource.saveLastSyncTime();

      return Right(
        ProductSyncResult(
          source: '1c',
          totalProducts: data.length,
          newProducts: 0,
          updatedProducts: data.length,
          unchangedProducts: 0,
          failedProducts: 0,
          totalCategories: 0,
          newCategories: 0,
          errors: [],
          startedAt: startTime,
          completedAt: DateTime.now(),
          duration: DateTime.now().difference(startTime),
        ),
      );
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProductSyncResult>> syncProductsFromSAP({
    DateTime? sinceDate,
    String? materialGroup,
  }) async {
    try {
      final startTime = DateTime.now();
      final data = await remoteDataSource.syncProductsFromSAP(
        sinceDate: sinceDate,
        materialGroup: materialGroup,
      );
      await localDataSource.cacheProducts(data);
      await localDataSource.saveLastSyncTime();

      return Right(
        ProductSyncResult(
          source: 'sap',
          totalProducts: data.length,
          newProducts: 0,
          updatedProducts: data.length,
          unchangedProducts: 0,
          failedProducts: 0,
          totalCategories: 0,
          newCategories: 0,
          errors: [],
          startedAt: startTime,
          completedAt: DateTime.now(),
          duration: DateTime.now().difference(startTime),
        ),
      );
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> syncCategoriesFrom1C() async {
    try {
      final data = await remoteDataSource.syncCategoriesFrom1C();
      await localDataSource.cacheCategories(data);
      return Right(data.map((d) => ProductCategory.fromJson(d)).toList());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> syncCategoriesFromSAP() async {
    try {
      final data = await remoteDataSource.syncCategoriesFromSAP();
      await localDataSource.cacheCategories(data);
      return Right(data.map((d) => ProductCategory.fromJson(d)).toList());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PriceListItem>>> syncPricesFrom1C({
    String? priceGroupId,
  }) async {
    try {
      final data = await remoteDataSource.syncPricesFrom1C(
        priceGroupId: priceGroupId,
      );
      await localDataSource.cachePrices(data);
      return Right(data.map((d) => PriceListItem.fromJson(d)).toList());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PriceListItem>>> syncPricesFromSAP({
    String? priceGroupId,
  }) async {
    try {
      final data = await remoteDataSource.syncPricesFromSAP(
        priceGroupId: priceGroupId,
      );
      await localDataSource.cachePrices(data);
      return Right(data.map((d) => PriceListItem.fromJson(d)).toList());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<StockItem>>> syncStockFrom1C({
    String? warehouseId,
  }) async {
    try {
      final data = await remoteDataSource.syncStockFrom1C(
        warehouseId: warehouseId,
      );
      await localDataSource.cacheStock(data);
      return Right(data.map((d) => StockItem.fromJson(d)).toList());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<StockItem>>> syncStockFromSAP({
    String? warehouseId,
  }) async {
    try {
      final data = await remoteDataSource.syncStockFromSAP(
        warehouseId: warehouseId,
      );
      await localDataSource.cacheStock(data);
      return Right(data.map((d) => StockItem.fromJson(d)).toList());
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProductSyncResult>> syncAllProducts() async {
    try {
      final result1C = await syncProductsFrom1C();
      final resultSAP = await syncProductsFromSAP();

      return result1C.fold(
        (failure) => resultSAP,
        (r1) => resultSAP.fold(
          (failure) => Right(r1),
          (r2) => Right(
            ProductSyncResult(
              source: 'both',
              totalProducts: r1.totalProducts + r2.totalProducts,
              newProducts: r1.newProducts + r2.newProducts,
              updatedProducts: r1.updatedProducts + r2.updatedProducts,
              unchangedProducts: r1.unchangedProducts + r2.unchangedProducts,
              failedProducts: r1.failedProducts + r2.failedProducts,
              totalCategories: r1.totalCategories + r2.totalCategories,
              newCategories: r1.newCategories + r2.newCategories,
              errors: [...r1.errors, ...r2.errors],
              startedAt: r1.startedAt,
              completedAt: DateTime.now(),
              duration: DateTime.now().difference(r1.startedAt),
            ),
          ),
        ),
      );
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastSyncTime() async {
    try {
      final time = await localDataSource.getLastSyncTime();
      return Right(time);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, int>> importFromCSV(String filePath) async {
    try {
      final count = await remoteDataSource.importFromCSV(filePath);
      return Right(count);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> exportToCSV({
    String? categoryId,
    bool? activeOnly,
  }) async {
    try {
      final path = await remoteDataSource.exportToCSV(
        categoryId: categoryId,
        activeOnly: activeOnly,
      );
      return Right(path);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProductStatistics>> getStatistics() async {
    try {
      if (await networkInfo.isConnected) {
        return Right(
          ProductStatistics(
            totalProducts: 0,
            activeProducts: 0,
            inactiveProducts: 0,
            newProducts: 0,
            lowStockProducts: 0,
            outOfStockProducts: 0,
            discountedProducts: 0,
            totalStockValue: 0,
            totalCategories: 0,
            totalBrands: 0,
            lastUpdated: DateTime.now(),
          ),
        );
      } else {
        final cached = await localDataSource.getCachedStatistics();
        if (cached != null) {
          return Right(
            ProductStatistics(
              totalProducts: cached['total_products'] ?? 0,
              activeProducts: cached['active_products'] ?? 0,
              inactiveProducts: cached['inactive_products'] ?? 0,
              newProducts: cached['new_products'] ?? 0,
              lowStockProducts: cached['low_stock_products'] ?? 0,
              outOfStockProducts: cached['out_of_stock_products'] ?? 0,
              discountedProducts: cached['discounted_products'] ?? 0,
              totalStockValue: (cached['total_stock_value'] ?? 0).toDouble(),
              totalCategories: cached['total_categories'] ?? 0,
              totalBrands: cached['total_brands'] ?? 0,
              lastUpdated: cached['last_updated'] != null
                  ? DateTime.parse(cached['last_updated'])
                  : DateTime.now(),
            ),
          );
        }
        return Right(
          ProductStatistics(
            totalProducts: 0,
            activeProducts: 0,
            inactiveProducts: 0,
            newProducts: 0,
            lowStockProducts: 0,
            outOfStockProducts: 0,
            discountedProducts: 0,
            totalStockValue: 0,
            totalCategories: 0,
            totalBrands: 0,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getTopProducts({
    String period = 'monthly',
    int limit = 10,
  }) async {
    try {
      return const Right([]);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getNewProducts({
    int limit = 10,
  }) async {
    try {
      return const Right([]);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getDiscountedProducts({
    int limit = 10,
  }) async {
    try {
      return const Right([]);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getLowStockProducts({
    int limit = 10,
  }) async {
    try {
      return const Right([]);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    try {
      final data = await remoteDataSource.createProduct(
        _productToPayload(product),
      );
      return Right(Product.from1C(data));
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      final data = await remoteDataSource.updateProduct(
        product.id,
        _productToPayload(product),
      );
      return Right(Product.from1C(data));
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deactivateProduct(String productId) async {
    try {
      final result = await remoteDataSource.deactivateProduct(productId);
      return Right(result);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> activateProduct(String productId) async {
    try {
      return const Right(true);
    } catch (e) {
      return Left(
        ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> importFromExcel(String filePath) async {
    return importFromCSV(filePath);
  }

  @override
  Future<Either<Failure, String>> exportToExcel({
    String? categoryId,
    bool? activeOnly,
  }) async {
    return exportToCSV(categoryId: categoryId, activeOnly: activeOnly);
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    return getProducts(search: query);
  }

  @override
  Future<Either<Failure, ProductStatistics>> getProductStatistics() async {
    return getStatistics();
  }

  Product _productFromMap(Map<String, dynamic> json) {
    if (json.containsKey('Ref_Key') || json.containsKey('Description')) {
      return Product.from1C(json);
    }
    if (json.containsKey('Material') ||
        json.containsKey('MaterialDescription')) {
      return Product.fromSAP(json);
    }
    final now = DateTime.now();
    return Product(
      id: (json['id'] ?? json['product_id'] ?? json['code'] ?? '').toString(),
      externalId1C: (json['external_id_1c'] ?? '').toString(),
      externalIdSAP: (json['external_id_sap'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? json['product_name'] ?? '').toString(),
      description: json['description']?.toString(),
      sku: (json['sku'] ?? json['code'] ?? '').toString(),
      barcode: json['barcode']?.toString(),
      article: json['article']?.toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      categoryName: (json['category_name'] ?? '').toString(),
      unitOfMeasure: (json['unit_of_measure'] ?? 'dona').toString(),
      weight: (json['weight'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 0).toDouble(),
      basePrice: (json['base_price'] ?? json['price'] ?? 0).toDouble(),
      currency: (json['currency'] ?? 'UZS').toString(),
      stockQuantity: (json['stock_quantity'] ?? json['stock'] ?? 0).toDouble(),
      reservedQuantity: (json['reserved_quantity'] ?? 0).toDouble(),
      availableQuantity:
          (json['available_quantity'] ?? json['stock'] ?? 0).toDouble(),
      imageUrl: json['image_url']?.toString(),
      images: (json['images'] is List)
          ? List<String>.from(json['images'])
          : const [],
      brand: json['brand']?.toString(),
      manufacturer: json['manufacturer']?.toString(),
      countryOfOrigin: json['country_of_origin']?.toString(),
      hasDiscount: json['has_discount'] ?? false,
      discountPercent: json['discount_percent']?.toDouble(),
      discountPrice: json['discount_price']?.toDouble(),
      isActive: json['is_active'] ?? true,
      isAvailable: json['is_available'] ?? true,
      isNew: json['is_new'] ?? false,
      isPopular: json['is_popular'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      syncSource: (json['sync_source'] ?? 'api').toString(),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.tryParse(json['last_synced_at'].toString()) ?? now
          : now,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? now
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> _productToPayload(Product product) {
    return {
      'id': product.id,
      'code': product.code,
      'name': product.name,
      'description': product.description,
      'sku': product.sku,
      'barcode': product.barcode,
      'category_id': product.categoryId,
      'category_name': product.categoryName,
      'unit_of_measure': product.unitOfMeasure,
      'base_price': product.basePrice,
      'currency': product.currency,
      'is_active': product.isActive,
    };
  }
}
