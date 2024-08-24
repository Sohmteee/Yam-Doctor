import 'package:flutter/material.dart';

class BoldText extends StatelessWidget {
  const BoldText( 
    this.text, {
       this.fontSize,
        this.fontWeight,
    super.key,

  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;


  @override
  Widget build(BuildContext context) {
    return Text(
      'Yam Doctor',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
