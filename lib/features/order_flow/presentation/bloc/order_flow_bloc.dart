import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_flow_entities.dart' as order_entities;
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/sync_order_usecase.dart';
import '../../domain/repositories/order_flow_repository.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================================
// ORDER FLOW BLOC
// Agent → Mijoz → Mahsulot → Buyurtma → 1C/SAP
// ============================================================

// ============ EVENTS ============

abstract class OrderFlowEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 1-bosqich: Mijozlar ro'yxatini yuklash
class LoadCustomers extends OrderFlowEvent {
  final String? search;
  final int page;

  LoadCustomers({this.search, this.page = 1});

  @override
  List<Object?> get props => [search, page];
}

/// 2-bosqich: Mijozni tanlash
class SelectCustomer extends OrderFlowEvent {
  final order_entities.OrderCustomer customer;

  SelectCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

/// 3-bosqich: Mahsulotlarni yuklash
class LoadProducts extends OrderFlowEvent {
  final String? categoryId;
  final String? search;
  final int page;

  LoadProducts({this.categoryId, this.search, this.page = 1});

  @override
  List<Object?> get props => [categoryId, search, page];
}

/// 4-bosqich: Kategoriyalarni yuklash
class LoadCategories extends OrderFlowEvent {}

/// 5-bosqich: Mahsulotni tanlash va narxini olish
class SelectProduct extends OrderFlowEvent {
  final order_entities.OrderProduct product;

  SelectProduct(this.product);

  @override
  List<Object?> get props => [product];
}

/// 6-bosqich: Ombor qoldig'ini tekshirish
class CheckStock extends OrderFlowEvent {
  final String productId;
  final String warehouseId;

  CheckStock({required this.productId, required this.warehouseId});
}

/// 7-bosqich: Savatga qo'shish
class AddToCart extends OrderFlowEvent {
  final order_entities.OrderProduct product;
  final order_entities.ProductPrice price;
  final order_entities.ProductStock stock;
  final int quantity;

  AddToCart({
    required this.product,
    required this.price,
    required this.stock,
    required this.quantity,
  });

  @override
  List<Object?> get props => [product, quantity];
}

/// Savatdagi mahsulotni yangilash
class UpdateCartItem extends OrderFlowEvent {
  final String itemId;
  final int quantity;

  UpdateCartItem({required this.itemId, required this.quantity});

  @override
  List<Object?> get props => [itemId, quantity];
}

/// Savatdan o'chirish
class RemoveFromCart extends OrderFlowEvent {
  final String itemId;

  RemoveFromCart(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Savatni tozalash
class ClearCart extends OrderFlowEvent {}

/// Buyurtma yaratadigan foydalanuvchi konteksti
class ConfigureOrderActor extends OrderFlowEvent {
  final String agentId;
  final String agentName;
  final String agentCode;
  final String regionId;
  final String warehouseId;

  ConfigureOrderActor({
    required this.agentId,
    required this.agentName,
    required this.agentCode,
    required this.regionId,
    required this.warehouseId,
  });

  @override
  List<Object?> get props =>
      [agentId, agentName, agentCode, regionId, warehouseId];
}

/// 8-bosqich: Buyurtmani yaratish
class CreateOrder extends OrderFlowEvent {
  final String paymentMethod;
  final DateTime? deliveryDate;
  final String? deliveryTimeSlot;
  final String? notes;

  CreateOrder({
    required this.paymentMethod,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.notes,
  });
}

/// 9-bosqich: Buyurtmani 1C/SAP ga yuborish
class SubmitOrder extends OrderFlowEvent {
  final String orderId;

  SubmitOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Buyurtma holatini tekshirish
class CheckOrderStatus extends OrderFlowEvent {
  final String orderId;

  CheckOrderStatus(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Barcha sinxronlash
class SyncAllPending extends OrderFlowEvent {}

/// Tayyor buyurtmani local saqlash (MVP/local oqimi uchun)
class SaveLocalOrder extends OrderFlowEvent {
  final order_entities.Order order;

  SaveLocalOrder(this.order);

  @override
  List<Object?> get props => [order];
}

/// Formani tozalash
class ResetOrderForm extends OrderFlowEvent {}

// ============ STATES ============

abstract class OrderFlowState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Boshlang'ich holat
class OrderFlowInitial extends OrderFlowState {}

/// Yuklanmoqda
class OrderFlowLoading extends OrderFlowState {
  final String? message;

  OrderFlowLoading({this.message});
}

/// 1-bosqich: Mijozlar ro'yxati
class CustomersLoaded extends OrderFlowState {
  final List<order_entities.OrderCustomer> customers;
  final bool hasMore;

  CustomersLoaded({required this.customers, this.hasMore = false});
}

/// 2-bosqich: Mijoz tanlandi
class CustomerSelected extends OrderFlowState {
  final order_entities.OrderCustomer customer;

  CustomerSelected(this.customer);
}

/// 3-bosqich: Mahsulotlar ro'yxati
class ProductsLoaded extends OrderFlowState {
  final order_entities.OrderCustomer customer;
  final List<order_entities.OrderProduct> products;
  final List<order_entities.ProductCategory> categories;
  final bool hasMore;

  ProductsLoaded({
    required this.customer,
    required this.products,
    required this.categories,
    this.hasMore = false,
  });
}

/// 5-bosqich: Mahsulot tanlandi, narx va ombor
class ProductSelected extends OrderFlowState {
  final order_entities.OrderCustomer customer;
  final order_entities.OrderProduct product;
  final order_entities.ProductPrice price;
  final order_entities.ProductStock? stock;

  ProductSelected({
    required this.customer,
    required this.product,
    required this.price,
    this.stock,
  });
}

/// 7-bosqich: Savat holati
class CartUpdated extends OrderFlowState {
  final order_entities.OrderCustomer customer;
  final List<order_entities.OrderItem> cartItems;
  final double subtotal;
  final double totalDiscount;
  final double totalAmount;
  final int totalItems;

  CartUpdated({
    required this.customer,
    required this.cartItems,
    required this.subtotal,
    required this.totalDiscount,
    required this.totalAmount,
    required this.totalItems,
  });
}

/// 8-bosqich: Buyurtma yaratildi
class OrderCreatedSuccess extends OrderFlowState {
  final order_entities.Order order;

  OrderCreatedSuccess(this.order);
}

/// 9-bosqich: Buyurtma yuborilmoqda
class OrderSubmitting extends OrderFlowState {
  final order_entities.Order order;

  OrderSubmitting(this.order);
}

/// Buyurtma muvaffaqiyatli yuborildi
class OrderSubmittedSuccess extends OrderFlowState {
  final order_entities.Order order;
  final bool syncedTo1C;
  final bool syncedToSAP;

  OrderSubmittedSuccess({
    required this.order,
    required this.syncedTo1C,
    required this.syncedToSAP,
  });
}

/// Sinxronlash natijasi
class SyncCompleted extends OrderFlowState {
  final order_entities.SyncResult result;

  SyncCompleted(this.result);
}

/// Xatolik
class OrderFlowError extends OrderFlowState {
  final String message;
  final String? errorCode;
  final order_entities.Order? order; // Xatolik bo'lgan buyurtma

  OrderFlowError({
    required this.message,
    this.errorCode,
    this.order,
  });
}

// ============ BLOC ============

class OrderFlowBloc extends Bloc<OrderFlowEvent, OrderFlowState> {
  final OrderFlowRepository _repository;
  final CreateOrderUseCase _createOrder;
  final SyncOrderToAllSystemsUseCase _syncOrder;
  final SyncAllPendingOrdersUseCase _syncAll;

  // Savat va foydalanuvchi konteksti
  order_entities.OrderCustomer? _selectedCustomer;
  final List<order_entities.OrderItem> _cartItems = [];
  String _agentId = 'agent_1';
  String _agentName = 'Agent';
  String _agentCode = 'AG001';
  String _regionId = 'region_1';
  String _warehouseId = '';

  OrderFlowBloc({
    required OrderFlowRepository repository,
    required CreateOrderUseCase createOrder,
    required SyncOrderToAllSystemsUseCase syncOrder,
    required SyncAllPendingOrdersUseCase syncAll,
  })  : _repository = repository,
        _createOrder = createOrder,
        _syncOrder = syncOrder,
        _syncAll = syncAll,
        super(OrderFlowInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SelectCustomer>(_onSelectCustomer);
    on<LoadProducts>(_onLoadProducts);
    on<LoadCategories>(_onLoadCategories);
    on<SelectProduct>(_onSelectProduct);
    on<CheckStock>(_onCheckStock);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<ConfigureOrderActor>(_onConfigureOrderActor);
    on<CreateOrder>(_onCreateOrder);
    on<SubmitOrder>(_onSubmitOrder);
    on<CheckOrderStatus>(_onCheckOrderStatus);
    on<SyncAllPending>(_onSyncAllPending);
    on<SaveLocalOrder>(_onSaveLocalOrder);
    on<ResetOrderForm>(_onResetForm);
  }

  // ============ HANDLERS ============

  /// Mijozlar ro'yxatini yuklash
  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<OrderFlowState> emit,
  ) async {
    emit(OrderFlowLoading(message: 'Mijozlar yuklanmoqda...'));

    final result = await _repository.getCustomers(
      search: event.search,
      page: event.page,
    );

    result.fold(
      (failure) => emit(OrderFlowError(message: failure.message)),
      (customers) => emit(CustomersLoaded(
        customers: customers,
        hasMore: customers.length >= 20,
      )),
    );
  }

  /// Mijozni tanlash
  void _onSelectCustomer(
    SelectCustomer event,
    Emitter<OrderFlowState> emit,
  ) {
    _selectedCustomer = event.customer;
    _cartItems.clear();
    emit(CustomerSelected(event.customer));
  }

  /// Mahsulotlarni yuklash
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<OrderFlowState> emit,
  ) async {
    emit(OrderFlowLoading(message: 'Mahsulotlar yuklanmoqda...'));

    final productsResult = await _repository.getProducts(
      categoryId: event.categoryId,
      search: event.search,
      page: event.page,
    );

    productsResult.fold(
      (failure) => emit(OrderFlowError(message: failure.message)),
      (products) {
        if (_selectedCustomer != null) {
          emit(ProductsLoaded(
            customer: _selectedCustomer!,
            products: products,
            categories: [], // Kategoriyalar alohida yuklanadi
            hasMore: products.length >= 50,
          ));
        }
      },
    );
  }

  /// Kategoriyalarni yuklash
  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<OrderFlowState> emit,
  ) async {
    final result = await _repository.getCategories();
    // Kategoriyalar state ga qo'shiladi
  }

  /// Mahsulotni tanlash va narxini olish
  Future<void> _onSelectProduct(
    SelectProduct event,
    Emitter<OrderFlowState> emit,
  ) async {
    if (_selectedCustomer == null) return;

    emit(OrderFlowLoading(message: 'Narx yuklanmoqda...'));

    // Narxni olish
    final priceResult = await _repository.getProductPrice(
      productId: event.product.id,
      priceGroupId: _selectedCustomer!.priceGroupId,
    );

    priceResult.fold(
      (failure) => emit(OrderFlowError(message: failure.message)),
      (price) async {
        // Ombor qoldig'ini olish
        final stockResult = await _repository.getProductStock(
          productId: event.product.id,
          warehouseId: 'main', // Default ombor
        );

        stockResult.fold(
          (_) => emit(ProductSelected(
            customer: _selectedCustomer!,
            product: event.product,
            price: price,
          )),
          (stock) => emit(ProductSelected(
            customer: _selectedCustomer!,
            product: event.product,
            price: price,
            stock: stock,
          )),
        );
      },
    );
  }

  /// Ombor qoldig'ini tekshirish
  Future<void> _onCheckStock(
    CheckStock event,
    Emitter<OrderFlowState> emit,
  ) async {
    final result = await _repository.getProductStock(
      productId: event.productId,
      warehouseId: event.warehouseId,
    );
    // Stock state ga qo'shiladi
  }

  /// Savatga qo'shish
  void _onAddToCart(
    AddToCart event,
    Emitter<OrderFlowState> emit,
  ) {
    if (_selectedCustomer == null) return;

    // Tayyor element yaratish
    final item = order_entities.OrderItem.fromProductAndPrice(
      product: event.product,
      price: event.price,
      stock: event.stock,
      quantity: event.quantity,
    );

    // Savatga qo'shish (yoki yangilash)
    final existingIndex = _cartItems.indexWhere(
      (i) => i.productId == item.productId,
    );

    if (existingIndex >= 0) {
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + event.quantity,
      );
    } else {
      _cartItems.add(item);
    }

    _emitCartState(emit);
  }

  /// Savatdagi miqdorni yangilash
  void _onUpdateCartItem(
    UpdateCartItem event,
    Emitter<OrderFlowState> emit,
  ) {
    final index = _cartItems.indexWhere((i) => i.id == event.itemId);
    if (index >= 0) {
      if (event.quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index] = _cartItems[index].copyWith(
          quantity: event.quantity,
        );
      }
      _emitCartState(emit);
    }
  }

  /// Savatdan o'chirish
  void _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<OrderFlowState> emit,
  ) {
    _cartItems.removeWhere((i) => i.id == event.itemId);
    _emitCartState(emit);
  }

  /// Savatni tozalash
  void _onClearCart(
    ClearCart event,
    Emitter<OrderFlowState> emit,
  ) {
    _cartItems.clear();
    _emitCartState(emit);
  }

  /// Buyurtmani yaratish
  void _onConfigureOrderActor(
    ConfigureOrderActor event,
    Emitter<OrderFlowState> emit,
  ) {
    _agentId = event.agentId;
    _agentName = event.agentName;
    _agentCode = event.agentCode;
    _regionId = event.regionId;
    _warehouseId = event.warehouseId;
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrderFlowState> emit,
  ) async {
    if (_selectedCustomer == null || _cartItems.isEmpty) return;

    emit(OrderFlowLoading(message: 'Buyurtma yaratilmoqda...'));

    final params = CreateOrderParams(
      agentId: _agentId,
      agentName: _agentName,
      agentCode: _agentCode,
      regionId: _regionId,
      customerId: _selectedCustomer!.id,
      warehouseId: _warehouseId,
      items: _cartItems
          .map((item) => CreateOrderItemParams(
                productId: item.productId,
                productName: item.productName,
                quantity: item.quantity,
              ))
          .toList(),
      paymentMethod: event.paymentMethod,
      deliveryDate: event.deliveryDate,
      deliveryTimeSlot: event.deliveryTimeSlot,
      notes: event.notes,
    );

    final result = await _createOrder(params);

    result.fold(
      (failure) => emit(OrderFlowError(
        message: failure.message,
        errorCode: failure.statusCode?.toString(),
      )),
      (order) {
        _cartItems.clear();
        emit(OrderCreatedSuccess(order));
      },
    );
  }

  /// Buyurtmani serverga yuborish va 1C/SAP dan QAT'IY tasdiq kutish
  Future<void> _onSubmitOrder(
    SubmitOrder event,
    Emitter<OrderFlowState> emit,
  ) async {
    emit(OrderFlowLoading(message: 'Serverdan tasdiq kutilmoqda...'));

    // 1. Avval repository orqali serverga yuboramiz
    final syncResult = await _syncOrder(SyncOrderParams(
      orderId: event.orderId,
    ));

    syncResult.fold(
      (failure) {
        // Server xato bersa yoki internet bo'lmasa - TASDIQ BERILMAYDI
        emit(OrderFlowError(
          message: 'Server tasdiqlamadi: ${failure.message}',
          order: null,
        ));
      },
      (syncedOrder) {
        // FAQAT serverdan ID kelgandagina Success emit qilinadi
        if (syncedOrder.externalId1C != null ||
            syncedOrder.externalIdSAP != null) {
          emit(OrderSubmittedSuccess(
            order: syncedOrder,
            syncedTo1C: syncedOrder.externalId1C != null,
            syncedToSAP: syncedOrder.externalIdSAP != null,
          ));
        } else {
          emit(
              OrderFlowError(message: 'Serverdan ID qaytmadi. Qayta urining.'));
        }
      },
    );
  }

  /// Buyurtma holatini tekshirish
  Future<void> _onCheckOrderStatus(
    CheckOrderStatus event,
    Emitter<OrderFlowState> emit,
  ) async {
    final result = await _repository.getOrderById(event.orderId);

    result.fold(
      (failure) => emit(OrderFlowError(message: failure.message)),
      (order) {
        if (order.status == order_entities.OrderStatus.confirmed) {
          emit(OrderSubmittedSuccess(
            order: order,
            syncedTo1C: order.isSyncedTo1C,
            syncedToSAP: order.isSyncedToSAP,
          ));
        }
      },
    );
  }

  /// Barcha sinxronlash
  Future<void> _onSyncAllPending(
    SyncAllPending event,
    Emitter<OrderFlowState> emit,
  ) async {
    emit(OrderFlowLoading(message: 'Sinxronlash...'));

    final result = await _syncAll(NoParams());

    result.fold(
      (failure) => emit(OrderFlowError(message: failure.message)),
      (syncResult) => emit(SyncCompleted(syncResult)),
    );
  }

  /// Tayyor buyurtmani local saqlash
  Future<void> _onSaveLocalOrder(
    SaveLocalOrder event,
    Emitter<OrderFlowState> emit,
  ) async {
    emit(OrderFlowLoading(message: 'Buyurtma saqlanmoqda...'));

    final result = await _repository.saveOrderLocally(event.order);
    result.fold(
      (failure) => emit(OrderFlowError(message: failure.message)),
      (order) => emit(OrderCreatedSuccess(order)),
    );
  }

  /// Formani tozalash
  void _onResetForm(
    ResetOrderForm event,
    Emitter<OrderFlowState> emit,
  ) {
    _selectedCustomer = null;
    _cartItems.clear();
    emit(OrderFlowInitial());
  }

  // ============ HELPERS ============

  /// Savat holatini emit qilish
  void _emitCartState(Emitter<OrderFlowState> emit) {
    if (_selectedCustomer == null) return;

    final subtotal = _cartItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final totalDiscount = _cartItems.fold<double>(
      0,
      (sum, item) => sum + item.discountAmount,
    );
    final totalAmount = subtotal - totalDiscount;
    final totalItems = _cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    emit(CartUpdated(
      customer: _selectedCustomer!,
      cartItems: List.from(_cartItems),
      subtotal: subtotal,
      totalDiscount: totalDiscount,
      totalAmount: totalAmount,
      totalItems: totalItems,
    ));
  }
}
