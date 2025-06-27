import 'package:flutter/material.dart';
import 'package:flutter_application_1/base_class.dart';
import 'package:flutter_application_1/models/notification_message.dart';
import 'package:flutter_application_1/screens/chat_screen.dart';
import 'package:flutter_application_1/services/database_service.dart';

import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseClass<HomeScreen> {
  late Future<List<NotificationMessage>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = DatabaseService.instance.getNotifications();
    initProvider();
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      changeSystemUiColor(
        statusBarColor: Colors.white,
        navBarColor: Colors.white,
        brightness: Brightness.dark,
        navBrightness: Brightness.dark,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const CircleAvatar(child: Icon(Icons.person)),
            onPressed: () {
              gotoNext(const ProfileScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.black),
            onPressed: () {
              showLogoutDialog();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationMessage>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          } else {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(notification.userName ?? 'Unknown Sender'),
                  subtitle: Text(notification.msg ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatScreen(
                              senderId: notification.senderId!,
                              userName: notification.userName!,
                            ),
                      ),
                    ).then((_) {
                      // Refresh the list when returning from chat screen
                      setState(() {
                        _notificationsFuture =
                            DatabaseService.instance.getNotifications();
                      });
                    });
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
