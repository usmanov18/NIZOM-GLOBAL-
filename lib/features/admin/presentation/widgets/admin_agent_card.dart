import 'package:flutter/material.dart';

import '../../../../shared/design/app_design_tokens.dart';

class AdminAgentCard extends StatelessWidget {
  final Map<String, dynamic> agent;
  final bool grid;
  final Widget portfolioBadges;
  final Widget roleBadge;
  final VoidCallback onTap;

  const AdminAgentCard({
    super.key,
    required this.agent,
    required this.grid,
    required this.portfolioBadges,
    required this.roleBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return grid ? _gridCard() : _listCard();
  }

  Color get _statusColor {
    final status = agent['status'] as String? ?? 'active';
    if (status == 'active') return AppColors.success;
    if (status == 'blocked') return AppColors.danger;
    return AppColors.warning;
  }

  Widget _listCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.soft),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(children: [
                _avatar(24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(agent['name'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('Kod: ${agent['code']} • ${agent['region']}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        Text('Supervisor: ${agent['supervisor']}',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 11)),
                        const SizedBox(height: 4),
                        roleBadge,
                      ]),
                ),
                _statusBadge(),
              ]),
              const SizedBox(height: AppSpacing.sm),
              portfolioBadges,
              const Divider(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _stat('Buyurtmalar', '${agent['orders']}', Icons.shopping_cart),
                _stat(
                    'Sotuv',
                    '${((agent['sales'] ?? 0) / 1000000).toStringAsFixed(0)}M',
                    Icons.attach_money),
                _stat('Mijozlar', '${agent['customers']}', Icons.people),
                _stat('Reyting', '${agent['rating']}', Icons.star),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridCard() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.soft),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _avatar(28),
            const SizedBox(height: 10),
            Text(agent['name'] ?? '',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                textAlign: TextAlign.center),
            Text(agent['code'] ?? '',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            roleBadge,
            const SizedBox(height: 6),
            portfolioBadges,
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _mini('${agent['orders']}', 'Buyurtma'),
              _mini('${((agent['sales'] ?? 0) / 1000000).toStringAsFixed(0)}M',
                  'Sotuv'),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _avatar(double radius) {
    return Stack(children: [
      CircleAvatar(
        radius: radius,
        backgroundColor: _statusColor.withValues(alpha: 0.1),
        child: Text((agent['name'] ?? 'A').toString().substring(0, 1),
            style: TextStyle(
                color: _statusColor,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.75)),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: _statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2))),
      ),
    ]);
  }

  Widget _statusBadge() {
    final status = agent['status'] as String? ?? 'active';
    final text = status == 'active'
        ? 'Faol'
        : status == 'blocked'
            ? 'Bloklangan'
            : 'Nofaol';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: _statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(
              color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Column(children: [
      Icon(icon, size: 16, color: Colors.grey.shade500),
      const SizedBox(height: 2),
      Text(value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
    ]);
  }

  Widget _mini(String value, String label) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              color: _statusColor, fontWeight: FontWeight.bold, fontSize: 14)),
      Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 9)),
    ]);
  }
}
