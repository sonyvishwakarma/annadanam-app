// pages/chat/chat_inbox_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../utils/colors.dart';
import '../../models/user_role.dart';
import 'api_chat_page.dart';

class ChatInboxPage extends StatefulWidget {
  final User user;

  const ChatInboxPage({super.key, required this.user});

  @override
  State<ChatInboxPage> createState() => _ChatInboxPageState();
}

class _ChatInboxPageState extends State<ChatInboxPage> {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    if (_chats.isEmpty && !kIsWeb) {
      setState(() => _isLoading = true);
      // Load from local DB first
      final localChats = await _dbService.getLocalChats(widget.user.id);
      if (localChats.isNotEmpty && mounted) {
        setState(() {
          _chats = localChats.map((c) => Map<String, dynamic>.from(c)).toList();
          _isLoading = false;
        });
      }
    }

    try {
      final chats = await _apiService.apiGetUserChats(widget.user.id);
      if (mounted) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });

        // Save to local DB (Skip on Web)
        if (!kIsWeb) {
          for (var chat in chats) {
            await _dbService.saveLocalChat(chat);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching chats: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getOtherUserName(Map<String, dynamic> chat) {
    if (chat['user1Id'] == widget.user.id) {
      return chat['user2Name'] ?? 'Unknown';
    }
    return chat['user1Name'] ?? 'Unknown';
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt =
          DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp.toString()));
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    if (widget.user.role == UserRole.recipient ||
        widget.user.role == UserRole.admin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 20),
              const Text(
                'Unauthorized Access',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chat is only available for Donors and Volunteers.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchChats,
              color: primaryColor,
              child: _chats.isEmpty
                  ? _buildEmptyState(primaryColor)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _chats.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final chat = _chats[index];
                        final otherName = _getOtherUserName(chat);
                        final lastMsg =
                            chat['lastMessage'] as String? ?? 'No messages yet';
                        final lastTime = _formatTime(chat['lastMessageTime']);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: primaryColor.withOpacity(0.15),
                            child: Text(
                              otherName.isNotEmpty
                                  ? otherName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          title: Text(
                            otherName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            lastMsg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          trailing: lastTime.isNotEmpty
                              ? Text(
                                  lastTime,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                )
                              : null,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                chatId: chat['id'].toString(),
                                currentUserId: widget.user.id,
                                currentUserName: widget.user.name,
                                currentUserRole: widget.user.role,
                                otherUserName: otherName,
                              ),
                            ),
                          ).then((_) => _fetchChats()),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline,
                size: 64, color: primaryColor.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your chats with other users\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
