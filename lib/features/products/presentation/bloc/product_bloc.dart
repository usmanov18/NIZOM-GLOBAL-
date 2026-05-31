import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entities.dart';
import '../../domain/repositories/product_repository.dart';

// ============================================================
// PRODUCT BLOC - Mahsulotlar boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductsLoadRequested extends ProductEvent {
  final String? categoryId;
  final String? search;
  final String? sortBy;
  final int page;

  ProductsLoadRequested(
      {this.categoryId, this.search, this.sortBy, this.page = 1});
}

class ProductDetailRequested extends ProductEvent {
  final String productId;
  ProductDetailRequested(this.productId);
}

class ProductSearchRequested extends ProductEvent {
  final String query;
  ProductSearchRequested(this.query);
}

class ProductByBarcodeRequested extends ProductEvent {
  final String barcode;
  ProductByBarcodeRequested(this.barcode);
}

class CategoriesLoadRequested extends ProductEvent {}

class PriceListsLoadRequested extends ProductEvent {}

class PriceListItemsLoadRequested extends ProductEvent {
  final String priceListId;
  PriceListItemsLoadRequested(this.priceListId);
}

class StockBalanceLoadRequested extends ProductEvent {
  final String? warehouseId;
  final String? categoryId;
  final bool? lowStock;
  StockBalanceLoadRequested({this.warehouseId, this.categoryId, this.lowStock});
}

class WarehousesLoadRequested extends ProductEvent {}

class ProductSyncFrom1CRequested extends ProductEvent {
  final DateTime? sinceDate;
  ProductSyncFrom1CRequested({this.sinceDate});
}

class ProductSyncFromSAPRequested extends ProductEvent {
  final DateTime? sinceDate;
  ProductSyncFromSAPRequested({this.sinceDate});
}

class ProductSyncAllRequested extends ProductEvent {}

class ProductCreateRequested extends ProductEvent {
  final Product product;
  ProductCreateRequested(this.product);
}

class ProductUpdateRequested extends ProductEvent {
  final Product product;
  ProductUpdateRequested(this.product);
}

class ProductDeactivateRequested extends ProductEvent {
  final String productId;
  ProductDeactivateRequested(this.productId);
}

class ProductStatisticsLoadRequested extends ProductEvent {}

class PriceUpdateRequested extends ProductEvent {
  final String priceListId;
  final List<PriceUpdateItem> items;
  PriceUpdateRequested({required this.priceListId, required this.items});
}

class ProductImportFromCSVRequested extends ProductEvent {
  final String filePath;
  ProductImportFromCSVRequested(this.filePath);
}

class ProductExportToCSVRequested extends ProductEvent {
  final String? categoryId;
  ProductExportToCSVRequested({this.categoryId});
}

// ============ STATES ============

abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<Product> products;
  final bool hasMore;
  final int currentPage;
  final int totalProducts;

  ProductsLoaded({
    required this.products,
    this.hasMore = false,
    this.currentPage = 1,
    required this.totalProducts,
  });
}

class ProductDetailLoaded extends ProductState {
  final Product product;
  final List<StockItem> stockItems;

  ProductDetailLoaded({required this.product, required this.stockItems});
}

class ProductSearchResults extends ProductState {
  final List<Product> results;
  final String query;

  ProductSearchResults({required this.results, required this.query});
}

class ProductByBarcodeLoaded extends ProductState {
  final Product? product;
  final String barcode;

  ProductByBarcodeLoaded({this.product, required this.barcode});
}

class CategoriesLoaded extends ProductState {
  final List<ProductCategory> categories;

  CategoriesLoaded({required this.categories});
}

class PriceListsLoaded extends ProductState {
  final List<PriceList> priceLists;

  PriceListsLoaded({required this.priceLists});
}

class PriceListItemsLoaded extends ProductState {
  final List<PriceListItem> items;
  final String priceListId;

  PriceListItemsLoaded({required this.items, required this.priceListId});
}

class StockBalanceLoaded extends ProductState {
  final List<StockItem> stockItems;
  final String? warehouseId;

  StockBalanceLoaded({required this.stockItems, this.warehouseId});
}

class WarehousesLoaded extends ProductState {
  final List<Warehouse> warehouses;

  WarehousesLoaded({required this.warehouses});
}

class ProductSyncInProgress extends ProductState {
  final String source;
  final double progress;

  ProductSyncInProgress({required this.source, required this.progress});
}

class ProductSyncCompleted extends ProductState {
  final ProductSyncResult result;

  ProductSyncCompleted({required this.result});
}

class ProductCreated extends ProductState {
  final Product product;
  ProductCreated({required this.product});
}

class ProductUpdated extends ProductState {
  final Product product;
  ProductUpdated({required this.product});
}

class ProductDeactivated extends ProductState {
  final String productId;
  ProductDeactivated({required this.productId});
}

class ProductStatisticsLoaded extends ProductState {
  final ProductStatistics statistics;

  ProductStatisticsLoaded({required this.statistics});
}

class PriceUpdateCompleted extends ProductState {
  final int updatedCount;
  PriceUpdateCompleted({required this.updatedCount});
}

class ProductImportCompleted extends ProductState {
  final int importedCount;
  ProductImportCompleted({required this.importedCount});
}

class ProductExportCompleted extends ProductState {
  final String filePath;
  ProductExportCompleted({required this.filePath});
}

class ProductError extends ProductState {
  final String message;
  final String? errorCode;

  ProductError({required this.message, this.errorCode});
}

// ============ BLOC ============

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<ProductsLoadRequested>(_onProductsLoad);
    on<ProductDetailRequested>(_onProductDetail);
    on<ProductSearchRequested>(_onProductSearch);
    on<ProductByBarcodeRequested>(_onProductByBarcode);
    on<CategoriesLoadRequested>(_onCategoriesLoad);
    on<PriceListsLoadRequested>(_onPriceListsLoad);
    on<PriceListItemsLoadRequested>(_onPriceListItemsLoad);
    on<StockBalanceLoadRequested>(_onStockBalanceLoad);
    on<WarehousesLoadRequested>(_onWarehousesLoad);
    on<ProductSyncFrom1CRequested>(_onSyncFrom1C);
    on<ProductSyncFromSAPRequested>(_onSyncFromSAP);
    on<ProductSyncAllRequested>(_onSyncAll);
    on<ProductCreateRequested>(_onProductCreate);
    on<ProductUpdateRequested>(_onProductUpdate);
    on<ProductDeactivateRequested>(_onProductDeactivate);
    on<ProductStatisticsLoadRequested>(_onStatisticsLoad);
    on<PriceUpdateRequested>(_onPriceUpdate);
    on<ProductImportFromCSVRequested>(_onImportCSV);
    on<ProductExportToCSVRequested>(_onExportCSV);
  }

  Future<void> _onProductsLoad(
      ProductsLoadRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.getProducts(
      categoryId: event.categoryId,
      search: event.search,
      sortBy: event.sortBy,
      page: event.page,
    );
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductsLoaded(
        products: products,
        hasMore: products.length >= 50,
        currentPage: event.page,
        totalProducts: products.length,
      )),
    );
  }

  Future<void> _onProductDetail(
      ProductDetailRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final productResult = await repository.getProductById(event.productId);
    final stockResult = await repository.getProductStock(event.productId);

    productResult.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) {
        stockResult.fold(
          (_) => emit(ProductDetailLoaded(product: product, stockItems: [])),
          (stockItems) => emit(
              ProductDetailLoaded(product: product, stockItems: stockItems)),
        );
      },
    );
  }

  Future<void> _onProductSearch(
      ProductSearchRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.getProducts(search: event.query);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) =>
          emit(ProductSearchResults(results: products, query: event.query)),
    );
  }

  Future<void> _onProductByBarcode(
      ProductByBarcodeRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.getProductByBarcode(event.barcode);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(
          ProductByBarcodeLoaded(product: product, barcode: event.barcode)),
    );
  }

  Future<void> _onCategoriesLoad(
      CategoriesLoadRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.getCategories();
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (categories) => emit(CategoriesLoaded(categories: categories)),
    );
  }

  Future<void> _onPriceListsLoad(
      PriceListsLoadRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.getPriceLists();
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (priceLists) => emit(PriceListsLoaded(priceLists: priceLists)),
    );
  }

  Future<void> _onPriceListItemsLoad(
      PriceListItemsLoadRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.getPriceListItems(event.priceListId);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (items) => emit(
          PriceListItemsLoaded(items: items, priceListId: event.priceListId)),
    );
  }

  Future<void> _onStockBalanceLoad(
      StockBalanceLoadRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.getStockBalance(
      warehouseId: event.warehouseId,
      categoryId: event.categoryId,
      lowStock: event.lowStock,
    );
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (stockItems) => emit(StockBalanceLoaded(
          stockItems: stockItems, warehouseId: event.warehouseId)),
    );
  }

  Future<void> _onWarehousesLoad(
      WarehousesLoadRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.getWarehouses();
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (warehouses) => emit(WarehousesLoaded(warehouses: warehouses)),
    );
  }

  Future<void> _onSyncFrom1C(
      ProductSyncFrom1CRequested event, Emitter<ProductState> emit) async {
    emit(ProductSyncInProgress(source: '1C', progress: 0));
    final result =
        await repository.syncProductsFrom1C(sinceDate: event.sinceDate);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (syncResult) => emit(ProductSyncCompleted(result: syncResult)),
    );
  }

  Future<void> _onSyncFromSAP(
      ProductSyncFromSAPRequested event, Emitter<ProductState> emit) async {
    emit(ProductSyncInProgress(source: 'SAP', progress: 0));
    final result =
        await repository.syncProductsFromSAP(sinceDate: event.sinceDate);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (syncResult) => emit(ProductSyncCompleted(result: syncResult)),
    );
  }

  Future<void> _onSyncAll(
      ProductSyncAllRequested event, Emitter<ProductState> emit) async {
    emit(ProductSyncInProgress(source: 'All', progress: 0));
    final result = await repository.syncAllProducts();
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (syncResult) => emit(ProductSyncCompleted(result: syncResult)),
    );
  }

  Future<void> _onProductCreate(
      ProductCreateRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.createProduct(event.product);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(ProductCreated(product: product)),
    );
  }

  Future<void> _onProductUpdate(
      ProductUpdateRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.updateProduct(event.product);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(ProductUpdated(product: product)),
    );
  }

  Future<void> _onProductDeactivate(
      ProductDeactivateRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.deactivateProduct(event.productId);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (_) => emit(ProductDeactivated(productId: event.productId)),
    );
  }

  Future<void> _onStatisticsLoad(
      ProductStatisticsLoadRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.getStatistics();
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (statistics) => emit(ProductStatisticsLoaded(statistics: statistics)),
    );
  }

  Future<void> _onPriceUpdate(
      PriceUpdateRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.updatePrices(
      priceListId: event.priceListId,
      items: event.items,
    );
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (_) => emit(PriceUpdateCompleted(updatedCount: event.items.length)),
    );
  }

  Future<void> _onImportCSV(
      ProductImportFromCSVRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.importFromCSV(event.filePath);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (count) => emit(ProductImportCompleted(importedCount: count)),
    );
  }

  Future<void> _onExportCSV(
      ProductExportToCSVRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await repository.exportToCSV(categoryId: event.categoryId);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (filePath) => emit(ProductExportCompleted(filePath: filePath)),
    );
  }
}
