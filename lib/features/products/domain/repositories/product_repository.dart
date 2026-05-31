import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entities.dart';
import 'package:equatable/equatable.dart';

// ============================================================
// PRODUCT REPOSITORY - Mahsulotlar boshqaruvi
// ============================================================

abstract class ProductRepository {
  // ============ MAHSULOTLAR ============

  /// Barcha mahsulotlar
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
  });

  /// Mahsulot tafsilotlari
  Future<Either<Failure, Product>> getProductById(String productId);

  /// Barcode bo'yicha qidirish
  Future<Either<Failure, Product?>> getProductByBarcode(String barcode);

  /// Yangi mahsulot yaratish
  Future<Either<Failure, Product>> createProduct(Product product);

  /// Mahsulotni yangilash
  Future<Either<Failure, Product>> updateProduct(Product product);

  /// Mahsulotni o'chirish (deactivate)
  Future<Either<Failure, bool>> deactivateProduct(String productId);

  /// Mahsulotni faollashtirish
  Future<Either<Failure, bool>> activateProduct(String productId);

  // ============ KATEGORIYALAR ============

  /// Barcha kategoriyalar
  Future<Either<Failure, List<ProductCategory>>> getCategories({
    String? parentId,
    bool? isActive,
  });

  /// Kategoriya tafsilotlari
  Future<Either<Failure, ProductCategory>> getCategoryById(String categoryId);

  /// Yangi kategoriya yaratish
  Future<Either<Failure, ProductCategory>> createCategory(
    ProductCategory category,
  );

  /// Kategoriyani yangilash
  Future<Either<Failure, ProductCategory>> updateCategory(
    ProductCategory category,
  );

  // ============ NARXLAR ============

  /// Narx jadvali
  Future<Either<Failure, List<PriceList>>> getPriceLists();

  /// Narx jadvali elementlari
  Future<Either<Failure, List<PriceListItem>>> getPriceListItems(
    String priceListId,
  );

  /// Mahsulot narxi (narx guruhi bo'yicha)
  Future<Either<Failure, double>> getProductPrice({
    required String productId,
    required String priceGroupId,
  });

  /// Narxlarni yangilash
  Future<Either<Failure, bool>> updatePrices({
    required String priceListId,
    required List<PriceUpdateItem> items,
  });

  // ============ OMBOR ============

  /// Omborlar ro'yxati
  Future<Either<Failure, List<Warehouse>>> getWarehouses();

  /// Ombor qoldiqlari
  Future<Either<Failure, List<StockItem>>> getStockBalance({
    String? warehouseId,
    String? productId,
    String? categoryId,
    bool? lowStock,
    bool? outOfStock,
  });

  /// Mahsulot qoldiqlari (barcha omborlar)
  Future<Either<Failure, List<StockItem>>> getProductStock(String productId);

  // ============ SINXRONLASH ============

  /// 1C dan mahsulotlarni yuklash
  Future<Either<Failure, ProductSyncResult>> syncProductsFrom1C({
    DateTime? sinceDate,
    String? categoryId,
  });

  /// SAP dan mahsulotlarni yuklash
  Future<Either<Failure, ProductSyncResult>> syncProductsFromSAP({
    DateTime? sinceDate,
    String? materialGroup,
  });

  /// 1C dan kategoriyalarni yuklash
  Future<Either<Failure, List<ProductCategory>>> syncCategoriesFrom1C();

  /// SAP dan kategoriyalarni yuklash
  Future<Either<Failure, List<ProductCategory>>> syncCategoriesFromSAP();

  /// 1C dan narxlarni yuklash
  Future<Either<Failure, List<PriceListItem>>> syncPricesFrom1C({
    String? priceGroupId,
  });

  /// SAP dan narxlarni yuklash
  Future<Either<Failure, List<PriceListItem>>> syncPricesFromSAP({
    String? priceGroupId,
  });

  /// 1C dan ombor qoldiqlarini yuklash
  Future<Either<Failure, List<StockItem>>> syncStockFrom1C({
    String? warehouseId,
  });

  /// SAP dan ombor qoldiqlarini yuklash
  Future<Either<Failure, List<StockItem>>> syncStockFromSAP({
    String? warehouseId,
  });

  /// Barcha mahsulot ma'lumotlarini sinxronlash
  Future<Either<Failure, ProductSyncResult>> syncAllProducts();

  /// Oxirgi sinxronlash vaqti
  Future<Either<Failure, DateTime?>> getLastSyncTime();

  // ============ IMPORT/EXPORT ============

  /// CSV dan import
  Future<Either<Failure, int>> importFromCSV(String filePath);

  /// CSV ga export
  Future<Either<Failure, String>> exportToCSV({
    String? categoryId,
    bool? activeOnly,
  });

  /// Excel dan import
  Future<Either<Failure, int>> importFromExcel(String filePath);

  /// Excel ga export
  Future<Either<Failure, String>> exportToExcel({
    String? categoryId,
    bool? activeOnly,
  });

  // ============ STATISTIKA ============

  /// Mahsulotlar statistikasi
  Future<Either<Failure, ProductStatistics>> getStatistics();

  /// Top mahsulotlar
  Future<Either<Failure, List<Product>>> getTopProducts({
    String period = 'monthly',
    int limit = 10,
  });

  /// Yangi mahsulotlar
  Future<Either<Failure, List<Product>>> getNewProducts({int limit = 10});

  /// Chegirmali mahsulotlar
  Future<Either<Failure, List<Product>>> getDiscountedProducts({
    int limit = 10,
  });

  /// Tugayotgan mahsulotlar (low stock)
  Future<Either<Failure, List<Product>>> getLowStockProducts({int limit = 10});

  Future<Either<Failure, List<Product>>> searchProducts(String query);

  Future<Either<Failure, ProductStatistics>> getProductStatistics();
}

/// Narx yangilash elementi
class PriceUpdateItem extends Equatable {
  final String productId;
  final double newPrice;
  final double? oldPrice;

  const PriceUpdateItem({
    required this.productId,
    required this.newPrice,
    this.oldPrice,
  });

  @override
  List<Object?> get props => [productId, newPrice];
}

/// Mahsulotlar statistikasi
class ProductStatistics extends Equatable {
  final int totalProducts;
  final int activeProducts;
  final int inactiveProducts;
  final int newProducts; // Oxirgi 30 kunda
  final int lowStockProducts;
  final int outOfStockProducts;
  final int discountedProducts;
  final double totalStockValue;
  final int totalCategories;
  final int totalBrands;
  final DateTime lastUpdated;

  const ProductStatistics({
    required this.totalProducts,
    required this.activeProducts,
    required this.inactiveProducts,
    required this.newProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.discountedProducts,
    required this.totalStockValue,
    required this.totalCategories,
    required this.totalBrands,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [totalProducts, activeProducts];
}
