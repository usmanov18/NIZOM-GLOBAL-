import 'package:flutter/material.dart';

class WarehouseAssignmentEditor extends StatelessWidget {
  final String selectedWarehouse;
  final ValueChanged<String> onDefaultWarehouseChanged;
  final Set<String> selectedWarehouseIds;
  final ValueChanged<Set<String>> onAllowedWarehousesChanged;

  const WarehouseAssignmentEditor({
    super.key,
    required this.selectedWarehouse,
    required this.onDefaultWarehouseChanged,
    required this.selectedWarehouseIds,
    required this.onAllowedWarehousesChanged,
  });

  static const warehouses = {
    'warehouse_1': 'Asosiy ombor',
    'warehouse_2': 'Toshkent ombor',
    'warehouse_3': 'Samarqand ombor',
  };

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DropdownButtonFormField<String>(
        initialValue: selectedWarehouse,
        decoration: InputDecoration(
            labelText: 'Default sklad',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        items: warehouses.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          final next = {...selectedWarehouseIds, value};
          onDefaultWarehouseChanged(value);
          onAllowedWarehousesChanged(next);
        },
      ),
      const SizedBox(height: 12),
      const Text('Sklad ruxsatlari',
          style: TextStyle(fontWeight: FontWeight.w600)),
      Wrap(
        spacing: 8,
        children: warehouses.entries.map((e) {
          final selected = selectedWarehouseIds.contains(e.key);
          return FilterChip(
            label: Text(e.value),
            selected: selected,
            onSelected: (value) {
              final next = {...selectedWarehouseIds};
              if (value) {
                next.add(e.key);
              } else {
                next.remove(e.key);
              }
              if (next.isEmpty) next.add(selectedWarehouse);
              onAllowedWarehousesChanged(next);
            },
          );
        }).toList(),
      ),
    ]);
  }
}
