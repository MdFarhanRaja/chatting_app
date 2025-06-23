import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/app_constants.dart';

abstract class BaseClass<T extends StatefulWidget> extends State<T> {
  BaseClass() {}

  late AuthProvider authProvider;

  initProvider() {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  gotoNextWithNoBack(Widget widget) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget),
      (Route<dynamic> route) => false,
    );
  }

  gotoNextClearThis(Widget widget) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  Future<Object?> gotoNext(Widget v) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (mContext) => v),
    );
  }

  bool isIOS() {
    return Platform.isIOS;
  }

  bool isNullOrEmpty(String? data) {
    return data == null || data == '';
  }

  void onBackPress({Object? result}) {
    Navigator.pop(context, result);
  }

  void hideKeyBoard({BuildContext? mContext}) {
    FocusScopeNode currentFocus = FocusScope.of(mContext ?? context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  getHorizontalGap({double width = 20}) {
    return SizedBox(width: width);
  }

  getVerticalGap({double height = 20}) {
    return SizedBox(height: height);
  }

  void changeSystemUiColor({
    Color statusBarColor = Colors.black,
    Color navBarColor = Colors.black,
    brightness = Brightness.light,
    navBrightness = Brightness.light,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: navBarColor, // navigation bar color
        statusBarColor: statusBarColor, // status bar color
        statusBarIconBrightness: brightness, // status bar icon color
        systemNavigationBarIconBrightness:
            navBrightness, // color of navigation controls
      ),
    );
  }

  bool isProgress = false;
  void showProgress({String? msg}) {
    isProgress = true;
    /* changeSystemUiColor(
        statusBarColor: Colors.transparent,
        navBarColor: AppTheme.white.withOpacity(0.9)); */
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              height: 40,
              width: 40,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(100)),
                color: Colors.white,
              ),
              child: const SpinKitFadingCircle(
                color: Color(0xFFddb12e),
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      //prevent outside touch
      barrierDismissible: true,
      barrierColor: Colors.white.withOpacity(0.9),
      context: context,
      builder: (BuildContext context) {
        //prevent Back button press
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: alert,
        );
      },
    );
  }

  void hideProgress() {
    if (isProgress) {
      isProgress = false;
      // if (changestatusBarColor) {
      //   changeSystemUiColor(
      //       statusBarColor: statusBarColor, brightness: Brightness.light);
      // }
      Navigator.pop(context);
    }
  }

  bool equalsIgnoreCase(String? a, String? b) =>
      (a == null && b == null) ||
      (a != null && b != null && a.toLowerCase() == b.toLowerCase());

  void showSnackBar(
    dynamic msg, {
    int msgType = AppConstants.SUCCESS,
    BuildContext? buildContext,
    Color bgColor = Colors.green,
    Duration d = const Duration(milliseconds: 2500),
  }) {
    var scaffoldMessenger = ScaffoldMessenger.of(buildContext ?? context);
    var sn = scaffoldMessenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        elevation: 0,
        content: Container(
          decoration: BoxDecoration(
            color: msgType == AppConstants.SUCCESS ? bgColor : Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(msg),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                },
              ),
            ],
          ),
        ),
        duration: d,
      ),
    );
  }

  void showToast(
    String msg, {
    ToastGravity? gravity = ToastGravity.BOTTOM,
    Color bgColor = Colors.white,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      //backgroundColor: bgColor.withAlpha(160),
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 17.0,
    );
  }
}
