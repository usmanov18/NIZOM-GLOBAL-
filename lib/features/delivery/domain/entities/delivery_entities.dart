// ============================================================
// DELIVERY ENTITIES - Yetkazib berish to'liq tuzilmasi
// Agent buyurtmasi bilan bog'langan
// ============================================================

import 'package:equatable/equatable.dart';

// ============ YETKAZIB BERISH BUYURTMASI ============

/// Yetkazib berish holati
enum DeliveryStatus {
  pending, // Kutilmoqda
  assigned, // Haydovchiga biriktirildi
  picked, // Ombordan olindi
  inTransit, // Yo'lda
  arrived, // Manzilga yetib keldi
  delivering, // Yetkazilmoqda
  delivered, // Yetkazildi
  failed, // Muvaffaqiyatsiz
  cancelled, // Bekor qilingan
  returned, // Qaytarildi
}

/// Yetkazib berish buyurtmasi - to'liq
class DeliveryOrder extends Equatable {
  factory DeliveryOrder.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String deliveryNumber; // Yetkazish raqami
  final String orderId; // Asosiy buyurtma ID
  final String orderNumber; // Buyurtma raqami

  // Mijoz
  final String customerId;
  final String customerCode;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? deliveryNotes;

  // Haydovchi
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber; // Mashina raqami
  final String? vehicleType; // Mashina turi

  // Agent
  final String agentId;
  final String agentCode;
  final String agentName;

  // Vaqt
  final DateTime createdAt;
  final DateTime? assignedAt; // Haydovchiga berilgan vaqt
  final DateTime? pickedAt; // Ombordan olingan vaqt
  final DateTime? departedAt; // Jo'nagan vaqt
  final DateTime? arrivedAt; // Yetib kelgan vaqt
  final DateTime? deliveredAt; // Yetkazilgan vaqt
  final DateTime? failedAt; // Muvaffaqiyatsiz vaqt
  final DateTime scheduledDate; // Rejalangan sana
  final String scheduledTimeSlot; // Vaqt oralig'i (09:00-12:00)
  final int estimatedDurationMinutes; // Taxminiy vaqt (daqiqa)
  final double estimatedDistanceKm; // Taxminiy masofa (km)

  // Yetkazish ma'lumotlari
  final DeliveryStatus status;
  final String? failureReason; // Muvaffaqiyatsizlik sababi
  final String? failureNotes; // Izoh
  final List<DeliveryItem> items; // Mahsulotlar
  final double totalAmount; // Jami summa
  final double collectedAmount; // Yig'ilgan summa
  final double remainingAmount; // Qoldiq
  final String paymentMethod; // To'lov usuli

  // Tasdiqlash
  final List<String> photoUrls; // Rasm URL lari
  final String? signatureUrl; // Imzo URL
  final String? recipientName; // Qabul qiluvchi ism
  final String? recipientPhone; // Qabul qiluvchi telefon
  final double? deliveredLatitude; // Yetkazilgan joylashuv
  final double? deliveredLongitude;
  final DateTime? deliveredTimestamp; // Yetkazilgan vaqt (GPS)

  // Marshrut
  final int routeSequence; // Marshrut tartib raqami
  final double? distanceFromPrevious; // Oldingi nuqtadan masofa
  final int? estimatedTimeFromPrevious; // Oldingi nuqtadan vaqt

  // 1C/SAP
  final String? externalId1C;
  final String? externalIdSAP;
  final String? documentNumber1C;
  final String? documentNumberSAP;
  final bool isSyncedTo1C;
  final bool isSyncedToSAP;
  final DateTime? syncedTo1CAt;
  final DateTime? syncedToSAPAt;

  const DeliveryOrder({
    required this.id,
    required this.deliveryNumber,
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.deliveryNotes,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    this.vehicleType,
    required this.agentId,
    required this.agentCode,
    required this.agentName,
    required this.createdAt,
    this.assignedAt,
    this.pickedAt,
    this.departedAt,
    this.arrivedAt,
    this.deliveredAt,
    this.failedAt,
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.estimatedDurationMinutes,
    required this.estimatedDistanceKm,
    required this.status,
    this.failureReason,
    this.failureNotes,
    required this.items,
    required this.totalAmount,
    required this.collectedAmount,
    required this.remainingAmount,
    required this.paymentMethod,
    this.photoUrls = const [],
    this.signatureUrl,
    this.recipientName,
    this.recipientPhone,
    this.deliveredLatitude,
    this.deliveredLongitude,
    this.deliveredTimestamp,
    required this.routeSequence,
    this.distanceFromPrevious,
    this.estimatedTimeFromPrevious,
    this.externalId1C,
    this.externalIdSAP,
    this.documentNumber1C,
    this.documentNumberSAP,
    required this.isSyncedTo1C,
    required this.isSyncedToSAP,
    this.syncedTo1CAt,
    this.syncedToSAPAt,
  });

  bool get isPending => status == DeliveryStatus.pending;
  bool get isAssigned => status == DeliveryStatus.assigned;
  bool get isInTransit => status == DeliveryStatus.inTransit;
  bool get isDelivered => status == DeliveryStatus.delivered;
  bool get isFailed => status == DeliveryStatus.failed;
  bool get hasLocation => deliveryLatitude != null && deliveryLongitude != null;
  bool get hasPhotos => photoUrls.isNotEmpty;
  bool get hasSignature => signatureUrl != null && signatureUrl!.isNotEmpty;
  bool get isFullyPaid => remainingAmount <= 0;

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.orderedQuantity);
  double get totalWeight => items.fold(0, (sum, item) => sum + item.weight);

  @override
  List<Object?> get props => [id, deliveryNumber, status];
}

/// Yetkazish elementi
class DeliveryItem extends Equatable {
  factory DeliveryItem.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String productId;
  final String productCode;
  final String productName;
  final int orderedQuantity; // Buyurtma miqdori
  final int deliveredQuantity; // Yetkazilgan miqdori
  final int returnedQuantity; // Qaytarilgan miqdori
  final String unitOfMeasure;
  final double unitPrice;
  final double totalPrice;
  final double weight;
  final bool isDelivered;
  final bool isReturned;
  final String? returnReason;
  final String? condition; // good, damaged, expired
  final String? photoUrl;

  const DeliveryItem({
    required this.id,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.orderedQuantity,
    required this.deliveredQuantity,
    required this.returnedQuantity,
    required this.unitOfMeasure,
    required this.unitPrice,
    required this.totalPrice,
    required this.weight,
    required this.isDelivered,
    required this.isReturned,
    this.returnReason,
    this.condition,
    this.photoUrl,
  });

  bool get isFullyDelivered => deliveredQuantity >= orderedQuantity;
  bool get isPartiallyDelivered =>
      deliveredQuantity > 0 && deliveredQuantity < orderedQuantity;

  @override
  List<Object?> get props => [id, productId, deliveredQuantity];
}

// ============ MARSHRUT ============

/// Marshrut
class DeliveryRoute extends Equatable {
  factory DeliveryRoute.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String routeDate;
  final String driverId;
  final String driverName;
  final List<DeliveryRouteStop> stops;
  final double totalDistanceKm;
  final int totalTimeMinutes;
  final int totalStops;
  final int completedStops;
  final String status; // planned, in_progress, completed
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<LatLng> polyline; // Xarita uchun

  const DeliveryRoute({
    required this.id,
    required this.routeDate,
    required this.driverId,
    required this.driverName,
    required this.stops,
    required this.totalDistanceKm,
    required this.totalTimeMinutes,
    required this.totalStops,
    required this.completedStops,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.polyline = const [],
  });

  double get completionRate => totalStops > 0 ? completedStops / totalStops : 0;
  bool get isCompleted => completedStops >= totalStops;

  @override
  List<Object?> get props => [id, routeDate, status];
}

/// Marshrut nuqtasi
class DeliveryRouteStop extends Equatable {
  factory DeliveryRouteStop.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String deliveryId;
  final String orderNumber;
  final String customerName;
  final String address;
  final double? latitude;
  final double? longitude;
  final int sequence;
  final String timeSlot;
  final String status; // pending, completed, skipped
  final double? distanceFromPrevious;
  final int? estimatedMinutes;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final String? notes;

  const DeliveryRouteStop({
    required this.deliveryId,
    required this.orderNumber,
    required this.customerName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.sequence,
    required this.timeSlot,
    required this.status,
    this.distanceFromPrevious,
    this.estimatedMinutes,
    this.arrivedAt,
    this.completedAt,
    this.notes,
  });

  bool get isCompleted => status == 'completed';
  bool get isSkipped => status == 'skipped';

  @override
  List<Object?> get props => [deliveryId, sequence, status];
}

/// LatLng
class LatLng extends Equatable {
  factory LatLng.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

// ============ YETKAZIB BERISH TASDIG'I ============

/// Yetkazib berish tasdig'i
class DeliveryConfirmation extends Equatable {
  factory DeliveryConfirmation.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String deliveryId;
  final String orderId;
  final DateTime confirmedAt;
  final double latitude;
  final double longitude;
  final String? accuracy; // GPS aniqligi

  // Rasmlar
  final List<String> photoPaths; // Rasm yo'llari
  final String? signaturePath; // Imzo yo'li

  // Qabul qiluvchi
  final String? recipientName;
  final String? recipientPhone;
  final String? recipientPosition; // Lavozim

  // To'lov
  final double collectedAmount;
  final String paymentMethod;
  final String? paymentReference;

  // Qaytarish
  final List<DeliveryReturnItem> returnedItems;
  final double returnAmount;
  final String? returnReason;

  // Izohlar
  final String? notes;
  final String? driverNotes;

  const DeliveryConfirmation({
    required this.deliveryId,
    required this.orderId,
    required this.confirmedAt,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.photoPaths = const [],
    this.signaturePath,
    this.recipientName,
    this.recipientPhone,
    this.recipientPosition,
    required this.collectedAmount,
    required this.paymentMethod,
    this.paymentReference,
    this.returnedItems = const [],
    this.returnAmount = 0,
    this.returnReason,
    this.notes,
    this.driverNotes,
  });

  bool get hasPhotos => photoPaths.isNotEmpty;
  bool get hasSignature => signaturePath != null && signaturePath!.isNotEmpty;
  bool get hasReturns => returnedItems.isNotEmpty;

  @override
  List<Object?> get props => [deliveryId, confirmedAt];
}

/// Qaytarilgan mahsulot
class DeliveryReturnItem extends Equatable {
  factory DeliveryReturnItem.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String productId;
  final String productCode;
  final String productName;
  final int quantity;
  final String reason; // defective, damaged, expired, wrong_item
  final String condition; // good, damaged, expired
  final double amount;
  final String? photoUrl;
  final String? notes;

  const DeliveryReturnItem({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.reason,
    required this.condition,
    required this.amount,
    this.photoUrl,
    this.notes,
  });

  @override
  List<Object?> get props => [productId, quantity, reason];
}

// ============ GPS LOKATSIYA ============

/// GPS lokatsiya ma'lumoti
class LocationPoint extends Equatable {
  factory LocationPoint.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final String? activity; // walking, driving, stationary

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
    this.activity,
  });

  @override
  List<Object?> get props => [latitude, longitude, timestamp];
}

/// Haydovchi kunlik marshruti
class DriverDailyTrack extends Equatable {
  factory DriverDailyTrack.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String driverId;
  final String date;
  final List<LocationPoint> points;
  final double totalDistanceKm;
  final Duration totalTime;
  final Duration drivingTime;
  final Duration idleTime;
  final int stopsCount;
  final DateTime? startTime;
  final DateTime? endTime;

  const DriverDailyTrack({
    required this.driverId,
    required this.date,
    required this.points,
    required this.totalDistanceKm,
    required this.totalTime,
    required this.drivingTime,
    required this.idleTime,
    required this.stopsCount,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [driverId, date];
}

// ============ HAYDOVCHI HOLATI ============

/// Haydovchi real vaqt holati
class DriverStatus extends Equatable {
  factory DriverStatus.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String driverId;
  final String driverName;
  final String status; // offline, idle, on_route, delivering, break
  final double? currentLatitude;
  final double? currentLongitude;
  final String? currentAddress;
  final DateTime? lastLocationUpdate;
  final int todayDeliveries;
  final int todayCompleted;
  final int todayPending;
  final double todayDistance;
  final Duration todayWorkTime;
  final String? currentDeliveryId;
  final String? currentCustomerName;
  final double? distanceToNextStop;
  final int? etaMinutes;

  const DriverStatus({
    required this.driverId,
    required this.driverName,
    required this.status,
    this.currentLatitude,
    this.currentLongitude,
    this.currentAddress,
    this.lastLocationUpdate,
    required this.todayDeliveries,
    required this.todayCompleted,
    required this.todayPending,
    required this.todayDistance,
    required this.todayWorkTime,
    this.currentDeliveryId,
    this.currentCustomerName,
    this.distanceToNextStop,
    this.etaMinutes,
  });

  bool get isOnline => status != 'offline';
  bool get isOnRoute => status == 'on_route';
  bool get isDelivering => status == 'delivering';
  bool get hasLocation => currentLatitude != null && currentLongitude != null;

  @override
  List<Object?> get props => [driverId, status];
}

// ============ YETKAZISH STATISTIKASI ============

/// Yetkazish statistikasi
class DeliveryStatistics extends Equatable {
  factory DeliveryStatistics.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String period; // daily, weekly, monthly
  final int totalDeliveries;
  final int completedDeliveries;
  final int failedDeliveries;
  final int returnedDeliveries;
  final double completionRate;
  final double totalDistance;
  final double totalCollected;
  final double avgDeliveryTime;
  final double avgDistancePerDelivery;
  final double customerSatisfaction;
  final List<DailyDeliveryStats> dailyStats;

  const DeliveryStatistics({
    required this.period,
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.failedDeliveries,
    required this.returnedDeliveries,
    required this.completionRate,
    required this.totalDistance,
    required this.totalCollected,
    required this.avgDeliveryTime,
    required this.avgDistancePerDelivery,
    required this.customerSatisfaction,
    required this.dailyStats,
  });

  @override
  List<Object?> get props => [period, totalDeliveries];
}

/// Kunlik statistika
class DailyDeliveryStats extends Equatable {
  factory DailyDeliveryStats.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final DateTime date;
  final int total;
  final int completed;
  final int failed;
  final double distance;
  final double collected;

  const DailyDeliveryStats({
    required this.date,
    required this.total,
    required this.completed,
    required this.failed,
    required this.distance,
    required this.collected,
  });

  @override
  List<Object?> get props => [date];
}
