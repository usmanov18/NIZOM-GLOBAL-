import 'package:flutter/material.dart';

class AdminAgentStatsBar extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;
  final int total;
  final int active;
  final int inactive;
  final int blocked;

  const AdminAgentStatsBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.total,
    required this.active,
    required this.inactive,
    required this.blocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        _chip('Barchasi', total.toString(), const Color(0xFF1565C0), 'all'),
        const SizedBox(width: 8),
        _chip('Faol', active.toString(), const Color(0xFF2E7D32), 'active'),
        const SizedBox(width: 8),
        _chip(
            'Nofaol', inactive.toString(), const Color(0xFFFF6F00), 'inactive'),
        const SizedBox(width: 8),
        _chip('Bloklangan', blocked.toString(), const Color(0xFFC62828),
            'blocked'),
      ]),
    );
  }

  Widget _chip(String label, String count, Color color, String value) {
    final selected = selectedStatus == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onStatusSelected(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? color : Colors.transparent),
          ),
          child: Column(children: [
            Text(count,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7), fontSize: 10)),
          ]),
        ),
      ),
    );
  }
}
