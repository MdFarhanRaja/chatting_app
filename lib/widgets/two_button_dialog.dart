import '../baseclass_stateless.dart';
import 'package:flutter/material.dart';

class TwoButtonDialog extends BaseClassStateLess {
  late final String title;
  late final String message;
  late final String positiveBtnText;
  late final String negativeBtnText;
  late final Function onPostivePressed;
  late final Function onNegativePressed;
  Color? titleColor;
  Color? positiveColor;
  Color? negativeColor;

  TwoButtonDialog({
    required this.title,
    required this.message,
    required this.positiveBtnText,
    required this.negativeBtnText,
    required this.onPostivePressed,
    required this.onNegativePressed,
    this.titleColor,
    this.positiveColor,
    this.negativeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 20,
                left: 15,
                right: 15,
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor ?? Colors.black,
                  fontSize: 13,
                ),
              ),
            ),
            getHorizontalLine(color: Colors.grey, height: 1),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: titleColor ?? Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onNegativePressed();
                      },
                      child: Text(
                        negativeBtnText.toUpperCase(),
                        style: TextStyle(
                          color: negativeColor ?? Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, color: Colors.grey[300]),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: titleColor ?? Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onPostivePressed();
                      },
                      child: Text(
                        positiveBtnText.toUpperCase(),
                        style: TextStyle(
                          color: positiveColor ?? Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }
}
