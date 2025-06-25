import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/notification_message.dart';
import 'package:flutter_application_1/services/database_service.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String senderName;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.senderName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<NotificationMessage>> _chatHistoryFuture;
  final DatabaseService _dbService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _chatHistoryFuture = _dbService.getChatHistory(widget.senderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.senderName)),
      body: FutureBuilder<List<NotificationMessage>>(
        future: _chatHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }

          final messages = snapshot.data!;

          return ListView.builder(
            itemCount: messages.length,
            reverse: true, // To show latest messages at the bottom
            itemBuilder: (context, index) {
              final message = messages[index];
              // Basic chat bubble layout
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Align(
                  // This is a simplified alignment. A real app would check if the message is from the current user.
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(message.msg ?? ''),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
