import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CommonLoader extends StatelessWidget {
  final double size;
  final Color? backgroundColor, ringColor;

  const CommonLoader({
    Key? key,
    this.size = 80,
    this.backgroundColor,
    this.ringColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(size * 0.25),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? themeData.colorScheme.primary,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: SpinKitDualRing(
        color: ringColor ?? themeData.colorScheme.onPrimary,
        duration: const Duration(milliseconds: 500),
        size: size * 0.9,
        lineWidth: size * 0.03,
      ),
    );
  }
}
