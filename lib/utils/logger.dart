import 'package:flutter/foundation.dart';

class Logger {
  // Private constructor to prevent instantiation
  Logger._();

  static void log(String message, {String tag = 'App'}) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  static void info(String message, {String tag = 'Info'}) {
    if (kDebugMode) {
      debugPrint('[$tag] [34m$message[0m'); // Blue for info
    }
  }

  static void success(String message, {String tag = 'Success'}) {
    if (kDebugMode) {
      debugPrint('[$tag] [32m$message[0m'); // Green for success
    }
  }

  static void warning(String message, {String tag = 'Warning'}) {
    if (kDebugMode) {
      debugPrint('[$tag] [33m$message[0m'); // Yellow for warning
    }
  }

  static void error(String message, {String tag = 'Error', Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[$tag] [31m$message[0m'); // Red for error
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }
}
