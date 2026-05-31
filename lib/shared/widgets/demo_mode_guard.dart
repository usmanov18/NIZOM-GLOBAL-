import 'package:flutter/material.dart';

import '../../core/config/env_config.dart';

/// Demo/sample ma'lumotlarni productionda ko'rsatmaslik uchun guard.
class DemoModeGuard extends StatelessWidget {
  final Widget child;
  final String title;
  final String message;
  final IconData icon;

  const DemoModeGuard({
    super.key,
    required this.child,
    this.title = 'Demo ma’lumot o‘chirilgan',
    this.message =
        'Bu ekran production muhitda real API yoki cache orqali to‘ldiriladi.',
    this.icon = Icons.cloud_off_outlined,
  });

  @override
  Widget build(BuildContext context) {
    if (EnvConfig.isDemoMode) return child;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade500),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
