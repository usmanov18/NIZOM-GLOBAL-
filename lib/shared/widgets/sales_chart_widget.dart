import 'package:flutter/material.dart';

/// Sotuv charti widget
class SalesChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String period;

  const SalesChartWidget({
    super.key,
    required this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<double>(
      0,
      (max, item) =>
          (item['value'] as double) > max ? item['value'] as double : max,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$period sotuv',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text(
                '${_formatTotal()} so\'m',
                style: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final height = maxValue > 0
                    ? (item['value'] as double) / maxValue * 130
                    : 0.0;
                final isToday = item['isToday'] as bool? ?? false;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatShort(item['value'] as double),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: height.toDouble(),
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFF1565C0)
                            : const Color(0xFF1565C0).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday
                            ? const Color(0xFF1565C0)
                            : Colors.grey.shade600,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTotal() {
    final total = data.fold<double>(
      0,
      (sum, item) => sum + (item['value'] as double),
    );
    return _formatShort(total);
  }

  String _formatShort(double value) {
    if (value >= 1000000000)
      return '${(value / 1000000000).toStringAsFixed(1)}Mrd';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(0)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}
