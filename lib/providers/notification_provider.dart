import 'dart:async';

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
    fetchNotifications();
    _notificationSubscription = notificationService.newNotificationStream.listen(addNotification);
  }

  Future<void> fetchNotifications() async {
    _notifications = await _dbService.getNotifications();
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
