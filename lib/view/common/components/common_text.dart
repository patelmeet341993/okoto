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
  final FontStyle fontStyle;
  final double? height;

  const CommonText({
    super.key,
    required this.text,
    this.fontSize = 13,
    this.fontStyle = FontStyle.normal,
    this.letterSpacing = 1.1,
    this.fontWeight = FontWeight.normal,
    this.color =  Colors.white,
    this.textAlign,
    this.maxLines,
    this.height,
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
        height: height,
        fontStyle: fontStyle,
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
