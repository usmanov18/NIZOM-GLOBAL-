import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'models/receipt_models.dart';
import 'templates/thermal_receipt.dart';
import 'templates/a4_document.dart';

// ============================================================
// PDF GENERATOR - PDF fayllar yaratish va ulashish
// ============================================================

class PdfGenerator {
  /// Sotuv hujjati PDF yaratish
  static Future<String> generateSalePdf(ReceiptData receipt) async {
    try {
      // HTML yaratish
      final html = A4Document.generateSaleDocument(receipt);

      // PDF ga aylantirish
      final pdfBytes = await _htmlToPdf(html);

      // Faylga saqlash
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/receipts/${receipt.documentNumber}.pdf';
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(pdfBytes);

      return filePath;
    } catch (e) {
      throw Exception('PDF yaratishda xatolik: $e');
    }
  }

  /// Kunlik hisobot PDF yaratish
  static Future<String> generateDailyReportPdf({
    required DateTime date,
    required String agentName,
    required String agentCode,
    required int totalOrders,
    required double totalSales,
    required double totalCollections,
    required int totalVisits,
    required int completedVisits,
    required double totalDistance,
    required List<Map<String, dynamic>> topProducts,
    required List<Map<String, dynamic>> topCustomers,
  }) async {
    try {
      final html = A4Document.generateDailyReport(
        date: date,
        agentName: agentName,
        agentCode: agentCode,
        totalOrders: totalOrders,
        totalSales: totalSales,
        totalCollections: totalCollections,
        totalVisits: totalVisits,
        completedVisits: completedVisits,
        totalDistance: totalDistance,
        topProducts: topProducts,
        topCustomers: topCustomers,
      );

      final pdfBytes = await _htmlToPdf(html);

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/reports/daily_${date.toIso8601String().substring(0, 10)}.pdf';
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(pdfBytes);

      return filePath;
    } catch (e) {
      throw Exception('Hisobot PDF yaratishda xatolik: $e');
    }
  }

  /// Termal printer uchun chek bytes
  static Uint8List generateThermalReceipt(ReceiptData receipt,
      {bool is80mm = true}) {
    if (is80mm) {
      return ThermalReceipt.generate80mm(receipt);
    } else {
      return ThermalReceipt.generate58mm(receipt);
    }
  }

  /// PDF ni ulashish
  static Future<void> sharePdf(String filePath, {String? subject}) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'NIZOM GLOBAL hujjat',
      );
    } catch (e) {
      throw Exception('Ulashishda xatolik: $e');
    }
  }

  /// PDF dan HTML yaratish
  static Future<Uint8List> _htmlToPdf(String html) async {
    // Lightweight fallback: HTML bytes are stored with .pdf extension until native renderer is attached.
    return Uint8List.fromList(utf8.encode(html));
  }

  /// Saqlangan PDF larni olish
  static Future<List<FileSystemEntity>> getSavedPdfs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${dir.path}/receipts');
      if (await receiptsDir.exists()) {
        return receiptsDir.listSync();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// PDF ni o'chirish
  static Future<void> deletePdf(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('O\'chirishda xatolik: $e');
    }
  }
}
