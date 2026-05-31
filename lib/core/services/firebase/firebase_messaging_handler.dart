import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  debugPrint('Background message: ${message.notification?.title}');
}

// ============================================================
// FIREBASE MESSAGING HANDLER - Push Notification Handler
// ============================================================

class FirebaseMessagingHandler {
  static final FirebaseMessagingHandler _instance =
      FirebaseMessagingHandler._internal();
  factory FirebaseMessagingHandler() => _instance;
  FirebaseMessagingHandler._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _lastNavigationRoute;
  String? get lastNavigationRoute => _lastNavigationRoute;

  // ============ INIT ============

  Future<void> initialize() async {
    await _initLocalNotifications();
    await _initFirebaseMessaging();
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _initFirebaseMessaging() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
  }

  // ============ HANDLERS ============

  void _onForegroundMessage(RemoteMessage message) {
    _showLocalNotification(
      title: message.notification?.title ?? 'Yangi xabar',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    _handleNavigation(message.data);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNavigation(data);
    }
  }

  // ============ LOCAL NOTIFICATION ============

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'nizom_global_channel',
      'NIZOM GLOBAL',
      channelDescription: 'Bildirishnomalar',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    );

    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // ============ NAVIGATION ============

  void _handleNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'order':
        _lastNavigationRoute = '/orders/history';
        break;
      case 'delivery':
        _lastNavigationRoute = '/delivery/home';
        break;
      case 'payment':
        _lastNavigationRoute = '/payments/collect';
        break;
      case 'chat':
        _lastNavigationRoute = id == null ? '/chat' : '/chat/detail';
        break;
      default:
        _lastNavigationRoute = '/notifications';
    }
    debugPrint('Notification navigation route: $_lastNavigationRoute');
  }

  // ============ TOKEN ============

  Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
