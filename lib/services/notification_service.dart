import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/services/key_file.dart';
import 'package:flutter_application_1/models/notification_message.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';

import '../firebase_options.dart';
import '../utils/logger.dart';

// Must be a top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Logger.info("Handling a background message: ${message.messageId}");
  Logger.info('Message data: ${message.data}');
  final notification = NotificationMessage.fromJson(message.data);
  await DatabaseService.instance.insertNotification(notification);
}

class NotificationService {
  final _newNotificationController =
      StreamController<NotificationMessage>.broadcast();
  Stream<NotificationMessage> get newNotificationStream =>
      _newNotificationController.stream;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Create a channel for Android
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  Future<void> init() async {
    // Create the notification channel on Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Initialize the plugin for Android and iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for iOS and newer Android versions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    Logger.info('User granted permission: ${settings.authorizationStatus}');

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.info('Got a message whilst in the foreground!');
      Logger.info('Message data: ${message.data}');

      // Save notification to local DB from data payload
      final notificationData = NotificationMessage.fromJson(message.data);
      DatabaseService.instance.insertNotification(notificationData);
      _newNotificationController.add(notificationData);

      // If message also contains a notification payload, show it
      if (message.notification != null) {
        Logger.info(
          'Message also contained a notification: ${message.notification}',
        );
        _showLocalNotification(message);
      }
    });

    // Handle messages when the app is in the background or terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'launch_background',
          ),
        ),
      );
    }
  }

  Future<String> getFCMToken() async {
    // Replace with the actual path to your service account key JSON file
    final Map<String, dynamic> serviceAccountMap = keyFile;

    // Define the required scopes for FCM
    final List<String> scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    // Create credentials from the service account key
    final credentials = ServiceAccountCredentials.fromJson(serviceAccountMap);

    // Obtain an authenticated client
    // The autoRefreshingAuthClient will handle token refreshing automatically
    final client = await clientViaServiceAccount(credentials, scopes);

    // Get the access token
    final String accessToken = client.credentials.accessToken.data;

    // Close the client when you're done (important for resource management)
    // In a long-running server, you might keep the client alive.
    // For a single request, you might close it immediately.
    client.close();

    return accessToken;
  }

  // Example of how to use it to send an FCM message
  Future<void> sendFCMMessage({
    required String token,
    String? title,
    String? msg,
    String? senderId,
    String? receiverId,
    String? userName,
  }) async {
    final String accessToken = await getFCMToken();
    Logger.info('Obtained Access Token: $accessToken');

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/chatapp-cb5e5/messages:send',
    );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final body = jsonEncode({
      'message': {
        'token': token,
        'notification': {
          'title': title ?? 'Hello from Dart FCM',
          'body': msg ?? 'This is a test notification from your Dart server!',
        },
        'data': {
          'userName': userName,
          'senderId': senderId,
          'receiverId': receiverId,
          'title': title,
          'msg': msg,
          'timestamp': DateTime.now().toIso8601String(),
          'token': await FirebaseMessaging.instance.getToken(),
        },
      },
    });

    final response = await Dio().post(
      url.toString(),
      data: body,
      options: Options(headers: headers),
    );

    if (response.statusCode == 200) {
      Logger.success('FCM message sent successfully: ${response.data}');
    } else {
      Logger.error(
        'Failed to send FCM message. Status code: ${response.statusCode}',
      );
      Logger.error('Response body: ${response.data}');
    }
  }
}
