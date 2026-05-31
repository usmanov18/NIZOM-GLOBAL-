import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dashboard widget - Agent bosh sahifasi uchun
class HomeDashboardWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback? onOrderTap;
  final VoidCallback? onSalesTap;
  final VoidCallback? onVisitsTap;
  final VoidCallback? onPaymentsTap;

  const HomeDashboardWidget({
    super.key,
    required this.stats,
    this.onOrderTap,
    this.onSalesTap,
    this.onVisitsTap,
    this.onPaymentsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // KPI Progress
        _buildKPISection(),
        const SizedBox(height: 16),

        // Stats Grid
        _buildStatsGrid(),
        const SizedBox(height: 16),

        // Quick Actions
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildKPISection() {
    final progress = (stats['planPercentage'] ?? 0.0) as double;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Oylik reja',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _kpiItem('Sotuv',
                  '${_formatM(stats['monthlyFact'])}M / ${_formatM(stats['monthlyPlan'])}M'),
              _kpiItem('Tashriflar',
                  '${stats['visitFact']} / ${stats['visitPlan']}'),
              _kpiItem('To\'lovlar', '${_formatM(stats['collectionFact'])}M'),
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
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
      ],
    );
  }

  Widget _buildStatsGrid() {
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
          '${stats['todayOrders']}',
          '${stats['pendingOrders']} kutilmoqda',
          Icons.shopping_cart,
          const Color(0xFF1565C0),
          onOrderTap,
        ),
        _statCard(
          'Sotuv',
          '${_formatM(stats['todaySales'])}M',
          'O\'rt: ${_formatM(stats['avgOrderAmount'])}M',
          Icons.attach_money,
          const Color(0xFF2E7D32),
          onSalesTap,
        ),
        _statCard(
          'Tashriflar',
          '${stats['todayVisits']}/${stats['completedVisits']}',
          '${stats['visitPercentage']}% bajarildi',
          Icons.location_on,
          const Color(0xFF00897B),
          onVisitsTap,
        ),
        _statCard(
          'To\'lovlar',
          '${_formatM(stats['todayCollections'])}M',
          '${stats['collectionCount']} ta',
          Icons.payment,
          const Color(0xFFFF6F00),
          onPaymentsTap,
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
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
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _quickAction(
            'Yangi buyurtma',
            Icons.add_shopping_cart,
            const Color(0xFF1565C0),
            onOrderTap ?? () => context.push('/orders/create')),
        const SizedBox(width: 10),
        _quickAction('To\'lov', Icons.payment, const Color(0xFF2E7D32),
            onPaymentsTap ?? () => context.push('/payments/collect')),
        const SizedBox(width: 10),
        _quickAction('Tashrif', Icons.check_circle, const Color(0xFF00897B),
            onVisitsTap ?? () => context.push('/agent/visits')),
        const SizedBox(width: 10),
        _quickAction('Barcode', Icons.qr_code_scanner, const Color(0xFFFF6F00),
            () => context.push('/products/barcode')),
      ],
    );
  }

  Widget _quickAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
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
      ),
    );
  }

  String _formatM(dynamic value) {
    if (value == null) return '0';
    return (value / 1000000).toStringAsFixed(0);
  }
}
