import 'package:flutter/material.dart';

import '../../data/datasources/order_local_storage_service.dart';

/// 1C va SAP dagi buyurtmalarni solishtirish — local sync storage asosida.
class OrderComparisonScreen extends StatefulWidget {
  const OrderComparisonScreen({super.key});

  @override
  State<OrderComparisonScreen> createState() => _OrderComparisonScreenState();
}

class _OrderComparisonScreenState extends State<OrderComparisonScreen> {
  final OrderLocalStorageService _storage = OrderLocalStorageService();
  late Future<List<_OrderComparisonView>> _future;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _future = _loadComparisons();
  }

  Future<List<_OrderComparisonView>> _loadComparisons() async {
    final orders = await _storage.getAllOrders();
    return orders.map(_OrderComparisonView.fromLocalOrder).toList();
  }

  void _reload() {
    setState(() => _future = _loadComparisons());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_OrderComparisonView>>(
      future: _future,
      builder: (context, snapshot) {
        final orders = snapshot.data ?? const <_OrderComparisonView>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Buyurtmalar solishtirish'),
            actions: [
              IconButton(icon: const Icon(Icons.sync), onPressed: _syncAll),
              IconButton(
                  icon: const Icon(Icons.compare_arrows), onPressed: _reload),
            ],
          ),
          body: _buildBody(snapshot, orders),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<List<_OrderComparisonView>> snapshot,
      List<_OrderComparisonView> orders) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return _emptyState(
        icon: Icons.error_outline,
        title: 'Solishtirish yuklanmadi',
        message: snapshot.error.toString(),
        action: ElevatedButton.icon(
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
          label: const Text('Qayta yuklash'),
        ),
      );
    }

    final filtered = _filteredOrders(orders);
    return Column(
      children: [
        _buildStats(orders),
        _buildFilterChips(),
        Expanded(
          child: filtered.isEmpty
              ? _emptyState(
                  icon: Icons.compare_arrows,
                  title: 'Solishtirish ma’lumoti yo‘q',
                  message:
                      'Local saqlangan buyurtmalar topilmadi yoki tanlangan filter bo‘yicha ma’lumot yo‘q.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildOrderCard(filtered[index]),
                ),
        ),
      ],
    );
  }

  List<_OrderComparisonView> _filteredOrders(
      List<_OrderComparisonView> orders) {
    return orders.where((order) {
      switch (_filterStatus) {
        case 'synced':
          return order.isSynced;
        case 'different':
          return order.hasDifference;
        case 'unsynced':
          return !order.isSynced;
        case 'all':
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildStats(List<_OrderComparisonView> orders) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _statChip(
              'Sinxronlangan',
              '${orders.where((order) => order.isSynced).length}',
              const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          _statChip(
              'Farqli',
              '${orders.where((order) => order.hasDifference).length}',
              const Color(0xFFFF6F00)),
          const SizedBox(width: 8),
          _statChip(
              'Sinxronlanmagan',
              '${orders.where((order) => !order.isSynced).length}',
              const Color(0xFFC62828)),
        ],
      ),
    );
  }

  Widget _statChip(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterChip('Barchasi', 'all'),
          const SizedBox(width: 8),
          _filterChip('Sinxronlangan', 'synced'),
          const SizedBox(width: 8),
          _filterChip('Farqli', 'different'),
          const SizedBox(width: 8),
          _filterChip('Sinxronlanmagan', 'unsynced'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filterStatus = value),
    );
  }

  Widget _buildOrderCard(_OrderComparisonView order) {
    final color = order.hasDifference
        ? const Color(0xFFFF6F00)
        : order.isSynced
            ? const Color(0xFF2E7D32)
            : const Color(0xFFC62828);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: order.hasDifference ? 2 : 1),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(order.orderNumber,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15))),
                _stateBadge(order.label, color),
              ],
            ),
            Text(order.customerName,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 12),
            _buildComparisonRow(
                'Holat', order.localStatus, order.oneCStatus, order.sapStatus),
            const SizedBox(height: 8),
            _buildAmountRow(
                'Summa', order.localAmount, order.oneCAmount, order.sapAmount),
            if (order.differences.isNotEmpty) ...[
              const Divider(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFFF6F00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, size: 16, color: Color(0xFFFF6F00)),
                        SizedBox(width: 6),
                        Text('Farqlar:',
                            style: TextStyle(
                                color: Color(0xFFFF6F00),
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ],
                    ),
                    ...order.differences.map((difference) => Padding(
                          padding: const EdgeInsets.only(left: 22, top: 4),
                          child: Text('• $difference',
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 12)),
                        )),
                  ],
                ),
              ),
            ],
            if (order.hasDifference || !order.isSynced) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => _syncOrder(order.orderNumber),
                          child: const Text('Sinxronlash'))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _resolveDifference(order),
                      style: ElevatedButton.styleFrom(backgroundColor: color),
                      child: const Text('Hal qilish'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stateBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildComparisonRow(
      String label, String local, String oneC, String sap) {
    return Row(
      children: [
        SizedBox(
            width: 60,
            child: Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12))),
        Expanded(child: _valueBadge('Local', local, const Color(0xFF1565C0))),
        const SizedBox(width: 4),
        Expanded(child: _valueBadge('1C', oneC, const Color(0xFF2E7D32))),
        const SizedBox(width: 4),
        Expanded(child: _valueBadge('SAP', sap, const Color(0xFFFF6F00))),
      ],
    );
  }

  Widget _buildAmountRow(String label, double local, double oneC, double sap) {
    return Row(
      children: [
        SizedBox(
            width: 60,
            child: Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12))),
        Expanded(
            child: _valueBadge('Local', '${_formatAmount(local)} so‘m',
                const Color(0xFF1565C0))),
        const SizedBox(width: 4),
        Expanded(
            child: _valueBadge(
                '1C',
                oneC == 0 ? '-' : '${_formatAmount(oneC)} so‘m',
                const Color(0xFF2E7D32))),
        const SizedBox(width: 4),
        Expanded(
            child: _valueBadge(
                'SAP',
                sap == 0 ? '-' : '${_formatAmount(sap)} so‘m',
                const Color(0xFFFF6F00))),
      ],
    );
  }

  Widget _valueBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: [
          Text(label,
              style:
                  TextStyle(color: color.withValues(alpha: 0.75), fontSize: 9)),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String _formatAmount(num amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }

  void _syncAll() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Buyurtmalar sinxronlash tekshiruviga yuborildi'),
        backgroundColor: Color(0xFF1565C0)));
    _reload();
  }

  void _syncOrder(String orderNumber) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$orderNumber sinxronlash navbatiga qo‘shildi'),
        backgroundColor: const Color(0xFF1565C0)));
  }

  void _resolveDifference(_OrderComparisonView order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Farqni hal qilish',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(order.orderNumber),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Local holatni saqlash')),
            OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('1C/SAP holatini qabul qilish')),
          ],
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
}

class _OrderComparisonView {
  final String id;
  final String orderNumber;
  final String customerName;
  final String localStatus;
  final String oneCStatus;
  final String sapStatus;
  final double localAmount;
  final double oneCAmount;
  final double sapAmount;
  final List<String> differences;

  const _OrderComparisonView({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.localStatus,
    required this.oneCStatus,
    required this.sapStatus,
    required this.localAmount,
    required this.oneCAmount,
    required this.sapAmount,
    required this.differences,
  });

  bool get isSynced => oneCStatus != '-' && sapStatus != '-' && !hasDifference;
  bool get hasDifference => differences.isNotEmpty;
  String get label => hasDifference
      ? 'Farqli'
      : isSynced
          ? 'Sinxronlangan'
          : 'Sinxronlanmagan';

  factory _OrderComparisonView.fromLocalOrder(Map<String, dynamic> order) {
    final localStatus = (order['status'] ?? 'draft').toString();
    final oneCStatus = (order['status1C'] ??
            order['remote1CStatus'] ??
            (order['externalId1C'] == null ? '-' : localStatus))
        .toString();
    final sapStatus = (order['statusSAP'] ??
            order['remoteSAPStatus'] ??
            (order['externalIdSAP'] == null ? '-' : localStatus))
        .toString();
    final localAmount = _num(order['totalAmount'] ?? order['localAmount']);
    final oneCAmount = _num(order['amount1C'] ??
        order['remote1CAmount'] ??
        (order['externalId1C'] == null ? 0 : localAmount));
    final sapAmount = _num(order['amountSAP'] ??
        order['remoteSAPAmount'] ??
        (order['externalIdSAP'] == null ? 0 : localAmount));
    final differences = <String>[];

    if (oneCStatus != '-' && oneCStatus != localStatus)
      differences.add('1C holat: $localStatus → $oneCStatus');
    if (sapStatus != '-' && sapStatus != localStatus)
      differences.add('SAP holat: $localStatus → $sapStatus');
    if (oneCAmount != 0 && (oneCAmount - localAmount).abs() > 0.01)
      differences.add('1C summa: $localAmount → $oneCAmount');
    if (sapAmount != 0 && (sapAmount - localAmount).abs() > 0.01)
      differences.add('SAP summa: $localAmount → $sapAmount');

    return _OrderComparisonView(
      id: (order['id'] ?? order['orderId'] ?? '').toString(),
      orderNumber: (order['orderNumber'] ??
              order['order_number'] ??
              order['number'] ??
              '-')
          .toString(),
      customerName:
          (order['customerName'] ?? order['customer_name'] ?? '-').toString(),
      localStatus: localStatus,
      oneCStatus: oneCStatus,
      sapStatus: sapStatus,
      localAmount: localAmount,
      oneCAmount: oneCAmount,
      sapAmount: sapAmount,
      differences: differences,
    );
  }

  static double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
