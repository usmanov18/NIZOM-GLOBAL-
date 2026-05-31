import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../domain/entities/inventory_entities.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

// ============================================================
// INVENTORY REPOSITORY IMPLEMENTATION
// ============================================================

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Inventory>>> getInventories({
    String? warehouseId,
    String? status,
    int page = 1,
  }) async {
    try {
      final data = await remoteDataSource.getInventories(
        warehouseId: warehouseId,
        status: status,
        page: page,
      );
      return Right(data.map((d) => _parseInventory(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Inventory>> getInventoryById(String id) async {
    try {
      final data = await remoteDataSource.getInventoryById(id);
      return Right(_parseInventory(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Inventory>> startInventory({
    required String warehouseId,
    required String agentId,
  }) async {
    try {
      final data = await remoteDataSource.startInventory({
        'warehouse_id': warehouseId,
        'agent_id': agentId,
      });
      return Right(_parseInventory(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, InventoryItem>> countItem({
    required String inventoryId,
    required String productId,
    required double actualQuantity,
    String? notes,
    String? photoPath,
  }) async {
    try {
      final data = await remoteDataSource.countItem(inventoryId, {
        'product_id': productId,
        'actual_quantity': actualQuantity,
        'notes': notes,
        'photo_path': photoPath,
      });
      return Right(_parseInventoryItem(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Inventory>> completeInventory(String id) async {
    try {
      final data = await remoteDataSource.completeInventory(id);
      return Right(_parseInventory(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Inventory>> submitInventory(String id) async {
    try {
      final data = await remoteDataSource.submitInventory(id);
      return Right(_parseInventory(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, InventoryResult>> getResults(String id) async {
    try {
      final data = await remoteDataSource.getResults(id);
      return Right(InventoryResult(
        inventoryId: id,
        totalItems: data['total_items'] ?? 0,
        matchedItems: data['matched_items'] ?? 0,
        surplusItems: data['surplus_items'] ?? 0,
        shortageItems: data['shortage_items'] ?? 0,
        totalSystemValue: (data['total_system_value'] ?? 0).toDouble(),
        totalActualValue: (data['total_actual_value'] ?? 0).toDouble(),
        differenceValue: (data['difference_value'] ?? 0).toDouble(),
        accuracy: (data['accuracy'] ?? 0).toDouble(),
        discrepancies: [],
      ));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> syncTo1C(String id) async {
    try {
      final result = await remoteDataSource.syncTo1C(id);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> syncToSAP(String id) async {
    try {
      final result = await remoteDataSource.syncToSAP(id);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  Inventory _parseInventory(Map<String, dynamic> d) {
    return Inventory(
      id: d['id'] ?? '',
      number: d['number'] ?? '',
      warehouseId: d['warehouse_id'] ?? '',
      warehouseName: d['warehouse_name'] ?? '',
      agentId: d['agent_id'] ?? '',
      agentName: d['agent_name'] ?? '',
      status: InventoryStatus.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => InventoryStatus.draft,
      ),
      scheduledDate: DateTime.parse(
          d['scheduled_date'] ?? DateTime.now().toIso8601String()),
      startedAt:
          d['started_at'] != null ? DateTime.parse(d['started_at']) : null,
      completedAt:
          d['completed_at'] != null ? DateTime.parse(d['completed_at']) : null,
      totalItems: d['total_items'] ?? 0,
      countedItems: d['counted_items'] ?? 0,
      matchedItems: d['matched_items'] ?? 0,
      surplusItems: d['surplus_items'] ?? 0,
      shortageItems: d['shortage_items'] ?? 0,
      totalValue: (d['total_value'] ?? 0).toDouble(),
      differenceValue: (d['difference_value'] ?? 0).toDouble(),
      notes: d['notes'],
      createdAt:
          DateTime.parse(d['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  InventoryItem _parseInventoryItem(Map<String, dynamic> d) {
    return InventoryItem(
      id: d['id'] ?? '',
      inventoryId: d['inventory_id'] ?? '',
      productId: d['product_id'] ?? '',
      productCode: d['product_code'] ?? '',
      productName: d['product_name'] ?? '',
      unitOfMeasure: d['unit_of_measure'] ?? 'dona',
      systemQuantity: (d['system_quantity'] ?? 0).toDouble(),
      actualQuantity: d['actual_quantity']?.toDouble(),
      difference: (d['difference'] ?? 0).toDouble(),
      unitPrice: (d['unit_price'] ?? 0).toDouble(),
      differenceValue: (d['difference_value'] ?? 0).toDouble(),
      status: d['status'] ?? 'pending',
      notes: d['notes'],
      photoUrl: d['photo_url'],
      countedAt:
          d['counted_at'] != null ? DateTime.parse(d['counted_at']) : null,
      countedBy: d['counted_by'],
    );
  }
}
