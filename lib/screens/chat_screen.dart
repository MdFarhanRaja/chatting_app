import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/notification_message.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/services/notification_service.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String userName;
  final String token;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.userName,
    required this.token,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<NotificationMessage>> _chatHistoryFuture;
  final TextEditingController _messageController = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _loadChatHistory() {
    final currentUserId = _currentUser?.uid ?? '';
    _chatHistoryFuture = DatabaseService.instance.getChatHistory(
      widget.senderId,
      currentUserId,
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to send messages.'),
        ),
      );
      return;
    }

    final messageText = _messageController.text;
    _messageController.clear();

    final notification = NotificationMessage(
      senderId: _currentUser.uid,
      receiverId: widget.senderId,
      userName: _currentUser.displayName ?? 'Unknown User',
      msg: messageText,
      timestamp: DateTime.now().toIso8601String(),
      token: widget.token,
      title: _currentUser.displayName ?? 'New Message',
    );

    try {
      await DatabaseService.instance.insertNotification(notification);

      await _notificationService.sendFCMMessage(
        token: widget.token,
        title: notification.title,
        msg: notification.msg,
        senderId: notification.senderId,
        receiverId: notification.receiverId,
        userName: notification.userName,
      );

      setState(() {
        _loadChatHistory();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      _messageController.text = messageText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.userName)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<NotificationMessage>>(
              future: _chatHistoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                } else {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == _currentUser?.uid;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.userName ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(message.msg ?? ''),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
