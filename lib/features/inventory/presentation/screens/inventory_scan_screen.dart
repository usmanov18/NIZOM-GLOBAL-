import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Inventarizatsiya - Barcode skanerlash va miqdor kiritish
class InventoryScanScreen extends StatefulWidget {
  const InventoryScanScreen({super.key});

  @override
  State<InventoryScanScreen> createState() => _InventoryScanScreenState();
}

class _InventoryScanScreenState extends State<InventoryScanScreen> {
  final List<_InventoryScanItem> _scannedItems = [];
  int _totalItems = 0;

  int get _countedItems => _scannedItems.length;

  @override
  Widget build(BuildContext context) {
    _totalItems = _totalItems < _countedItems ? _countedItems : _totalItems;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventarizatsiya'),
        actions: [
          IconButton(
              icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode),
          IconButton(
              icon: const Icon(Icons.check), onPressed: _submitInventory),
        ],
      ),
      body: Column(
        children: [
          _buildProgress(),
          Expanded(
              child: _scannedItems.isEmpty
                  ? _buildEmptyState()
                  : _buildScannedList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanBarcode,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Skanerlash'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  Widget _buildProgress() {
    final progress = _totalItems > 0 ? _countedItems / _totalItems : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$_countedItems / $_totalItems',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1565C0))),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF1565C0))),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
                'Mos: ${_scannedItems.where((i) => i.status == InventoryScanStatus.match).length}',
                style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 12)),
            Text(
                'Ortiqcha: ${_scannedItems.where((i) => i.status == InventoryScanStatus.surplus).length}',
                style: const TextStyle(color: Color(0xFFFF6F00), fontSize: 12)),
            Text(
                'Kam: ${_scannedItems.where((i) => i.status == InventoryScanStatus.shortage).length}',
                style: const TextStyle(color: Color(0xFFC62828), fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text('Barcode skanerlang',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        const SizedBox(height: 8),
        Text('Mahsulot barcode ini kameraga qarating',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
      ]),
    );
  }

  Widget _buildScannedList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scannedItems.length,
      itemBuilder: (context, index) => _buildScannedItem(_scannedItems[index]),
    );
  }

  Widget _buildScannedItem(_InventoryScanItem item) {
    final statusColor = switch (item.status) {
      InventoryScanStatus.match => const Color(0xFF2E7D32),
      InventoryScanStatus.surplus => const Color(0xFFFF6F00),
      InventoryScanStatus.shortage => const Color(0xFFC62828),
      InventoryScanStatus.unchecked => Colors.grey,
    };
    final statusText = switch (item.status) {
      InventoryScanStatus.match => 'Mos',
      InventoryScanStatus.surplus => 'Ortiqcha',
      InventoryScanStatus.shortage => 'Kam',
      InventoryScanStatus.unchecked => 'Tekshirilmagan',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: statusColor.withValues(alpha: 0.3))),
      child: Row(children: [
        Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.inventory_2, color: statusColor, size: 20)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          Text('Kod: ${item.code} • Barcode: ${item.barcode}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${_formatQty(item.systemQty)} → ${_formatQty(item.actualQty)}',
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          Text(statusText, style: TextStyle(color: statusColor, fontSize: 10)),
        ]),
      ]),
    );
  }

  Future<void> _scanBarcode() async {
    final result = await context
        .push<Map<String, dynamic>>('/products/barcode?purpose=inventory');
    if (!mounted || result == null) return;
    final item = _InventoryScanItem.fromScan(result);
    final existingIndex =
        _scannedItems.indexWhere((scan) => scan.barcode == item.barcode);
    setState(() {
      if (existingIndex >= 0) {
        final existing = _scannedItems[existingIndex];
        _scannedItems[existingIndex] =
            existing.copyWith(actualQty: existing.actualQty + 1);
      } else {
        _scannedItems.add(item);
      }
      _totalItems = _totalItems < _scannedItems.length
          ? _scannedItems.length
          : _totalItems;
    });
  }

  void _submitInventory() {
    if (_scannedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Avval mahsulot skanerlang'),
          backgroundColor: Colors.red));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inventarizatsiyani yakunlash'),
        content: Text('$_countedItems ta mahsulot sanaldi. Yakunlaysizmi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Yakunlash'),
          ),
        ],
      ),
    );
  }

  String _formatQty(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}

enum InventoryScanStatus { match, surplus, shortage, unchecked }

class _InventoryScanItem {
  final String name;
  final String code;
  final String barcode;
  final double systemQty;
  final double actualQty;

  const _InventoryScanItem({
    required this.name,
    required this.code,
    required this.barcode,
    required this.systemQty,
    required this.actualQty,
  });

  InventoryScanStatus get status {
    if (actualQty == systemQty) return InventoryScanStatus.match;
    if (actualQty > systemQty) return InventoryScanStatus.surplus;
    if (actualQty < systemQty) return InventoryScanStatus.shortage;
    return InventoryScanStatus.unchecked;
  }

  _InventoryScanItem copyWith({double? actualQty}) {
    return _InventoryScanItem(
        name: name,
        code: code,
        barcode: barcode,
        systemQty: systemQty,
        actualQty: actualQty ?? this.actualQty);
  }

  factory _InventoryScanItem.fromScan(Map<String, dynamic> data) {
    final stock = (data['stock'] is num)
        ? (data['stock'] as num).toDouble()
        : double.tryParse(data['stock']?.toString() ?? '') ?? 0;
    return _InventoryScanItem(
      name: (data['name'] ?? 'Barcode: ${data['barcode'] ?? ''}').toString(),
      code: (data['code'] ?? '').toString(),
      barcode: (data['barcode'] ?? '').toString(),
      systemQty: stock,
      actualQty: 1,
    );
  }
}
