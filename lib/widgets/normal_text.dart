import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText({super.key});

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