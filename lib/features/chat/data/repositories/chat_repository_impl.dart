import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/config/env_config.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

// ============================================================
// CHAT REPOSITORY IMPLEMENTATION
// ============================================================

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  final Map<String, Chat> _localChats = {};
  final Map<String, List<ChatMessage>> _localMessages = {};
  final StreamController<ChatMessage> _localMessageController =
      StreamController<ChatMessage>.broadcast();

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  }) {
    if (EnvConfig.isDemoMode) _seedLocalData();
  }

  @override
  Future<Either<Failure, List<Chat>>> getChats(String userId) async {
    try {
      final data = await remoteDataSource.getChats(userId);
      return Right(data.map((d) => _parseChat(d)).toList());
    } catch (e) {
      if (EnvConfig.isDemoMode) return Right(_localChats.values.toList());
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Chat>> getChatById(String chatId) async {
    try {
      final data = await remoteDataSource.getChatById(chatId);
      return Right(_parseChat(data));
    } catch (e) {
      final local = _localChats[chatId];
      if (EnvConfig.isDemoMode && local != null) return Right(local);
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Chat>> createChat({
    required String name,
    required ChatType type,
    required List<String> memberIds,
  }) async {
    try {
      final data = await remoteDataSource.createChat({
        'name': name,
        'type': type.name,
        'member_ids': memberIds,
      });
      return Right(_parseChat(data));
    } catch (e) {
      if (EnvConfig.isDemoMode) {
        final now = DateTime.now();
        final chat = Chat(
          id: 'chat_${now.microsecondsSinceEpoch}',
          name: name,
          type: type,
          members: memberIds
              .map((id) => ChatMember(
                  userId: id,
                  userName: id,
                  role: 'member',
                  joinedAt: now,
                  isOnline: id == 'current'))
              .toList(),
          unreadCount: 0,
          createdAt: now,
          updatedAt: now,
          isPinned: false,
          isMuted: false,
        );
        _localChats[chat.id] = chat;
        _localMessages[chat.id] = <ChatMessage>[];
        return Right(chat);
      }
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages({
    required String chatId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final data = await remoteDataSource.getMessages(
        chatId: chatId,
        page: page,
        limit: limit,
      );
      return Right(data.map((d) => _parseMessage(d)).toList());
    } catch (e) {
      if (EnvConfig.isDemoMode)
        return Right(
            List<ChatMessage>.from(_localMessages[chatId] ?? const []));
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String chatId,
    required MessageType type,
    String? text,
    String? mediaPath,
    double? latitude,
    double? longitude,
  }) async {
    try {
      String? mediaUrl;
      if (mediaPath != null) {
        mediaUrl = await remoteDataSource.uploadMedia(
          mediaPath,
          type.name,
        );
      }

      final data = await remoteDataSource.sendMessage({
        'chat_id': chatId,
        'type': type.name,
        'text': text,
        'media_url': mediaUrl,
        'latitude': latitude,
        'longitude': longitude,
      });

      return Right(_parseMessage(data));
    } catch (e) {
      if (EnvConfig.isDemoMode) {
        final now = DateTime.now();
        final message = ChatMessage(
          id: 'msg_${now.microsecondsSinceEpoch}',
          chatId: chatId,
          senderId: 'current',
          senderName: 'Men',
          type: type,
          text: text,
          mediaUrl: mediaPath,
          latitude: latitude,
          longitude: longitude,
          status: MessageStatus.sent,
          createdAt: now,
          readBy: const ['current'],
        );
        _localMessages.putIfAbsent(chatId, () => <ChatMessage>[]).add(message);
        _localMessageController.add(message);
        _touchLocalChat(chatId, message);
        return Right(message);
      }
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(
      String chatId, String messageId) async {
    try {
      final result = await remoteDataSource.markAsRead(chatId, messageId);
      return Right(result);
    } catch (e) {
      if (EnvConfig.isDemoMode) return const Right(true);
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> markChatAsRead(String chatId) async {
    try {
      final result = await remoteDataSource.markChatAsRead(chatId);
      return Right(result);
    } catch (e) {
      if (EnvConfig.isDemoMode) return const Right(true);
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Stream<ChatMessage> connectToChat(String chatId, String userId) {
    if (EnvConfig.isDemoMode) {
      return _localMessageController.stream
          .where((message) => message.chatId == chatId);
    }
    final stream = remoteDataSource.connectWebSocket(userId);
    return stream
        .where((data) => data['chat_id'] == chatId && data['type'] == 'message')
        .map((data) => _parseMessage(data));
  }

  @override
  void disconnect() {
    _subscription?.cancel();
    remoteDataSource.disconnectWebSocket();
  }

  @override
  void sendTypingStatus(String chatId, bool isTyping) {
    remoteDataSource.sendTypingStatus(chatId, isTyping);
  }

  void _seedLocalData() {
    if (_localChats.isNotEmpty) return;
    final now = DateTime.now();
    final chat = Chat(
      id: 'support',
      name: 'NIZOM Support',
      type: ChatType.direct,
      members: [
        ChatMember(
            userId: 'current',
            userName: 'Men',
            role: 'member',
            joinedAt: now,
            isOnline: true),
        ChatMember(
            userId: 'support',
            userName: 'Support',
            role: 'admin',
            joinedAt: now,
            isOnline: true),
      ],
      unreadCount: 0,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now,
      avatar: 'NS',
      isPinned: false,
      isMuted: false,
    );
    final message = ChatMessage(
      id: 'msg_welcome',
      chatId: chat.id,
      senderId: 'support',
      senderName: 'Support',
      type: MessageType.text,
      text: 'Assalomu alaykum! Chat servisi tayyor.',
      status: MessageStatus.read,
      createdAt: now.subtract(const Duration(minutes: 5)),
      readBy: const ['current'],
    );
    _localChats[chat.id] = Chat(
      id: chat.id,
      name: chat.name,
      type: chat.type,
      members: chat.members,
      lastMessage: message,
      unreadCount: chat.unreadCount,
      createdAt: chat.createdAt,
      updatedAt: message.createdAt,
      avatar: chat.avatar,
      isPinned: chat.isPinned,
      isMuted: chat.isMuted,
    );
    _localMessages[chat.id] = [message];
  }

  void _touchLocalChat(String chatId, ChatMessage message) {
    final chat = _localChats[chatId];
    if (chat == null) return;
    _localChats[chatId] = Chat(
      id: chat.id,
      name: chat.name,
      type: chat.type,
      members: chat.members,
      lastMessage: message,
      unreadCount: chat.unreadCount,
      createdAt: chat.createdAt,
      updatedAt: message.createdAt,
      avatar: chat.avatar,
      isPinned: chat.isPinned,
      isMuted: chat.isMuted,
    );
  }

  Chat _parseChat(Map<String, dynamic> d) {
    return Chat(
      id: d['id'] ?? '',
      name: d['name'] ?? '',
      type: ChatType.values.firstWhere(
        (t) => t.name == d['type'],
        orElse: () => ChatType.direct,
      ),
      members: (d['members'] as List? ?? [])
          .map((m) => ChatMember(
                userId: m['user_id'] ?? '',
                userName: m['user_name'] ?? '',
                avatar: m['avatar'],
                role: m['role'] ?? 'member',
                joinedAt: DateTime.parse(
                    m['joined_at'] ?? DateTime.now().toIso8601String()),
                isOnline: m['is_online'] ?? false,
              ))
          .toList(),
      lastMessage:
          d['last_message'] != null ? _parseMessage(d['last_message']) : null,
      unreadCount: d['unread_count'] ?? 0,
      createdAt:
          DateTime.parse(d['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(d['updated_at'] ?? DateTime.now().toIso8601String()),
      avatar: d['avatar'],
      isPinned: d['is_pinned'] ?? false,
      isMuted: d['is_muted'] ?? false,
    );
  }

  ChatMessage _parseMessage(Map<String, dynamic> d) {
    return ChatMessage(
      id: d['id'] ?? '',
      chatId: d['chat_id'] ?? '',
      senderId: d['sender_id'] ?? '',
      senderName: d['sender_name'] ?? '',
      senderAvatar: d['sender_avatar'],
      type: MessageType.values.firstWhere(
        (t) => t.name == d['type'],
        orElse: () => MessageType.text,
      ),
      text: d['text'],
      mediaUrl: d['media_url'],
      thumbnailUrl: d['thumbnail_url'],
      latitude: d['latitude']?.toDouble(),
      longitude: d['longitude']?.toDouble(),
      locationName: d['location_name'],
      voiceDuration: d['voice_duration'],
      fileName: d['file_name'],
      fileSize: d['file_size'],
      status: MessageStatus.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt:
          DateTime.parse(d['created_at'] ?? DateTime.now().toIso8601String()),
      readAt: d['read_at'] != null ? DateTime.parse(d['read_at']) : null,
      replyToId: d['reply_to_id'],
      replyToText: d['reply_to_text'],
      readBy: List<String>.from(d['read_by'] ?? []),
    );
  }
}
