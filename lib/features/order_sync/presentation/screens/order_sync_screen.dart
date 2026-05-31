import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../order_flow/presentation/bloc/order_flow_bloc.dart';
import '../../data/datasources/order_local_storage_service.dart';

/// Buyurtmalar sinxronlash — local order storage va OrderFlowBloc asosida.
class OrderSyncScreen extends StatefulWidget {
  const OrderSyncScreen({super.key});

  @override
  State<OrderSyncScreen> createState() => _OrderSyncScreenState();
}

class _OrderSyncScreenState extends State<OrderSyncScreen>
    with SingleTickerProviderStateMixin {
  final OrderLocalStorageService _storage = OrderLocalStorageService();
  late TabController _tabController;
  late Future<List<_OrderSyncView>> _future;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _future = _loadOrders();
  }

  Future<List<_OrderSyncView>> _loadOrders() async {
    final orders = await _storage.getAllOrders();
    return orders.map(_OrderSyncView.fromLocalOrder).toList();
  }

  void _reload() {
    setState(() => _future = _loadOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_OrderSyncView>>(
      future: _future,
      builder: (context, snapshot) {
        final orders = snapshot.data ?? const <_OrderSyncView>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Buyurtmalar sinxronlash'),
            actions: [
              IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: _syncAll,
                  tooltip: 'Barchasini sinxronlash'),
              IconButton(
                  icon: const Icon(Icons.compare_arrows),
                  onPressed: _reload,
                  tooltip: 'Solishtirish'),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Barchasi'),
                Tab(text: 'Sinxronlangan'),
                Tab(text: 'Sinxronlanmagan'),
                Tab(text: 'Farqli'),
              ],
            ),
          ),
          body: _buildBody(snapshot, orders),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<List<_OrderSyncView>> snapshot,
      List<_OrderSyncView> orders) {
    if (snapshot.connectionState == ConnectionState.waiting)
      return const Center(child: CircularProgressIndicator());
    if (snapshot.hasError) {
      return _emptyState(
        icon: Icons.error_outline,
        title: 'Sinxronlash ro‘yxati yuklanmadi',
        message: snapshot.error.toString(),
        action: ElevatedButton.icon(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            label: const Text('Qayta yuklash')),
      );
    }

    return Column(
      children: [
        _buildSummary(orders),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(orders, 'all'),
              _buildOrdersList(orders, 'synced'),
              _buildOrdersList(orders, 'unsynced'),
              _buildOrdersList(orders, 'different'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(List<_OrderSyncView> orders) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _statChip('Jami', '${orders.length}', const Color(0xFF1565C0)),
          const SizedBox(width: 8),
          _statChip('Sync', '${orders.where((item) => item.isSynced).length}',
              const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          _statChip(
              'Farqli',
              '${orders.where((item) => item.hasDifference).length}',
              const Color(0xFFFF6F00)),
          const SizedBox(width: 8),
          _statChip(
              'Kutilmoqda',
              '${orders.where((item) => !item.isSynced && !item.hasDifference).length}',
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

  Widget _buildOrdersList(List<_OrderSyncView> orders, String filter) {
    final filtered = orders.where((order) {
      switch (filter) {
        case 'synced':
          return order.isSynced;
        case 'unsynced':
          return !order.isSynced && !order.hasDifference;
        case 'different':
          return order.hasDifference;
        case 'all':
        default:
          return true;
      }
    }).toList();

    if (filtered.isEmpty) {
      return _emptyState(
        icon: Icons.sync_problem_outlined,
        title: 'Buyurtmalar topilmadi',
        message: 'Tanlangan filter bo‘yicha local buyurtmalar yo‘q.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildOrderCard(filtered[index]),
    );
  }

  Widget _buildOrderCard(_OrderSyncView order) {
    final statusColor = order.hasDifference
        ? const Color(0xFFFF6F00)
        : order.isSynced
            ? const Color(0xFF2E7D32)
            : const Color(0xFF1565C0);
    final statusIcon = order.hasDifference
        ? Icons.warning
        : order.isSynced
            ? Icons.check_circle
            : Icons.sync_problem;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: order.hasDifference
            ? Border.all(
                color: const Color(0xFFFF6F00).withValues(alpha: 0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(14),
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
                  _stateBadge(order.label, statusColor, statusIcon),
                ],
              ),
              const SizedBox(height: 4),
              Text(order.customerName,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              const SizedBox(height: 8),
              _buildStatusComparison(order),
              const SizedBox(height: 8),
              _buildAmountComparison(order),
              if (order.differences.isNotEmpty) ...[
                const Divider(height: 16),
                ...order.differences.map((difference) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning,
                              size: 16, color: Color(0xFFFF6F00)),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(difference,
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12))),
                        ],
                      ),
                    )),
              ],
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(order.createdAt),
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  Text('Oxirgi sync: ${order.lastSyncLabel}',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
              if (order.hasDifference || !order.isSynced) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _syncOrder(order.id),
                        icon: const Icon(Icons.sync, size: 16),
                        label: const Text('Sinxronlash'),
                      ),
                    ),
                    if (order.hasDifference) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _resolveDifference(order.id),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Hal qilish'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6F00)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stateBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusComparison(_OrderSyncView order) {
    return Row(
      children: [
        Expanded(
            child: _valueBadge(
                'Local', order.localStatus, const Color(0xFF1565C0))),
        const SizedBox(width: 8),
        Expanded(
            child: _valueBadge(
                '1C',
                order.oneCStatus,
                order.oneCStatus == '-'
                    ? Colors.grey
                    : const Color(0xFF2E7D32))),
        const SizedBox(width: 8),
        Expanded(
            child: _valueBadge(
                'SAP',
                order.sapStatus,
                order.sapStatus == '-'
                    ? Colors.grey
                    : const Color(0xFFFF6F00))),
      ],
    );
  }

  Widget _buildAmountComparison(_OrderSyncView order) {
    return Row(
      children: [
        Expanded(
            child: _valueBadge(
                'Local',
                '${_formatAmount(order.localAmount)} so‘m',
                const Color(0xFF1565C0))),
        const SizedBox(width: 8),
        Expanded(
            child: _valueBadge(
                '1C',
                order.oneCAmount == 0
                    ? '-'
                    : '${_formatAmount(order.oneCAmount)} so‘m',
                const Color(0xFF2E7D32))),
        const SizedBox(width: 8),
        Expanded(
            child: _valueBadge(
                'SAP',
                order.sapAmount == 0
                    ? '-'
                    : '${_formatAmount(order.sapAmount)} so‘m',
                const Color(0xFFFF6F00))),
      ],
    );
  }

  Widget _valueBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.75), fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String _formatAmount(num amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  void _syncAll() {
    context.read<OrderFlowBloc>().add(SyncAllPending());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Barcha pending buyurtmalar sinxronlashga yuborildi'),
        backgroundColor: Color(0xFF1565C0)));
    _reload();
  }

  void _compareAll() => _reload();

  void _syncOrder(String orderId) {
    context.read<OrderFlowBloc>().add(SubmitOrder(orderId));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$orderId sinxronlashga yuborildi'),
        backgroundColor: const Color(0xFF1565C0)));
  }

  void _resolveDifference(String orderId) {
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
            Text(orderId),
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

  void _showOrderDetails(_OrderSyncView order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.orderNumber,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(order.customerName),
            Text('Holat: ${order.label}'),
            Text('Summa: ${_formatAmount(order.localAmount)} so‘m'),
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

class _OrderSyncView {
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
  final DateTime createdAt;
  final DateTime? lastSyncAt;

  const _OrderSyncView({
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
    required this.createdAt,
    this.lastSyncAt,
  });

  bool get isSynced => oneCStatus != '-' && sapStatus != '-' && !hasDifference;
  bool get hasDifference => differences.isNotEmpty;
  String get label => hasDifference
      ? 'Farqli'
      : isSynced
          ? 'Sinxronlangan'
          : 'Sinxronlanmagan';
  String get lastSyncLabel => lastSyncAt == null
      ? 'Sinxronlanmagan'
      : '${DateTime.now().difference(lastSyncAt!).inMinutes} daqiqa oldin';

  factory _OrderSyncView.fromLocalOrder(Map<String, dynamic> order) {
    final localStatus = (order['status'] ?? 'draft').toString();
    final oneCStatus = (order['remote1CStatus'] ??
            order['status1C'] ??
            (order['externalId1C'] == null ? '-' : localStatus))
        .toString();
    final sapStatus = (order['remoteSAPStatus'] ??
            order['statusSAP'] ??
            (order['externalIdSAP'] == null ? '-' : localStatus))
        .toString();
    final localAmount = _num(order['localAmount'] ?? order['totalAmount']);
    final oneCAmount = _num(order['remote1CAmount'] ??
        order['amount1C'] ??
        (order['externalId1C'] == null ? 0 : localAmount));
    final sapAmount = _num(order['remoteSAPAmount'] ??
        order['amountSAP'] ??
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

    return _OrderSyncView(
      id: (order['id'] ?? order['orderId'] ?? '').toString(),
      orderNumber:
          (order['orderNumber'] ?? order['order_number'] ?? '-').toString(),
      customerName:
          (order['customerName'] ?? order['customer_name'] ?? '-').toString(),
      localStatus: localStatus,
      oneCStatus: oneCStatus,
      sapStatus: sapStatus,
      localAmount: localAmount,
      oneCAmount: oneCAmount,
      sapAmount: sapAmount,
      differences: differences,
      createdAt: DateTime.tryParse(
              (order['createdAt'] ?? order['created_at'] ?? '').toString()) ??
          DateTime.now(),
      lastSyncAt: DateTime.tryParse(
          (order['lastSyncAt'] ?? order['last_sync_at'] ?? '').toString()),
    );
  }

  static double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
