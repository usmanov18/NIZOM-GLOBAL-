import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../products/domain/repositories/product_portfolio_repository.dart';
import '../../../products/domain/entities/product_portfolio.dart';
import '../bloc/supervisor_bloc.dart';
import '../../domain/entities/supervisor_entities.dart';

/// Supervisor Dashboard - Agent monitoring va boshqaruv
class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() =>
      _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupervisorBloc>().add(
          SupervisorDashboardLoadRequested(supervisorId: 'sup_1'),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => context.push('/tracking'),
            tooltip: 'Xarita',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: BlocBuilder<SupervisorBloc, SupervisorState>(
        builder: (context, state) {
          if (state is SupervisorLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SupervisorDashboardLoaded) {
            return _buildDashboard(context, state.dashboard);
          }
          if (state is SupervisorError) {
            return _errorState(state.message);
          }
          return _emptyState(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard yuklanmagan',
            message:
                'Supervisor dashboard ma’lumotlarini yuklash uchun yangilang.',
            action: ElevatedButton.icon(
                onPressed: _reloadDashboard,
                icon: const Icon(Icons.refresh),
                label: const Text('Yuklash')),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTask,
        icon: const Icon(Icons.add_task),
        label: const Text('Vazifa yaratish'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  void _reloadDashboard() {
    context
        .read<SupervisorBloc>()
        .add(SupervisorDashboardLoadRequested(supervisorId: 'sup_1'));
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF00695C)]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.supervisor_account,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(height: 10),
                const Text('Supervisor Panel',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text('NIZOM GLOBAL',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12)),
              ],
            ),
          ),
          _drawerItem(Icons.dashboard, 'Dashboard', true, _reloadDashboard),
          _drawerItem(Icons.people, 'Agentlar', false,
              () => context.go('/supervisor/agents')),
          _drawerItem(
              Icons.map, 'Xarita', false, () => context.go('/supervisor/map')),
          _drawerItem(Icons.assignment, 'Vazifalar', false,
              () => context.push('/tasks')),
          _drawerItem(Icons.shopping_cart, 'Buyurtmalar', false,
              () => context.push('/orders/history')),
          _drawerItem(Icons.inventory_2, 'Portfellar (ko‘rish)', false,
              _showReadOnlyPortfolioSheet),
          const Divider(),
          _drawerItem(Icons.bar_chart, 'Hisobotlar', false,
              () => context.push('/reports/daily')),
          _drawerItem(Icons.settings, 'Sozlamalar', false,
              () => context.push('/notifications/settings')),
        ],
      ),
    );
  }

  Widget _drawerItem(
      IconData icon, String title, bool selected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon,
          color: selected ? const Color(0xFF00897B) : Colors.grey.shade600),
      title: Text(title,
          style: TextStyle(
              color: selected ? const Color(0xFF00897B) : null,
              fontWeight: selected ? FontWeight.w600 : null)),
      selected: selected,
      selectedTileColor: const Color(0xFF00897B).withValues(alpha: 0.1),
      onTap: onTap,
    );
  }

  Widget _buildDashboard(BuildContext context, SupervisorDashboard d) {
    return RefreshIndicator(
      onRefresh: () async => _reloadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent status overview
            _buildAgentOverview(d),
            const SizedBox(height: 20),

            // Today stats
            _buildSectionTitle('Bugungi ko\'rsatkichlar'),
            const SizedBox(height: 12),
            _buildTodayStats(d),
            const SizedBox(height: 20),

            // Agent list
            _buildSectionTitle('Agentlar holati'),
            const SizedBox(height: 12),
            _buildAgentList(d),
            const SizedBox(height: 20),

            // Portfolio read-only overview
            _buildSectionTitle('Agent portfellari (faqat ko‘rish)'),
            const SizedBox(height: 12),
            _buildPortfolioReadOnlyOverview(),
            const SizedBox(height: 20),

            // Tasks
            _buildSectionTitle('Vazifalar'),
            const SizedBox(height: 12),
            _buildTasksSummary(d),
            const SizedBox(height: 20),

            // Alerts
            _buildAlerts(d),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentOverview(SupervisorDashboard d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF00897B), Color(0xFF00695C)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF00897B).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bugun, ${d.date.day}.${d.date.month}.${d.date.year}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(d.supervisorName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${d.onlineAgents}/${d.totalAgents} online',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _agentStat('Online', '${d.onlineAgents}', Icons.circle,
                  const Color(0xFF4CAF50)),
              _agentStat('Yo\'lda', '${d.agentsOnRoute}', Icons.local_shipping,
                  const Color(0xFF2196F3)),
              _agentStat('Tashrifda', '${d.agentsVisiting}', Icons.store,
                  const Color(0xFFFF9800)),
              _agentStat('Tanaffus', '${d.agentsOnBreak}', Icons.coffee,
                  const Color(0xFF9E9E9E)),
              _agentStat('Offline', '${d.offlineAgents}', Icons.circle,
                  const Color(0xFFE53935)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _agentStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600));
  }

  Widget _buildTodayStats(SupervisorDashboard d) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard(
            'Buyurtmalar',
            '${d.todayOrders}',
            '${(d.todaySales / 1000000).toStringAsFixed(0)}M so\'m',
            Icons.shopping_cart,
            const Color(0xFF1565C0)),
        _statCard(
            'Tashriflar',
            '${d.todayVisits}/${d.completedVisits}',
            '${(d.visitCompletionRate * 100).toStringAsFixed(0)}% bajarildi',
            Icons.location_on,
            const Color(0xFF2E7D32)),
        _statCard(
            'To\'lovlar',
            '${(d.todayCollections / 1000000).toStringAsFixed(0)}M',
            'Qarz: ${(d.outstandingDebt / 1000000).toStringAsFixed(0)}M',
            Icons.payment,
            const Color(0xFFFF6F00)),
        _statCard(
            'Kutilayotgan',
            '${d.pendingOrders}',
            '${d.confirmedOrders} tasdiqlangan',
            Icons.pending,
            const Color(0xFF00897B)),
      ],
    );
  }

  Widget _statCard(
      String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            Icon(icon, color: color, size: 20),
          ]),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAgentList(SupervisorDashboard dashboard) {
    final agents = <AgentStatus>[
      ...dashboard.topAgents,
      ...dashboard.bottomAgents
    ];
    if (agents.isEmpty) {
      return _emptyState(
        icon: Icons.people_outline,
        title: 'Agentlar ro‘yxati bo‘sh',
        message: 'Supervisor uchun agent statuslari real API orqali yuklanadi.',
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(children: agents.map(_buildAgentRow).toList()),
    );
  }

  Widget _buildAgentRow(AgentStatus agent) {
    final status = agent.currentStatus;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'online':
        statusColor = const Color(0xFF4CAF50);
        statusText = 'Online';
        statusIcon = Icons.circle;
        break;
      case 'on_route':
        statusColor = const Color(0xFF2196F3);
        statusText = 'Yo‘lda';
        statusIcon = Icons.local_shipping;
        break;
      case 'visiting':
        statusColor = const Color(0xFFFF9800);
        statusText = 'Tashrifda';
        statusIcon = Icons.store;
        break;
      case 'break':
        statusColor = const Color(0xFF9E9E9E);
        statusText = 'Tanaffus';
        statusIcon = Icons.coffee;
        break;
      default:
        statusColor = const Color(0xFFE53935);
        statusText = 'Offline';
        statusIcon = Icons.circle;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        child: Text(
            agent.agentCode.isEmpty
                ? 'A'
                : agent.agentCode.substring(
                    0, agent.agentCode.length < 2 ? agent.agentCode.length : 2),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(agent.agentName,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(statusIcon, color: statusColor, size: 12),
            const SizedBox(width: 4),
            Text(statusText,
                style: TextStyle(color: statusColor, fontSize: 12)),
            const SizedBox(width: 8),
            Text(
                '• ${agent.todayOrders} buyurtma • ${agent.todayVisits} tashrif',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ]),
        ],
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
            icon: const Icon(Icons.call, size: 18),
            onPressed: () =>
                _showAgentAction('${agent.agentName}: ${agent.phone}'),
            color: const Color(0xFF2E7D32)),
        IconButton(
            icon: const Icon(Icons.message, size: 18),
            onPressed: () => context.push('/chat'),
            color: const Color(0xFF1565C0)),
      ]),
      onTap: () => _showAgentAction('${agent.agentName} tafsilotlari ochildi'),
    );
  }

  List<String> _agentPortfolioIds(int index) {
    if (index % 5 == 0) return ['pf_energy_premium'];
    if (index % 3 == 0) return ['pf_beverages', 'pf_energy_premium'];
    if (index % 2 == 0) return ['pf_beverages', 'pf_snacks'];
    return ['pf_beverages'];
  }

  Widget _buildSupervisorPortfolioBadges(List<String> portfolioIds) {
    return Wrap(
      spacing: 4,
      children: portfolioIds.map((id) {
        final color = _portfolioColor(id);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4)),
          child: Text(_portfolioShortName(id),
              style: TextStyle(
                  color: color, fontSize: 9, fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }

  Future<List<ProductPortfolio>> _loadPortfolios(
      ProductPortfolioRepository repository) async {
    final result = await repository.getPortfolios();
    return result.fold(
        (_) => const <ProductPortfolio>[], (portfolios) => portfolios);
  }

  Widget _buildPortfolioReadOnlyOverview() {
    final repository = getIt<ProductPortfolioRepository>();
    return FutureBuilder<List<ProductPortfolio>>(
      future: _loadPortfolios(repository),
      builder: (context, snapshot) {
        final portfolios = snapshot.data ?? const <ProductPortfolio>[];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.visibility, color: Color(0xFF00897B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Supervisor portfellarni boshqara olmaydi — faqat nazorat/ko‘rish huquqi.',
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              ...portfolios
                  .map((portfolio) => _portfolioOverviewRow(portfolio)),
            ],
          ),
        );
      },
    );
  }

  Widget _portfolioOverviewRow(ProductPortfolio portfolio) {
    final color = _portfolioColor(portfolio.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(_portfolioShortName(portfolio.id),
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(portfolio.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                    '${portfolio.sourceSystem.name.toUpperCase()} • ${portfolio.assortmentType.name} • ${portfolio.productIds.length} SKU',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  void _showReadOnlyPortfolioSheet() {
    Navigator.pop(context);
    final repository = getIt<ProductPortfolioRepository>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => FutureBuilder<List<ProductPortfolio>>(
        future: _loadPortfolios(repository),
        builder: (context, snapshot) {
          final portfolios = snapshot.data ?? const <ProductPortfolio>[];
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                const Text('Portfellar — faqat ko‘rish',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                    'Portfolio ruxsatlarini faqat admin boshqaradi. Supervisor bu yerda nazorat qiladi.',
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                ...portfolios.map((portfolio) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: _portfolioColor(portfolio.id)
                                .withValues(alpha: 0.1),
                            child: Text(_portfolioShortName(portfolio.id))),
                        title: Text(portfolio.name),
                        subtitle: Text(
                            '${portfolio.code} • ${portfolio.sourceSystem.name.toUpperCase()} • ${portfolio.productIds.length} SKU'),
                        trailing: const Icon(Icons.visibility),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _portfolioColor(String id) {
    switch (id) {
      case 'pf_beverages':
        return const Color(0xFF1565C0);
      case 'pf_snacks':
        return const Color(0xFF00897B);
      case 'pf_energy_premium':
        return const Color(0xFF6A1B9A);
      default:
        return Colors.grey;
    }
  }

  String _portfolioShortName(String id) {
    switch (id) {
      case 'pf_beverages':
        return 'BEV';
      case 'pf_snacks':
        return 'SNK';
      case 'pf_energy_premium':
        return 'PRM';
      default:
        return id;
    }
  }

  Widget _buildTasksSummary(SupervisorDashboard d) {
    return Row(children: [
      Expanded(
        child: _taskCard('Kutilmoqda', '${d.pendingTasks}',
            const Color(0xFFFF6F00), Icons.pending_actions),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _taskCard('O\'tgan muddat', '${d.overdueTasks}',
            const Color(0xFFC62828), Icons.warning),
      ),
    ]);
  }

  Widget _taskCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title,
              style:
                  TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _buildAlerts(SupervisorDashboard d) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSectionTitle('Ogohlantirishlar'),
      const SizedBox(height: 12),
      if (d.offlineAgents > 0)
        _alertItem('${d.offlineAgents} ta agent offline', Icons.wifi_off,
            const Color(0xFFC62828)),
      if (d.overdueTasks > 0)
        _alertItem('${d.overdueTasks} ta vazifa muddati o\'tdi', Icons.warning,
            const Color(0xFFFF6F00)),
      if (d.missedVisits > 0)
        _alertItem('${d.missedVisits} ta tashrif o\'tkazib yuborildi',
            Icons.event_busy, const Color(0xFFFF6F00)),
    ]);
  }

  Widget _alertItem(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w500, fontSize: 13))),
        Icon(Icons.chevron_right, color: color),
      ]),
    );
  }

  Widget _errorState(String message) => _emptyState(
        icon: Icons.error_outline,
        title: 'Xatolik',
        message: message,
        action: ElevatedButton.icon(
          onPressed: _reloadDashboard,
          icon: const Icon(Icons.refresh),
          label: const Text('Qayta urinish'),
        ),
      );

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade500),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600)),
          if (action != null) ...[
            const SizedBox(height: 12),
            action,
          ],
        ],
      ),
    );
  }

  void _createTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Yangi vazifa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: 'Agent',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: List.generate(
                  8,
                  (i) => DropdownMenuItem(
                      value: 'agent_$i', child: Text('Agent ${i + 1}'))),
              onChanged: (v) {},
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Vazifa nomi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Tavsif',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      labelText: 'Turi',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  items: const [
                    DropdownMenuItem(value: 'visit', child: Text('Tashrif')),
                    DropdownMenuItem(value: 'order', child: Text('Buyurtma')),
                    DropdownMenuItem(
                        value: 'collection', child: Text('To\'lov')),
                    DropdownMenuItem(value: 'other', child: Text('Boshqa')),
                  ],
                  onChanged: (v) {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      labelText: 'Muhimlik',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  items: const [
                    DropdownMenuItem(value: 'high', child: Text('Yuqori')),
                    DropdownMenuItem(value: 'medium', child: Text('O\'rta')),
                    DropdownMenuItem(value: 'low', child: Text('Past')),
                  ],
                  onChanged: (v) {},
                ),
              ),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Yaratish', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAgentAction(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
