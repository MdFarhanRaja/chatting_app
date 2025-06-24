import 'package:flutter/material.dart';
import '../baseclass_stateless.dart';

class RoundButton extends BaseClassStateLess {
  Color? backgroundColor;
  Color foregroundColor;
  Color borderColor;
  Color shadowColor;
  double paddingHorizontal;
  double paddingVertical;
  double borderRadius;
  BorderRadiusGeometry? borderRadiusGeometry;
  double elevation;
  double borderWidth;
  String? title;
  Widget? widget;
  TextStyle? textStyle;
  void Function() onClick;
  RoundButton(
      {super.key,
      required this.onClick,
      this.title,
      this.backgroundColor,
      this.foregroundColor = Colors.black,
      this.borderColor = Colors.transparent,
      this.shadowColor = Colors.transparent,
      this.paddingHorizontal = 10,
      this.paddingVertical = 10,
      this.borderRadius = 100,
      this.borderRadiusGeometry,
      this.elevation = 0,
      this.borderWidth = 0,
      this.widget,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onClick(),
      style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: borderColor, width: borderWidth),
              borderRadius: borderRadiusGeometry ??
                  BorderRadius.all(Radius.circular(borderRadius))),
          shadowColor: shadowColor,
          padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal, vertical: paddingVertical),
          elevation: elevation),
      child: widget ??
          Text(
            title ?? 'Title',
            style: textStyle,
          ),
    );
  }
}
