import 'package:equatable/equatable.dart';

// ============================================================
// RECEIPT MODELS - Chek va hujjatlar
// ============================================================

/// Chek turi
enum ReceiptType {
  sale, // Sotuv cheki
  return_, // Qaytarish cheki
  payment, // To'lov cheki
  dailyReport, // Kunlik hisobot (Z-report)
  inventory, // Inventarizatsiya
}

/// Chek formati
enum ReceiptFormat {
  thermal, // Termal printer (58mm/80mm)
  a4, // A4 hujjat
  pdf, // PDF
  image, // Rasm
}

/// Chek ma'lumotlari
class ReceiptData extends Equatable {
  final String id;
  final ReceiptType type;
  final String companyCode;
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String? companyLogo;
  final String? inn;

  // Hujjat
  final String documentNumber;
  final DateTime documentDate;
  final String? orderNumber;

  // Mijoz
  final String? customerId;
  final String? customerCode;
  final String customerName;
  final String? customerAddress;
  final String? customerPhone;
  final String? customerInn;

  // Agent
  final String agentId;
  final String agentCode;
  final String agentName;

  // Elementlar
  final List<ReceiptItem> items;

  // Summalar
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String currency;

  // To'lov
  final double paidAmount;
  final double changeAmount;
  final String paymentMethod;

  // QR kod
  final String? qrData;

  // Izohlar
  final String? notes;
  final String? footerText;

  const ReceiptData({
    required this.id,
    required this.type,
    required this.companyCode,
    required this.companyName,
    required this.companyAddress,
    required this.companyPhone,
    this.companyLogo,
    this.inn,
    required this.documentNumber,
    required this.documentDate,
    this.orderNumber,
    this.customerId,
    this.customerCode,
    required this.customerName,
    this.customerAddress,
    this.customerPhone,
    this.customerInn,
    required this.agentId,
    required this.agentCode,
    required this.agentName,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
    required this.paidAmount,
    required this.changeAmount,
    required this.paymentMethod,
    this.qrData,
    this.notes,
    this.footerText,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  bool get hasDiscount => discountAmount > 0;
  bool get isFullyPaid => paidAmount >= totalAmount;

  @override
  List<Object?> get props => [id, documentNumber];
}

/// Chek elementi
class ReceiptItem extends Equatable {
  final int lineNumber;
  final String productCode;
  final String productName;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double discountPercent;
  final double discountAmount;
  final double totalAmount;
  final String? barcode;

  const ReceiptItem({
    required this.lineNumber,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.discountPercent,
    required this.discountAmount,
    required this.totalAmount,
    this.barcode,
  });

  @override
  List<Object?> get props => [lineNumber, productCode, quantity];
}

/// Printer holati
enum PrinterStatus {
  disconnected,
  connected,
  printing,
  error,
  outOfPaper,
  lowBattery,
}

/// Printer ma'lumotlari
class PrinterDevice extends Equatable {
  final String id;
  final String name;
  final String address;
  final int type; // 0 = BLE, 1 = Classic
  final bool isBonded;

  const PrinterDevice({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.isBonded,
  });

  @override
  List<Object?> get props => [id, address];
}

/// Print result
class PrintResult extends Equatable {
  final bool success;
  final String? errorMessage;
  final int bytesPrinted;
  final Duration duration;

  const PrintResult({
    required this.success,
    this.errorMessage,
    required this.bytesPrinted,
    required this.duration,
  });

  @override
  List<Object?> get props => [success, bytesPrinted];
}
