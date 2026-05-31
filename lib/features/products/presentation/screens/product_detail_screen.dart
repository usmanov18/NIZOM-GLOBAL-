import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_entities.dart';
import '../bloc/product_bloc.dart';

/// Mahsulot tafsilotlari — ProductBloc orqali real repository/cache'dan yuklanadi.
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (widget.productId.trim().isEmpty) return;
    context.read<ProductBloc>().add(ProductDetailRequested(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productId.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mahsulot tafsilotlari')),
        body: _emptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Mahsulot tanlanmagan',
          message: 'Mahsulot tafsilotlarini ko‘rish uchun mahsulot ID kerak.',
        ),
      );
    }

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mahsulot tafsilotlari')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProductDetailLoaded) {
          return _detailScaffold(context, state.product, state.stockItems);
        }

        if (state is ProductError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mahsulot tafsilotlari')),
            body: _emptyState(
              icon: Icons.error_outline,
              title: 'Mahsulot yuklanmadi',
              message: state.message,
              action: ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Qayta yuklash'),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Mahsulot tafsilotlari')),
          body: _emptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Ma’lumot kutilmoqda',
            message: 'Mahsulot tafsilotlari repository orqali yuklanadi.',
            action: ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Yuklash'),
            ),
          ),
        );
      },
    );
  }

  Widget _detailScaffold(
      BuildContext context, Product product, List<StockItem> stockItems) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                _showInfo(context, 'Mahsulot tahrirlash oynasi ochildi'),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () =>
                _showInfo(context, '${product.name} ulashish tanlandi'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageBox(product),
              const SizedBox(height: 16),
              Text(product.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Kod: ${product.code} • SKU: ${product.sku}',
                  style: TextStyle(color: Colors.grey.shade600)),
              if (product.barcode != null && product.barcode!.isNotEmpty)
                Text('Barcode: ${product.barcode}',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              const SizedBox(height: 16),
              _buildPriceSection(product),
              const SizedBox(height: 16),
              _buildStockSection(product, stockItems),
              const SizedBox(height: 16),
              _buildDetailsSection(product),
              if (product.description != null &&
                  product.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSection('Tavsif', [
                  Text(product.description!,
                      style: TextStyle(color: Colors.grey.shade700))
                ]),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, product),
    );
  }

  Widget _imageBox(Product product) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: product.imageUrl == null || product.imageUrl!.isEmpty
          ? Icon(Icons.inventory_2, size: 80, color: Colors.grey.shade400)
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(product.imageUrl!, fit: BoxFit.cover),
            ),
    );
  }

  Widget _buildPriceSection(Product product) {
    final hasDiscount = product.hasDiscount && product.discountPrice != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Narx:', style: TextStyle(fontSize: 14)),
              if (hasDiscount)
                Text(
                  '${_formatAmount(product.basePrice)} ${product.currency}',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (hasDiscount)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC62828).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${product.discountPercent?.toStringAsFixed(0) ?? 0}%',
                    style: const TextStyle(
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                '${_formatAmount(product.effectivePrice)} ${product.currency}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockSection(Product product, List<StockItem> stockItems) {
    final quantity = stockItems.isEmpty
        ? product.stockQuantity
        : stockItems.fold<double>(0, (sum, item) => sum + item.quantity);
    final reserved = stockItems.isEmpty
        ? product.reservedQuantity
        : stockItems.fold<double>(0, (sum, item) => sum + item.reserved);
    final available = stockItems.isEmpty
        ? product.availableQuantity
        : stockItems.fold<double>(0, (sum, item) => sum + item.available);
    final progress =
        quantity <= 0 ? 0.0 : (available / quantity).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stockItem(
                  'Omborda', _formatQty(quantity), const Color(0xFF1565C0)),
              _stockItem('Band', _formatQty(reserved), const Color(0xFFFF6F00)),
              _stockItem(
                  'Mavjud', _formatQty(available), const Color(0xFF2E7D32)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                available > 20
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFFF6F00),
              ),
            ),
          ),
          if (stockItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...stockItems.take(3).map((item) => _detailRow(item.warehouseName,
                '${_formatQty(item.available)} ${item.unitOfMeasure}')),
          ],
        ],
      ),
    );
  }

  Widget _stockItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ],
    );
  }

  Widget _buildDetailsSection(Product product) {
    return _buildSection('Ma’lumotlar', [
      _detailRow('Kategoriya',
          product.categoryName.isEmpty ? '-' : product.categoryName),
      _detailRow('Brend', product.brand ?? '-'),
      _detailRow('Birlik', product.unitOfMeasure),
      _detailRow('Vazn', '${product.weight} kg'),
      _detailRow('Manba', product.syncSource.toUpperCase()),
      _detailRow('Oxirgi sync', _formatDate(product.lastSyncedAt)),
    ]);
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () =>
            _showInfo(context, '${product.name} savatga qo‘shildi'),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Savatga qo‘shish'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade500),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  String _formatQty(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
