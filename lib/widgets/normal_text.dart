import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        fontSize: fontSize ?? 16.sp,
        fontWeight: fontWeight ?? FontWeight.normal,
        fontFamily: 'Quicksand',
      ),
    );
  }
}
