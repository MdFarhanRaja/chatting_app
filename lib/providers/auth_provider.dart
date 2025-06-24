import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/base_provider.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'package:flutter_application_1/utils/logger.dart';

class AuthProvider extends BaseProvider {
  final NotificationService notificationService = NotificationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update the user's display name
      await userCredential.user?.updateDisplayName(username);
      await userCredential.user?.reload();

      debugPrint('Registered successfully: ${userCredential.user?.uid}');
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'An account already exists for that email.';
      } else {
        _errorMessage = 'Registration failed: ${e.message}';
      }
      debugPrint(_errorMessage);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      debugPrint(_errorMessage);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Logged in successfully: ${userCredential.user?.uid}');
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      Logger.error(e.message ?? 'Login failed');
      if (e.code == 'user-not-found') {
        _errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Wrong password provided for that user.';
      } else {
        _errorMessage = 'Login failed: ${e.message}';
      }
      debugPrint(_errorMessage);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      debugPrint(_errorMessage);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    notifyListeners();
    gotoNextWithNoBack(const LoginScreen(), context);
  }

  Future<String?> getFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      Logger.info('FCM Token: $token');
      return token;
    } catch (e) {
      Logger.error('Failed to get FCM token: $e');
      return null;
    }
  }
}
