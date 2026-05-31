import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/agent_dashboard_bloc.dart';
import '../../domain/entities/agent_dashboard.dart';

/// Agent Bosh sahifa - To'liq Dashboard
class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AgentDashboardBloc>().add(AgentDashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Bosh sahifa'),
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: _buildBadge(3),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncData,
          ),
        ],
      ),
      body: BlocBuilder<AgentDashboardBloc, AgentDashboardState>(
        builder: (context, state) {
          if (state is AgentDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AgentDashboardLoaded) {
            return _buildDashboard(context, state.dashboard);
          }
          if (state is AgentDashboardError) {
            return _errorState(state.message);
          }
          return _emptyState();
        },
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text('Dashboard yuklanmadi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _syncData,
              icon: const Icon(Icons.refresh),
              label: const Text('Qayta yuklash'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _syncData,
        icon: const Icon(Icons.refresh),
        label: const Text('Dashboard yuklash'),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Badge(
      label: Text('$count', style: const TextStyle(fontSize: 10)),
      backgroundColor: Colors.red,
    );
  }

  Widget _buildDashboard(BuildContext context, AgentDashboard dashboard) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<AgentDashboardBloc>()
            .add(AgentDashboardRefreshRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            _buildWelcomeCard(dashboard),
            const SizedBox(height: 16),

            // KPI Progress
            _buildKPISection(dashboard.kpi),
            const SizedBox(height: 16),

            // Stats grid
            _buildStatsGrid(dashboard.stats),
            const SizedBox(height: 16),

            // Quick actions
            _buildQuickActions(context),
            const SizedBox(height: 16),

            // Today visits
            _buildTodayVisits(dashboard.todayVisits),
            const SizedBox(height: 16),

            // Recent orders
            _buildRecentOrders(dashboard.recentOrders),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AgentDashboard dashboard) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xayrli kun!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Karimov Alisher',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 8),
                    SizedBox(width: 4),
                    Text('Online',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickStat('Buyurtmalar', '${dashboard.stats.todayOrders}',
                  Icons.shopping_cart),
              _quickStat(
                  'Sotuv',
                  '${(dashboard.stats.todaySales / 1000000).toStringAsFixed(0)}M',
                  Icons.attach_money),
              _quickStat('Tashriflar', '${dashboard.stats.todayVisits}',
                  Icons.location_on),
              _quickStat(
                  'To\'lovlar',
                  '${(dashboard.stats.todaySales * 0.6 / 1000000).toStringAsFixed(0)}M',
                  Icons.payment),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildKPISection(AgentKPI kpi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Oylik reja',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text(
                '${(kpi.planPercentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: kpi.isPlanOnTrack
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFFF6F00),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: kpi.planPercentage,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                kpi.isPlanOnTrack
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFFF6F00),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _kpiItem('Sotuv',
                  '${(kpi.monthlyFact / 1000000).toStringAsFixed(0)}M / ${(kpi.monthlyPlan / 1000000).toStringAsFixed(0)}M'),
              _kpiItem('Tashriflar', '${kpi.visitFact} / ${kpi.visitPlan}'),
              _kpiItem('To\'lovlar',
                  '${(kpi.collectionFact / 1000000).toStringAsFixed(0)}M'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ],
    );
  }

  Widget _buildStatsGrid(AgentStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _statCard('Kutilayotgan', '${stats.pendingOrders}', Icons.pending,
            const Color(0xFFFF6F00)),
        _statCard('Yangi mijozlar', '${stats.newClients}', Icons.person_add,
            const Color(0xFF2E7D32)),
        _statCard(
            'O\'rt. buyurtma',
            '${(stats.avgOrderAmount / 1000000).toStringAsFixed(1)}M',
            Icons.analytics,
            const Color(0xFF1565C0)),
        _statCard(
            'Qarzdorlik',
            '${(stats.totalDebt / 1000000).toStringAsFixed(0)}M',
            Icons.money_off,
            const Color(0xFFC62828)),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tezkor harakatlar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _actionButton(
                    'Yangi buyurtma',
                    Icons.add_shopping_cart,
                    const Color(0xFF1565C0),
                    () => context.push('/orders/create'))),
            const SizedBox(width: 10),
            Expanded(
                child: _actionButton(
                    'To\'lov',
                    Icons.payment,
                    const Color(0xFF2E7D32),
                    () => context.push('/payments/collect'))),
            const SizedBox(width: 10),
            Expanded(
                child: _actionButton(
                    'Tashrif',
                    Icons.check_circle,
                    const Color(0xFF00897B),
                    () => context.go('/agent/visits'))),
            const SizedBox(width: 10),
            Expanded(
                child: _actionButton(
                    'Barcode',
                    Icons.qr_code_scanner,
                    const Color(0xFFFF6F00),
                    () => context.push('/products/barcode'))),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayVisits(List<AgentVisit> visits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bugungi tashriflar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(
                '${visits.where((v) => v.isCompleted).length}/${visits.length}',
                style: const TextStyle(
                    color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        ...visits.take(3).map((visit) => _buildVisitCard(visit)),
      ],
    );
  }

  Widget _buildVisitCard(AgentVisit visit) {
    Color statusColor;
    String statusText;

    switch (visit.status) {
      case 'completed':
        statusColor = const Color(0xFF2E7D32);
        statusText = 'Bajarildi';
        break;
      case 'in_progress':
        statusColor = const Color(0xFFFF6F00);
        statusText = 'Jarayonda';
        break;
      default:
        statusColor = const Color(0xFF1565C0);
        statusText = 'Rejalangan';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    '${visit.scheduledTime.hour}:${visit.scheduledTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visit.customerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
                Text(visit.address,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(statusText,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(List<AgentOrder> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('So\'nggi buyurtmalar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton(
                onPressed: () => context.go('/agent/orders'),
                child: const Text('Barchasi')),
          ],
        ),
        const SizedBox(height: 12),
        ...orders.take(3).map((order) => _buildOrderCard(order)),
      ],
    );
  }

  Widget _buildOrderCard(AgentOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag,
                color: Color(0xFF1565C0), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.orderNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(order.customerName,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${(order.amount / 1000000).toStringAsFixed(1)}M',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1565C0))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(order.status,
                    style: TextStyle(
                        color: _getStatusColor(order.status), fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFFF6F00);
      case 'delivered':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  void _syncData() {
    context.read<AgentDashboardBloc>().add(AgentDashboardRefreshRequested());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Dashboard yangilanmoqda...'),
          backgroundColor: Color(0xFF1565C0)),
    );
  }
}
