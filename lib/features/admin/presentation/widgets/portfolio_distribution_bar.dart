import 'package:flutter/material.dart';
import '../../../../shared/utils/business_formatters.dart';

class PortfolioDistributionBar extends StatelessWidget {
  final Map<String, int> counts;
  final String selectedPortfolio;
  final ValueChanged<String> onSelected;

  const PortfolioDistributionBar({
    super.key,
    required this.counts,
    required this.selectedPortfolio,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: counts.entries.map((entry) {
          final color = BusinessFormatters.portfolioColor(entry.key);
          final selected = selectedPortfolio == entry.key;
          return GestureDetector(
            onTap: () => onSelected(selected ? 'all' : entry.key),
            child: Container(
              width: 132,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? color : color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(BusinessFormatters.portfolioShortName(entry.key),
                      style: TextStyle(
                          color: selected ? Colors.white : color,
                          fontWeight: FontWeight.bold)),
                  Text('${entry.value} profil',
                      style: TextStyle(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.85)
                              : Colors.grey.shade700,
                          fontSize: 12)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
