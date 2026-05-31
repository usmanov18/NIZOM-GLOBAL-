import 'package:flutter/material.dart';
import '../../../../shared/utils/business_formatters.dart';

import '../../../../shared/design/app_design_tokens.dart';
import '../../../../shared/utils/app_formatters.dart';
import '../../domain/entities/order_catalog_product.dart';

class OrderProductCard extends StatelessWidget {
  final OrderCatalogProduct product;
  final int? quantity;
  final int stock;
  final bool canSell;
  final String? accessReason;
  final String? stockWarning;
  final String? pricingNote;
  final VoidCallback? onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const OrderProductCard({
    super.key,
    required this.product,
    this.quantity,
    required this.stock,
    required this.canSell,
    this.accessReason,
    this.stockWarning,
    this.pricingNote,
    this.onAdd,
    this.onIncrement,
    this.onDecrement,
  });

  bool get _inCart => quantity != null && quantity! > 0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: canSell ? 1 : 0.56,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _inCart
              ? AppColors.success.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: _inCart
              ? Border.all(color: AppColors.success.withValues(alpha: 0.3))
              : null,
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            _imageBox(),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _info()),
            _actions(),
          ],
        ),
      ),
    );
  }

  Widget _imageBox() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(Icons.inventory_2, color: Colors.grey.shade400),
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        Text('Kategoriya: ${product.category} • ${product.brand}',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 3),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _tag(product.source, AppColors.primary),
            _tag(BusinessFormatters.portfolioShortName(product.portfolioId),
                AppColors.teal),
            _tag(product.assortment, AppColors.warning),
          ],
        ),
        if (!canSell && accessReason != null) ...[
          const SizedBox(height: 3),
          Text(accessReason!,
              style: const TextStyle(
                  color: AppColors.danger,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ],
        if (stockWarning != null) ...[
          const SizedBox(height: 3),
          Text(stockWarning!,
              style: const TextStyle(
                  color: AppColors.warning,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ],
        if (pricingNote != null) ...[
          const SizedBox(height: 3),
          Text(pricingNote!,
              style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ],
        const SizedBox(height: 3),
        Row(
          children: [
            Text(AppFormatters.money(product.price),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(width: AppSpacing.sm),
            _tag('Omborda: $stock',
                stock > 0 ? AppColors.success : AppColors.danger),
          ],
        ),
      ],
    );
  }

  Widget _actions() {
    if (!_inCart) {
      return IconButton(
        icon: Icon(canSell && stock > 0 ? Icons.add_circle : Icons.lock_outline,
            color: canSell && stock > 0 ? AppColors.primary : Colors.grey),
        onPressed: canSell && stock > 0 ? onAdd : null,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onDecrement,
            iconSize: 22),
        Text('$quantity',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: canSell && quantity! < stock ? onIncrement : null,
            iconSize: 22),
      ],
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}
