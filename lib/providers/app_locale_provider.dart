import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_prefs.dart';

class AppLocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<bool> changeLocale({String language = 'en'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppPref.APP_LOCALE, language);
    _locale = Locale(language);
    notifyListeners();
    return Future.value(true);
  }

  void setLocale(Locale l) async {
    _locale = l;
  }
}
