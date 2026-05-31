import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_entities.dart';
import '../bloc/chat_bloc.dart';

/// Chat oynasi — ChatBloc/ChatRepository orqali boshqariladi.
class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final bool isOnline;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    this.isOnline = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.chatId.isNotEmpty) {
      context
          .read<ChatBloc>()
          .add(ChatMessagesLoadRequested(chatId: widget.chatId));
      context
          .read<ChatBloc>()
          .add(ChatConnectRequested(chatId: widget.chatId, userId: 'current'));
    }
  }

  @override
  void dispose() {
    context.read<ChatBloc>().add(ChatDisconnectRequested());
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: _onChatState,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      const Color(0xFF1565C0).withValues(alpha: 0.1),
                  child: Text(
                    widget.chatName.isEmpty
                        ? '?'
                        : widget.chatName.substring(0, 1),
                    style: const TextStyle(
                        color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.chatName, style: const TextStyle(fontSize: 16)),
                    Text(widget.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                            fontSize: 12,
                            color: widget.isOnline
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.call), onPressed: _startCall),
              IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: _showChatActions),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: state is ChatLoading && _messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMessagesList(),
              ),
              _buildInputBar(),
            ],
          ),
        );
      },
    );
  }

  void _onChatState(BuildContext context, ChatState state) {
    if (state is ChatMessagesLoaded) {
      setState(() => _messages = state.messages);
      _scrollToBottom();
    } else if (state is ChatMessageSent) {
      setState(() => _messages = [..._messages, state.message]);
      _scrollToBottom();
    } else if (state is ChatNewMessageReceived) {
      setState(() => _messages = [..._messages, state.message]);
      _scrollToBottom();
    } else if (state is ChatError) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red));
    }
  }

  Widget _buildMessagesList() {
    if (widget.chatId.isEmpty) {
      return _emptyState(
          'Chat tanlanmagan', 'Xabar yozish uchun chat ID kerak.');
    }
    if (_messages.isEmpty) {
      return _emptyState('Xabarlar yo‘q', 'Bu chatda hali xabarlar yo‘q.');
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildMessage(_messages[index]),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isMe = message.senderId == 'me' || message.senderId == 'current';
    final isSystem = message.type == MessageType.system;
    final isLocation = message.type == MessageType.location;

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12)),
          child: Text(message.text ?? '',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
                child: Text(
                    message.senderName.isEmpty
                        ? '?'
                        : message.senderName.substring(0, 1),
                    style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF1565C0) : Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isLocation)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.location_on,
                            color:
                                isMe ? Colors.white : const Color(0xFF00897B),
                            size: 16),
                        const SizedBox(width: 4),
                        Text('Lokatsiya',
                            style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : const Color(0xFF00897B),
                                fontWeight: FontWeight.w500)),
                      ])
                    else
                      Text(message.text ?? '',
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(_formatTime(message.createdAt),
                          style: TextStyle(
                              color: isMe
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.grey.shade400,
                              fontSize: 10)),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(message.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.isRead
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5)),
                      ],
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2))
      ]),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _showAttachMenu,
              color: Colors.grey.shade500),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Xabar yozing...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF1565C0),
            child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || widget.chatId.isEmpty) return;
    context.read<ChatBloc>().add(ChatMessageSendRequested(
        chatId: widget.chatId, type: MessageType.text, text: text));
    _messageController.clear();
  }

  void _showAttachMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _attachOption(Icons.camera_alt, 'Kamera', const Color(0xFF1565C0),
              MessageType.image),
          _attachOption(
              Icons.image, 'Rasm', const Color(0xFF2E7D32), MessageType.image),
          _attachOption(Icons.location_on, 'Lokatsiya', const Color(0xFFFF6F00),
              MessageType.location),
          _attachOption(Icons.insert_drive_file, 'Fayl',
              const Color(0xFF00897B), MessageType.file),
        ]),
      ),
    );
  }

  Widget _attachOption(
      IconData icon, String label, Color color, MessageType type) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (widget.chatId.isEmpty) return;
        context.read<ChatBloc>().add(ChatMessageSendRequested(
              chatId: widget.chatId,
              type: type,
              text: type == MessageType.location
                  ? 'Lokatsiya yuborildi 📍'
                  : '$label biriktirildi',
              latitude: type == MessageType.location ? 41.2995 : null,
              longitude: type == MessageType.location ? 69.2401 : null,
            ));
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color)),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
      ]),
    );
  }

  void _startCall() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('${widget.chatName} bilan qo‘ng‘iroq funksiyasi tanlandi')));
  }

  void _showChatActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Chat ichida qidirish'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat qidiruvi ochildi')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_off_outlined),
            title: const Text('Bildirishnomani o‘chirish'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Chat bildirishnomalari o‘chirildi')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Chatni tozalash'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _messages.clear());
            },
          ),
        ]),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Widget _emptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.chat_bubble_outline,
              size: 56, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600)),
        ]),
      ),
    );
  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
