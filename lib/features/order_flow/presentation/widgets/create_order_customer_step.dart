import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../domain/entities/order_flow_entities.dart';
import 'order_customer_card.dart';

class CreateOrderCustomerStep extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final bool loading;
  final List<OrderCustomer> customers;
  final OrderCustomer? selectedCustomer;
  final void Function(OrderCustomer customer) onCustomerSelected;

  const CreateOrderCustomerStep({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.loading,
    required this.customers,
    required this.selectedCustomer,
    required this.onCustomerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mijozni tanlang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Mijoz qidirish...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear), onPressed: onClearSearch),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (loading) const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 8),
          if (customers.isEmpty)
            const AppEmptyState(
              icon: Icons.store_outlined,
              title: 'Mijoz topilmadi',
              message:
                  'Qidiruv shartlarini o‘zgartiring yoki mijoz biriktirilganini tekshiring.',
            )
          else
            ...customers.asMap().entries.map((entry) => OrderCustomerCard(
                  customer: entry.value,
                  index: entry.key,
                  selected: selectedCustomer?.id == entry.value.id,
                  onTap: () => onCustomerSelected(entry.value),
                )),
        ],
      ),
    );
  }
}
