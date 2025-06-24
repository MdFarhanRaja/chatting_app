import 'package:flutter_application_1/models/user.dart';

class AuthService {
  // In a real app, you would inject an HTTP client here.
  // For now, the service is self-contained.

  Future<User> login(String email, String password) async {
    // Simulate a network request
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, you would make a network request here
    // and handle success/error cases.
    // For now, we'll return a dummy user.
    if (email == 'test@example.com' && password == 'password') {
      return User(id: '1', name: 'Test User', email: email);
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<User> register(String name, String email, String password) async {
    // Simulate a network request
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, you would make a network request here
    // and handle success/error cases.
    // For now, we'll return a new dummy user.
    return User(id: '2', name: name, email: email);
  }
}
