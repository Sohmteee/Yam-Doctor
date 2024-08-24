import 'package:flutter/material.dart';

class AppBoldText extends StatelessWidget {
  AppBoldText(
    this.text, {
    this.fontSize,
    this.fontWeight,
    super.key,
  });

  final String text;
  double? fontSize;
  FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight ?? FontWeight.bold,
        fontFamily: 'Quicksand',
      ),
    );
  }
}
