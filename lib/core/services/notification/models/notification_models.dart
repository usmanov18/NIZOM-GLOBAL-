import 'package:equatable/equatable.dart';

// ============================================================
// NOTIFICATION MODELS - Bildirishnomalar
// ============================================================

/// Bildirishnoma turi
enum NotificationType {
  // Agent uchun
  newTask,
  orderConfirmed,
  orderCancelled,
  paymentReceived,
  lowStock,
  promotion,
  message,
  systemAlert,

  // Haydovchi uchun
  newDelivery,
  routeChanged,
  deliveryAssigned,

  // Admin uchun
  agentOffline,
  deliveryFailed,
  largeOrder,
  highDebt,
  systemError,
  syncCompleted,
}

/// Bildirishnoma kanali
enum NotificationChannel {
  orders('orders_channel', 'Buyurtmalar', 'Buyurtmalar haqida'),
  payments('payments_channel', 'To\'lovlar', 'To\'lovlar haqida'),
  delivery('delivery_channel', 'Yetkazish', 'Yetkazish haqida'),
  tasks('tasks_channel', 'Vazifalar', 'Vazifalar haqida'),
  promotions('promos_channel', 'Aksiyalar', 'Aksiyalar haqida'),
  system('system_channel', 'Tizim', 'Tizim xabarlari'),
  chat('chat_channel', 'Xabarlar', 'Chat xabarlari'),
  sync('sync_channel', 'Sinxronlash', 'Sinxronlash haqida');

  final String id;
  final String name;
  final String description;

  const NotificationChannel(this.id, this.name, this.description);
}

/// Bildirishnoma
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationChannel channel;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? actionUrl;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.channel,
    this.data,
    required this.createdAt,
    required this.isRead,
    this.imageUrl,
    this.actionUrl,
  });

  AppNotification markAsRead() {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      channel: channel,
      data: data,
      createdAt: createdAt,
      isRead: true,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotificationType.systemAlert,
      ),
      channel: NotificationChannel.values.firstWhere(
        (c) => c.id == json['channel'],
        orElse: () => NotificationChannel.system,
      ),
      data: json['data'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      imageUrl: json['image_url'],
      actionUrl: json['action_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'channel': channel.id,
        'data': data,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
        'image_url': imageUrl,
        'action_url': actionUrl,
      };

  @override
  List<Object?> get props => [id, isRead];
}

/// Notification settings
class NotificationSettings extends Equatable {
  final bool pushEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final Map<String, bool> channelSettings;
  final QuietHours? quietHours;

  const NotificationSettings({
    required this.pushEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.channelSettings,
    this.quietHours,
  });

  bool isChannelEnabled(String channelId) {
    return pushEnabled && (channelSettings[channelId] ?? true);
  }

  @override
  List<Object?> get props => [pushEnabled, channelSettings];
}

/// Quiet hours
class QuietHours extends Equatable {
  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const QuietHours({
    required this.enabled,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  bool get isQuietNow {
    if (!enabled) return false;
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  @override
  List<Object?> get props => [enabled, startHour, endHour];
}
