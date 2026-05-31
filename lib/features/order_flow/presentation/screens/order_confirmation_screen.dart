import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_flow_bloc.dart';
import '../../domain/entities/order_flow_entities.dart';

/// 4-BOSQICH: Buyurtmani tasdiqlash va yuborish
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  String _paymentMethod = 'credit';
  DateTime? _deliveryDate;
  String? _deliveryTimeSlot;
  final _notesController = TextEditingController();
  
  final List<String> _timeSlots = [
    '09:00 - 12:00',
    '12:00 - 15:00',
    '15:00 - 18:00',
    '18:00 - 21:00',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyurtmani tasdiqlash'),
      ),
      body: BlocConsumer<OrderFlowBloc, OrderFlowState>(
        listener: (context, state) {
          if (state is OrderCreatedSuccess) {
            // Buyurtma yaratildi, status sahifasiga o'tish
            Navigator.pushReplacementNamed(
              context,
              '/order-status',
              arguments: state.order,
            );
          }
          if (state is OrderFlowError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartUpdated) {
            return _buildContent(context, state);
          }
          if (state is OrderFlowLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Buyurtma yaratilmoqda...'),
                ],
              ),
            );
          }
          return const Center(child: Text('Savat bo\'sh'));
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CartUpdated cartState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mijoz ma'lumotlari
          _buildSection(
            'Mijoz',
            Icons.store,
            [
              _buildInfoRow('Nomi', cartState.customer.name),
              _buildInfoRow('Kod', cartState.customer.code),
              _buildInfoRow('Manzil', cartState.customer.address),
              _buildInfoRow('Telefon', cartState.customer.phone),
              if (cartState.customer.hasDebt)
                _buildInfoRow(
                  'Qarzdorlik',
                  '${_formatAmount(cartState.customer.currentDebt)} so\'m',
                  valueColor: Colors.red,
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Buyurtma elementlari
          _buildSection(
            'Mahsulotlar (${cartState.totalItems} ta)',
            Icons.inventory_2,
            cartState.cartItems.map((item) => _buildItemRow(item)).toList(),
          ),
          const SizedBox(height: 16),
          
          // To'lov usuli
          _buildSection(
            'To\'lov usuli',
            Icons.payment,
            [
              _buildPaymentOption('credit', 'Kredit (muddatli to\'lov)', Icons.credit_card),
              _buildPaymentOption('cash', 'Naqd pul', Icons.money),
              _buildPaymentOption('card', 'Plastik karta', Icons.credit_card),
              _buildPaymentOption('transfer', 'Bank o\'tkazmasi', Icons.account_balance),
            ],
          ),
          const SizedBox(height: 16),
          
          // Yetkazib berish
          _buildSection(
            'Yetkazib berish',
            Icons.local_shipping,
            [
              // Sana tanlash
              InkWell(
                onTap: _selectDeliveryDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _deliveryDate != null
                            ? '${_deliveryDate!.day}.${_deliveryDate!.month}.${_deliveryDate!.year}'
                            : 'Yetkazish sanasini tanlang',
                        style: TextStyle(
                          color: _deliveryDate != null
                              ? Colors.black
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Vaqt oralig'i
              DropdownButtonFormField<String>(
                value: _deliveryTimeSlot,
                decoration: InputDecoration(
                  labelText: 'Vaqt oralig\'i',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _timeSlots.map((slot) {
                  return DropdownMenuItem(value: slot, child: Text(slot));
                }).toList(),
                onChanged: (value) {
                  setState(() => _deliveryTimeSlot = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Izohlar
          _buildSection(
            'Izohlar',
            Icons.note,
            [
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Qo\'shimcha ma\'lumotlar...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Jami summa
          _buildTotalSection(cartState),
          const SizedBox(height: 24),
          
          // Tasdiqlash tugmasi
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _submitOrder(context),
              icon: const Icon(Icons.send, size: 22),
              label: const Text(
                'Buyurtmani yaratish va yuborish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF1565C0)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.productName,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              '${item.quantity} ${item.unitOfMeasure}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              '${_formatAmount(item.totalWithDiscount)} so\'m',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _paymentMethod,
      onChanged: (newValue) {
        setState(() => _paymentMethod = newValue!);
      },
      title: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      activeColor: const Color(0xFF1565C0),
    );
  }

  Widget _buildTotalSection(CartUpdated state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTotalRow('Mahsulotlar', '${state.totalItems} ta'),
          _buildTotalRow('Ortiqcha summa', '${_formatAmount(state.subtotal)} so\'m'),
          if (state.totalDiscount > 0)
            _buildTotalRow(
              'Chegirma',
              '- ${_formatAmount(state.totalDiscount)} so\'m',
            ),
          const Divider(color: Colors.white24, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'JAMI TO\'LASH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_formatAmount(state.totalAmount)} so\'m',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDeliveryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => _deliveryDate = date);
    }
  }

  void _submitOrder(BuildContext context) {
    context.read<OrderFlowBloc>().add(CreateOrder(
      paymentMethod: _paymentMethod,
      deliveryDate: _deliveryDate,
      deliveryTimeSlot: _deliveryTimeSlot,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    ));
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}
