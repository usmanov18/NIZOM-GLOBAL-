import 'package:flutter/material.dart';

import '../../../../shared/design/app_design_tokens.dart';
import '../../../../shared/utils/app_formatters.dart';
import '../../domain/entities/order_flow_entities.dart';

class CreateOrderConfirmStep extends StatelessWidget {
  final OrderCustomer? customer;
  final List<ConfirmCartItem> items;
  final String paymentName;
  final String warehouseName;
  final List<String> customerServiceWarehouseNames;
  final DateTime? deliveryDate;
  final String? deliveryTimeSlot;
  final double totalAmount;

  const CreateOrderConfirmStep({
    super.key,
    required this.customer,
    required this.items,
    required this.paymentName,
    required this.warehouseName,
    this.customerServiceWarehouseNames = const [],
    required this.deliveryDate,
    required this.deliveryTimeSlot,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('Mijoz', Icons.store, [
            _row('Nomi', customer?.name ?? ''),
            _row('Manzil', customer?.address ?? ''),
            _row('Telefon', customer?.phone ?? ''),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _section(
              'Mahsulotlar (${items.length} ta)',
              Icons.inventory_2,
              items
                  .map((item) => _row(item.productName,
                      '${item.quantity} x ${AppFormatters.money(item.price)} = ${AppFormatters.money(item.price * item.quantity)}'))
                  .toList()),
          const SizedBox(height: AppSpacing.lg),
          _section('To\'lov va sklad', Icons.payment, [
            _row('Sklad', warehouseName),
            if (customerServiceWarehouseNames.isNotEmpty)
              _row('Mijoz hududi skladlari',
                  customerServiceWarehouseNames.join(', ')),
            _row('Usuli', paymentName),
            _row(
                'Sana',
                deliveryDate != null
                    ? AppFormatters.date(deliveryDate!)
                    : 'Tanlanmagan'),
            _row('Vaqt', deliveryTimeSlot ?? 'Tanlanmagan'),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('JAMI TO\'LASH',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(AppFormatters.money(totalAmount),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ]),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class ConfirmCartItem {
  final String productName;
  final int quantity;
  final double price;

  const ConfirmCartItem(
      {required this.productName, required this.quantity, required this.price});
}
