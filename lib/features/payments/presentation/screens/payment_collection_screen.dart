import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/payment/models/payment_models.dart';
import '../../../../core/services/payment/payment_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../customers/domain/entities/customer_sync_entities.dart';
import '../../../customers/domain/repositories/customer_repository.dart';

/// To'lov qabul qilish — PaymentService va CustomerRepository asosida.
class PaymentCollectionScreen extends StatefulWidget {
  const PaymentCollectionScreen({super.key});

  @override
  State<PaymentCollectionScreen> createState() =>
      _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen> {
  SyncedCustomer? _selectedCustomer;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late Future<List<SyncedCustomer>> _customersFuture;
  bool _receiptPhotoRequired = true;
  bool _signatureRequired = true;
  bool _submitting = false;

  CustomerRepository get _customerRepository => getIt<CustomerRepository>();
  PaymentService get _paymentService => getIt<PaymentService>();

  @override
  void initState() {
    super.initState();
    _customersFuture = _loadCustomers();
  }

  Future<List<SyncedCustomer>> _loadCustomers() async {
    final auth = await getIt<AuthRepository>().getCurrentUser();
    final user = auth.fold((_) => null, (value) => value);
    final result = await _customerRepository.getAgentCustomers(
        agentId: user?.id ?? user?.code ?? 'current',
        hasDebt: true,
        limit: 100);
    return result.fold(
        (failure) => throw Exception(failure.message), (items) => items);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SyncedCustomer>>(
      future: _customersFuture,
      builder: (context, snapshot) {
        final customers = snapshot.data ?? const <SyncedCustomer>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text('To‘lov qabul qilish'),
            actions: [
              IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () => context.push('/customers/debt'),
                  tooltip: 'Tarix'),
              IconButton(
                  icon: const Icon(Icons.refresh), onPressed: _reloadCustomers),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : snapshot.hasError
                  ? _emptyState(Icons.error_outline, 'Mijozlar yuklanmadi',
                      snapshot.error.toString())
                  : _buildForm(customers),
        );
      },
    );
  }

  Widget _buildForm(List<SyncedCustomer> customers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(customers),
          const SizedBox(height: 20),
          _buildSection('Mijoz tanlash', Icons.store, [
            DropdownButtonFormField<String>(
              initialValue: _selectedCustomer?.id,
              decoration: InputDecoration(
                hintText: 'Mijozni tanlang',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: customers
                  .map((customer) => DropdownMenuItem(
                      value: customer.id, child: Text(customer.name)))
                  .toList(),
              onChanged: (id) {
                setState(() {
                  _selectedCustomer = customers
                      .where((customer) => customer.id == id)
                      .cast<SyncedCustomer?>()
                      .firstOrNull;
                  if (_selectedCustomer != null &&
                      _amountController.text.isEmpty) {
                    _amountController.text =
                        _selectedCustomer!.currentDebt.toStringAsFixed(0);
                  }
                });
              },
            ),
            if (_selectedCustomer != null) ...[
              const SizedBox(height: 12),
              _buildCustomerDebt(_selectedCustomer!),
            ],
          ]),
          const SizedBox(height: 16),
          _buildSection('To‘lov summasi', Icons.money, [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Summani kiriting',
                prefixText: 'so‘m  ',
                prefixStyle: const TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickAmountButton('100,000'),
                _quickAmountButton('500,000'),
                _quickAmountButton('1,000,000'),
                _quickAmountButton('5,000,000'),
                _quickAmountButton('10,000,000'),
                _quickAmountButton('To‘liq summa'),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection('To‘lov usuli', Icons.payment, [
            _paymentMethodTile(PaymentMethod.cash, 'Naqd pul', Icons.money,
                const Color(0xFF2E7D32)),
            _paymentMethodTile(PaymentMethod.card, 'Plastik karta',
                Icons.credit_card, const Color(0xFF1565C0)),
            _paymentMethodTile(PaymentMethod.transfer, 'Bank o‘tkazmasi',
                Icons.account_balance, const Color(0xFFFF6F00)),
            _paymentMethodTile(PaymentMethod.payme, 'Payme',
                Icons.phone_android, const Color(0xFF00A6D6)),
            _paymentMethodTile(PaymentMethod.click, 'Click', Icons.touch_app,
                const Color(0xFF6A1B9A)),
          ]),
          const SizedBox(height: 16),
          _buildSection('Izohlar', Icons.note, [
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Qo‘shimcha ma’lumot...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection('Chek', Icons.receipt, [
            SwitchListTile(
              title: const Text('Chek rasmga olish'),
              subtitle: const Text('To‘lov chekini suratga oling'),
              value: _receiptPhotoRequired,
              onChanged: (value) =>
                  setState(() => _receiptPhotoRequired = value),
              activeThumbColor: const Color(0xFF1565C0),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Imzo olish'),
              subtitle: const Text('Mijoz imzosini oling'),
              value: _signatureRequired,
              onChanged: (value) => setState(() => _signatureRequired = value),
              activeThumbColor: const Color(0xFF1565C0),
              contentPadding: EdgeInsets.zero,
            ),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Rasm olish'))),
                const SizedBox(width: 12),
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: _takeSignature,
                        icon: const Icon(Icons.draw),
                        label: const Text('Imzo'))),
              ],
            ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submitPayment,
              icon: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle, size: 24),
              label: Text(
                  _submitting ? 'Yuborilmoqda...' : 'To‘lovni qabul qilish',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _reloadCustomers() {
    setState(() => _customersFuture = _loadCustomers());
  }

  Widget _buildQuickStats(List<SyncedCustomer> customers) {
    final totalDebt = customers.fold<double>(
        0, (sum, customer) => sum + customer.currentDebt);
    return Row(
      children: [
        Expanded(
            child: _statCard(
                'Tanlangan',
                _selectedCustomer == null
                    ? '0'
                    : _formatAmount(_selectedCustomer!.currentDebt),
                const Color(0xFF2E7D32))),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard('Umumiy qarz', _formatAmount(totalDebt),
                const Color(0xFFC62828))),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style:
                TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
        const SizedBox(height: 4),
        Text('$value so‘m',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 20),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
        ]),
        const Divider(height: 20),
        ...children,
      ]),
    );
  }

  Widget _buildCustomerDebt(SyncedCustomer customer) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFC62828).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFFC62828).withValues(alpha: 0.3))),
      child: Row(children: [
        const Icon(Icons.warning, color: Color(0xFFC62828), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Qarzdorlik',
                style: TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            Text(
                '${_formatAmount(customer.currentDebt)} ${customer.currency} • ${customer.totalOrders} ta buyurtma',
                style: TextStyle(
                    color: const Color(0xFFC62828).withValues(alpha: 0.7),
                    fontSize: 12)),
          ]),
        ),
        TextButton(
            onPressed: () => context.push('/customers/debt'),
            child: const Text('Batafsil')),
      ]),
    );
  }

  Widget _quickAmountButton(String amount) {
    return ActionChip(
      label: Text(amount, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        if (amount == 'To‘liq summa' && _selectedCustomer != null) {
          _amountController.text =
              _selectedCustomer!.currentDebt.toStringAsFixed(0);
          return;
        }
        _amountController.text = amount.replaceAll(',', '').replaceAll(' ', '');
      },
      backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: Color(0xFF1565C0)),
    );
  }

  Widget _paymentMethodTile(
      PaymentMethod value, String title, IconData icon, Color color) {
    return RadioListTile<PaymentMethod>(
      value: value,
      groupValue: _paymentMethod,
      onChanged: (method) =>
          setState(() => _paymentMethod = method ?? _paymentMethod),
      title: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 14))
      ]),
      activeColor: const Color(0xFF1565C0),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _takePhoto() => _showSnack('Kamera ochildi');
  void _takeSignature() => _showSnack('Imzo olish oynasi');

  Future<void> _submitPayment() async {
    final customer = _selectedCustomer;
    if (customer == null) {
      _showSnack('Mijozni tanlang', isError: true);
      return;
    }
    final amount = double.tryParse(
        _amountController.text.replaceAll(' ', '').replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      _showSnack('Summani to‘g‘ri kiriting', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('To‘lovni tasdiqlash'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Mijoz: ${customer.name}'),
          Text('Summa: ${_formatAmount(amount)} ${customer.currency}',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Usul: ${_paymentMethod.name}'),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Bekor qilish')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tasdiqlash')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    final auth = await getIt<AuthRepository>().getCurrentUser();
    final user = auth.fold((_) => null, (value) => value);
    final result = await _paymentService.createPayment(
      orderId: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'MANUAL-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customer.id,
      customerName: customer.name,
      amount: amount,
      method: _paymentMethod,
      agentId: user?.id ?? 'current',
      agentName: user?.name ?? 'Agent',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold(
      (failure) => _showSnack(failure.message, isError: true),
      (payment) {
        _showSnack(
            'To‘lov qabul qilindi: ${payment.transactionId ?? payment.id}');
        Navigator.pop(context);
      },
    );
  }

  Widget _emptyState(IconData icon, String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 56, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600)),
        ]),
      ),
    );
  }

  String _formatAmount(num amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF2E7D32)));
  }
}
