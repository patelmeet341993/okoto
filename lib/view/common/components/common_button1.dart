import 'package:flutter/material.dart';

import 'common_text.dart';

class CommonButton1 extends StatelessWidget {
  final String text;
  final Color? backgroundColor, textColor;
  final Function()? onTap;
  final EdgeInsetsGeometry? padding;
  final double textSize;

  const CommonButton1({
    super.key,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.textSize = 12,
  });

  @override
  Widget build(BuildContext context) {
     ThemeData themeData = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor ?? themeData.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child:CommonText(
            text: text,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: textSize,
          )
      ),
    );
  }
}
