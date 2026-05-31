import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../config/env_config.dart';

// ============================================================
// WEBSOCKET SERVICE - Real-Time Connection
// ============================================================

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  String? _lastUserId;
  String? _lastBaseUrl;
  static const int _maxReconnectAttempts = 5;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;

  // ============ CONNECT ============

  Future<void> connect(String userId, {String? baseUrl}) async {
    try {
      _lastUserId = userId;
      _lastBaseUrl = baseUrl;
      final url = baseUrl ?? EnvConfig.wsUrl;

      _channel = WebSocketChannel.connect(
        Uri.parse('$url?user_id=$userId'),
      );

      _channel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data);
            _messageController.add(decoded);
          } catch (e) {
            debugPrint('WebSocket parse error: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('WebSocket disconnected');
          _handleDisconnect();
        },
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionController.add(true);

      // Heartbeat
      _startHeartbeat();

      debugPrint('WebSocket connected');
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _handleDisconnect();
    }
  }

  // ============ DISCONNECT ============

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _connectionController.add(false);
    debugPrint('WebSocket disconnected');
  }

  // ============ SEND ============

  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void sendTyping(String chatId, bool isTyping) {
    sendMessage({
      'type': 'typing',
      'chat_id': chatId,
      'is_typing': isTyping,
    });
  }

  void sendLocation(double latitude, double longitude) {
    sendMessage({
      'type': 'location',
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendOrderUpdate(String orderId, String status) {
    sendMessage({
      'type': 'order_update',
      'order_id': orderId,
      'status': status,
    });
  }

  // ============ HEARTBEAT ============

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (_isConnected) {
          sendMessage({'type': 'ping'});
        }
      },
    );
  }

  // ============ RECONNECT ============

  void _handleDisconnect() {
    _isConnected = false;
    _connectionController.add(false);
    _heartbeatTimer?.cancel();

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(
        Duration(seconds: (_reconnectAttempts + 1) * 2),
        () {
          _reconnectAttempts++;
          debugPrint('WebSocket reconnecting... Attempt $_reconnectAttempts');
          final userId = _lastUserId;
          if (userId != null) {
            connect(userId, baseUrl: _lastBaseUrl);
          }
        },
      );
    }
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
