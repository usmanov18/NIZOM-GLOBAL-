import 'package:flutter/material.dart';

import '../../../order_sync/data/datasources/order_local_storage_service.dart';

/// Qaytarish - Local order storage asosida mahsulotlarni qaytarish.
class ReturnOrderScreen extends StatefulWidget {
  final String orderId;
  final String orderNumber;
  final String customerName;

  const ReturnOrderScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
  });

  @override
  State<ReturnOrderScreen> createState() => _ReturnOrderScreenState();
}

class _ReturnOrderScreenState extends State<ReturnOrderScreen> {
  final OrderLocalStorageService _storage = OrderLocalStorageService();
  final List<_ReturnItem> _items = [];
  final _notesController = TextEditingController();
  final List<String> _photos = [];
  late Future<Map<String, dynamic>> _orderFuture;
  String _returnReason = 'defective';

  final Map<String, String> _reasons = {
    'defective': 'Nosoz mahsulot',
    'expired': 'Muddati o‘tgan',
    'wrong_item': 'Noto‘g‘ri mahsulot',
    'overstock': 'Ortiqcha qoldiq',
    'customer_request': 'Mijoz so‘rovi',
    'damaged_transport': 'Transportda shikastlangan',
  };

  @override
  void initState() {
    super.initState();
    _orderFuture = _loadOrder();
  }

  Future<Map<String, dynamic>> _loadOrder() async {
    if (widget.orderId.trim().isEmpty) throw const FormatException('Buyurtma ID berilmagan');
    final order = await _storage.getOrder(widget.orderId);
    if (order == null) throw Exception('Buyurtma local storage ichida topilmadi');
    return order;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _orderFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text('Qaytarish')),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : snapshot.hasError || !snapshot.hasData
                  ? _emptyState(Icons.assignment_return_outlined, 'Qaytarish yuklanmadi', snapshot.error?.toString() ?? 'Buyurtma topilmadi')
                  : _buildForm(snapshot.data!),
        );
      },
    );
  }

  Widget _buildForm(Map<String, dynamic> order) {
    final orderItems = _orderItems(order);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderInfo(order),
          const SizedBox(height: 16),
          _buildReasonSection(),
          const SizedBox(height: 16),
          _buildProductsSection(orderItems),
          const SizedBox(height: 16),
          _buildPhotoSection(),
          const SizedBox(height: 16),
          _buildNotesSection(),
          const SizedBox(height: 16),
          if (_items.isNotEmpty) _buildTotalSection(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _items.isNotEmpty ? () => _submitReturn(order) : null,
              icon: const Icon(Icons.assignment_return, size: 24),
              label: const Text('Qaytarishni yuborish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F00),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(Map<String, dynamic> order) {
    final number = widget.orderNumber.isNotEmpty ? widget.orderNumber : (order['orderNumber'] ?? order['order_number'] ?? '').toString();
    final customer = widget.customerName.isNotEmpty ? widget.customerName : (order['customerName'] ?? order['customer_name'] ?? '').toString();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6F00).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6F00).withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.assignment_return, color: Color(0xFFFF6F00), size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(number.isEmpty ? widget.orderId : number, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(customer.isEmpty ? 'Mijoz ko‘rsatilmagan' : customer, style: TextStyle(color: Colors.grey.shade700)),
        ])),
      ]),
    );
  }

  Widget _buildReasonSection() {
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.help_outline, color: Color(0xFFFF6F00)), SizedBox(width: 8), Text('Qaytarish sababi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _reasons.entries.map((entry) {
            final isSelected = _returnReason == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => setState(() => _returnReason = entry.key),
              selectedColor: const Color(0xFFFF6F00).withOpacity(0.2),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _buildProductsSection(List<_OrderItemView> orderItems) {
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [Icon(Icons.inventory_2, color: Color(0xFFFF6F00)), SizedBox(width: 8), Text('Mahsulotlar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))]),
          Text('${_items.length} ta tanlandi', style: const TextStyle(color: Color(0xFFFF6F00), fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        if (orderItems.isEmpty)
          Text('Buyurtmada mahsulotlar topilmadi', style: TextStyle(color: Colors.grey.shade600))
        else
          ...orderItems.map(_buildProductItem),
      ]),
    );
  }

  Widget _buildProductItem(_OrderItemView item) {
    final matches = _items.where((returnItem) => returnItem.productId == item.id);
    final existingItem = matches.isEmpty ? null : matches.first;
    final isSelected = existingItem != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF6F00).withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: const Color(0xFFFF6F00).withOpacity(0.3)) : null,
      ),
      child: Row(children: [
        Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _items.add(_ReturnItem(productId: item.id, productName: item.name, quantity: 1, maxQuantity: item.quantity, price: item.price));
              } else {
                _items.removeWhere((returnItem) => returnItem.productId == item.id);
              }
            });
          },
          activeColor: const Color(0xFFFF6F00),
        ),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          Text('${item.quantity} dona • ${_formatAmount(item.price)} so‘m', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ])),
        if (isSelected)
          Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                setState(() {
                  if (existingItem.quantity > 1) {
                    existingItem.quantity--;
                  } else {
                    _items.removeWhere((returnItem) => returnItem.productId == item.id);
                  }
                });
              },
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            SizedBox(width: 36, child: Text('${existingItem.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF6F00)),
              onPressed: () {
                setState(() {
                  if (existingItem.quantity < item.quantity) existingItem.quantity++;
                });
              },
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
      ]),
    );
  }

  Widget _buildPhotoSection() {
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.camera_alt, color: Color(0xFFFF6F00)), SizedBox(width: 8), Text('Rasmlar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))]),
        const SizedBox(height: 8),
        Text('Nosoz mahsulotlar rasmini oling', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [..._photos.asMap().entries.map((entry) => _buildPhotoItem(entry.key)), _buildAddPhotoButton()]),
      ]),
    );
  }

  Widget _buildPhotoItem(int index) {
    return Stack(children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)),
      Positioned(
        top: 4,
        right: 4,
        child: GestureDetector(
          onTap: () => setState(() => _photos.removeAt(index)),
          child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 14)),
        ),
      ),
    ]);
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: () => setState(() => _photos.add('photo_${_photos.length}')),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(color: const Color(0xFFFF6F00).withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFF6F00).withOpacity(0.3))),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: Color(0xFFFF6F00)), SizedBox(height: 2), Text('Rasm', style: TextStyle(color: Color(0xFFFF6F00), fontSize: 10))]),
      ),
    );
  }

  Widget _buildNotesSection() {
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.note, color: Color(0xFFFF6F00)), SizedBox(width: 8), Text('Izohlar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))]),
        const SizedBox(height: 12),
        TextField(controller: _notesController, maxLines: 3, decoration: InputDecoration(hintText: 'Qo‘shimcha ma’lumotlar...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
      ]),
    );
  }

  Widget _buildTotalSection() {
    final totalAmount = _items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFF6F00).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFF6F00).withOpacity(0.3))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_items.length} ta mahsulot', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          Text('${_items.fold(0, (sum, item) => sum + item.quantity)} dona', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
        Text('${_formatAmount(totalAmount)} so‘m', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFFF6F00))),
      ]),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)]),
      child: child,
    );
  }

  void _submitReturn(Map<String, dynamic> order) {
    if (_items.isEmpty) {
      _showSnack('Kamida bitta mahsulot tanlang', isError: true);
      return;
    }
    final updated = {
      ...order,
      'returnReason': _returnReason,
      'returnNotes': _notesController.text.trim(),
      'returnPhotos': List<String>.from(_photos),
      'returnItems': _items.map((item) => item.toJson()).toList(),
      'returnAmount': _items.fold<double>(0, (sum, item) => sum + item.price * item.quantity),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qaytarishni tasdiqlash'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.assignment_return, color: Color(0xFFFF6F00), size: 48),
          const SizedBox(height: 16),
          Text('${_items.length} ta mahsulot qaytariladi'),
          Text('Sabab: ${_reasons[_returnReason]}'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _storage.saveOrder(updated);
              if (!mounted) return;
              Navigator.pop(context);
              _showSnack('Qaytarish local storagega saqlandi');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6F00)),
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }

  List<_OrderItemView> _orderItems(Map<String, dynamic> order) {
    final rawItems = order['items'] as List? ?? const [];
    return rawItems.whereType<Map>().map((item) {
      return _OrderItemView(
        id: (item['productId'] ?? item['product_id'] ?? item['id'] ?? '').toString(),
        name: (item['productName'] ?? item['product_name'] ?? item['name'] ?? '').toString(),
        quantity: (item['quantity'] ?? 0).toInt(),
        price: (item['unitPrice'] ?? item['unit_price'] ?? item['price'] ?? 0).toDouble(),
      );
    }).where((item) => item.id.isNotEmpty).toList();
  }

  Widget _emptyState(IconData icon, String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 56, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
        ]),
      ),
    );
  }

  String _formatAmount(num amount) => amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : const Color(0xFFFF6F00)));
  }
}

class _OrderItemView {
  final String id;
  final String name;
  final int quantity;
  final double price;

  const _OrderItemView({required this.id, required this.name, required this.quantity, required this.price});
}

class _ReturnItem {
  final String productId;
  final String productName;
  int quantity;
  final int maxQuantity;
  final double price;

  _ReturnItem({required this.productId, required this.productName, required this.quantity, required this.maxQuantity, required this.price});

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'price': price,
      };
}
