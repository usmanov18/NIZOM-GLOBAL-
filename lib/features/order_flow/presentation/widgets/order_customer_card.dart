import 'package:flutter/material.dart';

import '../../../../shared/design/app_design_tokens.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../domain/entities/order_flow_entities.dart';

class OrderCustomerCard extends StatelessWidget {
  final OrderCustomer customer;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const OrderCustomerCard({
    super.key,
    required this.customer,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDebt = customer.hasDebt;
    final statusColor = selected
        ? AppColors.primary
        : hasDebt
            ? AppColors.danger
            : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color:
            selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border:
            selected ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: AppShadows.soft,
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Text(
            'M${index + 1}',
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(customer.name,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.address,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                AppStatusBadge.info(customer.code,
                    icon: Icons.tag, compact: true),
                if (hasDebt)
                  AppStatusBadge.danger('Qarzdor',
                      icon: Icons.money_off, compact: true),
                if (!customer.isActive)
                  AppStatusBadge.warning('Nofaol',
                      icon: Icons.pause_circle, compact: true),
                if (customer.isBlocked)
                  AppStatusBadge.danger('Bloklangan',
                      icon: Icons.block, compact: true),
              ],
            ),
          ],
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
