import 'dart:typed_data';
import 'dart:convert';
import '../models/receipt_models.dart';

// ============================================================
// THERMAL RECEIPT - Kichik termal printer (58mm/80mm)
// ESC/POS formatida
// ============================================================

class ThermalReceipt {
  /// 58mm termal printer uchun chek
  static Uint8List generate58mm(ReceiptData receipt) {
    final buffer = BytesBuilder();

    // ESC/POS init
    buffer.add(_initPrinter());

    // Header
    buffer.add(_centerBold(receipt.companyName, 32));
    buffer.add(_center(receipt.companyAddress, 32));
    buffer.add(_center('Tel: ${receipt.companyPhone}', 32));
    if (receipt.inn != null) {
      buffer.add(_center('STIR: ${receipt.inn}', 32));
    }
    buffer.add(_newLine());
    buffer.add(_dashLine(32));

    // Hujjat
    buffer.add(_leftRight('Chek:', receipt.documentNumber, 32));
    buffer.add(_leftRight('Sana:', _formatDate(receipt.documentDate), 32));
    if (receipt.orderNumber != null) {
      buffer.add(_leftRight('Buyurtma:', receipt.orderNumber!, 32));
    }
    buffer.add(_leftRight('Agent:', receipt.agentName, 32));
    buffer.add(_dashLine(32));

    // Mijoz
    buffer.add(_bold('Mijoz: ${receipt.customerName}'));
    buffer.add(_newLine());
    buffer.add(_dashLine(32));

    // Elementlar
    buffer.add(_leftRight('Mahsulot', 'Summa', 32));
    buffer.add(_dashLine(32));

    for (final item in receipt.items) {
      buffer.add(_normal(item.productName));
      buffer.add(_leftRight(
        '  ${item.quantity}${item.unit} x ${_fmt(item.unitPrice)}',
        _fmt(item.totalAmount),
        32,
      ));
      if (item.discountAmount > 0) {
        buffer.add(_leftRight(
          '  Cheg. ${item.discountPercent}%',
          '-${_fmt(item.discountAmount)}',
          32,
        ));
      }
    }

    buffer.add(_dashLine(32));

    // Summalar
    buffer.add(_leftRight(
        'Ortiqcha:', '${_fmt(receipt.subtotal)} ${receipt.currency}', 32));
    if (receipt.hasDiscount) {
      buffer.add(_leftRight('Chegirma:',
          '-${_fmt(receipt.discountAmount)} ${receipt.currency}', 32));
    }
    buffer.add(_doubleDashLine(32));
    buffer.add(_centerBold(
        'JAMI: ${_fmt(receipt.totalAmount)} ${receipt.currency}', 32));
    buffer.add(_doubleDashLine(32));

    // To'lov
    buffer.add(_leftRight('To\'lov:', receipt.paymentMethod, 32));
    buffer.add(_leftRight(
        'Summa:', '${_fmt(receipt.paidAmount)} ${receipt.currency}', 32));
    if (receipt.changeAmount > 0) {
      buffer.add(_leftRight(
          'Qaytim:', '${_fmt(receipt.changeAmount)} ${receipt.currency}', 32));
    }

    buffer.add(_dashLine(32));

    // QR kod
    if (receipt.qrData != null) {
      buffer.add(_center('[QR KOD]', 32));
      buffer.add(_newLine());
    }

    // Footer
    buffer.add(_center(receipt.footerText ?? 'Rahmat!', 32));
    buffer.add(_center('NIZOM GLOBAL', 32));
    buffer.add(_newLine());
    buffer.add(_newLine());
    buffer.add(_cutPaper());

    return buffer.toBytes();
  }

  /// 80mm termal printer uchun chek
  static Uint8List generate80mm(ReceiptData receipt) {
    final buffer = BytesBuilder();

    // ESC/POS init
    buffer.add(_initPrinter());

    // Header
    buffer.add(_centerBold(receipt.companyName, 48));
    buffer.add(_center(receipt.companyAddress, 48));
    buffer.add(_center('Tel: ${receipt.companyPhone}', 48));
    if (receipt.inn != null) {
      buffer.add(_center('STIR: ${receipt.inn}', 48));
    }
    buffer.add(_newLine());
    buffer.add(_dashLine(48));

    // Hujjat
    buffer.add(_leftRight('Chek:', receipt.documentNumber, 48));
    buffer.add(_leftRight('Sana:', _formatDate(receipt.documentDate), 48));
    if (receipt.orderNumber != null) {
      buffer.add(_leftRight('Buyurtma:', receipt.orderNumber!, 48));
    }
    buffer.add(_leftRight(
        'Agent:', '${receipt.agentName} (${receipt.agentCode})', 48));
    buffer.add(_dashLine(48));

    // Mijoz
    buffer.add(_bold('Mijoz: ${receipt.customerName}'));
    if (receipt.customerCode != null) {
      buffer.add(_normal('Kod: ${receipt.customerCode}'));
    }
    buffer.add(_dashLine(48));

    // Elementlar
    buffer.add(_leftRight('Mahsulot', 'Summa', 48));
    buffer.add(_dashLine(48));

    for (final item in receipt.items) {
      buffer.add(_normal(item.productName));
      buffer.add(_leftRight(
        '  ${item.quantity} ${item.unit} x ${_fmt(item.unitPrice)}',
        _fmt(item.totalAmount),
        48,
      ));
      if (item.discountAmount > 0) {
        buffer.add(_leftRight(
          '  Chegirma ${item.discountPercent}%',
          '-${_fmt(item.discountAmount)}',
          48,
        ));
      }
    }

    buffer.add(_dashLine(48));

    // Summalar
    buffer.add(_leftRight(
        'Ortiqcha:', '${_fmt(receipt.subtotal)} ${receipt.currency}', 48));
    if (receipt.hasDiscount) {
      buffer.add(_leftRight('Chegirma:',
          '-${_fmt(receipt.discountAmount)} ${receipt.currency}', 48));
    }
    if (receipt.taxAmount > 0) {
      buffer.add(_leftRight(
          'Soliq:', '${_fmt(receipt.taxAmount)} ${receipt.currency}', 48));
    }
    buffer.add(_doubleDashLine(48));
    buffer.add(_centerBold(
        'JAMI: ${_fmt(receipt.totalAmount)} ${receipt.currency}', 48));
    buffer.add(_doubleDashLine(48));

    // To'lov
    buffer.add(_leftRight('To\'lov:', receipt.paymentMethod, 48));
    buffer.add(_leftRight(
        'Summa:', '${_fmt(receipt.paidAmount)} ${receipt.currency}', 48));
    if (receipt.changeAmount > 0) {
      buffer.add(_leftRight(
          'Qaytim:', '${_fmt(receipt.changeAmount)} ${receipt.currency}', 48));
    }

    buffer.add(_dashLine(48));

    // QR kod
    if (receipt.qrData != null) {
      buffer.add(_center('[QR KOD]', 48));
      buffer.add(_newLine());
    }

    // Izohlar
    if (receipt.notes != null && receipt.notes!.isNotEmpty) {
      buffer.add(_normal('Izoh: ${receipt.notes}'));
      buffer.add(_dashLine(48));
    }

    // Footer
    buffer
        .add(_center(receipt.footerText ?? 'Rahmat! Yana tashrif buyur!', 48));
    buffer.add(_center('NIZOM GLOBAL', 48));
    buffer.add(_center('www.nizomglobal.uz', 48));
    buffer.add(_newLine());
    buffer.add(_newLine());
    buffer.add(_cutPaper());

    return buffer.toBytes();
  }

  // ============ ESC/POS COMMANDS ============

  static Uint8List _initPrinter() {
    return Uint8List.fromList([0x1B, 0x40]); // ESC @
  }

  static Uint8List _centerBold(String text, int width) {
    return Uint8List.fromList([
      0x1B, 0x61, 0x01, // Center align
      0x1B, 0x45, 0x01, // Bold on
      ...utf8.encode(_padCenter(text, width)),
      0x1B, 0x45, 0x00, // Bold off
      0x0A, // New line
    ]);
  }

  static Uint8List _center(String text, int width) {
    return Uint8List.fromList([
      0x1B, 0x61, 0x01, // Center align
      ...utf8.encode(_padCenter(text, width)),
      0x0A,
    ]);
  }

  static Uint8List _bold(String text) {
    return Uint8List.fromList([
      0x1B, 0x45, 0x01, // Bold on
      ...utf8.encode(text),
      0x1B, 0x45, 0x00, // Bold off
      0x0A,
    ]);
  }

  static Uint8List _normal(String text) {
    return Uint8List.fromList([
      ...utf8.encode(text),
      0x0A,
    ]);
  }

  static Uint8List _leftRight(String left, String right, int width) {
    final spaces = width - left.length - right.length;
    final text = spaces > 0 ? '$left${' ' * spaces}$right' : '$left $right';
    return Uint8List.fromList([
      0x1B, 0x61, 0x00, // Left align
      ...utf8.encode(text),
      0x0A,
    ]);
  }

  static Uint8List _dashLine(int width) {
    return Uint8List.fromList([
      ...utf8.encode('─' * width),
      0x0A,
    ]);
  }

  static Uint8List _doubleDashLine(int width) {
    return Uint8List.fromList([
      ...utf8.encode('═' * width),
      0x0A,
    ]);
  }

  static Uint8List _newLine() {
    return Uint8List.fromList([0x0A]);
  }

  static Uint8List _cutPaper() {
    return Uint8List.fromList([0x1D, 0x56, 0x00]); // GS V 0
  }

  static String _padCenter(String text, int width) {
    if (text.length >= width) return text;
    final padding = (width - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  static String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  static String _fmt(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}
