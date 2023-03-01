import 'package:flutter/material.dart';

import 'common_text.dart';

class CommonButton1 extends StatelessWidget {
  final String text;
  final Color? backgroundColor, textColor, borderColor;
  final Function()? onTap;
  final EdgeInsetsGeometry? padding;
  final Widget? rowWidget;
  final double textSize;
  final double? height, width;

  const CommonButton1({
    super.key,
    required this.text,
    this.onTap,
    this.width,
    this.rowWidget,
    this.height,
    this.borderColor,
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
          height: height,
          width: width,

          decoration: BoxDecoration(
            color: backgroundColor ?? themeData.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor ?? Colors.transparent)
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
          child: rowWidget ?? CommonText(
            text: text,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: textSize,
          )
      ),
    );
  }
}
