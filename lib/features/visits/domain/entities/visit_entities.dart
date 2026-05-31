import 'package:equatable/equatable.dart';

// ============================================================
// VISIT ENTITIES - Tashriflar
// ============================================================

/// Tashrif holati
enum VisitStatus {
  planned, // Rejalangan
  inProgress, // Jarayonda
  completed, // Tugallangan
  missed, // O'tkazib yuborildi
  cancelled, // Bekor qilingan
  rescheduled, // Qayta rejalangan
}

/// Tashrif turi
enum VisitType {
  sales, // Savdo tashrifi
  collection, // To'lov yig'ish
  delivery, // Yetkazib berish
  survey, // So'rovnoma
  training, // O'qitish
  maintenance, // Texnik xizmat
  other, // Boshqa
}

/// Tashrif
class Visit extends Equatable {
  factory Visit.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String agentId;
  final String agentName;
  final String customerId;
  final String customerName;
  final String customerAddress;
  final double? customerLatitude;
  final double? customerLongitude;
  final VisitType type;
  final VisitStatus status;
  final DateTime scheduledDate;
  final String scheduledTime;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final int? durationMinutes;
  final String? notes;
  final String? purpose;
  final double? orderAmount;
  final double? collectionAmount;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Visit({
    required this.id,
    required this.agentId,
    required this.agentName,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    this.customerLatitude,
    this.customerLongitude,
    required this.type,
    required this.status,
    required this.scheduledDate,
    required this.scheduledTime,
    this.checkedInAt,
    this.checkedOutAt,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.durationMinutes,
    this.notes,
    this.purpose,
    this.orderAmount,
    this.collectionAmount,
    this.photoUrls = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted => status == VisitStatus.completed;
  bool get isMissed => status == VisitStatus.missed;
  bool get isInProgress => status == VisitStatus.inProgress;

  @override
  List<Object?> get props => [id, status, scheduledDate];
}

/// Tashrif statistikasi
class VisitStatistics extends Equatable {
  factory VisitStatistics.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final int totalPlanned;
  final int totalCompleted;
  final int totalMissed;
  final int totalCancelled;
  final double completionRate;
  final double avgDuration;
  final double totalOrderAmount;
  final double totalCollectionAmount;

  const VisitStatistics({
    required this.totalPlanned,
    required this.totalCompleted,
    required this.totalMissed,
    required this.totalCancelled,
    required this.completionRate,
    required this.avgDuration,
    required this.totalOrderAmount,
    required this.totalCollectionAmount,
  });

  @override
  List<Object?> get props => [totalPlanned, totalCompleted];
}
