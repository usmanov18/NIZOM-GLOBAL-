import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_flow_bloc.dart';
import '../../domain/entities/order_flow_entities.dart';

/// 2-BOSQICH: Agent mahsulotlarni tanlaydi
class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    context.read<OrderFlowBloc>().add(LoadProducts());
    context.read<OrderFlowBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mahsulotlar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<OrderFlowBloc>().add(
                      LoadProducts(search: value),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Mahsulot qidirish...',
                    prefixIcon: const Icon(Icons.search, size: 22),
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
              // Categories
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildCategoryChip('Barchasi', null),
                    _buildCategoryChip('Ichimliklar', 'drinks'),
                    _buildCategoryChip('Non mahsulotlari', 'bakery'),
                    _buildCategoryChip('Sut mahsulotlari', 'dairy'),
                    _buildCategoryChip('Shirinliklar', 'sweets'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<OrderFlowBloc, OrderFlowState>(
        listener: (context, state) {
          if (state is ProductSelected) {
            _showProductDetailSheet(state.product, state.price, state.stock);
          }
        },
        builder: (context, state) {
          if (state is OrderFlowLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ProductsLoaded) {
            return _buildProductGrid(state.products);
          }
          
          if (state is CustomerSelected) {
            return const Center(child: Text('Mahsulotlar yuklanmoqda...'));
          }
          
          return const Center(child: Text('Mahsulotlarni yuklang'));
        },
      ),
      // Savat tugmasi
      floatingActionButton: _buildCartFab(),
    );
  }

  Widget _buildCategoryChip(String label, String? categoryId) {
    final isSelected = _selectedCategoryId == categoryId;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategoryId = selected ? categoryId : null);
          context.read<OrderFlowBloc>().add(
            LoadProducts(categoryId: _selectedCategoryId),
          );
        },
        selectedColor: const Color(0xFF1565C0).withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
        side: BorderSide(
          color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<OrderProduct> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Mahsulotlar topilmadi',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(OrderProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectProduct(product),
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          ),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              
              // Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.categoryName,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.unitOfMeasure,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: product.isAvailable
                                      ? const Color(0xFF2E7D32).withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product.isAvailable ? 'Mavjud' : 'Yo\'q',
                                  style: TextStyle(
                                    color: product.isAvailable
                                        ? const Color(0xFF2E7D32)
                                        : Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2,
        size: 40,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildCartFab() {
    return BlocBuilder<OrderFlowBloc, OrderFlowState>(
      builder: (context, state) {
        int itemCount = 0;
        if (state is CartUpdated) {
          itemCount = state.totalItems;
        }
        
        return FloatingActionButton.extended(
          onPressed: itemCount > 0 ? _goToCart : null,
          backgroundColor: itemCount > 0
              ? const Color(0xFF2E7D32)
              : Colors.grey,
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              if (itemCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          label: Text(
            itemCount > 0 ? 'Savat ($itemCount)' : 'Savat',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  void _selectProduct(OrderProduct product) {
    final state = context.read<OrderFlowBloc>().state;
    if (state is CustomerSelected || state is ProductsLoaded) {
      context.read<OrderFlowBloc>().add(SelectProduct(product));
    }
  }

  void _showProductDetailSheet(
    OrderProduct product,
    ProductPrice price,
    ProductStock? stock,
  ) {
    int quantity = 1;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Product info
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.code} • ${product.unitOfMeasure}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Asosiy narx:'),
                            Text(
                              '${_formatAmount(price.basePrice)} so\'m',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if (price.discountPercent > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Chegirma (${price.discountPercent}%):',
                                style: const TextStyle(color: Colors.green),
                              ),
                              Text(
                                '- ${_formatAmount(price.discountAmount)} so\'m',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sotuv narxi:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${_formatAmount(price.finalPrice)} so\'m',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stock
                  if (stock != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: stock.isAvailableForSale
                            ? const Color(0xFF2E7D32).withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            stock.isAvailableForSale
                                ? Icons.check_circle
                                : Icons.warning,
                            color: stock.isAvailableForSale
                                ? const Color(0xFF2E7D32)
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Omborda: ${stock.actualQuantity.toStringAsFixed(0)} ${product.unitOfMeasure}',
                            style: TextStyle(
                              color: stock.isAvailableForSale
                                  ? const Color(0xFF2E7D32)
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  
                  // Quantity selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => setSheetState(() => quantity--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 32,
                      ),
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setSheetState(() => quantity++),
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 32,
                        color: const Color(0xFF1565C0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jami:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_formatAmount(price.finalPrice * quantity)} so\'m',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _addToCart(product, price, stock, quantity);
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text(
                        'Savatga qo\'shish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addToCart(
    OrderProduct product,
    ProductPrice price,
    ProductStock? stock,
    int quantity,
  ) {
    if (stock == null || !stock.isAvailableForSale) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Omborda mahsulot yo\'q'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    context.read<OrderFlowBloc>().add(AddToCart(
      product: product,
      price: price,
      stock: stock,
      quantity: quantity,
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} savatga qo\'shildi'),
        backgroundColor: const Color(0xFF2E7D32),
        action: SnackBarAction(
          label: 'Savatga o\'tish',
          textColor: Colors.white,
          onPressed: _goToCart,
        ),
      ),
    );
  }

  void _goToCart() {
    context.push('/orders/cart');
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}
