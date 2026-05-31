import 'dart:async';
import 'dart:convert';
import 'models/notification_models.dart';
import 'push_notification_service.dart';

// ============================================================
// SMART NOTIFICATION SERVICE - Aqlli bildirishnomalar
// ============================================================

class SmartNotificationService {
  static final SmartNotificationService _instance =
      SmartNotificationService._internal();
  factory SmartNotificationService() => _instance;
  SmartNotificationService._internal();

  final List<ScheduledSmartNotification> _scheduled = [];
  final List<Timer> _timers = [];

  List<ScheduledSmartNotification> get scheduledNotifications =>
      List.unmodifiable(_scheduled);

  // ============ SCHEDULING ============

  /// Bildirishnoma rejalashtirish
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    Map<String, dynamic>? data,
    String channel = 'general',
  }) async {
    final notification = ScheduledSmartNotification(
      id: id,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      data: data,
      channel: channel,
    );
    _scheduled.removeWhere((item) => item.id == id);
    _scheduled.add(notification);

    final delay = scheduledAt.difference(DateTime.now());
    if (delay <= Duration.zero) {
      await _dispatch(notification);
      return;
    }

    _timers.add(Timer(delay, () {
      _dispatch(notification);
    }));
  }

  /// Takrorlanuvchi bildirishnoma
  Future<void> scheduleRepeating({
    required String id,
    required String title,
    required String body,
    required RepeatInterval interval,
    Map<String, dynamic>? data,
  }) async {
    final duration = switch (interval) {
      RepeatInterval.daily => const Duration(days: 1),
      RepeatInterval.weekly => const Duration(days: 7),
      RepeatInterval.monthly => const Duration(days: 30),
    };
    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledAt: DateTime.now().add(duration),
      data: {...?data, 'repeat': interval.name},
    );
  }

  // ============ SMART TRIGGERS ============

  /// GPS asosida bildirishnoma
  Future<void> scheduleLocationTrigger({
    required String id,
    required String title,
    required String body,
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledAt: DateTime.now(),
      data: {
        'type': 'location_trigger',
        'latitude': latitude,
        'longitude': longitude,
        'radius_meters': radiusMeters,
      },
      channel: 'alerts',
    );
  }

  /// Ombor ogohlantirishi
  Future<void> checkStockAlerts(List<Map<String, dynamic>> products) async {
    for (final product in products) {
      final stock = product['available_quantity'] as int;
      final threshold = product['reorder_level'] as int? ?? 10;

      if (stock <= threshold) {
        await scheduleNotification(
          id: 'stock_${product['id']}',
          title: 'Ombor ogohlantirishi',
          body: '${product['name']} omborda $stock dona qoldi',
          scheduledAt: DateTime.now(),
          data: {'type': 'stock_alert', 'product_id': product['id']},
          channel: 'alerts',
        );
      }
    }
  }

  /// Qarzdorlik ogohlantirishi
  Future<void> checkDebtAlerts(List<Map<String, dynamic>> customers) async {
    for (final customer in customers) {
      final debt = customer['current_debt'] as double;

      if (debt > 10000000) {
        await scheduleNotification(
          id: 'debt_${customer['id']}',
          title: 'Yuqori qarzdorlik',
          body: '${customer['name']} - ${_formatAmount(debt)} so\'m qarz',
          scheduledAt: DateTime.now(),
          data: {'type': 'debt_alert', 'customer_id': customer['id']},
          channel: 'alerts',
        );
      }
    }
  }

  /// Tashrif eslatmasi
  Future<void> scheduleVisitReminder({
    required String visitId,
    required String customerName,
    required DateTime visitTime,
    int minutesBefore = 30,
  }) async {
    await scheduleNotification(
      id: 'visit_$visitId',
      title: 'Tashrif eslatmasi',
      body: '$customerName ga tashrif ${_formatTime(visitTime)} da',
      scheduledAt: visitTime.subtract(Duration(minutes: minutesBefore)),
      data: {'type': 'visit_reminder', 'visit_id': visitId},
      channel: 'tasks',
    );
  }

  // ============ QUIET HOURS ============

  bool isQuietHours() {
    final now = DateTime.now();
    // 22:00 - 07:00
    return now.hour >= 22 || now.hour < 7;
  }

  Future<void> _dispatch(ScheduledSmartNotification notification) async {
    if (isQuietHours() && notification.channel != 'alerts') return;
    await PushNotificationService().showNotification(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.body,
      payload: jsonEncode(notification.data ?? {'id': notification.id}),
      channel: _channelFromString(notification.channel),
    );
  }

  NotificationChannel _channelFromString(String channel) {
    return NotificationChannel.values.firstWhere(
      (item) =>
          item.id == channel ||
          item.name.toLowerCase() == channel.toLowerCase() ||
          item.name == channel,
      orElse: () => channel == 'alerts'
          ? NotificationChannel.system
          : NotificationChannel.system,
    );
  }

  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}

enum RepeatInterval {
  daily,
  weekly,
  monthly,
}

class ScheduledSmartNotification {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final Map<String, dynamic>? data;
  final String channel;

  const ScheduledSmartNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.data,
    required this.channel,
  });
}
