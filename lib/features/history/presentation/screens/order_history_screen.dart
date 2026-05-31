import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/sync_queue/sync_queue_models.dart';
import '../../../../core/services/sync_queue/sync_queue_service.dart';
import '../../../order_flow/data/datasources/order_local_datasource.dart';
import '../../../order_flow/domain/entities/order_flow_entities.dart';
import '../../../order_flow/presentation/bloc/order_flow_bloc.dart';
import '../../../order_flow/domain/policies/order_validation_policy.dart';

/// Buyurtmalar tarixi - Barcha buyurtmalar filtrlash va qidirish
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedFilter = 'all';
  String _selectedPeriod = 'month';
  DateTimeRange? _customRange;
  final _searchController = TextEditingController();
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = getIt<OrderLocalDataSource>().getAllOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderFlowBloc, OrderFlowState>(
        listener: _onOrderFlowStateChanged,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Buyurtmalar tarixi'),
            actions: [
              IconButton(
                  icon: const Icon(Icons.cloud_sync),
                  onPressed: _syncPendingOrders),
              IconButton(
                  icon: const Icon(Icons.file_download), onPressed: _export),
              IconButton(
                  icon: const Icon(Icons.refresh), onPressed: _refreshOrders),
              IconButton(
                  icon: const Icon(Icons.filter_list), onPressed: _showFilters),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buyurtma raqami, mijoz nomi...',
                    prefixIcon: const Icon(Icons.search, size: 22),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // Period selector
              _buildPeriodSelector(),

              // Stats
              _buildStatsBar(),

              // Orders list
              Expanded(child: _buildOrdersList()),
            ],
          ),
        ));
  }

  void _onOrderFlowStateChanged(BuildContext context, OrderFlowState state) {
    if (state is OrderFlowLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message ?? 'Jarayon bajarilmoqda...')),
      );
    } else if (state is SyncCompleted) {
      _refreshOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Sync tugadi: ${state.result.success}/${state.result.total} muvaffaqiyatli'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } else if (state is OrderFlowError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _periodChip('Bugun', 'today'),
          const SizedBox(width: 8),
          _periodChip('Hafta', 'week'),
          const SizedBox(width: 8),
          _periodChip('Oy', 'month'),
          const SizedBox(width: 8),
          _periodChip('Yil', 'year'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.calendar_month, size: 20),
            onPressed: _selectDateRange,
          ),
        ],
      ),
    );
  }

  Widget _periodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _statChip('Barchasi', '156', const Color(0xFF1565C0)),
          const SizedBox(width: 8),
          _statChip('Tasdiqlangan', '120', const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          _statChip('Kutilmoqda', '25', const Color(0xFFFF6F00)),
          const SizedBox(width: 8),
          _statChip('Bekor', '11', const Color(0xFFC62828)),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return FutureBuilder<List<Order>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOrders = snapshot.data ?? [];
        if (allOrders.isEmpty) {
          return const Center(child: Text('Buyurtmalar topilmadi'));
        }

        final localOrders = _applyOrderFilters(allOrders);
        if (localOrders.isEmpty) {
          return const Center(
              child: Text('Filter bo‘yicha buyurtma topilmadi'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: localOrders.length,
          itemBuilder: (context, index) =>
              _buildLocalOrderCard(localOrders[index]),
        );
      },
    );
  }

  List<Order> _applyOrderFilters(List<Order> orders) {
    final query = _searchController.text.trim().toLowerCase();
    return orders.where((order) {
      final matchesQuery = query.isEmpty ||
          order.orderNumber.toLowerCase().contains(query) ||
          order.customerName.toLowerCase().contains(query) ||
          order.status.name.toLowerCase().contains(query);

      final matchesStatus = switch (_selectedFilter) {
        'draft' => order.status == OrderStatus.draft,
        'pending' => order.status == OrderStatus.pending ||
            order.status == OrderStatus.submitted,
        'confirmed' => order.status == OrderStatus.confirmed ||
            order.status == OrderStatus.delivered,
        'failed' => order.status == OrderStatus.syncFailed ||
            order.status == OrderStatus.cancelled,
        _ => true,
      };

      final matchesPeriod = _matchesSelectedPeriod(order.createdAt);
      return matchesQuery && matchesStatus && matchesPeriod;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool _matchesSelectedPeriod(DateTime date) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'today':
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case 'week':
        return now.difference(date).inDays <= 7;
      case 'month':
        return date.year == now.year && date.month == now.month;
      case 'year':
        return date.year == now.year;
      case 'custom':
        final range = _customRange;
        if (range == null) return true;
        return !date.isBefore(range.start) &&
            !date.isAfter(range.end.add(const Duration(days: 1)));
      default:
        return true;
    }
  }

  Widget _buildLocalOrderCard(Order order) {
    final color = _statusColor(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: ListTile(
        onTap: () => _showLocalOrderTerritory(order),
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_long, color: color),
        ),
        title: Text(order.orderNumber,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(order.customerName),
            Text('${order.items.length} ta mahsulot • ${order.status.name}'),
            if (order.metadata?['selectedWarehouseName'] != null)
              Text(
                '${order.metadata?['selectedWarehouseName']} • ${order.metadata?['territorySource'] ?? 'local'}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            _syncReadinessLine(order),
          ],
        ),
        trailing: Text(
          '${_formatAmount(order.totalAmount)} so\'m',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
        ),
      ),
    );
  }

  Widget _syncReadinessLine(Order order) {
    return FutureBuilder<SyncQueueItem?>(
      future: getIt<SyncQueueService>().getOrderQueueItem(order.id),
      builder: (context, snapshot) {
        final queueItem = snapshot.data;
        final validation = OrderValidationPolicy.validateBeforeSync(
            role: 'agent', order: order);
        final status = queueItem?.status.name ??
            (validation.isValid ? 'ready' : 'invalid');
        final color = _syncStatusColor(queueItem?.status, validation.isValid);
        final text = queueItem == null
            ? (validation.isValid
                ? 'Syncga tayyor'
                : 'Sync xatolik: ${validation.blockingMessages.length}')
            : 'Sync: $status${queueItem.retryCount > 0 ? ' • retry ${queueItem.retryCount}' : ''}';
        return Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              Icon(_syncStatusIcon(queueItem?.status, validation.isValid),
                  size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(text,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600))),
            ],
          ),
        );
      },
    );
  }

  Color _syncStatusColor(SyncQueueStatus? status, bool validationOk) {
    if (status == null)
      return validationOk ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    switch (status) {
      case SyncQueueStatus.success:
        return const Color(0xFF2E7D32);
      case SyncQueueStatus.failed:
        return const Color(0xFFC62828);
      case SyncQueueStatus.processing:
        return const Color(0xFF1565C0);
      case SyncQueueStatus.cancelled:
        return Colors.grey;
      case SyncQueueStatus.pending:
        return const Color(0xFFFF6F00);
    }
  }

  IconData _syncStatusIcon(SyncQueueStatus? status, bool validationOk) {
    if (status == null)
      return validationOk ? Icons.cloud_done : Icons.cloud_off;
    switch (status) {
      case SyncQueueStatus.success:
        return Icons.cloud_done;
      case SyncQueueStatus.failed:
        return Icons.error;
      case SyncQueueStatus.processing:
        return Icons.sync;
      case SyncQueueStatus.cancelled:
        return Icons.cancel;
      case SyncQueueStatus.pending:
        return Icons.cloud_upload;
    }
  }

  void _showLocalOrderTerritory(Order order) {
    final metadata = order.metadata ?? {};
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
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _territoryRow('Sklad',
                metadata['selectedWarehouseName'] ?? order.warehouseId),
            _territoryRow('Manba', metadata['territorySource'] ?? 'local'),
            _territoryRow('Direct match',
                '${metadata['hasDirectRegionMatch'] ?? 'unknown'}'),
            if (metadata['resolutionWarning'] != null)
              _territoryRow('Warning', metadata['resolutionWarning']),
            _territoryChips('Available skladlar',
                List<String>.from(metadata['availableWarehouseNames'] ?? [])),
            _territoryChips(
                'Agent skladlari',
                List<String>.from(
                    metadata['agentAllowedWarehouseNames'] ?? [])),
            _territoryChips(
                'Mijoz hududi skladlari',
                List<String>.from(
                    metadata['customerServiceWarehouseNames'] ?? [])),
            _pricingSnapshotDetails(metadata),
            _syncValidationDetails(order),
          ],
        ),
      ),
    );
  }

  Widget _pricingSnapshotDetails(Map<String, dynamic> metadata) {
    final snapshots =
        List<Map<String, dynamic>>.from(metadata['pricingSnapshots'] ?? []);
    if (snapshots.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pricing snapshot',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...snapshots.take(5).map((item) {
            final rules = List<String>.from(item['appliedRules'] ?? []);
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['productName'] ?? item['productId'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(
                      "Base: ${item['basePrice']} → Final: ${item['finalUnitPrice']} • Discount: ${item['lineDiscount'] ?? 0}",
                      style: const TextStyle(fontSize: 11)),
                  if (rules.isNotEmpty)
                    Text("Rules: ${rules.join(', ')}",
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF2E7D32))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _syncValidationDetails(Order order) {
    final validation =
        OrderValidationPolicy.validateBeforeSync(role: 'agent', order: order);
    if (validation.issues.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sync validation',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...validation.issues.map((issue) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(issue.blocking ? Icons.error : Icons.warning,
                      size: 16,
                      color: issue.blocking
                          ? Colors.red
                          : const Color(0xFFFF6F00)),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(issue.message,
                          style: TextStyle(
                              fontSize: 12,
                              color: issue.blocking
                                  ? Colors.red
                                  : const Color(0xFFFF6F00)))),
                ],
              )),
        ],
      ),
    );
  }

  Widget _territoryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
              width: 115,
              child:
                  Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _territoryChips(String label, List<String> values) {
    if (values.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Wrap(
              spacing: 6,
              runSpacing: 6,
              children: values
                  .map((v) => Chip(
                      label: Text(v), visualDensity: VisualDensity.compact))
                  .toList()),
        ],
      ),
    );
  }

  String _formatAmount(num amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
      case OrderStatus.delivered:
      case OrderStatus.syncedTo1C:
      case OrderStatus.syncedToSAP:
        return const Color(0xFF2E7D32);
      case OrderStatus.cancelled:
      case OrderStatus.syncFailed:
        return const Color(0xFFC62828);
      case OrderStatus.draft:
      case OrderStatus.pending:
      case OrderStatus.submitted:
      default:
        return const Color(0xFFFF6F00);
    }
  }

  void _syncPendingOrders() {
    context.read<OrderFlowBloc>().add(SyncAllPending());
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = getIt<OrderLocalDataSource>().getAllOrders();
    });
  }

  void _export() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hisobot yuklab olinmoqda...')),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Filtrlash',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip('Barchasi', 'all'),
                _filterChip('Draft', 'draft'),
                _filterChip('Kutilmoqda', 'pending'),
                _filterChip('Tasdiqlangan', 'confirmed'),
                _filterChip('Xatolik/Bekor', 'failed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (_) {
        setState(() => _selectedFilter = value);
        Navigator.pop(context);
      },
    );
  }

  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (range != null) {
      setState(() => _selectedPeriod = 'custom');
      _customRange = range;
    }
  }

  void _openOrderDetail(int index) {
    _showInfo('Buyurtma tafsilotlari timeline orqali ko‘rsatiladi');
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
