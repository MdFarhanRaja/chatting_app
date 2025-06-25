import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/notification_provider.dart';
import 'package:flutter_application_1/providers/notification_provider.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/screens/qr_scanner_screen.dart';
import 'package:provider/provider.dart';

import '../base_class.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseClass<HomeScreen> {
  @override
  void initState() {
    super.initState();
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
        title: const Text('Notifications'),
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
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return ListTile(
                title: Text(notification.title ?? 'No Title'),
                subtitle: Text(notification.msg ?? 'No Body'),
                leading: CircleAvatar(
                  child: Text(
                    notification.userName != null &&
                            notification.userName!.isNotEmpty
                        ? notification.userName!.substring(0, 1).toUpperCase()
                        : 'U',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          gotoNext(const QrScannerScreen());
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
