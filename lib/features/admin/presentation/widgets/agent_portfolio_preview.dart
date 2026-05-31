import 'package:flutter/material.dart';
import '../../../../shared/utils/business_formatters.dart';

class AgentPortfolioPreview extends StatelessWidget {
  final List<String> portfolioIds;
  final bool canSellOutsidePortfolio;
  final bool canEdit;
  final VoidCallback? onEdit;

  const AgentPortfolioPreview({
    super.key,
    required this.portfolioIds,
    required this.canSellOutsidePortfolio,
    this.canEdit = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2, color: Color(0xFF1565C0)),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _badges(context),
              if (canSellOutsidePortfolio)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Portfeldan tashqari sotishga ruxsat bor',
                      style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32))),
                ),
            ]),
          ),
          if (canEdit)
            TextButton(onPressed: onEdit, child: const Text('Sozlash')),
        ],
      ),
    );
  }

  Widget _badges(BuildContext context) {
    if (portfolioIds.isEmpty) {
      return Text('Portfel yo‘q',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11));
    }
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: portfolioIds.map((id) {
        final color = BusinessFormatters.portfolioColor(id);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Text(BusinessFormatters.portfolioShortName(id),
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        );
      }).toList(),
    );
  }
}
