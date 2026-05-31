import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/product_management_cubit.dart';
import '../cubit/product_management_state.dart';
import '../../domain/entities/product_entities.dart';

/// Mahsulotlarni boshqarish - 1C/SAP dan yuklash, kategoriyalar, narxlar
class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<ProductManagementCubit>().loadProducts();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final index = _tabController.index;
    final cubit = context.read<ProductManagementCubit>();
    switch (index) {
      case 0:
        cubit.loadProducts();
        break;
      case 1:
        cubit.loadCategories();
        break;
      case 2:
        cubit.loadPrices();
        break;
      case 3:
        cubit.loadStock();
        break;
      case 4:
        cubit.loadStatistics();
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, ProductManagementState state) {
    if (state.syncMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.syncMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductManagementCubit, ProductManagementState>(
      listenWhen: (previous, current) =>
          previous.syncMessage != current.syncMessage &&
          current.syncMessage != null,
      listener: _onStateChanged,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mahsulotlar boshqaruvi'),
            actions: [
              IconButton(
                  icon: const Icon(Icons.sync), onPressed: _showSyncDialog),
              IconButton(
                  icon: const Icon(Icons.file_upload),
                  onPressed: _showImportDialog),
              IconButton(
                  icon: const Icon(Icons.file_download),
                  onPressed: _showExportDialog),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  // Search
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (val) => context
                          .read<ProductManagementCubit>()
                          .searchProducts(val),
                      decoration: InputDecoration(
                        hintText: 'Mahsulot qidirish (nomi, kod, barcode)...',
                        prefixIcon: const Icon(Icons.search, size: 22),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner, size: 22),
                          onPressed: _scanBarcode,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Mahsulotlar'),
                      Tab(text: 'Kategoriyalar'),
                      Tab(text: 'Narxlar'),
                      Tab(text: 'Ombor'),
                      Tab(text: 'Statistika'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildProductsTab(state),
              _buildCategoriesTab(state),
              _buildPricesTab(state),
              _buildStockTab(state),
              _buildStatisticsTab(state),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
            label: const Text('Mahsulot qo\'shish'),
            backgroundColor: const Color(0xFF1565C0),
          ),
        );
      },
    );
  }

  // ==================== PRODUCTS TAB ====================
  Widget _buildProductsTab(ProductManagementState state) {
    if (state.isLoadingProducts && state.products.isEmpty)
      return const Center(child: CircularProgressIndicator());
    if (state.errorMessage != null && state.products.isEmpty)
      return _messageState(Icons.error_outline, state.errorMessage!);
    if (state.products.isEmpty)
      return _messageState(Icons.inventory_2_outlined, 'Mahsulotlar topilmadi');
    return _buildProductList(state.products);
  }

  Widget _messageState(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _filterChip('Barchasi', true),
              const SizedBox(width: 8),
              _filterChip('Faol', false),
              const SizedBox(width: 8),
              _filterChip('Chegirma', false),
              const SizedBox(width: 8),
              _filterChip('Tugayotgan', false),
            ],
          ),
        ),
        // Products
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(products[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            Image.network(product.imageUrl!, fit: BoxFit.cover),
                      )
                    : Icon(Icons.inventory_2,
                        color: Colors.grey.shade400, size: 28),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('Kod: ${product.code} • ${product.sku}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    Text('${product.categoryName} • ${product.unitOfMeasure}',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 11)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('${_fmt(product.basePrice)} so\'m',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1565C0))),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('%',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Stock info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.availableQuantity > 10
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                          : const Color(0xFFFF6F00).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${product.availableQuantity.toInt()} ${product.unitOfMeasure}',
                      style: TextStyle(
                        color: product.availableQuantity > 10
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFFF6F00),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  product.isActive
                      ? const Icon(Icons.check_circle,
                          color: Color(0xFF2E7D32), size: 18)
                      : Icon(Icons.cancel,
                          color: Colors.grey.shade400, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== CATEGORIES TAB ====================
  Widget _buildCategoriesTab(ProductManagementState state) {
    if (state.isLoadingCategories && state.categories.isEmpty)
      return const Center(child: CircularProgressIndicator());
    if (state.errorMessage != null && state.categories.isEmpty)
      return _messageState(Icons.error_outline, state.errorMessage!);
    if (state.categories.isEmpty)
      return _messageState(Icons.category_outlined, 'Kategoriyalar topilmadi');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final cat = state.categories[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
              child: const Icon(Icons.category, color: Color(0xFF1565C0)),
            ),
            title: Text(cat.name,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle:
                Text('Kod: ${cat.code} • Mahsulotlar: ${cat.productCount}'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showComingSoon('Kategoriya tafsilotlari'),
          ),
        );
      },
    );
  }

  // ==================== PRICES TAB ====================
  Widget _buildPricesTab(ProductManagementState state) {
    if (state.isLoadingPrices && state.priceLists.isEmpty)
      return const Center(child: CircularProgressIndicator());
    if (state.errorMessage != null && state.priceLists.isEmpty)
      return _messageState(Icons.error_outline, state.errorMessage!);
    if (state.priceLists.isEmpty)
      return _messageState(Icons.attach_money, 'Narxlar topilmadi');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.priceLists.length,
      itemBuilder: (context, index) {
        final price = state.priceLists[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              child: const Icon(Icons.price_change, color: Color(0xFF2E7D32)),
            ),
            title: Text(price.name,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
                'Valyuta: ${price.currency} • Yaroqli: ${price.validFrom.toString().split(' ')[0]}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: price.isActive
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(price.isActive ? 'Faol' : 'Nofaol',
                  style: TextStyle(
                      color: price.isActive
                          ? const Color(0xFF2E7D32)
                          : Colors.grey,
                      fontSize: 12)),
            ),
            onTap: () => _showComingSoon('Narxlar jadvali tafsilotlari'),
          ),
        );
      },
    );
  }

  // ==================== STOCK TAB ====================
  Widget _buildStockTab(ProductManagementState state) {
    if (state.isLoadingStock && state.stockItems.isEmpty)
      return const Center(child: CircularProgressIndicator());
    if (state.errorMessage != null && state.stockItems.isEmpty)
      return _messageState(Icons.error_outline, state.errorMessage!);
    if (state.stockItems.isEmpty)
      return _messageState(
          Icons.warehouse_outlined, 'Ombor qoldig\'i topilmadi');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.stockItems.length,
      itemBuilder: (context, index) {
        final stock = state.stockItems[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory, color: Colors.grey),
            ),
            title: Text(stock.productName,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            subtitle: Text(
                'Ombor: ${stock.warehouseName} • Partiya: ${stock.batchNumber ?? "-"}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${stock.quantity.toInt()}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: stock.quantity > 10
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFFF6F00)),
                ),
                Text('ta',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
            onTap: () => _showComingSoon('Ombor qoldig‘i tafsilotlari'),
          ),
        );
      },
    );
  }

  // ==================== STATISTICS TAB ====================
  Widget _buildStatisticsTab(ProductManagementState state) {
    if (state.isLoadingStatistics && state.statistics == null)
      return const Center(child: CircularProgressIndicator());
    if (state.errorMessage != null && state.statistics == null)
      return _messageState(Icons.error_outline, state.errorMessage!);
    final stats = state.statistics;
    if (stats == null)
      return _messageState(Icons.bar_chart, 'Statistika topilmadi');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Stats
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _statCard('Jami mahsulotlar', '${stats.totalProducts}',
                  Icons.inventory_2, const Color(0xFF1565C0)),
              _statCard('Faol mahsulotlar', '${stats.activeProducts}',
                  Icons.check_circle, const Color(0xFF2E7D32)),
              _statCard('Yangi (30 kun)', '${stats.newProducts}',
                  Icons.new_releases, const Color(0xFFFF6F00)),
              _statCard('Tugayotgan', '${stats.lowStockProducts}',
                  Icons.warning, const Color(0xFFC62828)),
            ],
          ),
          const SizedBox(height: 20),

          // Stock value
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ombor qiymati',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text('${_fmt(stats.totalStockValue)} so\'m',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sync status
          _buildSectionHeader('Sinxronlash holati', Icons.sync),
          const SizedBox(height: 12),
          _buildSyncStatusCard(),
          const SizedBox(height: 20),

          // Quick actions
          _buildSectionHeader('Tezkor harakatlar', Icons.flash_on),
          const SizedBox(height: 12),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            Icon(icon, color: color, size: 20),
          ]),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(children: [
      Icon(icon, color: const Color(0xFF1565C0), size: 20),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildSyncStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          _syncRow(
              '1C:Enterprise', true, '15 daqiqa oldin', '1,234 ta yangilandi'),
          const Divider(height: 16),
          _syncRow('SAP S/4HANA', true, '30 daqiqa oldin', '890 ta yangilandi'),
          const Divider(height: 16),
          _syncRow('Kategoriyalar', true, '1 soat oldin', '45 ta yangilandi'),
          const Divider(height: 16),
          _syncRow('Narxlar', true, '2 soat oldin', '567 ta yangilandi'),
        ],
      ),
    );
  }

  Widget _syncRow(String name, bool isOk, String time, String count) {
    return Row(
      children: [
        Icon(isOk ? Icons.check_circle : Icons.error,
            size: 18, color: isOk ? const Color(0xFF2E7D32) : Colors.red),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            Text(time,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ]),
        ),
        Text(count,
            style: TextStyle(
                color: isOk ? const Color(0xFF2E7D32) : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
            child: _quickAction(
                '1C dan yuklash',
                Icons.cloud_download,
                const Color(0xFF1565C0),
                () => context.read<ProductManagementCubit>().syncFrom1C())),
        const SizedBox(width: 12),
        Expanded(
            child: _quickAction(
                'SAP dan yuklash',
                Icons.cloud_download,
                const Color(0xFFFF6F00),
                () => context.read<ProductManagementCubit>().syncFromSAP())),
        const SizedBox(width: 12),
        Expanded(
            child: _quickAction('CSV import', Icons.upload_file,
                const Color(0xFF2E7D32), _showImportDialog)),
        const SizedBox(width: 12),
        Expanded(
            child: _quickAction('CSV export', Icons.download,
                const Color(0xFF00897B), _showExportDialog)),
      ],
    );
  }

  Widget _quickAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _filterChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1565C0) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: selected ? const Color(0xFF1565C0) : Colors.grey.shade300),
      ),
      child: Text(label,
          style: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade700,
              fontSize: 12)),
    );
  }

  String _fmt(double amount) {
    if (amount >= 1000000000)
      return '${(amount / 1000000000).toStringAsFixed(1)}Mrd';
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }

  void _showSyncDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sinxronlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('1C',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
              title: const Text('1C:Enterprise dan yuklash'),
              subtitle: const Text('Mahsulotlar, kategoriyalar, narxlar'),
              onTap: () {
                Navigator.pop(context);
                context.read<ProductManagementCubit>().syncFrom1C();
              },
            ),
            ListTile(
              leading: const Text('SAP',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFFFF6F00))),
              title: const Text('SAP S/4HANA dan yuklash'),
              subtitle: const Text('Materiallar, narxlar, qoldiqlar'),
              onTap: () {
                Navigator.pop(context);
                context.read<ProductManagementCubit>().syncFromSAP();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync, color: Color(0xFF2E7D32)),
              title: const Text('Barcha tizimlar'),
              subtitle: const Text('1C + SAP dan to\'liq sinxronlash'),
              onTap: () {
                Navigator.pop(context);
                context.read<ProductManagementCubit>().syncAll();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog() {
    _showComingSoon('Import oynasi ochildi');
  }

  void _showExportDialog() {
    _showComingSoon('Eksport jarayoni boshlandi');
  }

  Future<void> _scanBarcode() async {
    final result =
        await context.push<Map<String, dynamic>>('/products/barcode');
    if (!mounted || result == null) return;
    final barcode = (result['barcode'] ?? '').toString();
    if (barcode.isEmpty) return;

    _searchController.text = barcode;
    context.read<ProductManagementCubit>().searchProductByBarcode(barcode);
  }

  void _showAddProductDialog() {
    _showComingSoon('Mahsulot qo‘shish formasi ochildi');
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Kod: ${product.code} • SKU: ${product.sku}'),
            Text('Kategoriya: ${product.categoryName}'),
            Text('Narx: ${_fmt(product.basePrice)} so‘m'),
            Text(
                'Ombor: ${product.availableQuantity.toInt()} ${product.unitOfMeasure}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Yopish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
