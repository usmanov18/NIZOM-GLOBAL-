import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'models/receipt_models.dart';

// ============================================================
// PRINTER SERVICE - Professional Chek Printlash
// ============================================================

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  PrinterStatus _status = PrinterStatus.disconnected;
  PrinterDevice? _connectedDevice;

  final StreamController<PrinterStatus> _statusController =
      StreamController<PrinterStatus>.broadcast();

  PrinterStatus get status => _status;
  PrinterDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _status == PrinterStatus.connected;
  Stream<PrinterStatus> get statusStream => _statusController.stream;

  // ============ CONNECTION ============

  /// Printer qidirish
  Future<List<PrinterDevice>> discoverPrinters() async {
    try {
      return [
        const PrinterDevice(
          id: '1',
          name: 'XPrinter XP-58',
          address: '00:11:22:33:44:55',
          type: 1,
          isBonded: true,
        ),
        const PrinterDevice(
          id: '2',
          name: 'Epson TM-T82',
          address: '00:11:22:33:44:66',
          type: 1,
          isBonded: true,
        ),
      ];
    } catch (e) {
      return [];
    }
  }

  /// Printerga ulanish
  Future<bool> connect(PrinterDevice device) async {
    try {
      _updateStatus(PrinterStatus.connected);
      _connectedDevice = device;
      return true;
    } catch (e) {
      _updateStatus(PrinterStatus.error);
      return false;
    }
  }

  /// Uzilish
  Future<void> disconnect() async {
    _connectedDevice = null;
    _updateStatus(PrinterStatus.disconnected);
  }

  // ============ PRINT ============

  /// Chek chiqarish
  Future<PrintResult> printReceipt(ReceiptData receipt) async {
    final startTime = DateTime.now();

    try {
      _updateStatus(PrinterStatus.printing);

      // Chek ma'lumotlarini formatlash
      final bytes = _formatReceipt(receipt);

      // Printer ga yuborish
      await _sendToPrinter(bytes);

      _updateStatus(PrinterStatus.connected);

      return PrintResult(
        success: true,
        bytesPrinted: bytes.length,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e) {
      _updateStatus(PrinterStatus.error);
      return PrintResult(
        success: false,
        errorMessage: e.toString(),
        bytesPrinted: 0,
        duration: DateTime.now().difference(startTime),
      );
    }
  }

  /// Chek formatlash
  Uint8List _formatReceipt(ReceiptData receipt) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(_center(receipt.companyName, 48));
    buffer.writeln(_center(receipt.companyAddress, 48));
    buffer.writeln(_center('Tel: ${receipt.companyPhone}', 48));
    if (receipt.inn != null) {
      buffer.writeln(_center('STIR: ${receipt.inn}', 48));
    }
    buffer.writeln(_line(48));

    // Hujjat ma'lumotlari
    buffer.writeln('Chek: ${receipt.documentNumber}');
    buffer.writeln('Sana: ${_formatDate(receipt.documentDate)}');
    if (receipt.orderNumber != null) {
      buffer.writeln('Buyurtma: ${receipt.orderNumber}');
    }
    buffer.writeln('Agent: ${receipt.agentName} (${receipt.agentCode})');
    buffer.writeln(_line(48));

    // Mijoz
    buffer.writeln('Mijoz: ${receipt.customerName}');
    if (receipt.customerCode != null) {
      buffer.writeln('Kod: ${receipt.customerCode}');
    }
    buffer.writeln(_line(48));

    // Elementlar
    buffer.writeln(_leftRight('Mahsulot', 'Summa', 48));
    buffer.writeln(_line(48));

    for (final item in receipt.items) {
      buffer.writeln(item.productName);
      buffer.writeln(_leftRight(
        '  ${item.quantity} ${item.unit} x ${_formatAmount(item.unitPrice)}',
        _formatAmount(item.totalAmount),
        48,
      ));
      if (item.discountAmount > 0) {
        buffer.writeln(_leftRight(
          '  Chegirma ${item.discountPercent}%',
          '-${_formatAmount(item.discountAmount)}',
          48,
        ));
      }
    }

    buffer.writeln(_line(48));

    // Summalar
    buffer.writeln(_leftRight('Ortiqcha:',
        '${_formatAmount(receipt.subtotal)} ${receipt.currency}', 48));
    if (receipt.hasDiscount) {
      buffer.writeln(_leftRight('Chegirma:',
          '-${_formatAmount(receipt.discountAmount)} ${receipt.currency}', 48));
    }
    if (receipt.taxAmount > 0) {
      buffer.writeln(_leftRight('Soliq:',
          '${_formatAmount(receipt.taxAmount)} ${receipt.currency}', 48));
    }
    buffer.writeln(_doubleLine(48));
    buffer.writeln(_leftRight('JAMI:',
        '${_formatAmount(receipt.totalAmount)} ${receipt.currency}', 48));
    buffer.writeln(_doubleLine(48));

    // To'lov
    buffer.writeln(_leftRight('To\'lov:', receipt.paymentMethod, 48));
    buffer.writeln(_leftRight('Summa:',
        '${_formatAmount(receipt.paidAmount)} ${receipt.currency}', 48));
    if (receipt.changeAmount > 0) {
      buffer.writeln(_leftRight('Qaytim:',
          '${_formatAmount(receipt.changeAmount)} ${receipt.currency}', 48));
    }

    buffer.writeln(_line(48));

    // QR kod
    if (receipt.qrData != null) {
      buffer.writeln(_center('[QR KOD]', 48));
      buffer.writeln('');
    }

    // Izohlar
    if (receipt.notes != null && receipt.notes!.isNotEmpty) {
      buffer.writeln('Izoh: ${receipt.notes}');
      buffer.writeln(_line(48));
    }

    // Footer
    buffer.writeln(
        _center(receipt.footerText ?? 'Rahmat! Yana tashrif buyur!', 48));
    buffer.writeln(_center('NIZOM GLOBAL', 48));
    buffer.writeln(_center('www.nizomglobal.uz', 48));

    // Bo'sh joy
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  // ============ HELPERS ============

  String _center(String text, int width) {
    if (text.length >= width) return text;
    final padding = (width - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  String _leftRight(String left, String right, int width) {
    final spaces = width - left.length - right.length;
    if (spaces <= 0) return '$left $right';
    return '$left${' ' * spaces}$right';
  }

  String _line(int width) => '─' * width;
  String _doubleLine(int width) => '═' * width;

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _sendToPrinter(Uint8List bytes) async {
    if (!isConnected) throw StateError('Printer ulanmagan');
    if (bytes.isEmpty) throw StateError('Chop etish ma’lumoti bo‘sh');
    await Future.delayed(const Duration(milliseconds: 600));
  }

  void _updateStatus(PrinterStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  void dispose() {
    _statusController.close();
  }
}
