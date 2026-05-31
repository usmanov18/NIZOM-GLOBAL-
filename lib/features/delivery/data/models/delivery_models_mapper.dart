import '../../domain/entities/delivery_entities.dart';

class DeliveryOrderMapper {
  static DeliveryOrder fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] ?? '',
      deliveryNumber: json['deliveryNumber'] ?? '',
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customerId: json['customerId'] ?? '',
      customerCode: json['customerCode'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      deliveryLatitude: json['deliveryLatitude']?.toDouble(),
      deliveryLongitude: json['deliveryLongitude']?.toDouble(),
      deliveryNotes: json['deliveryNotes'],
      status: DeliveryStatus.values.firstWhere(
        (e) => e.toString() == 'DeliveryStatus.${json['status']}',
        orElse: () => DeliveryStatus.pending,
      ),
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      vehicleNumber: json['vehicleNumber'],
      vehicleType: json['vehicleType'],
      agentId: json['agentId'] ?? '',
      agentCode: json['agentCode'] ?? '',
      agentName: json['agentName'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'])
          : null,
      pickedAt:
          json['pickedAt'] != null ? DateTime.parse(json['pickedAt']) : null,
      departedAt: json['departedAt'] != null
          ? DateTime.parse(json['departedAt'])
          : null,
      arrivedAt:
          json['arrivedAt'] != null ? DateTime.parse(json['arrivedAt']) : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      failedAt:
          json['failedAt'] != null ? DateTime.parse(json['failedAt']) : null,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : DateTime.now(),
      scheduledTimeSlot: json['scheduledTimeSlot'] ?? '09:00-18:00',
      estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 0,
      estimatedDistanceKm: json['estimatedDistanceKm']?.toDouble() ?? 0.0,
      failureReason: json['failureReason'],
      failureNotes: json['failureNotes'],
      items: (json['items'] as List?)
              ?.map((e) => DeliveryItemMapper.fromJson(e))
              .toList() ??
          [],
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      collectedAmount: json['collectedAmount']?.toDouble() ?? 0.0,
      remainingAmount: json['remainingAmount']?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'cash',
      photoUrls:
          (json['photoUrls'] as List?)?.map((e) => e as String).toList() ?? [],
      signatureUrl: json['signatureUrl'],
      recipientName: json['recipientName'],
      recipientPhone: json['recipientPhone'],
      deliveredLatitude: json['deliveredLatitude']?.toDouble(),
      deliveredLongitude: json['deliveredLongitude']?.toDouble(),
      deliveredTimestamp: json['deliveredTimestamp'] != null
          ? DateTime.parse(json['deliveredTimestamp'])
          : null,
      routeSequence: json['routeSequence'] ?? 0,
      distanceFromPrevious: json['distanceFromPrevious']?.toDouble(),
      estimatedTimeFromPrevious: json['estimatedTimeFromPrevious'],
      externalId1C: json['externalId1C'],
      externalIdSAP: json['externalIdSAP'],
      documentNumber1C: json['documentNumber1C'],
      documentNumberSAP: json['documentNumberSAP'],
      isSyncedTo1C: json['isSyncedTo1C'] ?? false,
      isSyncedToSAP: json['isSyncedToSAP'] ?? false,
      syncedTo1CAt: json['syncedTo1CAt'] != null
          ? DateTime.parse(json['syncedTo1CAt'])
          : null,
      syncedToSAPAt: json['syncedToSAPAt'] != null
          ? DateTime.parse(json['syncedToSAPAt'])
          : null,
    );
  }
}

class DeliveryItemMapper {
  static DeliveryItem fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productCode: json['productCode'] ?? '',
      productName: json['productName'] ?? '',
      orderedQuantity: (json['orderedQuantity'] ?? 0).toInt(),
      deliveredQuantity: (json['deliveredQuantity'] ?? 0).toInt(),
      returnedQuantity: (json['returnedQuantity'] ?? 0).toInt(),
      unitPrice: json['unitPrice']?.toDouble() ?? 0.0,
      totalPrice: json['totalPrice']?.toDouble() ?? 0.0,
      unitOfMeasure: json['unitOfMeasure'] ?? 'dona',
      weight: json['weight']?.toDouble() ?? 0.0,
      isDelivered: json['isDelivered'] ?? false,
      isReturned: json['isReturned'] ?? false,
      returnReason: json['returnReason'],
      condition: json['condition'],
    );
  }

  static Map<String, dynamic> toJson(DeliveryItem item) {
    return {
      'id': item.id,
      'productId': item.productId,
      'productCode': item.productCode,
      'productName': item.productName,
      'orderedQuantity': item.orderedQuantity,
      'deliveredQuantity': item.deliveredQuantity,
      'returnedQuantity': item.returnedQuantity,
      'unitPrice': item.unitPrice,
      'totalPrice': item.totalPrice,
      'unitOfMeasure': item.unitOfMeasure,
      'weight': item.weight,
      'isDelivered': item.isDelivered,
      'isReturned': item.isReturned,
      'returnReason': item.returnReason,
      'condition': item.condition,
    };
  }
}

class DeliveryReturnItemMapper {
  static DeliveryReturnItem fromJson(Map<String, dynamic> json) {
    return DeliveryReturnItem(
      productId: json['productId'] ?? '',
      productCode: json['productCode'] ?? '',
      productName: json['productName'] ?? '',
      quantity: (json['quantity'] ?? 0).toInt(),
      reason: json['reason'] ?? '',
      condition: json['condition'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      photoUrl: json['photoUrl'],
      notes: json['notes'],
    );
  }

  static Map<String, dynamic> toJson(DeliveryReturnItem item) {
    return {
      'productId': item.productId,
      'productCode': item.productCode,
      'productName': item.productName,
      'quantity': item.quantity,
      'reason': item.reason,
      'condition': item.condition,
      'amount': item.amount,
      'photoUrl': item.photoUrl,
      'notes': item.notes,
    };
  }
}

class DeliveryConfirmationMapper {
  static Map<String, dynamic> toJson(DeliveryConfirmation conf) {
    return {
      'deliveryId': conf.deliveryId,
      'orderId': conf.orderId,
      'confirmedAt': conf.confirmedAt.toIso8601String(),
      'latitude': conf.latitude,
      'longitude': conf.longitude,
      'accuracy': conf.accuracy,
      'photoPaths': conf.photoPaths,
      'signaturePath': conf.signaturePath,
      'recipientName': conf.recipientName,
      'recipientPhone': conf.recipientPhone,
      'recipientPosition': conf.recipientPosition,
      'collectedAmount': conf.collectedAmount,
      'paymentMethod': conf.paymentMethod,
      'paymentReference': conf.paymentReference,
      'notes': conf.notes,
      'returnItems': conf.returnedItems
          .map((e) => DeliveryReturnItemMapper.toJson(e))
          .toList(),
      'returnAmount': conf.returnAmount,
      'returnReason': conf.returnReason,
      'driverNotes': conf.driverNotes,
    };
  }
}

class DeliveryRouteMapper {
  static DeliveryRoute fromJson(Map<String, dynamic> json) {
    return DeliveryRoute(
      id: json['id'] ?? '',
      routeDate: json['routeDate'] ?? '',
      driverId: json['driverId'] ?? '',
      driverName: json['driverName'] ?? '',
      stops: (json['stops'] as List?)
              ?.map((e) => DeliveryRouteStopMapper.fromJson(e))
              .toList() ??
          [],
      totalDistanceKm: json['totalDistanceKm']?.toDouble() ?? 0.0,
      totalTimeMinutes: json['totalTimeMinutes'] ?? 0,
      totalStops: json['totalStops'] ?? 0,
      completedStops: json['completedStops'] ?? 0,
      status: json['status'] ?? 'planned',
    );
  }
}

class DeliveryRouteStopMapper {
  static DeliveryRouteStop fromJson(Map<String, dynamic> json) {
    return DeliveryRouteStop(
      deliveryId: json['deliveryId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      sequence: json['sequence'] ?? 0,
      timeSlot: json['timeSlot'] ?? '',
      status: json['status'] ?? 'pending',
      distanceFromPrevious: json['distanceFromPrevious']?.toDouble(),
      estimatedMinutes: json['estimatedMinutes'] ?? 0,
      arrivedAt:
          json['arrivedAt'] != null ? DateTime.parse(json['arrivedAt']) : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
    );
  }
}

class DriverDailyTrackMapper {
  static DriverDailyTrack fromJson(Map<String, dynamic> json) {
    return DriverDailyTrack(
      driverId: json['driverId'] ?? '',
      date: json['date'] ?? '',
      points: (json['points'] as List?)
              ?.map((e) => LocationPointMapper.fromJson(e))
              .toList() ??
          [],
      totalDistanceKm: json['totalDistanceKm']?.toDouble() ?? 0.0,
      totalTime: Duration(minutes: json['totalTimeMinutes'] ?? 0),
      drivingTime: Duration(minutes: json['drivingTimeMinutes'] ?? 0),
      idleTime: Duration(minutes: json['idleTimeMinutes'] ?? 0),
      stopsCount: json['stopsCount'] ?? 0,
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}

class LocationPointMapper {
  static LocationPoint fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      speed: json['speed']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      heading: json['heading']?.toDouble(),
    );
  }
}

class DriverStatusMapper {
  static DriverStatus fromJson(Map<String, dynamic> json) {
    return DriverStatus(
      driverId: json['driverId'] ?? '',
      driverName: json['driverName'] ?? '',
      status: json['status'] ?? 'offline',
      currentLatitude: json['currentLatitude']?.toDouble(),
      currentLongitude: json['currentLongitude']?.toDouble(),
      currentAddress: json['currentAddress'],
      lastLocationUpdate: json['lastLocationUpdate'] != null
          ? DateTime.parse(json['lastLocationUpdate'])
          : null,
      todayDeliveries: json['todayDeliveries'] ?? 0,
      todayCompleted: json['todayCompleted'] ?? 0,
      todayPending: json['todayPending'] ?? 0,
      todayDistance: json['todayDistance']?.toDouble() ?? 0.0,
      todayWorkTime: Duration(minutes: json['todayWorkTimeMinutes'] ?? 0),
      currentDeliveryId: json['currentDeliveryId'],
      currentCustomerName: json['currentCustomerName'],
      distanceToNextStop: json['distanceToNextStop']?.toDouble(),
      etaMinutes: json['etaMinutes'],
    );
  }
}

class DeliveryStatisticsMapper {
  static DeliveryStatistics fromJson(Map<String, dynamic> json) {
    return DeliveryStatistics(
      period: json['period'] ?? 'daily',
      totalDeliveries: json['totalDeliveries'] ?? 0,
      completedDeliveries: json['completedDeliveries'] ?? 0,
      failedDeliveries: json['failedDeliveries'] ?? 0,
      returnedDeliveries: json['returnedDeliveries'] ?? 0,
      completionRate: json['completionRate']?.toDouble() ?? 0.0,
      totalDistance: json['totalDistance']?.toDouble() ?? 0.0,
      totalCollected: json['totalCollected']?.toDouble() ?? 0.0,
      avgDeliveryTime: json['avgDeliveryTime']?.toDouble() ?? 0.0,
      avgDistancePerDelivery: json['avgDistancePerDelivery']?.toDouble() ?? 0.0,
      customerSatisfaction: json['customerSatisfaction']?.toDouble() ?? 0.0,
      dailyStats: (json['dailyStats'] as List?)
              ?.map((e) => DailyDeliveryStatsMapper.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DailyDeliveryStatsMapper {
  static DailyDeliveryStats fromJson(Map<String, dynamic> json) {
    return DailyDeliveryStats(
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      failed: json['failed'] ?? 0,
      distance: json['distance']?.toDouble() ?? 0.0,
      collected: json['collected']?.toDouble() ?? 0.0,
    );
  }
}
