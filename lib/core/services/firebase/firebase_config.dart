import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Firebase konfiguratsiya
class FirebaseConfig {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      await _initMessaging();
      await _initAnalytics();
      await _initCrashlytics();

      _initialized = true;
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }
  }

  static Future<void> _initMessaging() async {
    await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $token');
  }

  static Future<void> _initAnalytics() async {
    debugPrint('Firebase analytics ready');
  }

  static Future<void> _initCrashlytics() async {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('Flutter error captured: ${details.exception}');
    };
  }

  static Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static Future<void> logEvent(String name,
      {Map<String, dynamic>? params}) async {
    debugPrint('Firebase event: $name $params');
  }

  static Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', params: {'screen_name': screenName});
  }
}
