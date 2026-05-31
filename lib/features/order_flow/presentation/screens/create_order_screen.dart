import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/utils/app_formatters.dart';
import '../../../../shared/utils/business_formatters.dart';
import '../../../../core/services/territory_assignment/territory_assignment_service.dart';
import '../../../../core/services/territory_assignment/territory_assignment_models.dart';
import '../../../products/domain/repositories/product_portfolio_repository.dart';
import '../../../products/domain/entities/product_portfolio.dart';
import '../../../products/domain/policies/product_access_resolver.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../bloc/order_flow_bloc.dart';
import '../controllers/create_order_controller.dart';
import '../../data/datasources/order_seed_catalog_datasource.dart';
import '../../domain/repositories/order_catalog_repository.dart';
import '../../domain/entities/order_flow_entities.dart';
import '../../domain/policies/product_stock_resolver.dart';
import '../../domain/policies/order_validation_policy.dart';
import '../widgets/create_order_step_indicator.dart';
import '../widgets/portfolio_summary_card.dart';
import '../widgets/order_product_card.dart';
import '../widgets/order_customer_card.dart';
import '../widgets/create_order_customer_step.dart';
import '../widgets/create_order_payment_step.dart';
import '../widgets/create_order_confirm_step.dart';
import '../widgets/create_order_product_step.dart';
import '../../domain/policies/credit_limit_policy.dart';
import '../../domain/policies/pricing_resolver.dart';
import '../../../discounts/domain/entities/discount_entities.dart';
import '../../domain/entities/order_catalog_product.dart';

/// Yangi buyurtma yaratish - 4 bosqichli wizard
class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final PageController _pageController = PageController();
  final _customerSearchController = TextEditingController();
  final _productSearchController = TextEditingController();
  String _selectedPortfolioFilter = 'all';
  String _selectedAssortmentFilter = 'all';
  Set<String> _allowedPortfolioIds = {};
  bool _canSellOutsidePortfolio = false;
  bool _portfolioRulesLoaded = false;
  bool _showRestrictedProducts = false;
  PortfolioAssignment? _portfolioAssignment;
  List<ProductPortfolio> _portfolioCatalog = const [];
  String _currentUserId = 'demo_agent';
  String _currentUserRole = 'agent';
  int _currentStep = 0;
  
  // Tanlangan ma'lumotlar
  OrderCustomer? _selectedCustomer;
  final CreateOrderController _orderController = CreateOrderController();
  List<CreateOrderCartItem> get _cartItems => _orderController.items;
  String _paymentMethod = 'cash';
  String _selectedWarehouseId = 'warehouse_1';
  List<String> _allowedWarehouseIds = const ['warehouse_1'];
  OrderWarehouseResolution? _warehouseResolution;
  bool _warehouseResolving = false;
  DateTime? _deliveryDate;
  String? _deliveryTimeSlot;
  final _notesController = TextEditingController();
  List<OrderCustomer> _catalogCustomers = const [];
  List<_CatalogProduct> _catalogProducts = const [];
  bool _catalogLoading = true;
  bool _customersLoading = false;
  bool _productsLoading = false;
  Timer? _customerSearchDebounce;
  Timer? _productSearchDebounce;
  
  final List<String> _timeSlots = [
    '09:00 - 12:00',
    '12:00 - 15:00',
    '15:00 - 18:00',
    '18:00 - 21:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    _loadPortfolioRules();
  }

  Future<void> _loadCatalog() async {
    setState(() => _catalogLoading = true);
    await Future.wait([_loadCustomers(), _loadProducts()]);
    if (!mounted) return;
    setState(() => _catalogLoading = false);
  }

  Future<void> _loadCustomers({String? search}) async {
    setState(() => _customersLoading = true);
    final result = await getIt<OrderCatalogRepository>().getCustomers(search: search);
    if (!mounted) return;
    setState(() {
      _catalogCustomers = result.fold(
        (_) => OrderSeedCatalogDataSource.seedCustomers(),
        (items) => items,
      );
      _customersLoading = false;
    });
  }

  Future<void> _loadProducts({String? search}) async {
    setState(() => _productsLoading = true);
    final result = await getIt<OrderCatalogRepository>().getProducts(
      search: search,
      portfolioId: _selectedPortfolioFilter,
      assortment: _selectedAssortmentFilter,
    );
    if (!mounted) return;
    setState(() {
      _catalogProducts = result.fold(
        (_) => OrderSeedCatalogDataSource.seedProducts().map(_CatalogProduct.fromCatalog).toList(),
        (items) => items.map(_CatalogProduct.fromCatalog).toList(),
      );
      _productsLoading = false;
    });
  }

  void _onCustomerSearchChanged(String value) {
    setState(() {});
    _customerSearchDebounce?.cancel();
    _customerSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadCustomers(search: value);
    });
  }

  void _onProductSearchChanged(String value) {
    setState(() {});
    _productSearchDebounce?.cancel();
    _productSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadProducts(search: value);
    });
  }

  Future<void> _loadPortfolioRules() async {
    final repository = getIt<ProductPortfolioRepository>();
    final authResult = await getIt<AuthRepository>().getCurrentUser();
    final user = authResult.fold((_) => null, (value) => value);
    final userId = user?.id ?? 'demo_agent';
    final role = user?.role ?? 'agent';

    final assignmentResult = await repository.getAssignmentForUser(userId, role);
    final portfoliosResult = await repository.getPortfolios();
    final portfolios = portfoliosResult.fold(
      (_) => repository.demoPortfolios,
      (items) => items,
    );

    if (!mounted) return;
    assignmentResult.fold(
      (_) => setState(() {
        _currentUserId = userId;
        _currentUserRole = role;
        _portfolioAssignment = null;
        _portfolioCatalog = portfolios;
        _allowedPortfolioIds = {};
        _canSellOutsidePortfolio = false;
        _allowedWarehouseIds = user?.allowedWarehouseIds.isNotEmpty == true
            ? user!.allowedWarehouseIds
            : [if (user?.warehouseId != null) user!.warehouseId! else 'warehouse_1'];
        _selectedWarehouseId = (user?.warehouseId != null && _allowedWarehouseIds.contains(user!.warehouseId))
            ? user.warehouseId!
            : _allowedWarehouseIds.first;
        _portfolioRulesLoaded = true;
      }),
      (assignment) => setState(() {
        _currentUserId = userId;
        _currentUserRole = role;
        _portfolioAssignment = assignment;
        _portfolioCatalog = portfolios;
        _allowedPortfolioIds = assignment.portfolioIds.toSet();
        _canSellOutsidePortfolio = assignment.canSellOutsidePortfolio;
        _allowedWarehouseIds = user?.allowedWarehouseIds.isNotEmpty == true
            ? user!.allowedWarehouseIds
            : [if (user?.warehouseId != null) user!.warehouseId! else 'warehouse_1'];
        if (!_allowedWarehouseIds.contains(_selectedWarehouseId)) {
          _selectedWarehouseId = (user?.warehouseId != null && _allowedWarehouseIds.contains(user!.warehouseId))
              ? user.warehouseId!
              : _allowedWarehouseIds.first;
        }
        _portfolioRulesLoaded = true;
      }),
    );
  }

  @override
  void dispose() {
    _customerSearchDebounce?.cancel();
    _productSearchDebounce?.cancel();
    _pageController.dispose();
    _customerSearchController.dispose();
    _productSearchController.dispose();
    _notesController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderFlowBloc, OrderFlowState>(
      listener: _onOrderFlowStateChanged,
      child: Scaffold(
      appBar: AppBar(
        title: Text('Buyurtma (${_currentStep + 1}/4)'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildStepIndicator(),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [
          _buildStep1Customer(),
          _buildStep2Products(),
          _buildStep3Payment(),
          _buildStep4Confirm(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    ));
  }

  void _onOrderFlowStateChanged(BuildContext context, OrderFlowState state) {
    if (state is OrderCreatedSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Buyurtma ${state.order.orderNumber} local saqlandi ✅'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context);
    } else if (state is OrderFlowError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildStepIndicator() => CreateOrderStepIndicator(currentStep: _currentStep);


  // ==================== STEP 1: MIJOZ ====================
  Widget _buildStep1Customer() {
    return CreateOrderCustomerStep(
      searchController: _customerSearchController,
      onSearchChanged: _onCustomerSearchChanged,
      onClearSearch: () {
        _customerSearchController.clear();
        _loadCustomers();
        setState(() {});
      },
      loading: _customersLoading,
      customers: _filteredCustomers,
      selectedCustomer: _selectedCustomer,
      onCustomerSelected: (customer) {
        setState(() => _selectedCustomer = customer);
        _normalizeWarehouseForCustomer(customer);
        _resolveWarehouseFromSystems(customer);
      },
    );
  }

  List<OrderCustomer> get _seedCustomers => _catalogCustomers.isEmpty ? OrderSeedCatalogDataSource.seedCustomers() : _catalogCustomers;

  List<OrderCustomer> get _filteredCustomers {
    final query = _customerSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return _seedCustomers;
    return _seedCustomers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
          customer.code.toLowerCase().contains(query) ||
          customer.address.toLowerCase().contains(query) ||
          customer.phone.toLowerCase().contains(query);
    }).toList();
  }


  // ==================== STEP 2: MAHSULOTLAR ====================
  Widget _buildStep2Products() {
    return CreateOrderProductStep(
      searchController: _productSearchController,
      onSearchChanged: _onProductSearchChanged,
      onClearSearch: () {
        _productSearchController.clear();
        _loadProducts();
        setState(() {});
      },
      catalogLoading: _catalogLoading,
      productsLoading: _productsLoading,
      portfolioFilters: _buildProductPortfolioFilters(),
      accessModeToggle: _buildProductAccessModeToggle(),
      portfolioAccessInfo: _buildPortfolioAccessInfo(),
      assignedPortfolioSummary: _buildAssignedPortfolioSummary(),
      cartSummary: _cartItems.isEmpty ? null : _buildCartSummary(),
      products: _filteredProducts.map(_productViewModel).toList(),
      onScanBarcode: _scanBarcodeForOrder,
    );
  }

  Widget _buildCartSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text('${_orderController.lineCount} ta mahsulot tanlandi', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('${AppFormatters.money(_orderController.totalAmount, suffix: '')} so'm', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _scanBarcodeForOrder() async {
    final result = await context.push<Map<String, dynamic>>('/products/barcode');
    if (!mounted || result == null) return;

    final query = (result['barcode'] ?? result['name'] ?? '').toString();
    if (query.isEmpty) return;

    _productSearchController.text = query;
    await _loadProducts(search: query);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Barcode orqali qidirildi: $query')),
    );
  }

  ProductCardViewModel _productViewModel(_CatalogProduct product) {
    final decision = _accessDecisionFor(product);
    final canSell = decision.canSell;
    final cartItem = _cartItems.where((item) => item.productId == product.id).isEmpty
        ? null
        : _cartItems.firstWhere((item) => item.productId == product.id);
    final quantityForPricing = cartItem?.quantity ?? 1;
    final pricing = _pricingForProduct(product, quantityForPricing);
    final stock = _stockForProduct(product);
    final stockDecision = _stockDecisionFor(product, quantityForPricing);
    return ProductCardViewModel(
      product: OrderCatalogProduct(
        id: product.id,
        name: product.name,
        category: product.category,
        price: pricing.finalUnitPrice,
        stock: product.stock,
        stockByWarehouse: product.stockByWarehouse,
        portfolioId: product.portfolioId,
        assortment: product.assortment,
        source: product.source,
        brand: product.brand,
      ),
      quantity: cartItem?.quantity,
      stock: stock,
      canSell: canSell,
      accessReason: !canSell ? decision.reason : null,
      stockWarning: stockDecision.requiresWarning ? stockDecision.message : null,
      pricingNote: _pricingNote(pricing),
      onAdd: canSell && stockDecision.canAddToCart
          ? () {
              setState(() {
                _orderController.addItem(
                  productId: product.id,
                  productName: product.name,
                  price: pricing.finalUnitPrice,
                  quantity: 1,
                  pricingSnapshot: _pricingSnapshot(pricing),
                );
              });
            }
          : null,
      onIncrement: canSell && stockDecision.canIncreaseQuantity
          ? () {
              final nextQuantity = (cartItem?.quantity ?? 0) + 1;
              final newPricing = _pricingForProduct(product, nextQuantity);
              setState(() {
                _orderController.incrementItem(
                  productId: product.id,
                  price: newPricing.finalUnitPrice,
                  pricingSnapshot: _pricingSnapshot(newPricing),
                );
              });
            }
          : null,
      onDecrement: () {
        final current = _orderController.findItem(product.id);
        if (current == null) return;
        final nextQuantity = current.quantity - 1;
        final newPricing = nextQuantity > 0 ? _pricingForProduct(product, nextQuantity) : null;
        setState(() {
          _orderController.decrementItem(
            productId: product.id,
            price: newPricing?.finalUnitPrice,
            pricingSnapshot: newPricing == null ? null : _pricingSnapshot(newPricing),
          );
        });
      },
    );
  }

  Widget _buildProductPortfolioFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChoice('Barcha portfel', 'all', _selectedPortfolioFilter, _onPortfolioFilterChanged),
                _filterChoice('Ichimliklar', 'pf_beverages', _selectedPortfolioFilter, _onPortfolioFilterChanged),
                _filterChoice('Snack/Qandolat', 'pf_snacks', _selectedPortfolioFilter, _onPortfolioFilterChanged),
                _filterChoice('Premium', 'pf_energy_premium', _selectedPortfolioFilter, _onPortfolioFilterChanged),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChoice('Barcha assortiment', 'all', _selectedAssortmentFilter, _onAssortmentFilterChanged),
                _filterChoice('Majburiy', 'mandatory', _selectedAssortmentFilter, _onAssortmentFilterChanged),
                _filterChoice('Tavsiya', 'recommended', _selectedAssortmentFilter, _onAssortmentFilterChanged),
                _filterChoice('Ixtiyoriy', 'optional', _selectedAssortmentFilter, _onAssortmentFilterChanged),
                _filterChoice('Mavsumiy', 'seasonal', _selectedAssortmentFilter, _onAssortmentFilterChanged),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPortfolioAccessInfo() {
    if (!_portfolioRulesLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }

    final text = _canSellOutsidePortfolio
        ? '$_currentUserRole uchun barcha portfellardan sotish ruxsat etilgan'
        : "$_currentUserRole ruxsat portfellari: ${_allowedPortfolioIds.join(', ')}";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user, color: Color(0xFF1565C0), size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildProductAccessModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(children: [
        const Icon(Icons.visibility_outlined, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text('Ruxsatsiz mahsulotlarni ko‘rsatish', style: TextStyle(color: Colors.grey.shade700, fontSize: 12))),
        Switch.adaptive(value: _showRestrictedProducts, onChanged: (value) => setState(() => _showRestrictedProducts = value)),
      ]),
    );
  }

  ProductAccessDecision _accessDecisionFor(_CatalogProduct product) {
    if (!_portfolioRulesLoaded || _portfolioAssignment == null) {
      return const ProductAccessDecision(state: ProductAccessState.visible);
    }
    return ProductAccessResolver.resolve(
      role: _currentUserRole,
      productId: product.id,
      productPortfolioIds: [product.portfolioId],
      assignment: _portfolioAssignment!,
      portfolios: _portfolioCatalog,
      showRestrictedAsDisabled: _showRestrictedProducts,
    );
  }

  Widget _buildAssignedPortfolioSummary() {
    if (!_portfolioRulesLoaded || _allowedPortfolioIds.isEmpty) return const SizedBox.shrink();
    final ids = _canSellOutsidePortfolio ? ['pf_beverages', 'pf_snacks', 'pf_energy_premium'] : _allowedPortfolioIds.toList();
    return Container(
      height: 96,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ids.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final id = ids[index];
          final count = _seedProducts.where((p) => p.portfolioId == id).length;
          return PortfolioSummaryCard(
            id: id,
            shortName: _portfolioShortName(id),
            title: _portfolioDisplayName(id),
            skuCount: count,
            selected: _selectedPortfolioFilter == id,
            onTap: () => _onPortfolioFilterChanged(_selectedPortfolioFilter == id ? 'all' : id),
          );
        },
      ),
    );
  }

  void _onPortfolioFilterChanged(String value) {
    setState(() => _selectedPortfolioFilter = value);
    _loadProducts(search: _productSearchController.text);
  }

  void _onAssortmentFilterChanged(String value) {
    setState(() => _selectedAssortmentFilter = value);
    _loadProducts(search: _productSearchController.text);
  }

  Widget _filterChoice(String label, String value, String selected, ValueChanged<String> onSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected == value,
        onSelected: (_) => onSelected(value),
      ),
    );
  }

  Widget _miniProductTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }

  String _portfolioShortName(String id) => BusinessFormatters.portfolioShortName(id);

  String _portfolioDisplayName(String id) => BusinessFormatters.portfolioDisplayName(id);

  Color _portfolioColor(String id) => BusinessFormatters.portfolioColor(id);

  List<_CatalogProduct> get _seedProducts => _catalogProducts.isEmpty ? OrderSeedCatalogDataSource.seedProducts().map(_CatalogProduct.fromCatalog).toList() : _catalogProducts;

  List<_CatalogProduct> get _filteredProducts {
    final query = _productSearchController.text.trim().toLowerCase();
    return _seedProducts.where((product) {
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.id.toLowerCase().contains(query);
      final matchesPortfolio = _selectedPortfolioFilter == 'all' ||
          product.portfolioId == _selectedPortfolioFilter;
      final matchesAssortment = _selectedAssortmentFilter == 'all' ||
          product.assortment == _selectedAssortmentFilter;
      final decision = _accessDecisionFor(product);
      final matchesAccess = decision.canSell ||
          (_showRestrictedProducts && decision.isDisabled);
      return matchesQuery && matchesPortfolio && matchesAssortment && matchesAccess;
    }).toList();
  }

  int _stockForProduct(_CatalogProduct product) {
    return product.stockByWarehouse[_selectedWarehouseId] ?? product.stock;
  }

  _CatalogProduct? _findProductById(String id) {
    final matches = _seedProducts.where((product) => product.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  void _normalizeCartForSelectedWarehouse() {
    bool changed = false;
    final updated = <CreateOrderCartItem>[];

    for (final item in _cartItems) {
      final product = _findProductById(item.productId);
      if (product == null) continue;
      final stock = _stockForProduct(product);
      final decision = ProductStockResolver.resolve(
        requestedQuantity: item.quantity,
        availableQuantity: stock,
        allowPartialOrder: true,
      );
      if (!decision.canAddToCart || decision.allowedQuantity <= 0) {
        changed = true;
        continue;
      }
      if (item.quantity != decision.allowedQuantity) {
        item.quantity = decision.allowedQuantity;
        changed = true;
      }
      updated.add(item);
    }

    if (changed) {
      _orderController.replaceItems(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Savat tanlangan sklad qoldig‘iga moslashtirildi'),
          backgroundColor: Color(0xFFFF6F00),
        ),
      );
    }
  }

  ProductStockDecision _stockDecisionFor(_CatalogProduct product, int quantity) {
    return ProductStockResolver.resolve(
      requestedQuantity: quantity,
      availableQuantity: _stockForProduct(product),
      allowPartialOrder: true,
    );
  }

  List<ProductDiscount> get _pricingDiscounts {
    final now = DateTime.now();
    return [
      ProductDiscount(
        id: 'disc_qty_drinks',
        externalId1C: '1C-DISC-001',
        externalIdSAP: 'SAP-DISC-001',
        name: 'Ichimliklar 10+ chegirma',
        description: '10 dona va undan ko‘p ichimliklarda 5% chegirma',
        type: DiscountType.percent,
        percentValue: 5,
        fixedValue: 0,
        minQuantity: 10,
        productIds: const ['prod_1', 'prod_2', 'prod_3', 'prod_5'],
        currentUsageCount: 0,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 30)),
        status: PromoStatus.active,
        lastSyncedAt: now,
      ),
      ProductDiscount(
        id: 'disc_snack_fixed',
        externalId1C: '1C-DISC-002',
        externalIdSAP: 'SAP-DISC-002',
        name: 'Snack fixed chegirma',
        description: 'Snack portfel uchun 500 so‘m chegirma',
        type: DiscountType.fixedAmount,
        percentValue: 0,
        fixedValue: 500,
        minQuantity: 5,
        categoryIds: const ['cat_snacks'],
        currentUsageCount: 0,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 30)),
        status: PromoStatus.active,
        lastSyncedAt: now,
      ),
    ];
  }

  List<SpecialPrice> get _pricingSpecialPrices {
    final now = DateTime.now();
    return [
      SpecialPrice(
        id: 'sp_redbull_pg1',
        externalId1C: '1C-SP-001',
        externalIdSAP: 'SAP-SP-001',
        productId: 'prod_10',
        productCode: 'PROD_10',
        productName: 'Red Bull 250ml',
        priceGroupId: 'pg_1',
        priceGroupName: 'Asosiy',
        basePrice: 18000,
        specialPrice: 17000,
        discountPercent: 0,
        discountAmount: 1000,
        currency: 'UZS',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 20)),
        source: 'manual',
        lastSyncedAt: now,
      ),
    ];
  }

  PricingResult _pricingForProduct(_CatalogProduct product, int quantity) {
    if (_selectedCustomer == null) {
      return PricingResolver.resolve(
        context: PricingContext(
          customer: _seedCustomers.first,
          product: _orderProductFromCatalog(product),
          quantity: quantity,
          date: DateTime.now(),
        ),
        fallbackBasePrice: product.price,
      );
    }
    return PricingResolver.resolve(
      context: PricingContext(
        customer: _selectedCustomer!,
        product: _orderProductFromCatalog(product),
        quantity: quantity,
        date: DateTime.now(),
        discounts: _pricingDiscounts,
        specialPrices: _pricingSpecialPrices,
      ),
      fallbackBasePrice: product.price,
    );
  }

  OrderProduct _orderProductFromCatalog(_CatalogProduct product) {
    return OrderProduct(
      id: product.id,
      code: product.id.toUpperCase(),
      name: product.name,
      sku: product.id.toUpperCase(),
      categoryId: product.category.toLowerCase().contains('snack') ? 'cat_snacks' : product.category.toLowerCase().contains('qandolat') ? 'cat_confectionery' : 'cat_drinks',
      categoryName: product.category,
      unitOfMeasure: 'dona',
      weight: 0,
      volume: 0,
      isActive: true,
      isAvailable: true,
    );
  }

  String? _pricingNote(PricingResult pricing) {
    if (pricing.appliedRules.isEmpty && pricing.discountPercent == 0 && pricing.discountAmount == 0 && pricing.specialPrice == pricing.basePrice) {
      return null;
    }
    final rules = <String>[];
    if (pricing.specialPrice != pricing.basePrice) rules.add('maxsus narx');
    if (pricing.discountPercent > 0) rules.add('${pricing.discountPercent.toStringAsFixed(0)}% chegirma');
    if (pricing.discountAmount > 0) rules.add('${pricing.discountAmount.toStringAsFixed(0)} so‘m chegirma');
    return rules.join(' • ');
  }

  Map<String, dynamic> _pricingSnapshot(PricingResult pricing) {
    return {
      'productId': pricing.productId,
      'basePrice': pricing.basePrice,
      'specialPrice': pricing.specialPrice,
      'discountPercent': pricing.discountPercent,
      'discountAmount': pricing.discountAmount,
      'finalUnitPrice': pricing.finalUnitPrice,
      'lineSubtotal': pricing.lineSubtotal,
      'lineDiscount': pricing.lineDiscount,
      'lineTotal': pricing.lineTotal,
      'currency': pricing.currency,
      'appliedRules': pricing.appliedRules,
      'warnings': pricing.warnings,
      'calculatedAt': DateTime.now().toIso8601String(),
    };
  }


  // ==================== STEP 3: TO'LOV ====================
  Widget _buildStep3Payment() {
    return CreateOrderPaymentStep(
      paymentMethod: _paymentMethod,
      onPaymentMethodChanged: (value) => setState(() => _paymentMethod = value),
      creditLimitBanner: _buildCreditLimitBanner(),
      warehouseServiceInfo: _buildWarehouseServiceInfo(),
      warehouseSelector: _buildWarehouseSelector(),
      deliveryDate: _deliveryDate,
      onDeliveryDateChanged: (date) => setState(() => _deliveryDate = date),
      deliveryTimeSlot: _deliveryTimeSlot,
      onDeliveryTimeSlotChanged: (value) => setState(() => _deliveryTimeSlot = value),
      notesController: _notesController,
    );
  }


  Widget _buildCreditLimitBanner() {
    if (_selectedCustomer == null) return const SizedBox.shrink();
    final decision = CreditLimitPolicy.evaluate(customer: _selectedCustomer!, orderAmount: _orderController.totalAmount, paymentMethod: _paymentMethod);
    if (decision.message == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (decision.allowed ? const Color(0xFFFF6F00) : Colors.red).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (decision.allowed ? const Color(0xFFFF6F00) : Colors.red).withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(decision.allowed ? Icons.warning_amber : Icons.block, color: decision.allowed ? const Color(0xFFFF6F00) : Colors.red),
        const SizedBox(width: 10),
        Expanded(child: Text(decision.message!, style: const TextStyle(fontSize: 12))),
      ]),
    );
  }

  Future<void> _resolveWarehouseFromSystems(OrderCustomer customer) async {
    setState(() => _warehouseResolving = true);
    try {
      final resolution = await getIt<TerritoryAssignmentService>().resolveOrderWarehouse(agentCodeOrId: _currentUserId, customerCodeOrId: customer.id);
      if (!mounted) return;
      setState(() {
        _warehouseResolution = resolution;
        _allowedWarehouseIds = resolution.availableWarehouseIds;
        _selectedWarehouseId = resolution.selectedWarehouseId;
        _warehouseResolving = false;
      });
      _normalizeCartForSelectedWarehouse();
    } catch (_) {
      if (!mounted) return;
      setState(() => _warehouseResolving = false);
    }
  }

  List<String> get _availableWarehouseIdsForOrder {
    if (_warehouseResolution != null) return _warehouseResolution!.availableWarehouseIds;
    if (_selectedCustomer == null) return _allowedWarehouseIds;
    final customerWarehouses = _serviceWarehousesForCustomer(_selectedCustomer!);
    final intersection = _allowedWarehouseIds.where((warehouseId) => customerWarehouses.contains(warehouseId)).toList();
    return intersection.isNotEmpty ? intersection : _allowedWarehouseIds;
  }

  List<String> _serviceWarehousesForCustomer(OrderCustomer customer) {
    final address = customer.address.toLowerCase();
    if (address.contains('samarqand')) return const ['warehouse_3', 'warehouse_1'];
    if (address.contains('buxoro')) return const ['warehouse_1'];
    if (address.contains('toshkent')) return const ['warehouse_2', 'warehouse_1'];
    return const ['warehouse_1'];
  }

  void _normalizeWarehouseForCustomer(OrderCustomer customer) {
    final available = _availableWarehouseIdsForOrder;
    if (available.isEmpty) return;
    if (!available.contains(_selectedWarehouseId)) {
      setState(() => _selectedWarehouseId = available.first);
      _normalizeCartForSelectedWarehouse();
    }
  }

  Widget _buildWarehouseServiceInfo() {
    if (_selectedCustomer == null) return const SizedBox.shrink();
    if (_warehouseResolving) return const LinearProgressIndicator(minHeight: 2);
    final customerWarehouses = _serviceWarehousesForCustomer(_selectedCustomer!);
    final available = _availableWarehouseIdsForOrder;
    final hasDirectMatch = _warehouseResolution?.hasDirectRegionMatch ?? _allowedWarehouseIds.any(customerWarehouses.contains);
    final sourceText = _warehouseResolution == null ? 'local' : _warehouseResolution!.source.name;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasDirectMatch ? const Color(0xFF1565C0).withOpacity(0.08) : const Color(0xFFFF6F00).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(hasDirectMatch ? Icons.warehouse : Icons.warning_amber, color: hasDirectMatch ? const Color(0xFF1565C0) : const Color(0xFFFF6F00)),
        const SizedBox(width: 10),
        Expanded(child: Text(hasDirectMatch ? 'Mijoz hududiga mos skladlar: ${available.map(_warehouseName).join(', ')} • manba: $sourceText' : (_warehouseResolution?.warningMessage ?? 'Mijoz hududi uchun mos sklad agentga biriktirilmagan'), style: const TextStyle(fontSize: 12))),
      ]),
    );
  }

  Widget _buildWarehouseSelector() {
    final availableWarehouses = _availableWarehouseIdsForOrder;
    final dropdownValue = availableWarehouses.contains(_selectedWarehouseId) ? _selectedWarehouseId : availableWarehouses.first;
    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: InputDecoration(labelText: 'Buyurtma chiqadigan sklad', prefixIcon: const Icon(Icons.warehouse), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
      items: availableWarehouses.map((id) => DropdownMenuItem(value: id, child: Text(_warehouseName(id)))).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedWarehouseId = value);
        _normalizeCartForSelectedWarehouse();
      },
    );
  }

  String _warehouseName(String id) => BusinessFormatters.warehouseName(id);

  // ==================== STEP 4: TASDIQLASH ====================
  Widget _buildStep4Confirm() {
    return CreateOrderConfirmStep(
      customer: _selectedCustomer,
      items: _cartItems
          .map((item) => ConfirmCartItem(productName: item.productName, quantity: item.quantity, price: item.price))
          .toList(),
      paymentName: _getPaymentName(_paymentMethod),
      warehouseName: _warehouseName(_selectedWarehouseId),
      customerServiceWarehouseNames: _selectedCustomer == null
          ? const []
          : _serviceWarehousesForCustomer(_selectedCustomer!).map(_warehouseName).toList(),
      deliveryDate: _deliveryDate,
      deliveryTimeSlot: _deliveryTimeSlot,
      totalAmount: _orderController.totalAmount,
    );
  }


  // ==================== BOTTOM BAR ====================
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: const Text('Orqaga'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep < 3 ? _nextStep : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStep < 3 ? const Color(0xFF1565C0) : const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _currentStep < 3 ? 'Keyingisi' : 'Buyurtma berish',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    // Validatsiya
    if (_currentStep == 0 && _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mijozni tanlang'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_currentStep == 0 && _availableWarehouseIdsForOrder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu mijoz uchun sizga mos sklad biriktirilmagan'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_currentStep == 1 && _cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamida bitta mahsulot qo\'shing'), backgroundColor: Colors.red),
      );
      return;
    }
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateBeforeSubmit() {
    final items = _cartItems.map((item) {
      final product = _findProductById(item.productId);
      final availableStock = product == null ? 0 : _stockForProduct(product);
      return OrderItem(
        id: item.productId,
        productId: item.productId,
        productCode: item.productId.toUpperCase(),
        productName: item.productName,
        productSku: item.productId.toUpperCase(),
        quantity: item.quantity,
        unitOfMeasure: 'dona',
        unitPrice: item.price,
        discountPercent: 0,
        discountAmount: 0,
        totalPrice: item.price * item.quantity,
        totalWithDiscount: item.price * item.quantity,
        weight: 0,
        volume: 0,
        availableStock: availableStock.toDouble(),
        isStockSufficient: availableStock >= item.quantity,
      );
    }).toList();

    final result = OrderValidationPolicy.validateDraftOrder(
      role: _currentUserRole,
      customer: _selectedCustomer,
      items: items,
      selectedWarehouseId: _selectedWarehouseId,
      allowedWarehouseIds: _allowedWarehouseIds,
      territoryMetadata: _buildOrderTerritoryMetadata(),
    );

    final creditDecision = _selectedCustomer == null
        ? null
        : CreditLimitPolicy.evaluate(
            customer: _selectedCustomer!,
            orderAmount: _orderController.totalAmount,
            paymentMethod: _paymentMethod,
          );
    if (creditDecision != null && !creditDecision.allowed) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kredit limit tekshiruvi'),
          content: Text(creditDecision.message ?? 'To‘lov sharti mos emas'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tushunarli'))],
        ),
      );
      return false;
    }

    if (result.isValid) {
      if (result.warnings.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.warnings.join('
')), backgroundColor: const Color(0xFFFF6F00)),
        );
      }
      return true;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buyurtma tekshiruvdan o‘tmadi'),
        content: Text(result.blockingMessages.join('
')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tushunarli')),
        ],
      ),
    );
    return false;
  }

  void _submitOrder() {
    if (_selectedCustomer == null || _cartItems.isEmpty) return;
    if (!_validateBeforeSubmit()) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buyurtma berish'),
        content: Text('${AppFormatters.money(_orderController.totalAmount, suffix: '')} so\'mlik buyurtma local saqlansinmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OrderFlowBloc>().add(SaveLocalOrder(_buildOrderForSave()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _buildOrderTerritoryMetadata() {
    return {
      'territorySource': _warehouseResolution?.source.name ?? 'local',
      'hasDirectRegionMatch': _warehouseResolution?.hasDirectRegionMatch,
      'resolutionWarning': _warehouseResolution?.warningMessage,
      'resolvedAt': _warehouseResolution?.resolvedAt.toIso8601String(),
      'selectedWarehouseId': _selectedWarehouseId,
      'selectedWarehouseName': _warehouseName(_selectedWarehouseId),
      'availableWarehouseIds': _availableWarehouseIdsForOrder,
      'availableWarehouseNames': _availableWarehouseIdsForOrder.map(_warehouseName).toList(),
      'agentAllowedWarehouseIds': _allowedWarehouseIds,
      'agentAllowedWarehouseNames': _allowedWarehouseIds.map(_warehouseName).toList(),
      'customerServiceWarehouseIds': _selectedCustomer == null
          ? <String>[]
          : _serviceWarehousesForCustomer(_selectedCustomer!),
      'customerServiceWarehouseNames': _selectedCustomer == null
          ? <String>[]
          : _serviceWarehousesForCustomer(_selectedCustomer!).map(_warehouseName).toList(),
      'pricingSnapshots': _cartItems.map((item) => {
        'productId': item.productId,
        'productName': item.productName,
        ...item.pricingSnapshot,
      }).toList(),
    };
  }

  Order _buildOrderForSave() {
    final now = DateTime.now();
    final customer = _selectedCustomer!;
    final items = _cartItems.map((item) {
      final total = item.price * item.quantity;
      final product = _findProductById(item.productId);
      final availableStock = product == null ? 0 : _stockForProduct(product);
      return OrderItem(
        id: '${item.productId}_${now.microsecondsSinceEpoch}',
        productId: item.productId,
        productCode: item.productId.toUpperCase(),
        productName: item.productName,
        productSku: item.productId.toUpperCase(),
        quantity: item.quantity,
        unitOfMeasure: 'dona',
        unitPrice: item.price,
        discountPercent: 0,
        discountAmount: 0,
        totalPrice: total,
        totalWithDiscount: total,
        weight: 0,
        volume: 0,
        availableStock: availableStock.toDouble(),
        isStockSufficient: availableStock >= item.quantity,
      );
    }).toList();
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final discount = items.fold<double>(0, (sum, item) => sum + item.discountAmount);
    final total = subtotal - discount;

    return Order(
      id: 'local_${now.microsecondsSinceEpoch}_${Random().nextInt(9999)}',
      orderNumber: 'ORD-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}',
      customerId: customer.id,
      customerCode: customer.code,
      customerName: customer.name,
      customerAddress: customer.address,
      customerPhone: customer.phone,
      customerLatitude: customer.latitude,
      customerLongitude: customer.longitude,
      priceGroupId: customer.priceGroupId,
      agentId: _currentUserId,
      agentName: _currentUserRole,
      agentCode: 'AG001',
      regionId: 'region_1',
      warehouseId: _selectedWarehouseId,
      items: items,
      subtotal: subtotal,
      totalDiscount: discount,
      totalAmount: total,
      paidAmount: 0,
      remainingAmount: total,
      currency: 'UZS',
      paymentMethod: _paymentMethod,
      paymentTermDays: customer.paymentDelayDays,
      paymentDueDate: now.add(Duration(days: customer.paymentDelayDays)),
      deliveryDate: _deliveryDate,
      deliveryTimeSlot: _deliveryTimeSlot,
      deliveryAddress: customer.address,
      status: OrderStatus.draft,
      paymentStatus: PaymentStatus.unpaid,
      createdAt: now,
      metadata: _buildOrderTerritoryMetadata(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
  }



  String _getPaymentName(String code) {
    switch (code) {
      case 'cash': return 'Naqd pul';
      case 'card': return 'Plastik karta';
      case 'transfer': return 'Bank o\'tkazmasi';
      case 'credit': return 'Kredit (muddatli)';
      default: return code;
    }
  }
}

class _CatalogProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final Map<String, int> stockByWarehouse;
  final String portfolioId;
  final String assortment;
  final String source;
  final String brand;

  const _CatalogProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.stockByWarehouse = const {},
    required this.portfolioId,
    required this.assortment,
    required this.source,
    required this.brand,
  });

  factory _CatalogProduct.fromCatalog(OrderCatalogProduct product) {
    return _CatalogProduct(
      id: product.id,
      name: product.name,
      category: product.category,
      price: product.price,
      stock: product.stock,
      stockByWarehouse: product.stockByWarehouse,
      portfolioId: product.portfolioId,
      assortment: product.assortment,
      source: product.source,
      brand: product.brand,
    );
  }
}
