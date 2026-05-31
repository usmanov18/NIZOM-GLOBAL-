import 'package:equatable/equatable.dart';

// ============================================================
// CHAT ENTITIES - Chat tizimi
// ============================================================

/// Chat turi
enum ChatType {
  direct, // 1-on-1
  group, // Guruh
  broadcast, // E'lon
}

/// Xabar turi
enum MessageType {
  text, // Matn
  image, // Rasm
  location, // Lokatsiya
  voice, // Ovoz
  file, // Fayl
  order, // Buyurtma
  system, // Tizim xabari
}

/// Xabar holati
enum MessageStatus {
  sending, // Yuborilmoqda
  sent, // Yuborildi
  delivered, // Yetkazildi
  read, // O'qildi
  failed, // Xatolik
}

/// Chat
class Chat extends Equatable {
  factory Chat.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String name;
  final ChatType type;
  final List<ChatMember> members;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatar;
  final bool isPinned;
  final bool isMuted;

  const Chat({
    required this.id,
    required this.name,
    required this.type,
    required this.members,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    this.avatar,
    required this.isPinned,
    required this.isMuted,
  });

  @override
  List<Object?> get props => [id, lastMessage, unreadCount];
}

/// Chat a'zosi
class ChatMember extends Equatable {
  factory ChatMember.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String userId;
  final String userName;
  final String? avatar;
  final String role; // admin, member
  final DateTime joinedAt;
  final bool isOnline;

  const ChatMember({
    required this.userId,
    required this.userName,
    this.avatar,
    required this.role,
    required this.joinedAt,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [userId, role];
}

/// Xabar
class ChatMessage extends Equatable {
  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final MessageType type;
  final String? text;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final int? voiceDuration;
  final String? fileName;
  final int? fileSize;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? replyToId;
  final String? replyToText;
  final List<String> readBy;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.type,
    this.text,
    this.mediaUrl,
    this.thumbnailUrl,
    this.latitude,
    this.longitude,
    this.locationName,
    this.voiceDuration,
    this.fileName,
    this.fileSize,
    required this.status,
    required this.createdAt,
    this.readAt,
    this.replyToId,
    this.replyToText,
    required this.readBy,
  });

  bool get isRead => status == MessageStatus.read;
  bool get isSent =>
      status == MessageStatus.sent || status == MessageStatus.delivered;

  @override
  List<Object?> get props => [id, status, createdAt];
}
