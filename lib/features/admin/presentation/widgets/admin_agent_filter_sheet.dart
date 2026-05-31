import 'package:flutter/material.dart';

class AdminAgentFilterValues {
  final String status;
  final String role;
  final String region;
  final String portfolio;

  const AdminAgentFilterValues({
    required this.status,
    required this.role,
    required this.region,
    required this.portfolio,
  });

  AdminAgentFilterValues copyWith(
      {String? status, String? role, String? region, String? portfolio}) {
    return AdminAgentFilterValues(
      status: status ?? this.status,
      role: role ?? this.role,
      region: region ?? this.region,
      portfolio: portfolio ?? this.portfolio,
    );
  }
}

class AdminAgentFilterSheet extends StatefulWidget {
  final AdminAgentFilterValues initial;
  final ValueChanged<AdminAgentFilterValues> onApply;

  const AdminAgentFilterSheet(
      {super.key, required this.initial, required this.onApply});

  @override
  State<AdminAgentFilterSheet> createState() => _AdminAgentFilterSheetState();
}

class _AdminAgentFilterSheetState extends State<AdminAgentFilterSheet> {
  late AdminAgentFilterValues values;

  @override
  void initState() {
    super.initState();
    values = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Filtrlash',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _section('Holat', [
            _chip('Barchasi', 'all', values.status,
                (v) => setState(() => values = values.copyWith(status: v))),
            _chip('Faol', 'active', values.status,
                (v) => setState(() => values = values.copyWith(status: v))),
            _chip('Nofaol', 'inactive', values.status,
                (v) => setState(() => values = values.copyWith(status: v))),
            _chip('Bloklangan', 'blocked', values.status,
                (v) => setState(() => values = values.copyWith(status: v))),
          ]),
          _section('Rol', [
            _chip('Barchasi', 'all', values.role,
                (v) => setState(() => values = values.copyWith(role: v))),
            _chip('Agent', 'agent', values.role,
                (v) => setState(() => values = values.copyWith(role: v))),
            _chip('Menejer', 'manager', values.role,
                (v) => setState(() => values = values.copyWith(role: v))),
            _chip('Supervisor', 'supervisor', values.role,
                (v) => setState(() => values = values.copyWith(role: v))),
          ]),
          _section('Hudud', [
            _chip('Barchasi', 'all', values.region,
                (v) => setState(() => values = values.copyWith(region: v))),
            _chip('Toshkent', 'toshkent', values.region,
                (v) => setState(() => values = values.copyWith(region: v))),
            _chip('Samarqand', 'samarqand', values.region,
                (v) => setState(() => values = values.copyWith(region: v))),
            _chip('Buxoro', 'buxoro', values.region,
                (v) => setState(() => values = values.copyWith(region: v))),
          ]),
          _section('Portfolio', [
            _chip('Barchasi', 'all', values.portfolio,
                (v) => setState(() => values = values.copyWith(portfolio: v))),
            _chip('Ichimliklar', 'pf_beverages', values.portfolio,
                (v) => setState(() => values = values.copyWith(portfolio: v))),
            _chip('Snack/Qandolat', 'pf_snacks', values.portfolio,
                (v) => setState(() => values = values.copyWith(portfolio: v))),
            _chip('Premium', 'pf_energy_premium', values.portfolio,
                (v) => setState(() => values = values.copyWith(portfolio: v))),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onApply(values);
              Navigator.pop(context);
            },
            child: const Text('Qo‘llash'),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> chips) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ]),
    );
  }

  Widget _chip(String label, String value, String selected,
      ValueChanged<String> onSelected) {
    return FilterChip(
      label: Text(label),
      selected: selected == value,
      onSelected: (_) => onSelected(value),
    );
  }
}
