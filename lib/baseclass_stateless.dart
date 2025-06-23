import 'package:flutter/material.dart';

abstract class BaseClassStateLess extends StatelessWidget {
  const BaseClassStateLess({super.key});

  Widget getHorizontalLine({double height = 1.5, Color color = Colors.grey}) {
    return Container(height: height, color: color);
  }

  Widget getVerticalLine({double height = 1.5, Color color = Colors.grey}) {
    return Container(height: height, width: 1.5, color: color);
  }
}
