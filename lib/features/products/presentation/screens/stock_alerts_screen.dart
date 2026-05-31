import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/product_entities.dart';
import '../../domain/repositories/product_repository.dart';

/// Ombor ogohlantirishlari — ProductRepository stock data asosida.
class StockAlertsScreen extends StatefulWidget {
  const StockAlertsScreen({super.key});

  @override
  State<StockAlertsScreen> createState() => _StockAlertsScreenState();
}

class _StockAlertsScreenState extends State<StockAlertsScreen> {
  late Future<List<StockItem>> _future;
  bool _pushEnabled = true;
  bool _lowStockEnabled = true;
  bool _outOfStockEnabled = true;

  ProductRepository get _repository => getIt<ProductRepository>();

  @override
  void initState() {
    super.initState();
    _future = _loadAlerts();
  }

  Future<List<StockItem>> _loadAlerts() async {
    final result = await _repository.getStockBalance(lowStock: true);
    return result.fold((failure) => throw Exception(failure.message), (items) {
      return items
          .where((item) => item.isLowStock || item.isOutOfStock)
          .toList();
    });
  }

  void _reload() {
    setState(() => _future = _loadAlerts());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StockItem>>(
      future: _future,
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? const <StockItem>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ombor ogohlantirishlari'),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
              IconButton(
                  icon: const Icon(Icons.settings), onPressed: _showSettings),
            ],
          ),
          body: _buildBody(snapshot, alerts),
        );
      },
    );
  }

  Widget _buildBody(
      AsyncSnapshot<List<StockItem>> snapshot, List<StockItem> alerts) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return _emptyState(
        icon: Icons.error_outline,
        title: 'Ombor ogohlantirishlari yuklanmadi',
        message: snapshot.error.toString(),
        action: ElevatedButton.icon(
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
          label: const Text('Qayta yuklash'),
        ),
      );
    }

    return Column(
      children: [
        _buildStats(alerts),
        Expanded(
          child: alerts.isEmpty
              ? _emptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Ogohlantirish yo‘q',
                  message: 'Kam yoki tugagan qoldiq topilmadi.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) =>
                      _buildAlertCard(alerts[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildStats(List<StockItem> alerts) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFC62828).withValues(alpha: 0.05),
      child: Row(
        children: [
          _statItem(
              'Ogohlantirish', '${alerts.length}', const Color(0xFFC62828)),
          _statItem(
              'Tugadi',
              '${alerts.where((item) => item.isOutOfStock).length}',
              const Color(0xFFC62828)),
          _statItem(
              'Kam',
              '${alerts.where((item) => item.isLowStock && !item.isOutOfStock).length}',
              const Color(0xFFFF6F00)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 20)),
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(StockItem alert) {
    final isOut = alert.isOutOfStock;
    final color = isOut ? const Color(0xFFC62828) : const Color(0xFFFF6F00);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(isOut ? Icons.warning : Icons.info_outline,
                  color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.productName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('${alert.productCode} • ${alert.warehouseName}',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  Text('Yangilangan: ${_formatDate(alert.lastUpdated)}',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_formatQty(alert.available)} ${alert.unitOfMeasure}',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('Jami: ${_formatQty(alert.quantity)}',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ogohlantirish sozlamalari',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Push bildirishnoma'),
                value: _pushEnabled,
                onChanged: (value) => setModalState(() => _pushEnabled = value),
                activeThumbColor: const Color(0xFF1565C0),
              ),
              SwitchListTile(
                title: const Text('Kam qoldiq ogohlantirish'),
                value: _lowStockEnabled,
                onChanged: (value) =>
                    setModalState(() => _lowStockEnabled = value),
                activeThumbColor: const Color(0xFF1565C0),
              ),
              SwitchListTile(
                title: const Text('Tugadi ogohlantirish'),
                value: _outOfStockEnabled,
                onChanged: (value) =>
                    setModalState(() => _outOfStockEnabled = value),
                activeThumbColor: const Color(0xFF1565C0),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text('Saqlash'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }

  String _formatQty(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
