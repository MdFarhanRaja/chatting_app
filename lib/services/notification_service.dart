import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/utils/app_constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  Future<void> sendPushNotification({
    required String token,
    String? title,
    String? body,
  }) async {
    final dio = Dio();
    final url =
        'https://fcm.googleapis.com/v1/projects/chatapp-cb5e5/messages:send';

    final headers = {'Content-Type': 'application/json'};

    final data = {
      'notification': {
        'title': title ?? 'Test Notification',
        'body': body ?? 'This is a test notification from the app!',
      },
      'to': token,
    };

    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        Logger.success('Push notification sent successfully.');
      } else {
        Logger.error(
          'Failed to send push notification: ${response.statusCode} ${response.data}',
        );
      }
    } catch (e) {
      Logger.error('Error sending push notification: $e');
    }
  }
}
