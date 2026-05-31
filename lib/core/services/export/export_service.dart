import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ============================================================
// EXPORT SERVICE - PDF, Excel, CSV eksport
// ============================================================

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  // ============ PDF ============

  /// PDF yaratish
  Future<String> exportToPdf({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<String> columns,
    Map<String, String>? headers,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/exports/${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Hozircha HTML content .pdf pathga yoziladi; platform exporter keyin ulanadi.
      final file = File(filePath);
      await file.create(recursive: true);

      // HTML yaratish
      final html = _generateHtml(title, data, columns, headers);
      await file.writeAsString(html);

      return filePath;
    } catch (e) {
      throw Exception('PDF yaratishda xatolik: $e');
    }
  }

  // ============ CSV ============

  /// CSV yaratish
  Future<String> exportToCsv({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<String> columns,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/exports/${DateTime.now().millisecondsSinceEpoch}.csv';

      final buffer = StringBuffer();

      // Header
      buffer.writeln(columns.join(','));

      // Data
      for (final row in data) {
        final values = columns.map((col) {
          final value = row[col]?.toString() ?? '';
          return '"${value.replaceAll('"', '""')}"';
        }).toList();
        buffer.writeln(values.join(','));
      }

      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsString(buffer.toString());

      return filePath;
    } catch (e) {
      throw Exception('CSV yaratishda xatolik: $e');
    }
  }

  // ============ JSON ============

  Future<String> exportToJson({
    required String title,
    required Object data,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final safeTitle =
          title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
      final filePath =
          '${dir.path}/exports/${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File(filePath);
      await file.create(recursive: true);
      await file
          .writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      return filePath;
    } catch (e) {
      throw Exception('JSON export xatoligi: $e');
    }
  }

  // ============ SHARE ============

  /// Faylni ulashish
  Future<void> shareFile(String filePath, {String? subject}) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'NIZOM GLOBAL hisobot',
      );
    } catch (e) {
      throw Exception('Ulashishda xatolik: $e');
    }
  }

  // ============ HTML ============

  String _generateHtml(
    String title,
    List<Map<String, dynamic>> data,
    List<String> columns,
    Map<String, String>? headers,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; padding: 20px; }
    h1 { color: #1565C0; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th { background: #1565C0; color: white; padding: 10px; text-align: left; }
    td { padding: 8px; border-bottom: 1px solid #eee; }
    tr:nth-child(even) { background: #f9f9f9; }
    .footer { margin-top: 30px; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <h1>$title</h1>
  <p>NIZOM GLOBAL • ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}</p>
  <table>
    <thead>
      <tr>
''');

    for (final col in columns) {
      buffer.writeln('        <th>${headers?[col] ?? col}</th>');
    }

    buffer.writeln('''
      </tr>
    </thead>
    <tbody>
''');

    for (final row in data) {
      buffer.writeln('      <tr>');
      for (final col in columns) {
        buffer.writeln('        <td>${row[col] ?? ''}</td>');
      }
      buffer.writeln('      </tr>');
    }

    buffer.writeln('''
    </tbody>
  </table>
  <div class="footer">
    <p>© ${DateTime.now().year} NIZOM GLOBAL. Barcha huquqlar himoyalangan.</p>
  </div>
</body>
</html>
''');

    return buffer.toString();
  }
}
