import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_entities.dart';

// ============================================================
// INVENTORY REPOSITORY
// ============================================================

abstract class InventoryRepository {
  /// Inventarizatsiyalar ro'yxati
  Future<Either<Failure, List<Inventory>>> getInventories({
    String? warehouseId,
    String? status,
    int page = 1,
  });

  /// Inventarizatsiya tafsilotlari
  Future<Either<Failure, Inventory>> getInventoryById(String id);

  /// Yangi inventarizatsiya boshlash
  Future<Either<Failure, Inventory>> startInventory({
    required String warehouseId,
    required String agentId,
  });

  /// Elementni sanash
  Future<Either<Failure, InventoryItem>> countItem({
    required String inventoryId,
    required String productId,
    required double actualQuantity,
    String? notes,
    String? photoPath,
  });

  /// Inventarizatsiyani tugatish
  Future<Either<Failure, Inventory>> completeInventory(String id);

  /// Inventarizatsiyani yuborish (1C/SAP ga)
  Future<Either<Failure, Inventory>> submitInventory(String id);

  /// Natijalarni olish
  Future<Either<Failure, InventoryResult>> getResults(String id);

  /// 1C ga yuborish
  Future<Either<Failure, bool>> syncTo1C(String id);

  /// SAP ga yuborish
  Future<Either<Failure, bool>> syncToSAP(String id);
}
