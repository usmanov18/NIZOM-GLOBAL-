import 'package:flutter/material.dart';

class CreateOrderPaymentStep extends StatelessWidget {
  final String paymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;
  final Widget creditLimitBanner;
  final Widget warehouseServiceInfo;
  final Widget warehouseSelector;
  final DateTime? deliveryDate;
  final ValueChanged<DateTime> onDeliveryDateChanged;
  final String? deliveryTimeSlot;
  final ValueChanged<String?> onDeliveryTimeSlotChanged;
  final TextEditingController notesController;

  const CreateOrderPaymentStep({
    super.key,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    required this.creditLimitBanner,
    required this.warehouseServiceInfo,
    required this.warehouseSelector,
    required this.deliveryDate,
    required this.onDeliveryDateChanged,
    required this.deliveryTimeSlot,
    required this.onDeliveryTimeSlotChanged,
    required this.notesController,
  });

  static const _timeSlots = [
    '09:00 - 12:00',
    '12:00 - 15:00',
    '15:00 - 18:00',
    '18:00 - 21:00',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('To\'lov usuli',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _paymentOption(
              'cash', 'Naqd pul', Icons.money, const Color(0xFF2E7D32)),
          _paymentOption('card', 'Plastik karta', Icons.credit_card,
              const Color(0xFF1565C0)),
          _paymentOption('transfer', 'Bank o\'tkazmasi', Icons.account_balance,
              const Color(0xFFFF6F00)),
          _paymentOption('credit', 'Kredit (muddatli)', Icons.calendar_month,
              const Color(0xFF9C27B0)),
          creditLimitBanner,
          const SizedBox(height: 24),
          const Text('Yetkazib berish',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          warehouseServiceInfo,
          const SizedBox(height: 12),
          warehouseSelector,
          const SizedBox(height: 16),
          _dateSelector(context),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: deliveryTimeSlot,
            decoration: InputDecoration(
              labelText: 'Vaqt oralig\'i',
              prefixIcon: const Icon(Icons.access_time),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _timeSlots
                .map((slot) => DropdownMenuItem(value: slot, child: Text(slot)))
                .toList(),
            onChanged: onDeliveryTimeSlotChanged,
          ),
          const SizedBox(height: 24),
          const Text('Izohlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Qo\'shimcha ma\'lumotlar...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption(
      String value, String label, IconData icon, Color color) {
    final isSelected = paymentMethod == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: color, width: 2)
            : Border.all(color: Colors.grey.shade300),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: paymentMethod,
        onChanged: (v) {
          if (v != null) onPaymentMethodChanged(v);
        },
        title: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        activeColor: color,
      ),
    );
  }

  Widget _dateSelector(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) onDeliveryDateChanged(date);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF1565C0)),
            const SizedBox(width: 12),
            Text(
              deliveryDate != null
                  ? '${deliveryDate!.day}.${deliveryDate!.month}.${deliveryDate!.year}'
                  : 'Yetkazish sanasini tanlang',
              style: TextStyle(
                color:
                    deliveryDate != null ? Colors.black : Colors.grey.shade500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
