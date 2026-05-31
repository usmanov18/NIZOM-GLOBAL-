import '../entities/order_flow_entities.dart';

import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/errors/failures.dart';

// ============================================================
// ORDER FLOW REPOSITORY - Domain qatlamida interface
// Barcha ma'lumotlar manbalari uchun kontrakt
// ============================================================

abstract class OrderFlowRepository {
  // ============ MIJOZ OPERATSIYALARI ============

  /// Agent biriktirilgan mijozlar ro'yxati
  Future<Either<Failure, List<OrderCustomer>>> getCustomers({
    String? search,
    int page = 1,
    int limit = 20,
  });

  /// Mijoz tafsilotlari
  Future<Either<Failure, OrderCustomer>> getCustomerById(String customerId);

  /// Mijozning oxirgi buyurtmalari
  Future<Either<Failure, List<Order>>> getCustomerOrders({
    required String customerId,
    int limit = 10,
  });

  // ============ MAHSULOT OPERATSIYALARI ============

  /// Mahsulotlar katalogi (1C/SAP dan)
  Future<Either<Failure, List<OrderProduct>>> getProducts({
    String? categoryId,
    String? search,
    int page = 1,
    int limit = 50,
  });

  /// Mahsulot kategoriyalari
  Future<Either<Failure, List<ProductCategory>>> getCategories();

  /// Mahsulot narxi (mijoz narx guruhi bo'yicha)
  Future<Either<Failure, ProductPrice>> getProductPrice({
    required String productId,
    required String priceGroupId,
  });

  /// Bir nechta mahsulot narxlari
  Future<Either<Failure, List<ProductPrice>>> getProductsPrices({
    required List<String> productIds,
    required String priceGroupId,
  });

  // ============ OMBOR OPERATSIYALARI ============

  /// Ombordagi qoldiq
  Future<Either<Failure, ProductStock>> getProductStock({
    required String productId,
    required String warehouseId,
  });

  /// Bir nechta mahsulot qoldiqlari
  Future<Either<Failure, List<ProductStock>>> getProductsStock({
    required List<String> productIds,
    required String warehouseId,
  });

  // ============ BUYURTMA OPERATSIYALARI ============

  /// Buyurtma yaratish (local ga saqlash)
  Future<Either<Failure, Order>> createOrder(Order order);

  /// Buyurtmani yangilash
  Future<Either<Failure, Order>> updateOrder(Order order);

  /// Buyurtmani serverga yuborish
  Future<Either<Failure, Order>> submitOrder(String orderId);

  /// Buyurtmani 1C ga yuborish
  Future<Either<Failure, Order>> syncOrderTo1C(String orderId);

  /// Buyurtmani SAP ga yuborish
  Future<Either<Failure, Order>> syncOrderToSAP(String orderId);

  /// Buyurtmani 1C va SAP ga parallel yuborish
  Future<Either<Failure, Order>> syncOrderToAll(String orderId);

  /// Buyurtma holatini yangilash
  Future<Either<Failure, Order>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? comment,
  });

  /// Buyurtmani bekor qilish
  Future<Either<Failure, Order>> cancelOrder({
    required String orderId,
    required String reason,
  });

  /// Agent buyurtmalari
  Future<Either<Failure, List<Order>>> getOrders({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  });

  /// Buyurtma tafsilotlari
  Future<Either<Failure, Order>> getOrderById(String orderId);

  // ============ OFFLINE OPERATSIYALARI ============

  /// Sinxronlanmagan buyurtmalar
  Future<Either<Failure, List<Order>>> getPendingSyncOrders();

  /// Barcha sinxronlanmagan buyurtmalarni sinxronlash
  Future<Either<Failure, SyncResult>> syncAllPendingOrders();

  /// Offline buyurtmalarni saqlash
  Future<Either<Failure, Order>> saveOrderLocally(Order order);

  /// Local buyurtmani o'chirish
  Future<Either<Failure, bool>> deleteLocalOrder(String orderId);

  // ============ GENERATSIYA ============

  /// Buyurtma raqamini generatsiya qilish
  Future<Either<Failure, String>> generateOrderNumber();
}
