import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  final double boxSize, loaderSize;
  final Color? backgroundColor, loaderColor;
  final double borderRadius;
  const LoadingWidget({
    Key? key,
    this.boxSize = 90,
    this.loaderSize = 50,
    this.backgroundColor,
    this.loaderColor,
    this.borderRadius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      height: boxSize,
      width: boxSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? themeData.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(borderRadius)
      ),
      child: Center(child: LoadingAnimationWidget.fourRotatingDots(color: loaderColor ?? themeData.primaryColor, size: loaderSize)),
    );
  }
}
