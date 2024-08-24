import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  AppText(
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
        fontWeight: fontWeight ?? FontWeight.normal,
        fontFamily: 'Quicksand',
      ),
    );
  }
}
