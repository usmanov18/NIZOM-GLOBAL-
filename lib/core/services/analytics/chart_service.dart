import 'package:flutter/material.dart';

// ============================================================
// CHART SERVICE - Grafiklar va vizualizatsiya
// ============================================================

class ChartService {
  /// Line chart data
  static List<ChartPoint> generateLineData(List<double> values) {
    return values.asMap().entries.map((entry) {
      return ChartPoint(
        x: entry.key.toDouble(),
        y: entry.value,
        label: '${entry.key + 1}',
      );
    }).toList();
  }

  /// Bar chart data
  static List<BarData> generateBarData(Map<String, double> data) {
    return data.entries.map((entry) {
      return BarData(
        label: entry.key,
        value: entry.value,
        color: _getColorByIndex(data.keys.toList().indexOf(entry.key)),
      );
    }).toList();
  }

  /// Pie chart data
  static List<PieData> generatePieData(Map<String, double> data) {
    final total = data.values.fold<double>(0, (sum, v) => sum + v);
    return data.entries.map((entry) {
      return PieData(
        label: entry.key,
        value: entry.value,
        percentage: total > 0 ? (entry.value / total * 100) : 0,
        color: _getColorByIndex(data.keys.toList().indexOf(entry.key)),
      );
    }).toList();
  }

  static Color _getColorByIndex(int index) {
    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF2E7D32),
      const Color(0xFFFF6F00),
      const Color(0xFF00897B),
      const Color(0xFF9C27B0),
      const Color(0xFFC62828),
      const Color(0xFF00BCD4),
      const Color(0xFF795548),
    ];
    return colors[index % colors.length];
  }
}

class ChartPoint {
  final double x;
  final double y;
  final String? label;
  const ChartPoint({required this.x, required this.y, this.label});
}

class BarData {
  final String label;
  final double value;
  final Color color;
  const BarData(
      {required this.label, required this.value, required this.color});
}

class PieData {
  final String label;
  final double value;
  final double percentage;
  final Color color;
  const PieData(
      {required this.label,
      required this.value,
      required this.percentage,
      required this.color});
}
