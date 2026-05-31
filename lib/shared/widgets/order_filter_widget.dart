import 'package:flutter/material.dart';

/// Buyurtma filtri va qidiruv
class OrderFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;

  const OrderFilterWidget({super.key, required this.onApply});

  @override
  State<OrderFilterWidget> createState() => _OrderFilterWidgetState();
}

class _OrderFilterWidgetState extends State<OrderFilterWidget> {
  String _selectedStatus = 'all';
  String _selectedPeriod = 'today';
  String _selectedPayment = 'all';
  RangeValues _amountRange = const RangeValues(0, 100000000);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Filtrlash',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Status
          const Text('Holat', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filterChip('Barchasi', 'all', _selectedStatus,
                  (v) => setState(() => _selectedStatus = v)),
              _filterChip('Kutilmoqda', 'pending', _selectedStatus,
                  (v) => setState(() => _selectedStatus = v)),
              _filterChip('Tasdiqlangan', 'confirmed', _selectedStatus,
                  (v) => setState(() => _selectedStatus = v)),
              _filterChip('Yetkazilgan', 'delivered', _selectedStatus,
                  (v) => setState(() => _selectedStatus = v)),
              _filterChip('Bekor', 'cancelled', _selectedStatus,
                  (v) => setState(() => _selectedStatus = v)),
            ],
          ),
          const SizedBox(height: 16),

          // Period
          const Text('Davr', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filterChip('Bugun', 'today', _selectedPeriod,
                  (v) => setState(() => _selectedPeriod = v)),
              _filterChip('Hafta', 'week', _selectedPeriod,
                  (v) => setState(() => _selectedPeriod = v)),
              _filterChip('Oy', 'month', _selectedPeriod,
                  (v) => setState(() => _selectedPeriod = v)),
              _filterChip('Barchasi', 'all', _selectedPeriod,
                  (v) => setState(() => _selectedPeriod = v)),
            ],
          ),
          const SizedBox(height: 16),

          // Amount range
          const Text('Summa oralig\'i',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_formatAmount(_amountRange.start.toInt())} so\'m'),
              Text('${_formatAmount(_amountRange.end.toInt())} so\'m'),
            ],
          ),
          RangeSlider(
            values: _amountRange,
            min: 0,
            max: 100000000,
            divisions: 20,
            labels: RangeLabels(
              _formatAmount(_amountRange.start.toInt()),
              _formatAmount(_amountRange.end.toInt()),
            ),
            onChanged: (v) => setState(() => _amountRange = v),
            activeColor: const Color(0xFF1565C0),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = 'all';
                      _selectedPeriod = 'today';
                      _selectedPayment = 'all';
                      _amountRange = const RangeValues(0, 100000000);
                    });
                  },
                  child: const Text('Tozalash'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply({
                      'status': _selectedStatus,
                      'period': _selectedPeriod,
                      'payment': _selectedPayment,
                      'minAmount': _amountRange.start,
                      'maxAmount': _amountRange.end,
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                  ),
                  child: const Text('Qo\'llash'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String label,
    String value,
    String selected,
    Function(String) onSelected,
  ) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}
