import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/customer_sync_entities.dart';
import '../../domain/repositories/customer_repository.dart';

/// Qarzdorlik boshqaruvi — real CustomerRepository/cache asosida.
class CustomerDebtScreen extends StatefulWidget {
  const CustomerDebtScreen({super.key});

  @override
  State<CustomerDebtScreen> createState() => _CustomerDebtScreenState();
}

class _CustomerDebtScreenState extends State<CustomerDebtScreen> {
  String _filterType = 'all';
  late Future<List<SyncedCustomer>> _future;

  CustomerRepository get _repository => getIt<CustomerRepository>();

  @override
  void initState() {
    super.initState();
    _future = _loadDebtors();
  }

  Future<List<SyncedCustomer>> _loadDebtors() async {
    final authResult = await getIt<AuthRepository>().getCurrentUser();
    final user = authResult.fold((_) => null, (value) => value);
    final agentId = user?.id ?? user?.code ?? 'current';
    final result = await _repository.getAgentCustomers(
        agentId: agentId, hasDebt: true, limit: 200);
    return result.fold((failure) => throw Exception(failure.message), (items) {
      return items
          .where((customer) =>
              customer.currentDebt > 0 || customer.overdueDebt > 0)
          .toList();
    });
  }

  void _reload() {
    setState(() => _future = _loadDebtors());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SyncedCustomer>>(
      future: _future,
      builder: (context, snapshot) {
        final debtors = snapshot.data ?? const <SyncedCustomer>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Qarzdorlik boshqaruvi'),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
              IconButton(
                  icon: const Icon(Icons.file_download),
                  onPressed: () => _export(debtors)),
              IconButton(
                  icon: const Icon(Icons.sms),
                  onPressed: () => _sendReminders(debtors)),
            ],
          ),
          body: _buildBody(snapshot, debtors),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<List<SyncedCustomer>> snapshot,
      List<SyncedCustomer> debtors) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return _emptyState(
        icon: Icons.error_outline,
        title: 'Qarzdorlik yuklanmadi',
        message: snapshot.error.toString(),
        action: ElevatedButton.icon(
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
          label: const Text('Qayta yuklash'),
        ),
      );
    }

    final filtered = _filteredDebtors(debtors);
    return Column(
      children: [
        _buildStats(debtors),
        _buildFilterChips(),
        Expanded(
          child: filtered.isEmpty
              ? _emptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Qarzdor mijoz topilmadi',
                  message: 'Tanlangan filter bo‘yicha qarzdor mijozlar yo‘q.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildDebtorCard(filtered[index]),
                ),
        ),
      ],
    );
  }

  List<SyncedCustomer> _filteredDebtors(List<SyncedCustomer> debtors) {
    return debtors.where((customer) {
      switch (_filterType) {
        case 'overdue':
          return customer.overdueDebt > 0;
        case 'large':
          return customer.currentDebt >= 10000000;
        case 'new':
          return customer.lastPaymentDate == null ||
              DateTime.now().difference(customer.lastPaymentDate!).inDays <= 7;
        case 'all':
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildStats(List<SyncedCustomer> debtors) {
    final totalDebt =
        debtors.fold<double>(0, (sum, customer) => sum + customer.currentDebt);
    final overdueDebt =
        debtors.fold<double>(0, (sum, customer) => sum + customer.overdueDebt);
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFC62828).withValues(alpha: 0.05),
      child: Row(
        children: [
          _statItem('Jami qarz', '${(totalDebt / 1000000).toStringAsFixed(1)}M',
              const Color(0xFFC62828)),
          _statItem(
              'Muddati o‘tgan',
              '${(overdueDebt / 1000000).toStringAsFixed(1)}M',
              const Color(0xFFFF6F00)),
          _statItem('Qarzdorlar', '${debtors.length}', const Color(0xFF1565C0)),
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterChip('Barchasi', 'all'),
          const SizedBox(width: 8),
          _filterChip('Muddati o‘tgan', 'overdue'),
          const SizedBox(width: 8),
          _filterChip('Katta qarz', 'large'),
          const SizedBox(width: 8),
          _filterChip('Yangi', 'new'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filterType == value;
    return GestureDetector(
      onTap: () => setState(() => _filterType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC62828) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  isSelected ? const Color(0xFFC62828) : Colors.grey.shade300),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12)),
      ),
    );
  }

  Widget _buildDebtorCard(SyncedCustomer debtor) {
    final overdueDays = _overdueDays(debtor);
    final isOverdue = debtor.overdueDebt > 0 || overdueDays > 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isOverdue
            ? Border.all(color: const Color(0xFFC62828).withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      const Color(0xFFC62828).withValues(alpha: 0.1),
                  child: Text(
                    debtor.name.isEmpty ? '?' : debtor.name.substring(0, 1),
                    style: const TextStyle(
                        color: Color(0xFFC62828), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debtor.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${debtor.code} • ${debtor.phone}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatAmount(debtor.currentDebt)} ${debtor.currency}',
                      style: const TextStyle(
                          color: Color(0xFFC62828),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? const Color(0xFFC62828).withValues(alpha: 0.1)
                            : const Color(0xFFFF6F00).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        overdueDays == 0 ? 'joriy' : '$overdueDays kun',
                        style: TextStyle(
                          color: isOverdue
                              ? const Color(0xFFC62828)
                              : const Color(0xFFFF6F00),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(
                    'Oxirgi to‘lov',
                    debtor.lastPaymentDate == null
                        ? '-'
                        : _formatDate(debtor.lastPaymentDate!)),
                const SizedBox(width: 8),
                _infoChip('Buyurtmalar', '${debtor.totalOrders} ta'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAction('Qo‘ng‘iroq: ${debtor.phone}'),
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('Qo‘ng‘iroq'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAction('SMS: ${debtor.phone}'),
                    icon: const Icon(Icons.sms, size: 16),
                    label: const Text('SMS'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/payments/collect'),
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('To‘lov'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
            color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)),
        child: Column(
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            Text(label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  int _overdueDays(SyncedCustomer debtor) {
    if (debtor.lastPaymentDate == null) return debtor.overdueDebt > 0 ? 31 : 0;
    return DateTime.now().difference(debtor.lastPaymentDate!).inDays;
  }

  String _formatAmount(num amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  void _export(List<SyncedCustomer> debtors) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${debtors.length} ta qarzdor eksportga tayyorlandi')));
  }

  void _sendReminders(List<SyncedCustomer> debtors) {
    if (debtors.isEmpty) {
      _showAction('Eslatma yuboriladigan qarzdor topilmadi');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eslatma yuborish'),
        content:
            Text('${debtors.length} ta qarzdorga SMS eslatma yuborilsinmi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAction('Eslatmalar yuborildi');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0)),
            child: const Text('Yuborish'),
          ),
        ],
      ),
    );
  }

  void _showAction(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
