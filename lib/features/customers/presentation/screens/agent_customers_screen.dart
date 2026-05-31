import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../domain/entities/customer_sync_entities.dart';
import '../../domain/repositories/customer_repository.dart';

/// Agent mijozlari — CustomerRepository orqali real API/cache'dan yuklanadi.
class AgentCustomersScreen extends StatefulWidget {
  final String agentId;

  const AgentCustomersScreen({super.key, this.agentId = 'current'});

  @override
  State<AgentCustomersScreen> createState() => _AgentCustomersScreenState();
}

class _AgentCustomersScreenState extends State<AgentCustomersScreen> {
  final _searchController = TextEditingController();
  String _filterType = 'all'; // all, active, debt, vip
  bool _showSyncBanner = true;
  late Future<List<SyncedCustomer>> _future;

  CustomerRepository get _repository => getIt<CustomerRepository>();

  @override
  void initState() {
    super.initState();
    context.read<SyncBloc>().add(CheckSyncStatusRequested());
    _future = _loadCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _future = _loadCustomers());
  }

  Future<String> _agentId() async {
    if (widget.agentId != 'current' && widget.agentId.trim().isNotEmpty)
      return widget.agentId;
    final auth = await getIt<AuthRepository>().getCurrentUser();
    final user = auth.fold((_) => null, (value) => value);
    return user?.id ?? user?.code ?? 'current';
  }

  Future<List<SyncedCustomer>> _loadCustomers() async {
    final result = await _repository.getAgentCustomers(
      agentId: await _agentId(),
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      isActive: _filterType == 'active' ? true : null,
      hasDebt: _filterType == 'debt' ? true : null,
      limit: 200,
    );
    return result.fold((failure) => throw Exception(failure.message), (items) {
      return items.where((customer) {
        switch (_filterType) {
          case 'vip':
            return customer.isVIP;
          case 'debt':
            return customer.currentDebt > 0 || customer.overdueDebt > 0;
          case 'active':
            return customer.isActive;
          case 'all':
          default:
            return true;
        }
      }).toList();
    });
  }

  void _reload() {
    setState(() => _future = _loadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SyncedCustomer>>(
      future: _future,
      builder: (context, snapshot) {
        final customers = snapshot.data ?? const <SyncedCustomer>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mening mijozlarim'),
            actions: [
              BlocBuilder<SyncBloc, SyncState>(
                builder: (context, state) {
                  return IconButton(
                    icon: state is SyncInProgress
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.sync),
                    onPressed: state is SyncInProgress ? null : _startSync,
                    tooltip: 'Sinxronlash',
                  );
                },
              ),
              IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Mijoz qidirish...',
                    prefixIcon: const Icon(Icons.search, size: 22),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
          ),
          body: BlocConsumer<SyncBloc, SyncState>(
            listener: (context, state) {
              if (state is SyncCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Sinxronlash tugadi: ${state.totalSynced} ta yangilandi'),
                      backgroundColor: const Color(0xFF2E7D32)),
                );
                _reload();
              }
              if (state is SyncFailed) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red));
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  if (state is SyncInProgress) _buildSyncProgress(state),
                  if (state is SyncStatusLoaded &&
                      state.needsSync &&
                      _showSyncBanner)
                    _buildSyncBanner(),
                  _buildStatsBar(customers),
                  Expanded(child: _buildCustomerList(snapshot, customers)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSyncProgress(SyncInProgress state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1565C0).withValues(alpha: 0.1),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(state.currentTask,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14))),
              Text('${(state.progress * 100).toInt()}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: state.progress, backgroundColor: Colors.grey.shade200),
        ],
      ),
    );
  }

  Widget _buildSyncBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF6F00), Color(0xFFE65100)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_problem, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ma’lumotlar eskirgan',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text('Yangilash uchun bosing',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _startSync,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF6F00)),
            child: const Text('Yangilash'),
          ),
          IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () => setState(() => _showSyncBanner = false)),
        ],
      ),
    );
  }

  Widget _buildStatsBar(List<SyncedCustomer> customers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildStatChip(
              'Barchasi', '${customers.length}', const Color(0xFF1565C0)),
          const SizedBox(width: 8),
          _buildStatChip('Faol', '${customers.where((c) => c.isActive).length}',
              const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          _buildStatChip(
              'Qarzdor',
              '${customers.where((c) => c.currentDebt > 0 || c.overdueDebt > 0).length}',
              const Color(0xFFC62828)),
          const SizedBox(width: 8),
          _buildStatChip('VIP', '${customers.where((c) => c.isVIP).length}',
              const Color(0xFFFF6F00)),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String count, Color color) {
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
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList(AsyncSnapshot<List<SyncedCustomer>> snapshot,
      List<SyncedCustomer> customers) {
    if (snapshot.connectionState == ConnectionState.waiting)
      return const Center(child: CircularProgressIndicator());
    if (snapshot.hasError) {
      return _emptyState(
        icon: Icons.error_outline,
        title: 'Mijozlar yuklanmadi',
        message: snapshot.error.toString(),
        action: ElevatedButton.icon(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            label: const Text('Qayta yuklash')),
      );
    }
    if (customers.isEmpty) {
      return _emptyState(
        icon: Icons.people_outline,
        title: 'Mijozlar topilmadi',
        message: 'Qidiruv yoki filter shartlariga mos mijoz yo‘q.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: customers.length,
      itemBuilder: (context, index) => _buildCustomerCard(customers[index]),
    );
  }

  Widget _buildCustomerCard(SyncedCustomer customer) {
    final hasDebt = customer.currentDebt > 0 || customer.overdueDebt > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: InkWell(
        onTap: () => _showCustomerDetails(customer),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: hasDebt
                              ? Colors.red.withValues(alpha: 0.1)
                              : const Color(0xFF1565C0).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            customer.name.isEmpty
                                ? '?'
                                : customer.name.substring(0, 1),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: hasDebt
                                    ? Colors.red
                                    : const Color(0xFF1565C0)),
                          ),
                        ),
                      ),
                      if (customer.isVIP)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                color: Color(0xFFFF6F00),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.star,
                                size: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Kod: ${customer.code}',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                        Text(customer.address,
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _smallBadge(
                          customer.syncSource.name.toUpperCase(),
                          customer.syncSource == SyncSource.oneC
                              ? const Color(0xFF1565C0)
                              : const Color(0xFFFF6F00)),
                      const SizedBox(height: 4),
                      if (hasDebt) _smallBadge('Qarzdor', Colors.red),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCustomerStat('Buyurtmalar', '${customer.totalOrders}',
                      Icons.shopping_bag),
                  _buildCustomerStat(
                      'Sotuv',
                      '${(customer.totalSales / 1000000).toStringAsFixed(1)}M',
                      Icons.attach_money),
                  if (hasDebt)
                    _buildCustomerStat(
                        'Qarz',
                        '${(customer.currentDebt / 1000000).toStringAsFixed(1)}M',
                        Icons.money_off,
                        color: Colors.red),
                  _buildCustomerStat('Tashrif', '${customer.visitFrequency}k',
                      Icons.calendar_today),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCustomerStat(String label, String value, IconData icon,
      {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey.shade500),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13, color: color)),
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
      ],
    );
  }

  void _showCustomerDetails(SyncedCustomer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          const Color(0xFF1565C0).withValues(alpha: 0.1),
                      child: Text(
                          customer.name.isEmpty
                              ? '?'
                              : customer.name.substring(0, 1),
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                      child: Text(customer.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                  Center(
                      child: Text(
                          'Kod: ${customer.code} • STIR: ${customer.inn}',
                          style: TextStyle(color: Colors.grey.shade600))),
                  const SizedBox(height: 24),
                  _buildDetailSection('Aloqa', [
                    _buildDetailItem(Icons.location_on, customer.address),
                    _buildDetailItem(Icons.phone, customer.phone),
                    if (customer.email != null)
                      _buildDetailItem(Icons.email, customer.email!),
                    if (customer.contactPerson != null)
                      _buildDetailItem(Icons.person, customer.contactPerson!),
                  ]),
                  _buildDetailSection('Savdo', [
                    _buildDetailItem(Icons.price_change,
                        'Narx guruhi: ${customer.priceGroupName}'),
                    _buildDetailItem(
                        Icons.payment, 'To‘lov: ${customer.paymentTerms}'),
                    _buildDetailItem(Icons.credit_card,
                        'Kredit limit: ${_formatAmount(customer.creditLimit)} ${customer.currency}'),
                  ]),
                  _buildDetailSection('Statistika', [
                    _buildDetailItem(Icons.shopping_bag,
                        'Jami buyurtmalar: ${customer.totalOrders}'),
                    _buildDetailItem(Icons.attach_money,
                        'Jami sotuv: ${_formatAmount(customer.totalSales)} ${customer.currency}'),
                    if (customer.currentDebt > 0)
                      _buildDetailItem(Icons.money_off,
                          'Qarzdorlik: ${_formatAmount(customer.currentDebt)} ${customer.currency}',
                          color: Colors.red),
                  ]),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/orders/create');
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Buyurtma'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/tracking');
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Xarita'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      const SizedBox(height: 8),
      ...children,
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildDetailItem(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: color ?? Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color ?? Colors.grey.shade700, fontSize: 14))),
      ]),
    );
  }

  void _startSync() {
    context.read<SyncBloc>().add(SyncAllRequested(agentId: widget.agentId));
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filterlar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _filterAction('Barchasi', 'all'),
                _filterAction('Faol', 'active'),
                _filterAction('Qarzdor', 'debt'),
                _filterAction('VIP', 'vip'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterAction(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filterType == value,
      onSelected: (_) {
        Navigator.pop(context);
        setState(() {
          _filterType = value;
          _future = _loadCustomers();
        });
      },
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

  String _formatAmount(num amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }
}
