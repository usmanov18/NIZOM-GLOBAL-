import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ============================================================
// FIREBASE SERVICE - Push notifications, analytics, messaging
// ============================================================

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // ============ INIT ============

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      await _initLocalNotifications();

      // FCM init
      await _initFCM();

      // Analytics init
      // await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }
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
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  // ============ FCM (Firebase Cloud Messaging) ============

  Future<void> _initFCM() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      _fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Token: $_fcmToken');

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        _fcmToken = token;
        _sendTokenToServer(token);
      });
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  // Foreground xabar
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');

    // Local notification ko'rsatish
    _showLocalNotification(
      title: message.notification?.title ?? 'Yangi xabar',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  // Background xabar (top-level function bo'lishi kerak)
  // Token serverga yuborish
  Future<void> _sendTokenToServer(String token) async {
    try {
      debugPrint('FCM token ready for server sync: $token');
    } catch (e) {
      debugPrint('Error sending FCM token: $e');
    }
  }

  // ============ LOCAL NOTIFICATIONS ============

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
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
    } catch (e) {
      debugPrint('Local notification error: $e');
    }
  }

  // ============ TOPIC SUBSCRIPTION ============

  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Topic subscription error: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Topic unsubscription error: $e');
    }
  }

  // ============ ANALYTICS ============

  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // await FirebaseAnalytics.instance.logEvent(
      //   name: name,
      //   parameters: parameters,
      // );
      debugPrint('Analytics event: $name');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logScreenView(String screenName) async {
    await logEvent(
        name: 'screen_view', parameters: {'screen_name': screenName});
  }

  Future<void> logOrderCreated(String orderId, double amount) async {
    await logEvent(name: 'order_created', parameters: {
      'order_id': orderId,
      'amount': amount,
    });
  }

  Future<void> logPaymentReceived(double amount, String method) async {
    await logEvent(name: 'payment_received', parameters: {
      'amount': amount,
      'method': method,
    });
  }

  Future<void> logSyncCompleted(String source, int count) async {
    await logEvent(name: 'sync_completed', parameters: {
      'source': source,
      'count': count,
    });
  }

  // ============ CRASHLYTICS ============

  Future<void> recordError(dynamic error, StackTrace stackTrace) async {
    try {
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
      debugPrint('Error recorded: $error');
    } catch (e) {
      debugPrint('Crashlytics error: $e');
    }
  }

  Future<void> setUserIdentifier(String userId) async {
    try {
      // FirebaseCrashlytics.instance.setUserIdentifier(userId);
      // FirebaseAnalytics.instance.setUserId(id: userId);
    } catch (e) {
      debugPrint('Set user error: $e');
    }
  }
}
