import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_management_state.dart';

class ProductManagementCubit extends Cubit<ProductManagementState> {
  final ProductRepository repository;

  ProductManagementCubit({required this.repository})
      : super(const ProductManagementState());

  Future<void> loadProducts() async {
    if (state.products.isNotEmpty) return; // Cache hit
    emit(state.copyWith(isLoadingProducts: true, errorMessage: null));
    final result = await repository.getProducts();
    result.fold(
      (failure) => emit(state.copyWith(
          isLoadingProducts: false, errorMessage: failure.message)),
      (data) => emit(state.copyWith(isLoadingProducts: false, products: data)),
    );
  }

  Future<void> searchProducts(String query) async {
    emit(state.copyWith(isLoadingProducts: true, errorMessage: null));
    final result = await repository.searchProducts(query);
    result.fold(
      (failure) => emit(state.copyWith(
          isLoadingProducts: false, errorMessage: failure.message)),
      (data) => emit(state.copyWith(isLoadingProducts: false, products: data)),
    );
  }

  Future<void> searchProductByBarcode(String barcode) async {
    emit(state.copyWith(isLoadingProducts: true, errorMessage: null));
    final result = await repository.getProductByBarcode(barcode);
    result.fold(
      (failure) => emit(state.copyWith(
          isLoadingProducts: false, errorMessage: failure.message)),
      (data) => emit(state.copyWith(
        isLoadingProducts: false,
        products: data != null ? [data] : [],
        errorMessage: data == null
            ? 'Barcode bo‘yicha mahsulot topilmadi: $barcode'
            : null,
      )),
    );
  }

  Future<void> loadCategories() async {
    if (state.categories.isNotEmpty) return;
    emit(state.copyWith(isLoadingCategories: true, errorMessage: null));
    final result = await repository.getCategories();
    result.fold(
      (failure) => emit(state.copyWith(
          isLoadingCategories: false, errorMessage: failure.message)),
      (data) =>
          emit(state.copyWith(isLoadingCategories: false, categories: data)),
    );
  }

  Future<void> loadPrices() async {
    if (state.priceLists.isNotEmpty) return;
    emit(state.copyWith(isLoadingPrices: true, errorMessage: null));
    final result = await repository.getPriceLists();
    result.fold(
      (failure) => emit(state.copyWith(
          isLoadingPrices: false, errorMessage: failure.message)),
      (data) => emit(state.copyWith(isLoadingPrices: false, priceLists: data)),
    );
  }

  Future<void> loadStock() async {
    if (state.stockItems.isNotEmpty) return;
    emit(state.copyWith(isLoadingStock: true, errorMessage: null));
    final result = await repository.getStockBalance(warehouseId: 'all');
    result.fold(
      (failure) => emit(
          state.copyWith(isLoadingStock: false, errorMessage: failure.message)),
      (data) => emit(state.copyWith(isLoadingStock: false, stockItems: data)),
    );
  }

  Future<void> loadStatistics() async {
    if (state.statistics != null) return;
    emit(state.copyWith(isLoadingStatistics: true, errorMessage: null));
    final result = await repository.getProductStatistics();
    result.fold(
      (failure) => emit(state.copyWith(
          isLoadingStatistics: false, errorMessage: failure.message)),
      (data) =>
          emit(state.copyWith(isLoadingStatistics: false, statistics: data)),
    );
  }

  Future<void> syncFrom1C() async {
    emit(state.copyWith(syncMessage: '1C:Enterprise dan yuklash boshlandi...'));
    final result = await repository.syncProductsFrom1C();
    result.fold(
      (failure) => emit(
          state.copyWith(syncMessage: null, errorMessage: failure.message)),
      (_) => emit(
          state.copyWith(syncMessage: '1C:Enterprise dan yuklash yakunlandi')),
    );
  }

  Future<void> syncFromSAP() async {
    emit(state.copyWith(syncMessage: 'SAP S/4HANA dan yuklash boshlandi...'));
    final result = await repository.syncProductsFromSAP();
    result.fold(
      (failure) => emit(
          state.copyWith(syncMessage: null, errorMessage: failure.message)),
      (_) => emit(
          state.copyWith(syncMessage: 'SAP S/4HANA dan yuklash yakunlandi')),
    );
  }

  Future<void> syncAll() async {
    emit(state.copyWith(
        syncMessage: 'Barcha tizimlardan sinxronlash boshlandi...'));
    final result = await repository.syncAllProducts();
    result.fold(
      (failure) => emit(
          state.copyWith(syncMessage: null, errorMessage: failure.message)),
      (_) =>
          emit(state.copyWith(syncMessage: 'Sinxronlash to\'liq yakunlandi')),
    );
  }
}
