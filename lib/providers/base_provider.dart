import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BaseProvider with ChangeNotifier {
  AppLocalizations AppLocale(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  gotoNextWithNoBack(Widget widget, BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget),
      (Route<dynamic> route) => false,
    );
  }
}
