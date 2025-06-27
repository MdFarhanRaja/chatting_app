import 'package:flutter_application_1/models/notification_message.dart';
import 'package:flutter_application_1/providers/base_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/services/notification_service.dart';

class ChatProvider extends BaseProvider {
  List<NotificationMessage> _messages = [];
  bool _isLoading = false;

  List<NotificationMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> loadChatHistory(String senderId, String receiverId) async {
    _isLoading = true;
    notifyListeners();

    _messages = await DatabaseService.instance.getChatHistory(
      senderId,
      receiverId,
    );
    _messages.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    _isLoading = false;
    notifyListeners();
  }

  void addMessage(NotificationMessage message) {
    _messages.add(message);
    _messages.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    notifyListeners();
  }

  final NotificationService _notificationService = NotificationService();

  Future<void> sendMessage({
    required String receiverId,
    required String messageText,
    required String token,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final notification = NotificationMessage(
      senderId: currentUser.uid,
      receiverId: receiverId,
      userName: currentUser.displayName ?? 'Unknown User',
      msg: messageText,
      timestamp: DateTime.now().toIso8601String(),
      token: token,
      title: currentUser.displayName ?? 'New Message',
    );

    addMessage(notification);

    try {
      await DatabaseService.instance.insertNotification(notification);

      await _notificationService.sendFCMMessage(
        token: token,
        title: notification.title,
        msg: notification.msg,
        senderId: notification.senderId,
        receiverId: notification.receiverId,
        userName: notification.userName,
      );
    } catch (e) {
      _messages.remove(notification);
      //notifyListeners();
      rethrow;
    }
  }
}
