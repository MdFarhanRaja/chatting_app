import 'package:flutter/material.dart';

class BaseProvider with ChangeNotifier {
  gotoNextWithNoBack(Widget widget, BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget),
      (Route<dynamic> route) => false,
    );
  }
}
