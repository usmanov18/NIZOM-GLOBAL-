import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_entities.dart';

// ============================================================
// CHAT REPOSITORY
// ============================================================

abstract class ChatRepository {
  Future<Either<Failure, List<Chat>>> getChats(String userId);
  Future<Either<Failure, Chat>> getChatById(String chatId);
  Future<Either<Failure, Chat>> createChat({
    required String name,
    required ChatType type,
    required List<String> memberIds,
  });
  Future<Either<Failure, List<ChatMessage>>> getMessages({
    required String chatId,
    int page = 1,
    int limit = 50,
  });
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String chatId,
    required MessageType type,
    String? text,
    String? mediaPath,
    double? latitude,
    double? longitude,
  });
  Future<Either<Failure, bool>> markAsRead(String chatId, String messageId);
  Future<Either<Failure, bool>> markChatAsRead(String chatId);
  Stream<ChatMessage> connectToChat(String chatId, String userId);
  void disconnect();
  void sendTypingStatus(String chatId, bool isTyping);
}
