import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../products/domain/repositories/product_portfolio_repository.dart';
import '../../../products/domain/entities/product_portfolio.dart';

/// Agent profili - Shaxsiy ma'lumotlar, KPI, statistika
class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mening profilim'),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  _showComingSoon(context, 'Profil tahrirlash oynasi ochildi')),
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/notifications/settings')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(),
            const SizedBox(height: 20),

            // Portfolio access
            _buildPortfolioAccessSection(),
            const SizedBox(height: 20),

            // KPI cards
            _buildKPISection(),
            const SizedBox(height: 20),

            // Today stats
            _buildTodayStats(),
            const SizedBox(height: 20),

            // Monthly progress
            _buildMonthlyProgress(),
            const SizedBox(height: 20),

            // Achievements
            _buildAchievements(),
            const SizedBox(height: 20),

            // Quick stats
            _buildQuickStats(),
            const SizedBox(height: 20),

            // Settings shortcuts
            _buildSettingsShortcuts(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(20),
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
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Text(
                  'AK',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          const Text(
            'Karimov Alisher',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Role & Code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Agent • AG001',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Contact info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactItem(Icons.phone, '+998 90 123 45 67'),
              _buildContactItem(Icons.email, 'alisher@nizom.uz'),
              _buildContactItem(Icons.location_on, 'Toshkent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Future<List<ProductPortfolio>> _loadAssignedPortfolios() async {
    final authResult = await getIt<AuthRepository>().getCurrentUser();
    final user = authResult.fold((_) => null, (value) => value);
    final result =
        await getIt<ProductPortfolioRepository>().getAssignedPortfolios(
      user?.id ?? 'demo_agent',
      user?.role ?? 'agent',
    );
    return result.fold((_) => <ProductPortfolio>[], (portfolios) => portfolios);
  }

  Widget _buildPortfolioAccessSection() {
    return FutureBuilder<List<ProductPortfolio>>(
      future: _loadAssignedPortfolios(),
      builder: (context, snapshot) {
        final portfolios = snapshot.data ?? [];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2, color: Color(0xFF1565C0)),
                  SizedBox(width: 8),
                  Text('Mening portfellarim',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const LinearProgressIndicator(minHeight: 2)
              else if (portfolios.isEmpty)
                const Text('Portfel biriktirilmagan')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: portfolios.map((portfolio) {
                    return Chip(
                      avatar: CircleAvatar(
                          child: Text('${portfolio.productIds.length}')),
                      label: Text(
                          '${portfolio.name} • ${portfolio.sourceSystem.name.toUpperCase()}'),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKPISection() {
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
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
              SizedBox(width: 8),
              Text('KPI Ko\'rsatkichlar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 20),
          _buildKPIRow('Oylik sotuv', '78%', 0.78, const Color(0xFF2E7D32)),
          _buildKPIRow('Tashriflar', '85%', 0.85, const Color(0xFF1565C0)),
          _buildKPIRow(
              'To\'lov yig\'ish', '92%', 0.92, const Color(0xFF00897B)),
          _buildKPIRow('Yangi mijozlar', '60%', 0.6, const Color(0xFFFF6F00)),
        ],
      ),
    );
  }

  Widget _buildKPIRow(String label, String percent, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(percent,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: [
        _miniStat(
            'Buyurtmalar', '12', Icons.shopping_cart, const Color(0xFF1565C0)),
        _miniStat('Sotuv', '45M', Icons.attach_money, const Color(0xFF2E7D32)),
        _miniStat(
            'Tashriflar', '8', Icons.location_on, const Color(0xFF00897B)),
        _miniStat('To\'lovlar', '23M', Icons.payment, const Color(0xFFFF6F00)),
      ],
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style:
                  TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Oylik reja',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('567M so\'m',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Text('/ 720M so\'m',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.78,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text('78% bajarildi • 8 kun qoldi',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
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
          const Row(
            children: [
              Icon(Icons.military_tech, color: Color(0xFFFFD700)),
              SizedBox(width: 8),
              Text('Yutuqlar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _achievementBadge('🏆', 'Top Agent', const Color(0xFFFFD700)),
                _achievementBadge('🎯', 'Maqsad', const Color(0xFF1565C0)),
                _achievementBadge('⭐', '5 Yulduz', const Color(0xFFFF6F00)),
                _achievementBadge(
                    '📦', '1000 Buyurtma', const Color(0xFF2E7D32)),
                _achievementBadge('🤝', '500 Mijoz', const Color(0xFF00897B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementBadge(String emoji, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
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
          const Text('Umumiy statistika',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Divider(height: 20),
          _quickStatRow('Jami buyurtmalar', '1,234 ta', Icons.shopping_bag),
          _quickStatRow('Jami sotuv', '2.3 mlrd so\'m', Icons.attach_money),
          _quickStatRow('Jami tashriflar', '3,456 ta', Icons.location_on),
          _quickStatRow('Jami to\'lovlar', '1.8 mlrd so\'m', Icons.payment),
          _quickStatRow('Faol mijozlar', '156 ta', Icons.people),
          _quickStatRow('Ish staji', '2 yil 3 oy', Icons.work),
        ],
      ),
    );
  }

  Widget _quickStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSettingsShortcuts(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          _settingsTile(
              Icons.lock,
              'Parolni o\'zgartirish',
              () => _showComingSoon(
                  context, 'Parolni o‘zgartirish oynasi ochildi')),
          _settingsTile(Icons.fingerprint, 'Biometrik autentifikatsiya',
              () => _showComingSoon(context, 'Biometrik sozlama tanlandi')),
          _settingsTile(Icons.language, 'Til',
              () => _showComingSoon(context, 'Til sozlamasi tanlandi')),
          _settingsTile(Icons.dark_mode, 'Mavzu',
              () => _showComingSoon(context, 'Mavzu sozlamasi tanlandi')),
          _settingsTile(Icons.notifications, 'Bildirishnomalar',
              () => context.push('/notifications/settings')),
          _settingsTile(Icons.help, 'Yordam',
              () => _showComingSoon(context, 'Yordam oynasi ochildi')),
          _settingsTile(Icons.info, 'Ilova haqida',
              () => _showComingSoon(context, 'NIZOM GLOBAL v1.0.0')),
          const Divider(),
          _settingsTile(Icons.logout, 'Chiqish', () => _confirmLogout(context),
              color: Colors.red, isLast: true),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tizimdan chiqish'),
        content: const Text('Haqiqatan ham akkauntdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Chiqish'),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, VoidCallback onTap,
      {Color? color, bool isLast = false}) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF1565C0)),
      title: Text(title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey.shade400),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
