import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppPref {
  static clearSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear().catchError((err) {
      print(err.toString());
    });
  }

  static Future<bool> clearUserPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.remove(USER_DATA);
  }

  static Future<bool> addString(String key, String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, val);
  }

  static addInt(String key, int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, val);
  }

  static addBoolean(String key, bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, val);
  }

  static getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString(key) ?? "";
    return stringValue;
  }

  static getInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int intValue = prefs.getInt(key) ?? 0;
    return intValue;
  }

  static getBoolean(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool intValue = prefs.getBool(key) ?? false;
    return intValue;
  }

  static const String USER_DATA = "userDtls";
  static const String EMAIL_ID = "emailId";
  static const String PASSWORD = "password";
  static const String USER_TYPE = "userType";
  static const String APP_LOCALE = "appLocale";

  static Future<bool> setUserData(String val) async {
    return await addString(USER_DATA, val);
  }

  static setEmailId(String val) {
    addString(EMAIL_ID, val);
  }

  static setPassword(String val) {
    addString(PASSWORD, val);
  }

  static setUserType(int val) {
    addInt(USER_TYPE, val);
  }

  setAppLocale(String key, String val) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, val);
  }

  //-----------------------//

  /* static Future<Map<String, dynamic>> getRemberData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var email = pref.getString(EMAIL_ID) ?? "";
    var password = pref.getString(PASSWORD) ?? "";
    var uType = pref.getInt(USER_TYPE) ?? 0;
    return {
      Arguments.EMAIL: email,
      Arguments.PASSWORD: password,
      Arguments.USER_TYPE: uType
    };
  } */

  static Future<String> getUserType() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = pref.getString(USER_TYPE);
    if (data == null) {
      return "";
    } else {
      return data;
    }
  }

  static Future<String> getPassword() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = pref.getString(PASSWORD);
    if (data == null) {
      return "";
    } else {
      return data;
    }
  }

  static Future<String?> getLoginData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = pref.getString(USER_DATA);
    return data;
  }

  static Future<String> getAppLocale() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = pref.getString(APP_LOCALE);
    return data ?? 'en';
  }
}
