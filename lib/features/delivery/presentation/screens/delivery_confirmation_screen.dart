import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/delivery_entities.dart';
import '../bloc/delivery_bloc.dart';

/// Yetkazib berish tasdig'i - Rasm, Imzo, To'lov, Qaytarish
class DeliveryConfirmationScreen extends StatefulWidget {
  final String deliveryId;
  final String orderNumber;
  final String customerName;
  final double totalAmount;

  const DeliveryConfirmationScreen({
    super.key,
    required this.deliveryId,
    required this.orderNumber,
    required this.customerName,
    required this.totalAmount,
  });

  @override
  State<DeliveryConfirmationScreen> createState() =>
      _DeliveryConfirmationScreenState();
}

class _DeliveryConfirmationScreenState
    extends State<DeliveryConfirmationScreen> {
  // Rasm
  final List<String> _photos = [];

  // Imzo
  bool _hasSignature = false;

  // Qabul qiluvchi
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();

  // To'lov
  double _collectedAmount = 0;
  String _paymentMethod = 'cash';

  // Qaytarish
  final List<_ReturnItem> _returnItems = [];
  bool _showReturnSection = false;

  // Izohlar
  final _notesController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeliveryBloc, DeliveryState>(
      listener: _onDeliveryState,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yetkazish tasdig\'i'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order info
              _buildOrderInfo(),
              const SizedBox(height: 16),

              // Rasmlar
              _buildPhotoSection(),
              const SizedBox(height: 16),

              // Imzo
              _buildSignatureSection(),
              const SizedBox(height: 16),

              // Qabul qiluvchi
              _buildRecipientSection(),
              const SizedBox(height: 16),

              // To'lov
              _buildPaymentSection(),
              const SizedBox(height: 16),

              // Qaytarish
              _buildReturnSection(),
              const SizedBox(height: 16),

              // Izohlar
              _buildNotesSection(),
              const SizedBox(height: 24),

              // Tasdiqlash tugmasi
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _confirmDelivery,
                  icon: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle, size: 24),
                  label: Text(
                      _submitting
                          ? 'Tasdiqlanmoqda...'
                          : 'Yetkazishni tasdiqlash',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.orderNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(widget.customerName,
                    style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
          Text(
            '${_formatAmount(widget.totalAmount)} so\'m',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.camera_alt, color: Color(0xFF1565C0)),
                  SizedBox(width: 8),
                  Text('Rasmlar',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _photos.length >= 3
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_photos.length}/3+',
                  style: TextStyle(
                    color: _photos.length >= 3
                        ? const Color(0xFF2E7D32)
                        : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Kamida 3 ta rasm oling (mahsulotlar, manzil, qabul qiluvchi)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 12),

          // Rasmlar grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._photos
                  .asMap()
                  .entries
                  .map((entry) => _buildPhotoItem(entry.key)),
              _buildAddPhotoButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image, color: Colors.grey),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _photos.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _takePhoto,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.3)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Color(0xFF1565C0)),
            SizedBox(height: 2),
            Text('Rasm',
                style: TextStyle(color: Color(0xFF1565C0), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.draw, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text('Imzo',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (!_hasSignature)
            InkWell(
              onTap: _takeSignature,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: Colors.grey.shade400, size: 32),
                    const SizedBox(height: 8),
                    Text('Imzo olish uchun bosing',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E7D32)),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text('Imzo olindi ✅',
                        style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecipientSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text('Qabul qiluvchi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _recipientNameController,
            decoration: InputDecoration(
              labelText: 'Ismi *',
              prefixIcon: const Icon(Icons.person_outline),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _recipientPhoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Telefon',
              prefixIcon: const Icon(Icons.phone),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text('To\'lov',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),

          // Jami summa
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jami summa:'),
                Text('${_formatAmount(widget.totalAmount)} so\'m',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // To'lov summasi
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Qabul qilingan summa',
              prefixIcon: const Icon(Icons.money),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (v) {
              setState(() => _collectedAmount = double.tryParse(v) ?? 0);
            },
          ),
          const SizedBox(height: 12),

          // To'lov usuli
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            decoration: InputDecoration(
              labelText: 'To\'lov usuli',
              prefixIcon: const Icon(Icons.credit_card),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Naqd pul')),
              DropdownMenuItem(value: 'card', child: Text('Plastik karta')),
              DropdownMenuItem(
                  value: 'transfer', child: Text('Bank o\'tkazmasi')),
            ],
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),

          // Qoldiq
          if (_collectedAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _collectedAmount >= widget.totalAmount
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                    : const Color(0xFFFF6F00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_collectedAmount >= widget.totalAmount
                      ? 'Qoldiq:'
                      : 'Kam qoldi:'),
                  Text(
                    '${_formatAmount((widget.totalAmount - _collectedAmount).abs())} so\'m',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _collectedAmount >= widget.totalAmount
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFFF6F00),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReturnSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.assignment_return, color: Color(0xFFFF6F00)),
                  SizedBox(width: 8),
                  Text('Qaytarish',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
              Switch(
                value: _showReturnSection,
                onChanged: (v) => setState(() => _showReturnSection = v),
                activeThumbColor: const Color(0xFFFF6F00),
              ),
            ],
          ),
          if (_showReturnSection) ...[
            const SizedBox(height: 12),
            Text('Qaytarilgan mahsulotlarni kiriting:',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 12),

            // Qaytarish elementlari
            ..._returnItems
                .asMap()
                .entries
                .map((entry) => _buildReturnItem(entry.key, entry.value)),

            // Qo'shish tugmasi
            OutlinedButton.icon(
              onPressed: _addReturnItem,
              icon: const Icon(Icons.add),
              label: const Text('Mahsulot qo\'shish'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6F00),
                side: const BorderSide(color: Color(0xFFFF6F00)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReturnItem(int index, _ReturnItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6F00).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: const Color(0xFFFF6F00).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
                Text('${item.quantity} dona • ${item.reason}',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => setState(() => _returnItems.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text('Izohlar',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Qo\'shimcha ma\'lumotlar...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _takePhoto() {
    setState(() => _photos.add('photo_${_photos.length + 1}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Rasm ${_photos.length} qo\'shildi'),
          backgroundColor: const Color(0xFF2E7D32)),
    );
  }

  void _takeSignature() {
    setState(() => _hasSignature = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Imzo olindi'), backgroundColor: Color(0xFF2E7D32)),
    );
  }

  void _addReturnItem() {
    setState(() {
      _returnItems.add(_ReturnItem(
        productName: 'Coca-Cola 1.5L',
        quantity: 2,
        reason: 'Nosoz',
      ));
    });
  }

  void _confirmDelivery() {
    if (_photos.length < 3) {
      _showSnack('Kamida 3 ta rasm oling', isError: true);
      return;
    }
    if (_recipientNameController.text.trim().isEmpty) {
      _showSnack('Qabul qiluvchi ismini kiriting', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yetkazishni tasdiqlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 48),
            const SizedBox(height: 16),
            Text('Buyurtma #${widget.orderNumber} yetkazildi'),
            Text('Qabul qiluvchi: ${_recipientNameController.text.trim()}'),
            if (_collectedAmount > 0)
              Text('To‘lov: ${_formatAmount(_collectedAmount)} so‘m'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _dispatchConfirm();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }

  void _dispatchConfirm() {
    final confirmation = DeliveryConfirmation(
      deliveryId: widget.deliveryId,
      orderId: widget.orderNumber,
      confirmedAt: DateTime.now(),
      latitude: 0,
      longitude: 0,
      accuracy: 'manual',
      photoPaths: List<String>.from(_photos),
      signaturePath: _hasSignature ? 'signature_${widget.deliveryId}' : null,
      recipientName: _recipientNameController.text.trim(),
      recipientPhone: _recipientPhoneController.text.trim().isEmpty
          ? null
          : _recipientPhoneController.text.trim(),
      collectedAmount: _collectedAmount,
      paymentMethod: _paymentMethod,
      returnedItems: _returnItems.map((item) => item.toEntity()).toList(),
      returnAmount:
          _returnItems.fold<double>(0, (sum, item) => sum + item.amount),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    setState(() => _submitting = true);
    context.read<DeliveryBloc>().add(DeliveryConfirmRequested(confirmation));
  }

  void _onDeliveryState(BuildContext context, DeliveryState state) {
    if (state is DeliveryLoading) {
      setState(() => _submitting = true);
    } else {
      if (_submitting) setState(() => _submitting = false);
    }

    if (state is DeliveryConfirmed) {
      _showSnack(
          'Yetkazish tasdiqlandi! 1C: ${state.syncedTo1C ? '✅' : '⏳'} SAP: ${state.syncedToSAP ? '✅' : '⏳'}');
      Navigator.pop(context);
    } else if (state is DeliveryError) {
      _showSnack(state.message, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF2E7D32)));
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}

class _ReturnItem {
  final String productName;
  final int quantity;
  final String reason;
  final double amount;

  _ReturnItem(
      {required this.productName, required this.quantity, required this.reason})
      : amount = 0;

  DeliveryReturnItem toEntity() {
    return DeliveryReturnItem(
      productId: productName,
      productCode: productName,
      productName: productName,
      quantity: quantity,
      reason: reason,
      condition: reason == 'Nosoz' ? 'damaged' : 'good',
      amount: amount,
    );
  }
}
