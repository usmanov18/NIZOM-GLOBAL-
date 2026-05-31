import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_entities.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatListLoadRequested extends ChatEvent {
  final String userId;
  ChatListLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ChatMessagesLoadRequested extends ChatEvent {
  final String chatId;
  ChatMessagesLoadRequested({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ChatConnectRequested extends ChatEvent {
  final String chatId;
  final String userId;
  ChatConnectRequested({required this.chatId, required this.userId});
  @override
  List<Object?> get props => [chatId, userId];
}

class ChatDisconnectRequested extends ChatEvent {}

class ChatMessageSendRequested extends ChatEvent {
  final String chatId;
  final String senderId;
  final MessageType type;
  final String text;
  final double? latitude;
  final double? longitude;

  ChatMessageSendRequested({
    required this.chatId,
    this.senderId = 'current',
    this.type = MessageType.text,
    required this.text,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props =>
      [chatId, senderId, type, text, latitude, longitude];
}

class ChatCreateRequested extends ChatEvent {
  final String name;
  final ChatType type;
  final List<String> memberIds;
  ChatCreateRequested(
      {required this.name,
      this.type = ChatType.direct,
      this.memberIds = const []});
}

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

class ChatListLoaded extends ChatState {
  final List<Chat> chats;
  ChatListLoaded(this.chats);
  @override
  List<Object?> get props => [chats];
}

class ChatMessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  ChatMessagesLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class ChatMessageSent extends ChatState {
  final ChatMessage message;
  ChatMessageSent(this.message);
  @override
  List<Object?> get props => [message];
}

class ChatNewMessageReceived extends ChatState {
  final ChatMessage message;
  ChatNewMessageReceived(this.message);
  @override
  List<Object?> get props => [message];
}

class ChatCreated extends ChatState {
  final Chat chat;
  ChatCreated(this.chat);
  @override
  List<Object?> get props => [chat];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ChatListLoadRequested>((event, emit) async {
      emit(ChatListLoaded(const []));
    });
    on<ChatMessagesLoadRequested>((event, emit) async {
      emit(ChatMessagesLoaded(const []));
    });
    on<ChatConnectRequested>((event, emit) {});
    on<ChatDisconnectRequested>((event, emit) {});
    on<ChatMessageSendRequested>((event, emit) async {
      final message = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        chatId: event.chatId,
        senderId: event.senderId,
        senderName: 'Me',
        type: event.type,
        text: event.text,
        latitude: event.latitude,
        longitude: event.longitude,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        readBy: const [],
      );
      emit(ChatMessageSent(message));
    });
    on<ChatCreateRequested>((event, emit) async {
      final now = DateTime.now();
      emit(ChatCreated(Chat(
        id: now.microsecondsSinceEpoch.toString(),
        name: event.name,
        type: event.type,
        members: const [],
        unreadCount: 0,
        createdAt: now,
        updatedAt: now,
        isPinned: false,
        isMuted: false,
      )));
    });
  }
}
