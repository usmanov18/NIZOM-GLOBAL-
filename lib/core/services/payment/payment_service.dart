import 'dart:async';
import 'package:dartz/dartz.dart' hide id;
import '../../errors/failures.dart';
import 'models/payment_models.dart';

// ============================================================
// PAYMENT SERVICE - Professional To'lov Tizimi
// ============================================================

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final Map<String, Payment> _payments = {};

  // ============ ASOSIY TO'LOV ============

  /// To'lov yaratish
  Future<Either<Failure, Payment>> createPayment({
    required String orderId,
    required String orderNumber,
    required String customerId,
    required String customerName,
    required double amount,
    required PaymentMethod method,
    required String agentId,
    required String agentName,
    String? notes,
  }) async {
    try {
      if (amount <= 0) {
        return const Left(PaymentFailure(
            message: 'To‘lov summasi 0 dan katta bo‘lishi kerak'));
      }
      if (orderId.trim().isEmpty ||
          customerId.trim().isEmpty ||
          agentId.trim().isEmpty) {
        return const Left(PaymentFailure(
            message: 'To‘lov uchun majburiy maydonlar to‘ldirilmagan'));
      }

      final payment = Payment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        orderNumber: orderNumber,
        customerId: customerId,
        customerName: customerName,
        amount: amount,
        currency: 'UZS',
        method: method,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        agentId: agentId,
        agentName: agentName,
        notes: notes,
      );

      // To'lov usuliga qarab yo'naltirish
      PaymentResponse response;

      switch (method) {
        case PaymentMethod.cash:
          response = await _processCashPayment(payment);
          break;
        case PaymentMethod.card:
        case PaymentMethod.visa:
        case PaymentMethod.mastercard:
          response = await _processCardPayment(payment);
          break;
        case PaymentMethod.transfer:
          response = await _processTransferPayment(payment);
          break;
        case PaymentMethod.payme:
          response = await _processPaymePayment(payment);
          break;
        case PaymentMethod.click:
          response = await _processClickPayment(payment);
          break;
        case PaymentMethod.uzcard:
        case PaymentMethod.humo:
          response = await _processUzCardPayment(payment);
          break;
        case PaymentMethod.qr:
          response = await _processQRPayment(payment);
          break;
        case PaymentMethod.credit:
          response = await _processCreditPayment(payment);
          break;
      }

      if (response.success) {
        final completed = payment.copyWith(
          status: PaymentStatus.completed,
          completedAt: DateTime.now(),
          transactionId: response.transactionId,
          reference: response.reference,
        );
        _payments[completed.id] = completed;
        return Right(completed);
      } else {
        final failed = payment.copyWith(
            status: PaymentStatus.failed, reference: response.reference);
        _payments[failed.id] = failed;
        return Left(PaymentFailure(
            message: response.errorMessage ?? 'To\'lov xatoligi'));
      }
    } catch (e) {
      return Left(PaymentFailure(message: 'To\'lov xatoligi: $e'));
    }
  }

  // ============ NAQD PUL ============

  Future<PaymentResponse> _processCashPayment(Payment payment) async {
    // Naqd pul - darhol tasdiqlanadi
    return PaymentResponse(
      success: true,
      transactionId: 'CASH_${DateTime.now().millisecondsSinceEpoch}',
      reference: 'Naqd to\'lov',
      timestamp: DateTime.now(),
    );
  }

  // ============ PLASTIK KARTA ============

  Future<PaymentResponse> _processCardPayment(Payment payment) async {
    try {
      return _simulateGatewayResponse(
        prefix: payment.method == PaymentMethod.mastercard
            ? 'MC'
            : payment.method == PaymentMethod.visa
                ? 'VISA'
                : 'CARD',
        reference: payment.method == PaymentMethod.card
            ? 'Plastik karta'
            : payment.method.name.toUpperCase(),
      );
    } catch (e) {
      return PaymentResponse(
        success: false,
        errorMessage: 'Karta to\'lovi xatoligi',
        timestamp: DateTime.now(),
      );
    }
  }

  // ============ BANK O'TKAZMASI ============

  Future<PaymentResponse> _processTransferPayment(Payment payment) async {
    try {
      return _simulateGatewayResponse(
          prefix: 'TRF', reference: 'Bank o\'tkazmasi');
    } catch (e) {
      return PaymentResponse(
        success: false,
        errorMessage: 'O\'tkazma xatoligi',
        timestamp: DateTime.now(),
      );
    }
  }

  // ============ PAYME ============

  Future<PaymentResponse> _processPaymePayment(Payment payment) async {
    try {
      // Payme API
      // POST https://checkout.paycom.uz/api
      final receiptId = 'payme_${DateTime.now().millisecondsSinceEpoch}';

      return PaymentResponse(
        success: true,
        transactionId: receiptId,
        reference: 'Payme',
        timestamp: DateTime.now(),
        metadata: {
          'receipt_id': receiptId,
          'deep_link': 'payme://checkout?receipt=$receiptId',
        },
      );
    } catch (e) {
      return PaymentResponse(
        success: false,
        errorMessage: 'Payme xatoligi',
        timestamp: DateTime.now(),
      );
    }
  }

  // ============ CLICK ============

  Future<PaymentResponse> _processClickPayment(Payment payment) async {
    try {
      // Click API
      // POST https://api.click.uz/v1/merchant/invoice/create

      final invoiceId = 'click_${DateTime.now().millisecondsSinceEpoch}';

      return PaymentResponse(
        success: true,
        transactionId: invoiceId,
        reference: 'Click',
        timestamp: DateTime.now(),
        metadata: {
          'invoice_id': invoiceId,
          'deep_link': 'click://pay?invoice=$invoiceId',
        },
      );
    } catch (e) {
      return PaymentResponse(
        success: false,
        errorMessage: 'Click xatoligi',
        timestamp: DateTime.now(),
      );
    }
  }

  // ============ UZCARD/HUMO ============

  Future<PaymentResponse> _processUzCardPayment(Payment payment) async {
    try {
      // UzCard/Humo API
      return PaymentResponse(
        success: true,
        transactionId: 'UZC_${DateTime.now().millisecondsSinceEpoch}',
        reference: 'UzCard/Humo',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return PaymentResponse(
        success: false,
        errorMessage: 'UzCard/Humo xatoligi',
        timestamp: DateTime.now(),
      );
    }
  }

  // ============ QR TO'LOV ============

  Future<PaymentResponse> _processQRPayment(Payment payment) async {
    try {
      // QR kod generatsiya
      final qrData = {
        'order_id': payment.orderId,
        'amount': payment.amount,
        'merchant': 'NIZOM_GLOBAL',
        'timestamp': DateTime.now().toIso8601String(),
      };

      return PaymentResponse(
        success: true,
        transactionId: 'QR_${DateTime.now().millisecondsSinceEpoch}',
        reference: 'QR to\'lov',
        timestamp: DateTime.now(),
        metadata: {
          'qr_data': qrData,
          'qr_string': _generateQRString(qrData),
        },
      );
    } catch (e) {
      return PaymentResponse(
        success: false,
        errorMessage: 'QR to\'lov xatoligi',
        timestamp: DateTime.now(),
      );
    }
  }

  // ============ QR KOD ============

  /// QR kod generatsiya
  QRPayment generateQRCode({
    required String orderId,
    required double amount,
    String? description,
  }) {
    final qrData = {
      'order_id': orderId,
      'amount': amount,
      'merchant': 'NIZOM_GLOBAL',
      'timestamp': DateTime.now().toIso8601String(),
    };

    return QRPayment(
      qrCode: _generateQRString(qrData),
      amount: amount,
      orderId: orderId,
      description: description ?? 'NIZOM GLOBAL to\'lov',
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      deepLink: 'nizomglobal://payment?order=$orderId&amount=$amount',
    );
  }

  String _generateQRString(Map<String, dynamic> data) {
    // EMVCo QR code format
    return 'https://pay.nizomglobal.uz/qr/${data['order_id']}';
  }

  // ============ TO'LOV HOLATI ============

  /// To'lov holatini tekshirish
  Future<Either<Failure, PaymentStatus>> checkPaymentStatus(
    String transactionId,
  ) async {
    try {
      final payment = _payments.values.where(
        (item) =>
            item.transactionId == transactionId || item.id == transactionId,
      );
      if (payment.isEmpty) {
        return const Left(NotFoundFailure(resource: 'To‘lov'));
      }
      return Right(payment.first.status);
    } catch (e) {
      return Left(PaymentFailure(message: 'Holat tekshirishda xatolik'));
    }
  }

  // ============ QAYTARISH ============

  /// To'lovni qaytarish
  Future<Either<Failure, Payment>> refundPayment({
    required String paymentId,
    required double amount,
    required String reason,
  }) async {
    try {
      final payment = _payments[paymentId];
      if (payment == null) {
        return const Left(NotFoundFailure(resource: 'To‘lov'));
      }
      if (!payment.isCompleted) {
        return const Left(
            PaymentFailure(message: 'Faqat tugallangan to‘lov qaytariladi'));
      }
      if (amount <= 0 || amount > payment.amount) {
        return const Left(
            PaymentFailure(message: 'Qaytarish summasi noto‘g‘ri'));
      }

      final refunded = payment.copyWith(
        status: PaymentStatus.refunded,
        reference: 'Refund: $reason',
      );
      _payments[paymentId] = refunded;
      return Right(refunded);
    } catch (e) {
      return Left(PaymentFailure(message: 'Qaytarish xatoligi'));
    }
  }

  // ============ CREDIT ============

  Future<PaymentResponse> _processCreditPayment(Payment payment) async {
    return PaymentResponse(
      success: true,
      transactionId: 'CREDIT_${DateTime.now().millisecondsSinceEpoch}',
      reference: 'Nasiya',
      timestamp: DateTime.now(),
    );
  }

  // ============ SIMULATE ============

  PaymentResponse _simulateGatewayResponse({
    required String prefix,
    required String reference,
  }) {
    return PaymentResponse(
      success: true,
      transactionId: '${prefix}_${DateTime.now().millisecondsSinceEpoch}',
      reference: reference,
      timestamp: DateTime.now(),
    );
  }

  // ============ CHEK ============

  /// Chek yaratish
  Map<String, dynamic> generateReceipt(Payment payment) {
    return {
      'receipt_id': 'CHK_${payment.id}',
      'date': payment.createdAt.toIso8601String(),
      'order_number': payment.orderNumber,
      'customer': payment.customerName,
      'amount': payment.amount,
      'currency': payment.currency,
      'method': payment.method.name,
      'transaction_id': payment.transactionId,
      'agent': payment.agentName,
      'status': payment.status.name,
    };
  }
}

extension on Payment {
  Payment copyWith({
    PaymentStatus? status,
    DateTime? completedAt,
    String? transactionId,
    String? reference,
    String? receiptUrl,
  }) {
    return Payment(
      id: id,
      orderId: orderId,
      orderNumber: orderNumber,
      customerId: customerId,
      customerName: customerName,
      amount: amount,
      currency: currency,
      method: method,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      reference: reference ?? this.reference,
      transactionId: transactionId ?? this.transactionId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes,
      agentId: agentId,
      agentName: agentName,
    );
  }
}
