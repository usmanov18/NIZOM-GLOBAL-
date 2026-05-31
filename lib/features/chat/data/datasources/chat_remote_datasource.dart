import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/env_config.dart';

// ============================================================
// CHAT REMOTE DATASOURCE - WebSocket + REST API
// ============================================================

abstract class ChatRemoteDataSource {
  // Chat CRUD
  Future<List<Map<String, dynamic>>> getChats(String userId);
  Future<Map<String, dynamic>> getChatById(String chatId);
  Future<Map<String, dynamic>> createChat(Map<String, dynamic> data);

  // Messages
  Future<List<Map<String, dynamic>>> getMessages({
    required String chatId,
    int page = 1,
    int limit = 50,
  });
  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data);
  Future<bool> markAsRead(String chatId, String messageId);
  Future<bool> markChatAsRead(String chatId);

  // WebSocket
  Stream<Map<String, dynamic>> connectWebSocket(String userId);
  void disconnectWebSocket();
  void sendTypingStatus(String chatId, bool isTyping);

  // Media
  Future<String> uploadMedia(String filePath, String type);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  ChatRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Map<String, dynamic>>> getChats(String userId) async {
    try {
      final response = await _dio.get('/chats', queryParameters: {
        'user_id': userId,
      });
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Chatlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> getChatById(String chatId) async {
    try {
      final response = await _dio.get('/chats/$chatId');
      if (response.statusCode == 200) return response.data;
      throw ServerException(message: 'Chat topilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> createChat(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/chats', data: data);
      if (response.statusCode == 201) return response.data;
      throw ServerException(message: 'Chat yaratilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages({
    required String chatId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response =
          await _dio.get('/chats/$chatId/messages', queryParameters: {
        'page': page,
        'limit': limit,
      });
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      throw ServerException(message: 'Xabarlar yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/chats/${data['chat_id']}/messages', data: data);
      if (response.statusCode == 201) return response.data;
      throw ServerException(message: 'Xabar yuborilmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }

  @override
  Future<bool> markAsRead(String chatId, String messageId) async {
    try {
      final response =
          await _dio.put('/chats/$chatId/messages/$messageId/read');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> markChatAsRead(String chatId) async {
    try {
      final response = await _dio.put('/chats/$chatId/read');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<Map<String, dynamic>> connectWebSocket(String userId) {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('${EnvConfig.wsUrl}/chat?user_id=$userId'),
      );

      _channel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data);
            _messageController.add(decoded);
          } catch (e) {
            // Parse error
          }
        },
        onError: (error) {
          _messageController.addError(error);
        },
        onDone: () {
          // Connection closed
        },
      );

      return _messageController.stream;
    } catch (e) {
      throw ServerException(message: 'WebSocket ulanmadi');
    }
  }

  @override
  void disconnectWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }

  @override
  void sendTypingStatus(String chatId, bool isTyping) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'typing',
        'chat_id': chatId,
        'is_typing': isTyping,
      }));
    }
  }

  @override
  Future<String> uploadMedia(String filePath, String type) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'type': type,
      });
      final response = await _dio.post('/chats/upload', data: formData);
      if (response.statusCode == 200) return response.data['url'];
      throw ServerException(message: 'Fayl yuklanmadi');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }
}
