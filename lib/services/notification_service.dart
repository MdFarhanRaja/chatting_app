import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/services/key_file.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_application_1/utils/app_constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';

// Must be a top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger.info("Handling a background message: ${message.messageId}");
  Logger.info('Message data: ${message.data}');
  Logger.info('Message notification: ${message.notification?.title}');
}

class NotificationService {
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

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        Logger.info('Message also contained a notification: ${notification}');
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ),
        );
      }
    });

    // Handle messages when the app is in the background or terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
    String? userId,
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
        'data': {'userId': userId, 'title': title, 'msg': msg},
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
