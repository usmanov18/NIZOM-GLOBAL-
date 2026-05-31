import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/chat_entities.dart';
import '../bloc/chat_bloc.dart';

/// Chatlar ro'yxati
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _filter = 'all';

  List<Chat> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final auth = await getIt<AuthRepository>().getCurrentUser();
    final user = auth.fold((_) => null, (value) => value);
    if (!mounted) return;
    context.read<ChatBloc>().add(ChatListLoadRequested(user?.id ?? 'current'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xabarlar'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _showSearch),
          IconButton(icon: const Icon(Icons.edit), onPressed: _createChat),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: _onChatState,
        builder: (context, state) {
          return Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _filterChip('Barchasi', 'all'),
                    const SizedBox(width: 8),
                    _filterChip('Shaxsiy', 'direct'),
                    const SizedBox(width: 8),
                    _filterChip('Guruh', 'group'),
                  ],
                ),
              ),
              Expanded(
                child: state is ChatLoading && _chats.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildChatList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChat,
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.chat),
      ),
    );
  }

  void _onChatState(BuildContext context, ChatState state) {
    if (state is ChatListLoaded) {
      setState(() => _chats = state.chats);
    } else if (state is ChatCreated) {
      setState(() => _chats = [state.chat, ..._chats]);
    } else if (state is ChatError) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red));
    }
  }

  Widget _buildChatList() {
    final chats = _filteredChats();
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Chatlar topilmadi',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadChats,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: chats.length,
        itemBuilder: (context, index) => _buildChatTile(chats[index]),
      ),
    );
  }

  List<Chat> _filteredChats() {
    return _chats.where((chat) {
      switch (_filter) {
        case 'direct':
          return chat.type == ChatType.direct;
        case 'group':
          return chat.type == ChatType.group;
        case 'all':
        default:
          return true;
      }
    }).toList();
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(Chat chat) {
    final isGroup = chat.type == ChatType.group;
    final unread = chat.unreadCount;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isGroup
                ? const Color(0xFF00897B).withValues(alpha: 0.1)
                : const Color(0xFF1565C0).withValues(alpha: 0.1),
            child: Text(
              _chatAvatar(chat),
              style: TextStyle(
                color:
                    isGroup ? const Color(0xFF00897B) : const Color(0xFF1565C0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_isChatOnline(chat))
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.name,
              style: TextStyle(
                fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          if (isGroup)
            Text(
              "${chat.members.length} a’zo",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
        ],
      ),
      subtitle: Text(
        chat.lastMessage?.text ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unread > 0 ? Colors.black87 : Colors.grey.shade500,
          fontSize: 13,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _relativeTime(chat.updatedAt),
            style: TextStyle(
              color:
                  unread > 0 ? const Color(0xFF1565C0) : Colors.grey.shade400,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () => _openChat(chat),
    );
  }

  void _openChat(Chat chat) {
    final id = Uri.encodeComponent(chat.id);
    final name = Uri.encodeComponent(chat.name);
    final online = _isChatOnline(chat);
    context.push('/chat/detail?id=$id&name=$name&online=$online');
  }

  String _chatAvatar(Chat chat) {
    if (chat.avatar != null && chat.avatar!.isNotEmpty) return chat.avatar!;
    final parts = chat.name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return chat.name.isEmpty ? '?' : chat.name.substring(0, 1).toUpperCase();
  }

  bool _isChatOnline(Chat chat) =>
      chat.members.any((member) => member.isOnline);

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }

  void _showSearch() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Chat qidirish',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ism yoki xabar bo‘yicha qidirish',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final query = controller.text.trim().toLowerCase();
                final matches = _chats.where((chat) {
                  final textMatch = (chat.lastMessage?.text ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(query);
                  final nameMatch =
                      chat.name.toString().toLowerCase().contains(query);
                  return nameMatch || textMatch;
                }).length;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(query.isEmpty
                          ? 'Qidiruv bekor qilindi'
                          : '$matches ta chat topildi')),
                );
              },
              child: const Text('Qidirish'),
            ),
          ],
        ),
      ),
    );
  }

  void _createChat() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Yangi chat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF1565C0)),
              title: const Text('Shaxsiy xabar'),
              subtitle: const Text('Bir kishi bilan suhbatlashing'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatBloc>().add(ChatCreateRequested(
                    name: 'Yangi chat',
                    type: ChatType.direct,
                    memberIds: const ['current']));
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF00897B)),
              title: const Text('Guruh chati'),
              subtitle: const Text('Bir nechta kishi bilan suhbatlashing'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatBloc>().add(ChatCreateRequested(
                    name: 'Yangi guruh',
                    type: ChatType.group,
                    memberIds: const ['current']));
              },
            ),
          ],
        ),
      ),
    );
  }
}
