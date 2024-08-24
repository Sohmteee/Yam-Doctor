import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BoldText extends StatelessWidget {
  const BoldText(
    this.text, {
    this.fontSize,
    this.fontWeight,
    super.key,
  });

  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 24.sp,
        fontWeight: fontWeight ?? FontWeight.bold,
      ),
    );
  }
}
