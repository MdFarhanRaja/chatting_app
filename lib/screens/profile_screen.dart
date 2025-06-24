import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/base_class.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends BaseClass<ProfileScreen> {
  String? _fcmToken;
  String? _qrData;

  @override
  void initState() {
    super.initState();
    initProvider();
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFcmToken();
    });
  }

  Future<void> _loadFcmToken() async {
    final token = await authProvider.getFcmToken();
    setState(() {
      _fcmToken = token;
      _qrData = jsonEncode({
        'userId': currentUser.uid,
        'userName': currentUser.displayName,
        'fcmToken': _fcmToken,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_qrData != null)
                QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  size: 200.0,
                )
              else
                const CircularProgressIndicator(),
              const SizedBox(height: 40),
              Text(
                'Username: ${currentUser.displayName ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Email: ${currentUser.email ?? 'N/A'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'User ID: ${currentUser.uid}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (_fcmToken != null) {
                    authProvider.notificationService.sendPushNotification(
                      token: _fcmToken!,
                      title: 'Hello from the App!',
                      body: 'This is a test notification sent via API call.',
                    );
                  }
                },
                child: const Text('Send Test Notification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
