import 'package:flutter/material.dart';

/// Kengaytirilgan filter widget
class AdvancedFilterWidget extends StatefulWidget {
  final List<FilterOption> filters;
  final Map<String, dynamic> currentValues;
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onReset;

  const AdvancedFilterWidget({
    super.key,
    required this.filters,
    required this.currentValues,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<AdvancedFilterWidget> createState() => _AdvancedFilterWidgetState();
}

class _AdvancedFilterWidgetState extends State<AdvancedFilterWidget> {
  late Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    _values = Map.from(widget.currentValues);
  }

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
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtrlash',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _values.clear());
                  widget.onReset();
                },
                child: const Text('Tozalash'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters
          ...widget.filters.map((filter) => _buildFilter(filter)),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Bekor qilish'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_values);
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

  Widget _buildFilter(FilterOption filter) {
    switch (filter.type) {
      case FilterType.dropdown:
        return _buildDropdownFilter(filter);
      case FilterType.multiSelect:
        return _buildMultiSelectFilter(filter);
      case FilterType.dateRange:
        return _buildDateRangeFilter(filter);
      case FilterType.rangeSlider:
        return _buildRangeSliderFilter(filter);
      case FilterType.toggle:
        return _buildToggleFilter(filter);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDropdownFilter(FilterOption filter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: _values[filter.key] as String?,
        decoration: InputDecoration(
          labelText: filter.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: filter.options?.map((opt) {
          return DropdownMenuItem<String>(
            value: opt['value'].toString(),
            child: Text(opt['label'].toString()),
          );
        }).toList(),
        onChanged: (v) => setState(() => _values[filter.key] = v),
      ),
    );
  }

  Widget _buildMultiSelectFilter(FilterOption filter) {
    final selected = (_values[filter.key] as List<String>?) ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            filter.label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filter.options?.map((opt) {
                  final isSelected = selected.contains(opt['value']);
                  return FilterChip(
                    label: Text(opt['label']),
                    selected: isSelected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          selected.add(opt['value']);
                        } else {
                          selected.remove(opt['value']);
                        }
                        _values[filter.key] = selected;
                      });
                    },
                  );
                }).toList() ??
                [],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(String key) async {
    final now = DateTime.now();
    final current = _values[key] is DateTime ? _values[key] as DateTime : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() => _values[key] = picked);
  }

  String _formatDateValue(String key, String fallback) {
    final value = _values[key];
    if (value is! DateTime) return fallback;
    return "${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}";
  }

  Widget _buildDateRangeFilter(FilterOption filter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            filter.label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate('${filter.key}_from'),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _formatDateValue('${filter.key}_from', 'Boshlanish'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate('${filter.key}_to'),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_formatDateValue('${filter.key}_to', 'Tugash')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSliderFilter(FilterOption filter) {
    final range = (_values[filter.key] as RangeValues?) ??
        RangeValues(filter.min ?? 0, filter.max ?? 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                filter.label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${range.start.toStringAsFixed(0)} - ${range.end.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          RangeSlider(
            values: range,
            min: filter.min ?? 0,
            max: filter.max ?? 100,
            divisions: filter.divisions ?? 10,
            labels: RangeLabels(
              range.start.toStringAsFixed(0),
              range.end.toStringAsFixed(0),
            ),
            onChanged: (v) => setState(() => _values[filter.key] = v),
            activeColor: const Color(0xFF1565C0),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleFilter(FilterOption filter) {
    return SwitchListTile(
      title: Text(filter.label),
      value: _values[filter.key] ?? false,
      onChanged: (v) => setState(() => _values[filter.key] = v),
      activeThumbColor: const Color(0xFF1565C0),
    );
  }
}

// ============ MODELS ============

enum FilterType { dropdown, multiSelect, dateRange, rangeSlider, toggle }

class FilterOption {
  final String key;
  final String label;
  final FilterType type;
  final List<Map<String, dynamic>>? options;
  final double? min;
  final double? max;
  final int? divisions;

  const FilterOption({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.min,
    this.max,
    this.divisions,
  });
}
