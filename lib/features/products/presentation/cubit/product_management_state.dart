import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entities.dart';
import '../../domain/repositories/product_repository.dart'
    show ProductStatistics;

class ProductManagementState extends Equatable {
  final bool isLoadingProducts;
  final bool isLoadingCategories;
  final bool isLoadingPrices;
  final bool isLoadingStock;
  final bool isLoadingStatistics;

  final List<Product> products;
  final List<ProductCategory> categories;
  final List<PriceList> priceLists;
  final List<StockItem> stockItems;
  final ProductStatistics? statistics;

  final String? errorMessage;
  final String? syncMessage;

  const ProductManagementState({
    this.isLoadingProducts = false,
    this.isLoadingCategories = false,
    this.isLoadingPrices = false,
    this.isLoadingStock = false,
    this.isLoadingStatistics = false,
    this.products = const [],
    this.categories = const [],
    this.priceLists = const [],
    this.stockItems = const [],
    this.statistics,
    this.errorMessage,
    this.syncMessage,
  });

  ProductManagementState copyWith({
    bool? isLoadingProducts,
    bool? isLoadingCategories,
    bool? isLoadingPrices,
    bool? isLoadingStock,
    bool? isLoadingStatistics,
    List<Product>? products,
    List<ProductCategory>? categories,
    List<PriceList>? priceLists,
    List<StockItem>? stockItems,
    ProductStatistics? statistics,
    String? errorMessage,
    String? syncMessage,
  }) {
    return ProductManagementState(
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingPrices: isLoadingPrices ?? this.isLoadingPrices,
      isLoadingStock: isLoadingStock ?? this.isLoadingStock,
      isLoadingStatistics: isLoadingStatistics ?? this.isLoadingStatistics,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      priceLists: priceLists ?? this.priceLists,
      stockItems: stockItems ?? this.stockItems,
      statistics: statistics ?? this.statistics,
      errorMessage: errorMessage,
      syncMessage: syncMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoadingProducts,
        isLoadingCategories,
        isLoadingPrices,
        isLoadingStock,
        isLoadingStatistics,
        products,
        categories,
        priceLists,
        stockItems,
        statistics,
        errorMessage,
        syncMessage,
      ];
}
