import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/providers/base_provider.dart';

class AuthProvider extends BaseProvider {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    // Here you would typically call your authentication service
    debugPrint('Registered with username: $username, email: $email');

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    // Here you would typically call your authentication service
    // For now, we'll just pretend the login is successful
    debugPrint('Logged in with email: $email');

    _isLoading = false;
    notifyListeners();
  }
}
