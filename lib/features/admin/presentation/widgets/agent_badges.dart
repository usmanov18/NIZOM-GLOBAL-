import 'package:flutter/material.dart';
import '../../../../shared/utils/business_formatters.dart';

class AgentRoleBadge extends StatelessWidget {
  final String role;
  final bool compact;

  const AgentRoleBadge({super.key, required this.role, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(role);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 7, vertical: compact ? 2 : 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Text(_roleLabel(role),
          style: TextStyle(
              color: color,
              fontSize: compact ? 8 : 10,
              fontWeight: FontWeight.w700)),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'supervisor':
        return const Color(0xFF00897B);
      case 'manager':
        return const Color(0xFFFF6F00);
      case 'agent':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'supervisor':
        return 'Supervisor';
      case 'manager':
        return 'Menejer';
      case 'agent':
        return 'Agent';
      default:
        return role;
    }
  }
}

class AgentPortfolioBadges extends StatelessWidget {
  final List<String> portfolioIds;
  final bool compact;

  const AgentPortfolioBadges(
      {super.key, required this.portfolioIds, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (portfolioIds.isEmpty) {
      return Text('Portfel yo‘q',
          style: TextStyle(
              color: Colors.grey.shade500, fontSize: compact ? 9 : 11));
    }
    final visible = compact ? portfolioIds.take(2).toList() : portfolioIds;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: compact ? WrapAlignment.center : WrapAlignment.start,
      children: [
        ...visible.map((id) {
          final color = BusinessFormatters.portfolioColor(id);
          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 5 : 7, vertical: compact ? 2 : 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Text(BusinessFormatters.portfolioShortName(id),
                style: TextStyle(
                    color: color,
                    fontSize: compact ? 8 : 10,
                    fontWeight: FontWeight.w700)),
          );
        }),
        if (compact && portfolioIds.length > visible.length)
          Text('+${portfolioIds.length - visible.length}',
              style: const TextStyle(fontSize: 9)),
      ],
    );
  }
}
