import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'models/notification_models.dart';

Future<void> pushNotificationBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

// ============================================================
// PUSH NOTIFICATION SERVICE - Professional Push Notifications
// ============================================================

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<AppNotification> _notificationController =
      StreamController<AppNotification>.broadcast();

  final StreamController<String> _tokenController =
      StreamController<String>.broadcast();

  String? _fcmToken;
  bool _initialized = false;
  int _badgeCount = 0;

  // Getters
  Stream<AppNotification> get notificationStream =>
      _notificationController.stream;
  Stream<String> get tokenStream => _tokenController.stream;
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _initialized;

  // ============ INITIALIZATION ============

  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Local notifications init
      await _initLocalNotifications();

      // Firebase init
      await _initFirebase();

      _initialized = true;
      debugPrint('Push notification service initialized');
      return true;
    } catch (e) {
      debugPrint('Push notification init error: $e');
      return false;
    }
  }

  Future<void> _initLocalNotifications() async {
    // Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android kanallarini yaratish
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Orders channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'orders_channel',
        'Buyurtmalar',
        description: 'Buyurtmalar haqida bildirishnomalar',
        importance: Importance.high,
        playSound: true,
      ),
    );

    // Delivery channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'delivery_channel',
        'Yetkazish',
        description: 'Yetkazish haqida bildirishnomalar',
        importance: Importance.high,
        playSound: true,
      ),
    );

    // Payments channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'payments_channel',
        'To\'lovlar',
        description: 'To\'lovlar haqida bildirishnomalar',
        importance: Importance.high,
        playSound: true,
      ),
    );

    // Tasks channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'tasks_channel',
        'Vazifalar',
        description: 'Vazifalar haqida bildirishnomalar',
        importance: Importance.high,
        playSound: true,
      ),
    );

    // Promotions channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'promos_channel',
        'Aksiyalar',
        description: 'Aksiyalar haqida bildirishnomalar',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
    );

    // System channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'system_channel',
        'Tizim',
        description: 'Tizim xabarlari',
        importance: Importance.defaultImportance,
        playSound: false,
      ),
    );

    // Sync channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'sync_channel',
        'Sinxronlash',
        description: 'Sinxronlash haqida',
        importance: Importance.low,
        playSound: false,
      ),
    );
  }

  Future<void> _initFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);
      _fcmToken = await FirebaseMessaging.instance.getToken();
      if (_fcmToken != null) _tokenController.add(_fcmToken!);
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        _fcmToken = token;
        _tokenController.add(token);
      });
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onBackgroundMessage(pushNotificationBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
      debugPrint('Firebase messaging initialized');
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
  }

  // ============ PERMISSION ============

  Future<bool> requestPermission() async {
    try {
      if (Platform.isIOS) {
        final result = await _localNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return result ?? false;
      }

      if (Platform.isAndroid) {
        final result = await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return result ?? false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ============ SHOW NOTIFICATION ============

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationChannel channel = NotificationChannel.system,
    String? imageUrl,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: 'ic_notification',
        largeIcon: imageUrl != null ? FilePathAndroidBitmap(imageUrl) : null,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(id, title, body, details,
          payload: payload);
    } catch (e) {
      debugPrint('Show notification error: $e');
    }
  }

  // ============ SPECIFIC NOTIFICATIONS ============

  Future<void> showOrderNotification({
    required String orderId,
    required String status,
    required String customerName,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'confirmed':
        title = 'Buyurtma tasdiqlandi ✅';
        body = '$customerName uchun buyurtma #$orderId tasdiqlandi';
        break;
      case 'shipped':
        title = 'Buyurtma jo\'natildi 🚚';
        body = 'Buyurtma #$orderId yo\'lda';
        break;
      case 'delivered':
        title = 'Buyurtma yetkazildi 📦';
        body = '$customerName ga buyurtma #$orderId yetkazildi';
        break;
      case 'cancelled':
        title = 'Buyurtma bekor qilindi ❌';
        body = 'Buyurtma #$orderId bekor qilindi';
        break;
      default:
        title = 'Buyurtma yangilandi';
        body = 'Buyurtma #$orderId holati yangilandi';
    }

    await showNotification(
      id: orderId.hashCode,
      title: title,
      body: body,
      payload: jsonEncode({'type': 'order', 'order_id': orderId}),
      channel: NotificationChannel.orders,
    );
  }

  Future<void> showPaymentNotification({
    required String amount,
    required String customerName,
    required String method,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'To\'lov qabul qilindi 💰',
      body: '$customerName dan $amount so\'m ($method)',
      payload: jsonEncode({'type': 'payment'}),
      channel: NotificationChannel.payments,
    );
  }

  Future<void> showDeliveryNotification({
    required String orderId,
    required String message,
  }) async {
    await showNotification(
      id: 'delivery_$orderId'.hashCode,
      title: 'Yetkazib berish 🚚',
      body: message,
      payload: jsonEncode({'type': 'delivery', 'order_id': orderId}),
      channel: NotificationChannel.delivery,
    );
  }

  Future<void> showTaskNotification({
    required String taskId,
    required String title,
    required String body,
  }) async {
    await showNotification(
      id: taskId.hashCode,
      title: 'Yangi vazifa 📋',
      body: '$title - $body',
      payload: jsonEncode({'type': 'task', 'task_id': taskId}),
      channel: NotificationChannel.tasks,
    );
  }

  Future<void> showSyncNotification({
    required String message,
    required bool isSuccess,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: isSuccess ? 'Sinxronlash tugadi ✅' : 'Sinxronlash xatoligi ❌',
      body: message,
      channel: NotificationChannel.sync,
    );
  }

  // ============ HANDLERS ============

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final notification = AppNotification(
          id: data['id'] ?? DateTime.now().toString(),
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          type: NotificationType.systemAlert,
          channel: NotificationChannel.system,
          data: data,
          createdAt: DateTime.now(),
          isRead: false,
        );
        _notificationController.add(notification);
      } catch (e) {
        debugPrint('Parse notification error: $e');
      }
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = _messageToNotification(message);
    _notificationController.add(notification);
    showNotification(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.body,
      payload: jsonEncode(notification.toJson()),
      channel: notification.channel,
      imageUrl: notification.imageUrl,
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    _notificationController.add(_messageToNotification(message));
  }

  AppNotification _messageToNotification(RemoteMessage message) {
    final data = message.data;
    return AppNotification(
      id: data['id']?.toString() ??
          message.messageId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ??
          data['title']?.toString() ??
          'NIZOM GLOBAL',
      body: message.notification?.body ?? data['body']?.toString() ?? '',
      type: NotificationType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => NotificationType.systemAlert,
      ),
      channel: NotificationChannel.values.firstWhere(
        (channel) => channel.id == data['channel'],
        orElse: () => NotificationChannel.system,
      ),
      data: data,
      createdAt: DateTime.now(),
      isRead: false,
      imageUrl: data['image_url']?.toString(),
      actionUrl: data['action_url']?.toString(),
    );
  }

  // ============ TOPICS ============

  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Subscribe error: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Unsubscribe error: $e');
    }
  }

  // ============ BADGE ============

  Future<void> setBadgeCount(int count) async {
    _badgeCount = count < 0 ? 0 : count;
    debugPrint('Badge count set: $_badgeCount');
  }

  Future<void> clearBadge() async {
    await setBadgeCount(0);
  }

  // ============ CLEAR ============

  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _localNotifications.cancel(id);
  }

  void dispose() {
    _notificationController.close();
    _tokenController.close();
  }
}
