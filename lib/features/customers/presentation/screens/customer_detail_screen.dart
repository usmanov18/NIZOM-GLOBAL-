import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/customer_sync_entities.dart';
import '../../domain/repositories/customer_repository.dart';

/// Mijoz tafsilotlari — CustomerRepository orqali real API/cache'dan yuklanadi.
class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<_CustomerDetailData> _future;

  CustomerRepository get _repository => getIt<CustomerRepository>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _future = _load();
  }

  Future<_CustomerDetailData> _load() async {
    final id = widget.customerId.trim();
    if (id.isEmpty) {
      throw const FormatException('Mijoz ID berilmagan');
    }

    final customerResult = await _repository.getCustomerById(id);
    final customer = customerResult.fold(
        (failure) => throw Exception(failure.message), (value) => value);

    final ordersResult =
        await _repository.getCustomerOrders(customerId: customer.id);
    final paymentsResult =
        await _repository.getCustomerPayments(customerId: customer.id);

    return _CustomerDetailData(
      customer: customer,
      orders:
          ordersResult.fold((_) => const <CustomerOrder>[], (items) => items),
      payments: paymentsResult.fold(
          (_) => const <CustomerPayment>[], (items) => items),
    );
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CustomerDetailData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mijoz tafsilotlari')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mijoz tafsilotlari')),
            body: _emptyState(
              icon: Icons.store_mall_directory_outlined,
              title: 'Mijoz yuklanmadi',
              message:
                  snapshot.error?.toString() ?? 'Mijoz ma’lumotlari topilmadi.',
              action: ElevatedButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Qayta yuklash'),
              ),
            ),
          );
        }

        return _detailScaffold(snapshot.data!);
      },
    );
  }

  Widget _detailScaffold(_CustomerDetailData data) {
    final customer = data.customer;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          customer.name.isEmpty
                              ? '?'
                              : customer.name.substring(0, 1),
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        customer.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(customer.code,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
              PopupMenuButton<String>(
                onSelected: (action) => _handleMenuAction(action, customer),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'call', child: Text('Qo‘ng‘iroq')),
                  PopupMenuItem(value: 'sms', child: Text('SMS')),
                  PopupMenuItem(value: 'navigate', child: Text('Navigatsiya')),
                  PopupMenuItem(
                      value: 'order', child: Text('Buyurtma yaratish')),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsRow(customer),
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF1565C0),
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Ma’lumot'),
                      Tab(text: 'Buyurtmalar'),
                      Tab(text: 'To‘lovlar'),
                      Tab(text: 'Tashriflar'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 520,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(customer),
                      _buildOrdersTab(data.orders),
                      _buildPaymentsTab(data.payments),
                      _buildVisitsTab(customer),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStatsRow(SyncedCustomer customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _statItem('Buyurtmalar', '${customer.totalOrders}',
              const Color(0xFF1565C0)),
          _statItem(
              'Sotuv',
              '${(customer.totalSales / 1000000).toStringAsFixed(0)}M',
              const Color(0xFF2E7D32)),
          _statItem(
              'Qarz',
              '${(customer.currentDebt / 1000000).toStringAsFixed(1)}M',
              const Color(0xFFC62828)),
          _statItem(
              'Kredit',
              '${(customer.creditLimit / 1000000).toStringAsFixed(0)}M',
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
                  color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildInfoTab(SyncedCustomer customer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _infoSection('Asosiy ma’lumotlar', [
            _infoRow('Yuridik nom', customer.legalName),
            _infoRow('STIR', customer.inn),
            _infoRow('Manzil', customer.address),
            _infoRow('Telefon', customer.phone),
            _infoRow('Email', customer.email ?? '-'),
            _infoRow('Mas’ul shaxs', customer.contactPerson ?? '-'),
          ]),
          const SizedBox(height: 16),
          _infoSection('Savdo ma’lumotlari', [
            _infoRow('Hudud', customer.regionName ?? '-'),
            _infoRow('Narx guruhi', customer.priceGroupName),
            _infoRow('To‘lov sharti', customer.paymentTerms),
            _infoRow('Kredit limit',
                '${_formatAmount(customer.creditLimit)} ${customer.currency}'),
            _infoRow('Tashrif chastotasi', '${customer.visitFrequency} kun'),
            _infoRow('Sync manba', customer.syncSource.name),
          ]),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(List<CustomerOrder> orders) {
    if (orders.isEmpty) {
      return _emptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'Buyurtmalar yo‘q',
        message: 'Bu mijoz uchun buyurtmalar hali yuklanmagan.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _orderCard(orders[index]),
    );
  }

  Widget _buildPaymentsTab(List<CustomerPayment> payments) {
    if (payments.isEmpty) {
      return _emptyState(
        icon: Icons.payment_outlined,
        title: 'To‘lovlar yo‘q',
        message: 'Bu mijoz uchun to‘lovlar hali yuklanmagan.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) => _paymentCard(payments[index]),
    );
  }

  Widget _buildVisitsTab(SyncedCustomer customer) {
    return _emptyState(
      icon: Icons.location_on_outlined,
      title: 'Tashriflar statistikasi',
      message:
          'Jami tashriflar: ${customer.totalVisits}. Oxirgi tashrif: ${customer.lastVisitDate == null ? '-' : _formatDate(customer.lastVisitDate!)}',
    );
  }

  Widget _infoSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child: Text(label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _orderCard(CustomerOrder order) {
    return _listCard(
      icon: Icons.shopping_bag,
      color: const Color(0xFF1565C0),
      title: order.orderNumber,
      subtitle: '${_formatDate(order.date)} • ${order.status}',
      trailing: '${_formatAmount(order.amount)} so‘m',
    );
  }

  Widget _paymentCard(CustomerPayment payment) {
    return _listCard(
      icon: Icons.payment,
      color: const Color(0xFF2E7D32),
      title: 'To‘lov ${payment.reference ?? payment.id}',
      subtitle: '${_formatDate(payment.date)} • ${payment.method}',
      trailing: '${_formatAmount(payment.amount)} so‘m',
    );
  }

  Widget _listCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle,
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          Text(trailing,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/orders/create'),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Buyurtma'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/payments/collect'),
              icon: const Icon(Icons.payment),
              label: const Text('To‘lov'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/tracking'),
              icon: const Icon(Icons.map),
              label: const Text('Xarita'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ],
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

  void _handleMenuAction(String action, SyncedCustomer customer) {
    switch (action) {
      case 'call':
        _showInfo('Qo‘ng‘iroq: ${customer.phone}');
        break;
      case 'sms':
        _showInfo('SMS yuborish oynasi ochildi');
        break;
      case 'navigate':
        context.push('/tracking');
        break;
      case 'order':
        context.push('/orders/create');
        break;
    }
  }

  String _formatAmount(num amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CustomerDetailData {
  final SyncedCustomer customer;
  final List<CustomerOrder> orders;
  final List<CustomerPayment> payments;

  const _CustomerDetailData({
    required this.customer,
    required this.orders,
    required this.payments,
  });
}
