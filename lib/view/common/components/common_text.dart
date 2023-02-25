import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  final String text;
  final double fontSize, letterSpacing;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? textOverFlow;
  final TextDecoration? textDecoration;

  const CommonText({
    super.key,
    required this.text,
    this.fontSize = 13,
    this.letterSpacing = 1.1,
    this.fontWeight = FontWeight.normal,
    this.color =  Colors.white,
    this.textAlign,
    this.maxLines,
    this.textDecoration,
    this.textOverFlow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: textOverFlow,
      style: TextStyle(
        //height: 1,
        letterSpacing: letterSpacing,
        wordSpacing: 1,
        decoration: textDecoration,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
