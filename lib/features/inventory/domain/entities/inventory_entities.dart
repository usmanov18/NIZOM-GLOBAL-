import 'package:equatable/equatable.dart';

// ============================================================
// INVENTORY ENTITIES - Inventarizatsiya
// ============================================================

/// Inventarizatsiya holati
enum InventoryStatus {
  draft, // Qoralama
  inProgress, // Jarayonda
  completed, // Tugallangan
  submitted, // Yuborilgan
  approved, // Tasdiqlangan
  rejected, // Rad etilgan
}

/// Inventarizatsiya
class Inventory extends Equatable {
  factory Inventory.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String number;
  final String warehouseId;
  final String warehouseName;
  final String agentId;
  final String agentName;
  final InventoryStatus status;
  final DateTime scheduledDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int totalItems;
  final int countedItems;
  final int matchedItems;
  final int surplusItems; // Ortiqcha
  final int shortageItems; // Kamchilik
  final double totalValue;
  final double differenceValue;
  final String? notes;
  final DateTime createdAt;

  const Inventory({
    required this.id,
    required this.number,
    required this.warehouseId,
    required this.warehouseName,
    required this.agentId,
    required this.agentName,
    required this.status,
    required this.scheduledDate,
    this.startedAt,
    this.completedAt,
    required this.totalItems,
    required this.countedItems,
    required this.matchedItems,
    required this.surplusItems,
    required this.shortageItems,
    required this.totalValue,
    required this.differenceValue,
    this.notes,
    required this.createdAt,
  });

  double get progress => totalItems > 0 ? countedItems / totalItems : 0;
  bool get isCompleted => status == InventoryStatus.completed;

  @override
  List<Object?> get props => [id, status];
}

/// Inventarizatsiya elementi
class InventoryItem extends Equatable {
  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String inventoryId;
  final String productId;
  final String productCode;
  final String productName;
  final String unitOfMeasure;
  final double systemQuantity; // Tizimdagi miqdor
  final double? actualQuantity; // Haqiqiy miqdor
  final double difference; // Farq
  final double unitPrice;
  final double differenceValue; // Farq qiymati
  final String status; // matched, surplus, shortage, pending
  final String? notes;
  final String? photoUrl;
  final DateTime? countedAt;
  final String? countedBy;

  const InventoryItem({
    required this.id,
    required this.inventoryId,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.unitOfMeasure,
    required this.systemQuantity,
    this.actualQuantity,
    required this.difference,
    required this.unitPrice,
    required this.differenceValue,
    required this.status,
    this.notes,
    this.photoUrl,
    this.countedAt,
    this.countedBy,
  });

  bool get isCounted => actualQuantity != null;
  bool get isMatched => difference == 0;
  bool get isSurplus => difference > 0;
  bool get isShortage => difference < 0;

  @override
  List<Object?> get props => [id, productId, actualQuantity];
}

/// Inventarizatsiya natijasi
class InventoryResult extends Equatable {
  factory InventoryResult.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String inventoryId;
  final int totalItems;
  final int matchedItems;
  final int surplusItems;
  final int shortageItems;
  final double totalSystemValue;
  final double totalActualValue;
  final double differenceValue;
  final double accuracy; // Aniqlik foizi
  final List<InventoryDiscrepancy> discrepancies;

  const InventoryResult({
    required this.inventoryId,
    required this.totalItems,
    required this.matchedItems,
    required this.surplusItems,
    required this.shortageItems,
    required this.totalSystemValue,
    required this.totalActualValue,
    required this.differenceValue,
    required this.accuracy,
    required this.discrepancies,
  });

  @override
  List<Object?> get props => [inventoryId, totalItems];
}

/// Farq (nosozlik)
class InventoryDiscrepancy extends Equatable {
  factory InventoryDiscrepancy.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String productId;
  final String productName;
  final double systemQty;
  final double actualQty;
  final double difference;
  final double value;
  final String reason; // damage, theft, expired, counting_error
  final String? notes;

  const InventoryDiscrepancy({
    required this.productId,
    required this.productName,
    required this.systemQty,
    required this.actualQty,
    required this.difference,
    required this.value,
    required this.reason,
    this.notes,
  });

  @override
  List<Object?> get props => [productId, difference];
}
