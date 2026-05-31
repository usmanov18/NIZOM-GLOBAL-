import 'package:equatable/equatable.dart';

// ============================================================
// PAYMENT MODELS - To'lov modellari
// ============================================================

/// To'lov usuli
enum PaymentMethod {
  cash, // Naqd pul
  card, // Plastik karta
  transfer, // Bank o'tkazmasi
  payme, // Payme
  click, // Click
  uzcard, // UzCard
  humo, // Humo
  visa, // Visa
  mastercard, // MasterCard
  qr, // QR to'lov
  credit, // Kredit (muddatli)
}

/// To'lov holati
enum PaymentStatus {
  pending, // Kutilmoqda
  processing, // Jarayonda
  completed, // Tugallangan
  failed, // Muvaffaqiyatsiz
  cancelled, // Bekor qilingan
  refunded, // Qaytarilgan
  partial, // Qisman to'langan
}

/// To'lov
class Payment extends Equatable {
  final String id;
  final String orderId;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? reference;
  final String? transactionId;
  final String? receiptUrl;
  final String? notes;
  final String agentId;
  final String agentName;

  const Payment({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.reference,
    this.transactionId,
    this.receiptUrl,
    this.notes,
    required this.agentId,
    required this.agentName,
  });

  bool get isCompleted => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isPending => status == PaymentStatus.pending;

  @override
  List<Object?> get props => [id, orderId, status];
}

/// QR to'lov
class QRPayment extends Equatable {
  final String qrCode;
  final double amount;
  final String orderId;
  final String description;
  final DateTime expiresAt;
  final String? deepLink;

  const QRPayment({
    required this.qrCode,
    required this.amount,
    required this.orderId,
    required this.description,
    required this.expiresAt,
    this.deepLink,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [qrCode, orderId];
}

/// To'lov javobi
class PaymentResponse extends Equatable {
  final bool success;
  final String? transactionId;
  final String? reference;
  final String? errorMessage;
  final int? errorCode;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const PaymentResponse({
    required this.success,
    this.transactionId,
    this.reference,
    this.errorMessage,
    this.errorCode,
    required this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [success, transactionId];
}
