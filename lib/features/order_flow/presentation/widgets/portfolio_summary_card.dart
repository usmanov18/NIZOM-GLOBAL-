import 'package:flutter/material.dart';

import '../../../../shared/design/app_design_tokens.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final String id;
  final String shortName;
  final String title;
  final int skuCount;
  final bool selected;
  final VoidCallback? onTap;

  const PortfolioSummaryCard({
    super.key,
    required this.id,
    required this.shortName,
    required this.title,
    required this.skuCount,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.portfolio(id);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: selected ? 1 : 0.92),
              color.withValues(alpha: 0.70)
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(shortName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
                const Spacer(),
                Icon(selected ? Icons.check_circle : Icons.verified,
                    color: Colors.white, size: 17),
              ],
            ),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            Text('$skuCount SKU ruxsatli',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
