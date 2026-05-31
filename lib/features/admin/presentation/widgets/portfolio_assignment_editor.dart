import 'package:flutter/material.dart';

import '../../../products/domain/entities/product_portfolio.dart';

class PortfolioAssignmentEditor extends StatelessWidget {
  final List<ProductPortfolio> portfolios;
  final Set<String> selectedPortfolioIds;
  final ValueChanged<Set<String>> onChanged;
  final bool canSellOutsidePortfolio;
  final ValueChanged<bool> onOutsideChanged;

  const PortfolioAssignmentEditor({
    super.key,
    required this.portfolios,
    required this.selectedPortfolioIds,
    required this.onChanged,
    required this.canSellOutsidePortfolio,
    required this.onOutsideChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Portfolio va assortiment ruxsatlari',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...portfolios.map((portfolio) {
          final selected = selectedPortfolioIds.contains(portfolio.id);
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: selected,
            title: Text(portfolio.name),
            subtitle: Text(
                '${portfolio.sourceSystem.name.toUpperCase()} • ${portfolio.assortmentType.name} • ${portfolio.productIds.length} SKU'),
            onChanged: (value) {
              final next = {...selectedPortfolioIds};
              if (value == true) {
                next.add(portfolio.id);
              } else {
                next.remove(portfolio.id);
              }
              onChanged(next);
            },
          );
        }),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: canSellOutsidePortfolio,
          title: const Text('Portfeldan tashqari sotishga ruxsat'),
          subtitle: const Text('Faqat alohida holatlarda yoqing'),
          onChanged: onOutsideChanged,
        ),
      ],
    );
  }
}
