import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'package:flutter_application_1/models/notification_message.dart';
import 'package:flutter_application_1/services/database_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationMessage> _notifications = [];
  final DatabaseService _dbService = DatabaseService.instance;
  late final StreamSubscription _notificationSubscription;

  List<NotificationMessage> get notifications => _notifications;

  NotificationProvider(NotificationService notificationService) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    fetchNotifications(currentUser.uid);
    _notificationSubscription = notificationService.newNotificationStream
        .listen(addNotification);
  }

  Future<void> fetchNotifications(String currentUserUid) async {
    _notifications = await _dbService.getNotifications(currentUserUid);
    notifyListeners();
  }

  void addNotification(NotificationMessage notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }
}
