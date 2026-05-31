import 'models/receipt_models.dart';

// ============================================================
// RECEIPT GENERATOR - Chek ma'lumotlarini yaratish
// ============================================================

class ReceiptGenerator {
  /// Sotuv cheki yaratish
  static ReceiptData generateSaleReceipt({
    required String orderId,
    required String orderNumber,
    required String customerName,
    required String? customerCode,
    required String agentName,
    required String agentCode,
    required List<ReceiptItem> items,
    required double totalAmount,
    required double discountAmount,
    required double paidAmount,
    required String paymentMethod,
    String? notes,
  }) {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );

    return ReceiptData(
      id: 'receipt_$orderId',
      type: ReceiptType.sale,
      companyCode: 'NG001',
      companyName: 'NIZOM GLOBAL',
      companyAddress: 'Toshkent sh., Chilonzor t.',
      companyPhone: '+998 71 123 45 67',
      inn: '123456789',
      documentNumber: 'CHK-${DateTime.now().millisecondsSinceEpoch}',
      documentDate: DateTime.now(),
      orderNumber: orderNumber,
      customerCode: customerCode,
      customerName: customerName,
      agentId: 'agent_1',
      agentCode: agentCode,
      agentName: agentName,
      items: items,
      subtotal: subtotal,
      discountAmount: discountAmount,
      taxAmount: 0,
      totalAmount: totalAmount,
      currency: 'UZS',
      paidAmount: paidAmount,
      changeAmount: paidAmount - totalAmount,
      paymentMethod: _getPaymentMethodName(paymentMethod),
      qrData: 'https://nizomglobal.uz/receipt/$orderNumber',
      notes: notes,
      footerText: 'Rahmat! Yana tashrif buyur!',
    );
  }

  /// To'lov cheki yaratish
  static ReceiptData generatePaymentReceipt({
    required String paymentId,
    required String customerName,
    required String? customerCode,
    required String agentName,
    required String agentCode,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) {
    return ReceiptData(
      id: 'payment_$paymentId',
      type: ReceiptType.payment,
      companyCode: 'NG001',
      companyName: 'NIZOM GLOBAL',
      companyAddress: 'Toshkent sh., Chilonzor t.',
      companyPhone: '+998 71 123 45 67',
      documentNumber: 'TOL-${DateTime.now().millisecondsSinceEpoch}',
      documentDate: DateTime.now(),
      customerCode: customerCode,
      customerName: customerName,
      agentId: 'agent_1',
      agentCode: agentCode,
      agentName: agentName,
      items: [],
      subtotal: amount,
      discountAmount: 0,
      taxAmount: 0,
      totalAmount: amount,
      currency: 'UZS',
      paidAmount: amount,
      changeAmount: 0,
      paymentMethod: _getPaymentMethodName(paymentMethod),
      notes: notes,
      footerText: 'To\'lov qabul qilindi',
    );
  }

  /// Kunlik hisobot cheki (Z-report)
  static ReceiptData generateDailyReport({
    required DateTime date,
    required String agentName,
    required String agentCode,
    required int totalOrders,
    required double totalSales,
    required double totalCollections,
    required int totalVisits,
    required double totalDistance,
  }) {
    return ReceiptData(
      id: 'daily_${date.toIso8601String().substring(0, 10)}',
      type: ReceiptType.dailyReport,
      companyCode: 'NG001',
      companyName: 'NIZOM GLOBAL',
      companyAddress: 'Toshkent sh., Chilonzor t.',
      companyPhone: '+998 71 123 45 67',
      documentNumber:
          'Z-${date.toIso8601String().substring(0, 10).replaceAll('-', '')}',
      documentDate: date,
      agentId: 'agent_1',
      agentCode: agentCode,
      agentName: agentName,
      customerName: '',
      items: [],
      subtotal: totalSales,
      discountAmount: 0,
      taxAmount: 0,
      totalAmount: totalSales,
      currency: 'UZS',
      paidAmount: totalCollections,
      changeAmount: 0,
      paymentMethod: 'Aralash',
      footerText: 'Kunlik hisobot',
    );
  }

  static String _getPaymentMethodName(String code) {
    switch (code) {
      case 'cash':
        return 'Naqd pul';
      case 'card':
        return 'Plastik karta';
      case 'transfer':
        return 'Bank o\'tkazmasi';
      case 'credit':
        return 'Kredit';
      default:
        return code;
    }
  }
}
