import 'package:flutter/material.dart';

// ============================================================
// EMPTY STATE WIDGETS - Bo'sh holat widgetlari
// ============================================================

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? illustration;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.buttonText,
    this.onButtonPressed,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            illustration ?? Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center),
            ],
            if (onButtonPressed != null && buttonText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add),
                label: Text(buttonText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============ SPECIFIC EMPTY STATES ============

class EmptyOrdersWidget extends StatelessWidget {
  final VoidCallback? onCreateOrder;
  const EmptyOrdersWidget({super.key, this.onCreateOrder});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Buyurtmalar yo\'q',
      subtitle: 'Hali birorta buyurtma yaratmagansiz',
      icon: Icons.shopping_cart_outlined,
      buttonText: 'Yangi buyurtma',
      onButtonPressed: onCreateOrder,
    );
  }
}

class EmptyCustomersWidget extends StatelessWidget {
  final VoidCallback? onAddCustomer;
  const EmptyCustomersWidget({super.key, this.onAddCustomer});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Mijozlar topilmadi',
      subtitle: 'Qidiruv shartlariga mos mijoz yo\'q',
      icon: Icons.people_outline,
      buttonText: 'Mijoz qo\'shish',
      onButtonPressed: onAddCustomer,
    );
  }
}

class EmptyNotificationsWidget extends StatelessWidget {
  const EmptyNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: 'Bildirishnomalar yo\'q',
      subtitle: 'Yangi bildirishnomalar shu yerda ko\'rinadi',
      icon: Icons.notifications_none,
    );
  }
}

class EmptyChatWidget extends StatelessWidget {
  final VoidCallback? onStartChat;
  const EmptyChatWidget({super.key, this.onStartChat});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Xabarlar yo\'q',
      subtitle: 'Hali birorta suhbat boshlamagansiz',
      icon: Icons.chat_bubble_outline,
      buttonText: 'Suhbat boshlash',
      onButtonPressed: onStartChat,
    );
  }
}

class EmptySearchWidget extends StatelessWidget {
  final String query;
  const EmptySearchWidget({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Hech narsa topilmadi',
      subtitle: '"$query" bo\'yicha natija yo\'q',
      icon: Icons.search_off,
    );
  }
}

class EmptyCartWidget extends StatelessWidget {
  final VoidCallback? onContinue;
  const EmptyCartWidget({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Savat bo\'sh',
      subtitle: 'Mahsulotlarni katalogdan tanlang',
      icon: Icons.shopping_cart_outlined,
      buttonText: 'Xarid qilish',
      onButtonPressed: onContinue,
    );
  }
}

class EmptyVisitsWidget extends StatelessWidget {
  final VoidCallback? onAddVisit;
  const EmptyVisitsWidget({super.key, this.onAddVisit});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Bugun tashriflar yo\'q',
      subtitle: 'Bugungi kun uchun tashriflar rejalashtirilmagan',
      icon: Icons.calendar_today_outlined,
      buttonText: 'Tashrif qo\'shish',
      onButtonPressed: onAddVisit,
    );
  }
}
