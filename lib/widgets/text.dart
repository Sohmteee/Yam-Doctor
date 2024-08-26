import 'package:flutter/material.dart';

class AppBoldText extends StatelessWidget {
  AppBoldText(
    this.text, {
    this.fontSize,
    this.fontWeight,
    this.color,
    super.key,
  });

  final String text;
  double? fontSize;
  FontWeight? fontWeight;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight ?? FontWeight.bold,
        fontFamily: 'Quicksand',
        fontSize: fontSize,
      ),
    );
  }
}

class AppText extends StatelessWidget {
  AppText(
    this.text, {
    this.fontSize,
    this.fontWeight,
    this.color,
    super.key,
  });

  final String text;
  double? fontSize;
  FontWeight? fontWeight;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight,
        fontFamily: 'Quicksand',
        fontSize: fontSize,
      ),
    );
  }
}
