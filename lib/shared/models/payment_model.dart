import 'package:equatable/equatable.dart';

/// To'lov model
class PaymentModel extends Equatable {
  final String id;
  final String? orderId;
  final String? orderNumber;
  final String customerId;
  final String customerName;
  final double amount;
  final String currency;
  final String method; // cash, card, transfer, online
  final String status; // pending, completed, failed, refunded
  final String? reference;
  final String? receiptUrl;
  final String agentId;
  final String agentName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  const PaymentModel({
    required this.id,
    this.orderId,
    this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.reference,
    this.receiptUrl,
    required this.agentId,
    required this.agentName,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      orderId: json['order_id'],
      orderNumber: json['order_number'],
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UZS',
      method: json['method'] ?? 'cash',
      status: json['status'] ?? 'pending',
      reference: json['reference'],
      receiptUrl: json['receipt_url'],
      agentId: json['agent_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'order_number': orderNumber,
        'customer_id': customerId,
        'customer_name': customerName,
        'amount': amount,
        'currency': currency,
        'method': method,
        'status': status,
        'reference': reference,
        'receipt_url': receiptUrl,
        'agent_id': agentId,
        'agent_name': agentName,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, status];
}
