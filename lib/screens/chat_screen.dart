import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/notification_message.dart';
import 'package:flutter_application_1/services/database_service.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<NotificationMessage>> _chatHistoryFuture;

  @override
  void initState() {
    super.initState();
    _chatHistoryFuture = DatabaseService.instance.getChatHistory(widget.senderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
      ),
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
                      return ListTile(
                        title: Text(message.userName ?? 'Unknown'),
                        subtitle: Text(message.msg ?? ''),
                      );
                    },
                  );
                }
              },
            ),
          ),
          // Placeholder for a message input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Send message logic to be implemented
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


