import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import 'order_product_card.dart';
import '../../domain/entities/order_catalog_product.dart';

class CreateOrderProductStep extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final bool catalogLoading;
  final bool productsLoading;
  final Widget portfolioFilters;
  final Widget accessModeToggle;
  final Widget portfolioAccessInfo;
  final Widget assignedPortfolioSummary;
  final Widget? cartSummary;
  final List<ProductCardViewModel> products;
  final VoidCallback? onScanBarcode;

  const CreateOrderProductStep({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.catalogLoading,
    required this.productsLoading,
    required this.portfolioFilters,
    required this.accessModeToggle,
    required this.portfolioAccessInfo,
    required this.assignedPortfolioSummary,
    this.cartSummary,
    required this.products,
    this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Mahsulot qidirish...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: onClearSearch),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                    icon:
                        const Icon(Icons.qr_code_scanner, color: Colors.white),
                    onPressed: onScanBarcode),
              ),
            ],
          ),
        ),
        if (catalogLoading || productsLoading)
          const LinearProgressIndicator(minHeight: 2),
        portfolioFilters,
        accessModeToggle,
        portfolioAccessInfo,
        assignedPortfolioSummary,
        if (cartSummary != null) cartSummary!,
        Expanded(
          child: products.isEmpty
              ? const AppEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Mahsulot topilmadi',
                  message:
                      'Qidiruv, portfolio yoki assortiment filterlarini o‘zgartiring.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final vm = products[index];
                    return OrderProductCard(
                      product: vm.product,
                      quantity: vm.quantity,
                      stock: vm.stock,
                      canSell: vm.canSell,
                      accessReason: vm.accessReason,
                      stockWarning: vm.stockWarning,
                      pricingNote: vm.pricingNote,
                      onAdd: vm.onAdd,
                      onIncrement: vm.onIncrement,
                      onDecrement: vm.onDecrement,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class ProductCardViewModel {
  final OrderCatalogProduct product;
  final int? quantity;
  final int stock;
  final bool canSell;
  final String? accessReason;
  final String? stockWarning;
  final String? pricingNote;
  final VoidCallback? onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const ProductCardViewModel({
    required this.product,
    this.quantity,
    required this.stock,
    required this.canSell,
    this.accessReason,
    this.stockWarning,
    this.pricingNote,
    this.onAdd,
    this.onIncrement,
    this.onDecrement,
  });
}
