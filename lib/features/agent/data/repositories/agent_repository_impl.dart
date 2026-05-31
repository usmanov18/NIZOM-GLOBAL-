import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/config/env_config.dart';
import '../../domain/entities/agent_dashboard.dart';
import '../../domain/repositories/agent_repository.dart';
import '../datasources/agent_remote_datasource.dart';
import '../datasources/agent_local_datasource.dart';

// ============================================================
// AGENT REPOSITORY IMPLEMENTATION
// ============================================================

class AgentRepositoryImpl implements AgentRepository {
  final AgentRemoteDataSource remoteDataSource;
  final AgentLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AgentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // ============ DASHBOARD ============

  @override
  Future<Either<Failure, AgentDashboard>> getDashboard() async {
    try {
      if (await networkInfo.isConnected) {
        // Online - serverdan olish
        final data = await remoteDataSource.getDashboard('current');

        // Cache ga saqlash
        await localDataSource.cacheDashboard(data);

        return Right(AgentDashboard.fromJson(data));
      } else {
        // Offline - cache dan olish
        final cached = await localDataSource.getCachedDashboard();
        if (cached != null) {
          return Right(AgentDashboard.fromJson(cached));
        }
        if (EnvConfig.isDemoMode) return Right(_demoDashboard());
        return const Left(
            CacheFailure(message: 'Agent dashboard cache topilmadi'));
      }
    } catch (e) {
      // Xatolik bo'lsa, cache dan olishga harakat
      try {
        final cached = await localDataSource.getCachedDashboard();
        if (cached != null) {
          return Right(AgentDashboard.fromJson(cached));
        }
      } catch (_) {}

      if (EnvConfig.isDemoMode) return Right(_demoDashboard());
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ ORDERS ============

  @override
  Future<Either<Failure, List<AgentOrder>>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getOrders(
          agentId: 'current',
          status: status,
          page: page,
          limit: limit,
        );

        final orders = data.map((json) => AgentOrder.fromJson(json)).toList();

        // Cache ga saqlash
        await localDataSource.cacheOrders(data);

        return Right(orders);
      } else {
        // Offline - cache dan olish
        final cached = await localDataSource.getCachedOrders(status: status);
        final orders = cached.map((json) => AgentOrder.fromJson(json)).toList();
        return Right(orders);
      }
    } catch (e) {
      try {
        final cached = await localDataSource.getCachedOrders(status: status);
        final orders = cached.map((json) => AgentOrder.fromJson(json)).toList();
        return Right(orders);
      } catch (_) {
        return Left(ErrorHandler.handleException(
            e is Exception ? e : Exception(e.toString())));
      }
    }
  }

  @override
  Future<Either<Failure, AgentOrder>> getOrderDetails(String orderId) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getOrderDetails(orderId);
        return Right(AgentOrder.fromJson(data));
      } else {
        final cached = await localDataSource.getOrder(orderId);
        if (cached != null) {
          return Right(AgentOrder.fromJson(cached));
        }
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AgentOrder>> createOrder({
    required String customerId,
    required List<OrderItem> items,
    String? notes,
    DateTime? deliveryDate,
  }) async {
    try {
      // Buyurtma ma'lumotlarini tayyorlash
      final orderData = {
        'customer_id': customerId,
        'items': items
            .map((item) => {
                  'product_id': item.productId,
                  'product_name': item.productName,
                  'quantity': item.quantity,
                  'unit_price': item.unitPrice,
                  'total_price': item.totalPrice,
                })
            .toList(),
        'notes': notes,
        'delivery_date': deliveryDate?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      if (await networkInfo.isConnected) {
        // Online - serverga yuborish
        final data = await remoteDataSource.createOrder(orderData);
        return Right(AgentOrder.fromJson(data));
      } else {
        // Offline - local ga saqlash
        orderData['id'] = 'local_${DateTime.now().millisecondsSinceEpoch}';
        orderData['status'] = 'pending';
        await localDataSource.saveOrder(orderData);
        return Right(AgentOrder.fromJson(orderData));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> updateOrderStatus({
    required String orderId,
    required String status,
    String? comment,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateOrderStatus(
          orderId: orderId,
          status: status,
          comment: comment,
        );
        return const Right(true);
      } else {
        // Offline - local da yangilash
        final order = await localDataSource.getOrder(orderId);
        if (order != null) {
          order['status'] = status;
          await localDataSource.saveOrder(order);
          return const Right(true);
        }
        return const Left(OrderNotFoundFailure());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ CUSTOMERS ============

  @override
  Future<Either<Failure, List<AgentCustomer>>> getCustomers({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getCustomers(
          agentId: 'current',
          search: search,
          page: page,
          limit: limit,
        );

        final customers =
            data.map((json) => AgentCustomer.fromJson(json)).toList();

        // Cache ga saqlash
        await localDataSource.cacheCustomers(data);

        return Right(customers);
      } else {
        final cached = await localDataSource.getCachedCustomers(search: search);
        final customers =
            cached.map((json) => AgentCustomer.fromJson(json)).toList();
        return Right(customers);
      }
    } catch (e) {
      try {
        final cached = await localDataSource.getCachedCustomers(search: search);
        final customers =
            cached.map((json) => AgentCustomer.fromJson(json)).toList();
        return Right(customers);
      } catch (_) {
        return Left(ErrorHandler.handleException(
            e is Exception ? e : Exception(e.toString())));
      }
    }
  }

  // ============ VISITS ============

  @override
  Future<Either<Failure, List<AgentVisit>>> getVisits({
    DateTime? date,
    String? status,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getVisits(
          agentId: 'current',
          date: date,
          status: status,
        );

        final visits = data.map((json) => AgentVisit.fromJson(json)).toList();

        await localDataSource.cacheVisits(data);

        return Right(visits);
      } else {
        final cached = await localDataSource.getCachedVisits(date: date);
        final visits = cached.map((json) => AgentVisit.fromJson(json)).toList();
        return Right(visits);
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AgentVisit>> checkInVisit({
    required String visitId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = await remoteDataSource.checkInVisit(
        visitId: visitId,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(AgentVisit.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AgentVisit>> checkOutVisit({
    required String visitId,
    String? notes,
    double? orderAmount,
  }) async {
    try {
      final data = await remoteDataSource.checkOutVisit(
        visitId: visitId,
        notes: notes,
        orderAmount: orderAmount,
      );
      return Right(AgentVisit.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ KPI ============

  @override
  Future<Either<Failure, AgentKPI>> getKPI({
    required String period,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getKPI(
          agentId: 'current',
          period: period,
        );

        await localDataSource.cacheKPI(data, period);

        return Right(AgentKPI.fromJson(data));
      } else {
        final cached = await localDataSource.getCachedKPI(period);
        if (cached != null) {
          return Right(AgentKPI.fromJson(cached));
        }
        return const Left(CacheFailure(message: 'KPI ma\'lumotlari topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ DAILY REPORT ============

  @override
  Future<Either<Failure, AgentDailyReport>> getDailyReport({
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().substring(0, 10);

      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getDailyReport(
          agentId: 'current',
          date: date,
        );

        await localDataSource.cacheDailyReport(data, dateStr);

        return Right(AgentDailyReport.fromJson(data));
      } else {
        final cached = await localDataSource.getCachedDailyReport(dateStr);
        if (cached != null) {
          return Right(AgentDailyReport.fromJson(cached));
        }
        return const Left(CacheFailure(message: 'Hisobot topilmadi'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  // ============ SYNC ============

  @override
  Future<Either<Failure, int>> syncPendingOrders() async {
    try {
      final pendingOrders = await localDataSource.getPendingOrders();
      int syncedCount = 0;

      for (final order in pendingOrders) {
        try {
          await remoteDataSource.createOrder(order);
          await localDataSource.deleteOrder(order['id']);
          syncedCount++;
        } catch (e) {
          // Xatolik bo'lsa keyinroq urinish
        }
      }

      return Right(syncedCount);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  AgentDashboard _demoDashboard() {
    final now = DateTime.now();
    return AgentDashboard(
      stats: const AgentStats(
        todayOrders: 8,
        todaySales: 12500000,
        todayVisits: 12,
        pendingOrders: 3,
        totalDebt: 18500000,
        newClients: 2,
        avgOrderAmount: 1560000,
      ),
      kpi: const AgentKPI(
        monthlyPlan: 200000000,
        monthlyFact: 146000000,
        planPercentage: 0.73,
        visitPlan: 220,
        visitFact: 164,
        collectionPlan: 150000000,
        collectionFact: 91000000,
      ),
      todayVisits: List.generate(
          4,
          (i) => AgentVisit(
                id: 'visit_$i',
                customerName: 'Super Market ${i + 1}',
                address: 'Toshkent, Chilonzor ${i + 1}',
                scheduledTime: now.add(Duration(hours: i + 1)),
                status: i == 0
                    ? 'completed'
                    : i == 1
                        ? 'in_progress'
                        : 'planned',
              )),
      recentOrders: List.generate(
          3,
          (i) => AgentOrder(
                id: 'order_$i',
                orderNumber: 'ORD-${now.year}-${100 + i}',
                customerName: 'Super Market ${i + 1}',
                amount: (i + 1) * 1500000,
                status: i == 0 ? 'confirmed' : 'pending',
                createdAt: now.subtract(Duration(hours: i + 1)),
              )),
      quickActions: const [],
    );
  }
}
