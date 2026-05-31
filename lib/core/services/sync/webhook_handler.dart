import 'dart:async';
import 'package:flutter/material.dart';

// ============================================================
// WEBHOOK HANDLER - 1C/SAP dan kelgan xabarlarni qabul qilish
// ============================================================

class WebhookHandler {
  static final WebhookHandler _instance = WebhookHandler._();
  factory WebhookHandler() => _instance;
  WebhookHandler._();

  final StreamController<WebhookEvent> _eventController =
      StreamController<WebhookEvent>.broadcast();

  Stream<WebhookEvent> get eventStream => _eventController.stream;
  final List<WebhookEvent> _eventLog = [];

  // ============ WEBHOOK PROCESSING ============

  /// Webhook ni qayta ishlash
  Future<WebhookResult> handleWebhook({
    required String source, // '1c' or 'sap'
    required Map<String, dynamic> payload,
  }) async {
    try {
      final eventType = payload['event_type'] ?? 'unknown';
      final entityType = payload['entity_type'] ?? 'unknown';
      final entityId = payload['entity_id'] ?? '';
      final timestamp = DateTime.now();

      final event = WebhookEvent(
        id: '${source}_${timestamp.millisecondsSinceEpoch}',
        source: source,
        eventType: eventType,
        entityType: entityType,
        entityId: entityId,
        payload: payload,
        timestamp: timestamp,
      );

      _eventLog.add(event);
      _eventController.add(event);

      // Event turiga qarab qayta ishlash
      await _processEvent(event);

      return WebhookResult(
        success: true,
        eventId: event.id,
        message: 'Webhook qabul qilindi',
      );
    } catch (e) {
      return WebhookResult(
        success: false,
        message: 'Xatolik: $e',
      );
    }
  }

  // ============ EVENT PROCESSING ============

  Future<void> _processEvent(WebhookEvent event) async {
    switch (event.entityType) {
      case 'order':
        await _processOrderEvent(event);
        break;
      case 'customer':
        await _processCustomerEvent(event);
        break;
      case 'product':
        await _processProductEvent(event);
        break;
      case 'payment':
        await _processPaymentEvent(event);
        break;
      default:
        debugPrint('Unknown entity type: ${event.entityType}');
    }
  }

  Future<void> _processOrderEvent(WebhookEvent event) async {
    switch (event.eventType) {
      case 'created':
        // Yangi buyurtma yaratildi
        break;
      case 'updated':
        // Buyurtma yangilandi
        break;
      case 'status_changed':
        // Holat o'zgartirildi
        break;
      case 'cancelled':
        // Bekor qilindi
        break;
    }
  }

  Future<void> _processCustomerEvent(WebhookEvent event) async {
    switch (event.eventType) {
      case 'created':
        // Yangi mijoz
        break;
      case 'updated':
        // Mijoz yangilandi
        break;
      case 'blocked':
        // Mijoz bloklandi
        break;
    }
  }

  Future<void> _processProductEvent(WebhookEvent event) async {
    switch (event.eventType) {
      case 'price_changed':
        // Narx o'zgartirildi
        break;
      case 'stock_changed':
        // Ombor o'zgartirildi
        break;
      case 'discount_added':
        // Chegirma qo'shildi
        break;
    }
  }

  Future<void> _processPaymentEvent(WebhookEvent event) async {
    switch (event.eventType) {
      case 'received':
        // To'lov qabul qilindi
        break;
      case 'confirmed':
        // To'lov tasdiqlandi
        break;
    }
  }

  // ============ LOG ============

  List<WebhookEvent> getEventLog({int limit = 100}) {
    return _eventLog.reversed.take(limit).toList();
  }

  void clearLog() {
    _eventLog.clear();
  }

  void dispose() {
    _eventController.close();
  }
}

// ============ MODELS ============

class WebhookEvent {
  final String id;
  final String source;
  final String eventType;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  const WebhookEvent({
    required this.id,
    required this.source,
    required this.eventType,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.timestamp,
  });
}

class WebhookResult {
  final bool success;
  final String? eventId;
  final String message;

  const WebhookResult({
    required this.success,
    this.eventId,
    required this.message,
  });
}
