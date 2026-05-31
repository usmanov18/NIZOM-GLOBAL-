import 'package:flutter/material.dart';

// ============================================================
// ERROR STATE WIDGETS - Xatolik holati widgetlari
// ============================================================

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final Color? color;

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onRetry,
    this.retryText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color ?? Colors.red.shade300),
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
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Qayta urinish'),
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

// ============ SPECIFIC ERROR STATES ============

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Internetga ulanmagan',
      subtitle: 'Tarmoq sozlamalarini tekshiring va qayta urinib ko\'ring',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      color: Colors.orange,
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;
  const ServerErrorWidget({super.key, this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Server xatosi',
      subtitle: message ??
          'Server bilan bog\'lanishda muammo. Keyinroq qayta urinib ko\'ring.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
      color: Colors.red,
    );
  }
}

class TimeoutErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  const TimeoutErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Vaqt tugadi',
      subtitle: 'Server javob bermadi. Qayta urinib ko\'ring.',
      icon: Icons.timer_off,
      onRetry: onRetry,
      color: Colors.orange,
    );
  }
}

class NotFoundWidget extends StatelessWidget {
  final String? itemName;
  const NotFoundWidget({super.key, this.itemName});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: '${itemName ?? "Ma'lumot"} topilmadi',
      subtitle: 'Qidiruv shartlariga mos natija yo\'q',
      icon: Icons.search_off,
      color: Colors.grey,
    );
  }
}

class PermissionErrorWidget extends StatelessWidget {
  final VoidCallback? onSettings;
  const PermissionErrorWidget({super.key, this.onSettings});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Ruxsat berilmagan',
      subtitle: 'Sozlamalardan ruxsat bering',
      icon: Icons.lock_outline,
      onRetry: onSettings,
      retryText: 'Sozlamalar',
      color: Colors.orange,
    );
  }
}
