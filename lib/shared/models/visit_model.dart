import 'package:equatable/equatable.dart';

/// Tashrif model
class VisitModel extends Equatable {
  final String id;
  final String agentId;
  final String agentName;
  final String customerId;
  final String customerName;
  final String customerAddress;
  final double? customerLatitude;
  final double? customerLongitude;
  final String type; // sales, collection, training, other
  final String status; // planned, in_progress, completed, missed, cancelled
  final DateTime scheduledDate;
  final String scheduledTime;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final int? durationMinutes;
  final String? notes;
  final String? purpose;
  final double? orderAmount;
  final double? collectionAmount;
  final List<String> photoUrls;

  const VisitModel({
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
    this.durationMinutes,
    this.notes,
    this.purpose,
    this.orderAmount,
    this.collectionAmount,
    this.photoUrls = const [],
  });

  bool get isCompleted => status == 'completed';
  bool get isMissed => status == 'missed';
  bool get isInProgress => status == 'in_progress';

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'] ?? '',
      agentId: json['agent_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerAddress: json['customer_address'] ?? '',
      customerLatitude: json['customer_latitude']?.toDouble(),
      customerLongitude: json['customer_longitude']?.toDouble(),
      type: json['type'] ?? 'sales',
      status: json['status'] ?? 'planned',
      scheduledDate: DateTime.parse(
          json['scheduled_date'] ?? DateTime.now().toIso8601String()),
      scheduledTime: json['scheduled_time'] ?? '',
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'])
          : null,
      checkedOutAt: json['checked_out_at'] != null
          ? DateTime.parse(json['checked_out_at'])
          : null,
      checkInLatitude: json['check_in_latitude']?.toDouble(),
      checkInLongitude: json['check_in_longitude']?.toDouble(),
      durationMinutes: json['duration_minutes'],
      notes: json['notes'],
      purpose: json['purpose'],
      orderAmount: json['order_amount']?.toDouble(),
      collectionAmount: json['collection_amount']?.toDouble(),
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'agent_id': agentId,
        'agent_name': agentName,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_address': customerAddress,
        'customer_latitude': customerLatitude,
        'customer_longitude': customerLongitude,
        'type': type,
        'status': status,
        'scheduled_date': scheduledDate.toIso8601String(),
        'scheduled_time': scheduledTime,
        'checked_in_at': checkedInAt?.toIso8601String(),
        'checked_out_at': checkedOutAt?.toIso8601String(),
        'check_in_latitude': checkInLatitude,
        'check_in_longitude': checkInLongitude,
        'duration_minutes': durationMinutes,
        'notes': notes,
        'purpose': purpose,
        'order_amount': orderAmount,
        'collection_amount': collectionAmount,
        'photo_urls': photoUrls,
      };

  @override
  List<Object?> get props => [id, status];
}
