import 'package:flutter/material.dart';

import '../../../order_sync/data/datasources/order_local_storage_service.dart';

/// Buyurtma tarixi - local order storage versiyalari asosida timeline.
class OrderTimelineScreen extends StatefulWidget {
  final String orderId;
  final String orderNumber;

  const OrderTimelineScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<OrderTimelineScreen> createState() => _OrderTimelineScreenState();
}

class _OrderTimelineScreenState extends State<OrderTimelineScreen> {
  final OrderLocalStorageService _storage = OrderLocalStorageService();
  late Future<_TimelineData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TimelineData> _load() async {
    if (widget.orderId.trim().isEmpty) throw const FormatException('Buyurtma ID berilmagan');
    final order = await _storage.getOrder(widget.orderId);
    if (order == null) throw Exception('Buyurtma local storage ichida topilmadi');
    return _TimelineData(order: order, events: _buildEvents(order));
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TimelineData>(
      future: _future,
      builder: (context, snapshot) {
        final orderNumber = widget.orderNumber.isNotEmpty ? widget.orderNumber : (snapshot.data?.order['orderNumber'] ?? snapshot.data?.order['order_number'] ?? '').toString();
        return Scaffold(
          appBar: AppBar(
            title: Text(orderNumber.isEmpty ? 'Buyurtma timeline' : 'Buyurtma $orderNumber'),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _reload)],
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<_TimelineData> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
    if (snapshot.hasError || !snapshot.hasData) {
      return _emptyState(
        icon: Icons.timeline_outlined,
        title: 'Timeline yuklanmadi',
        message: snapshot.error?.toString() ?? 'Buyurtma timeline ma’lumotlari topilmadi.',
      );
    }

    final data = snapshot.data!;
    return Column(
      children: [
        _buildStatusHeader(data.order),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.events.length,
            itemBuilder: (context, index) => _timelineRow(data.events[index], isLast: index == data.events.length - 1),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeader(Map<String, dynamic> order) {
    final status = (order['status'] ?? 'draft').toString();
    final total = _num(order['totalAmount'] ?? order['total_amount']);
    final paid = _num(order['paidAmount'] ?? order['paid_amount']);
    final isDone = ['delivered', 'completed', 'confirmed'].contains(status);
    final color = isDone ? const Color(0xFF2E7D32) : const Color(0xFFFF6F00);

    return Container(
      padding: const EdgeInsets.all(16),
      color: color.withOpacity(0.1),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : Icons.pending, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Holat: $status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
              Text('Jami: ${_formatAmount(total)} so‘m • To‘langan: ${_formatAmount(paid)} so‘m', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _timelineRow(_TimelineEvent item, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Column(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: item.color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            if (!isLast) Container(width: 2, height: 40, color: Colors.grey.shade300),
          ]),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 5)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(item.subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 4),
              Text(_formatDateTime(item.time), style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
            ]),
          ),
        ),
      ],
    );
  }

  List<_TimelineEvent> _buildEvents(Map<String, dynamic> order) {
    final created = _date(order['createdAt'] ?? order['created_at'] ?? order['savedAt']);
    final submitted = _optionalDate(order['submittedAt'] ?? order['submitted_at']);
    final synced1C = _optionalDate(order['syncedTo1CAt'] ?? order['synced_to_1c_at']);
    final syncedSAP = _optionalDate(order['syncedToSAPAt'] ?? order['synced_to_sap_at']);
    final confirmed = _optionalDate(order['confirmedAt'] ?? order['confirmed_at']);
    final delivered = _optionalDate(order['deliveredAt'] ?? order['delivered_at']);
    final versions = (order['versions'] as List?) ?? const [];

    final events = <_TimelineEvent>[
      _TimelineEvent(
        title: 'Buyurtma yaratildi',
        subtitle: 'Local saqlandi',
        time: created,
        icon: Icons.add_shopping_cart,
        color: const Color(0xFF1565C0),
      ),
    ];
    if (submitted != null) {
      events.add(_TimelineEvent(title: 'Serverga yuborildi', subtitle: 'Submit bajarildi', time: submitted, icon: Icons.cloud_upload, color: const Color(0xFF00897B)));
    }
    if (synced1C != null) {
      events.add(_TimelineEvent(title: '1C ga yuborildi', subtitle: '1C sync tugadi', time: synced1C, icon: Icons.cloud_done, color: const Color(0xFF00897B)));
    }
    if (syncedSAP != null) {
      events.add(_TimelineEvent(title: 'SAP ga yuborildi', subtitle: 'SAP sync tugadi', time: syncedSAP, icon: Icons.cloud_done, color: const Color(0xFFFF6F00)));
    }
    if (confirmed != null) {
      events.add(_TimelineEvent(title: 'Tasdiqlandi', subtitle: 'Buyurtma tasdiqlandi', time: confirmed, icon: Icons.check_circle, color: const Color(0xFF2E7D32)));
    }
    if (delivered != null) {
      events.add(_TimelineEvent(title: 'Yetkazildi', subtitle: 'Delivery tasdiqlandi', time: delivered, icon: Icons.local_shipping, color: const Color(0xFF2E7D32)));
    }
    for (final version in versions.skip(1)) {
      if (version is Map) {
        events.add(_TimelineEvent(title: 'O‘zgartirish', subtitle: 'Version ${version['version'] ?? ''}', time: _optionalDate(version['savedAt']) ?? created, icon: Icons.history, color: Colors.grey));
      }
    }
    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

  Widget _emptyState({required IconData icon, required String title, required String message}) {
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

  DateTime _date(dynamic value) => DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  DateTime? _optionalDate(dynamic value) => DateTime.tryParse(value?.toString() ?? '');
  DateTime? _date(dynamic value, {bool nullable = true}) => DateTime.tryParse(value?.toString() ?? '');

  double _num(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;

  String _formatAmount(num amount) => amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');

  String _formatDateTime(DateTime date) => '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _TimelineData {
  final Map<String, dynamic> order;
  final List<_TimelineEvent> events;

  const _TimelineData({required this.order, required this.events});
}

class _TimelineEvent {
  final String title;
  final String subtitle;
  final DateTime time;
  final IconData icon;
  final Color color;

  const _TimelineEvent({required this.title, required this.subtitle, required this.time, required this.icon, required this.color});
}
