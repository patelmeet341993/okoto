import 'package:flutter/material.dart';

import '../../../configs/styles.dart';


class MyScreenBackground extends StatelessWidget {
  Widget child;
   MyScreenBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
         //color: Styles.myBackgroundShade2,

        image: DecorationImage(
        fit: BoxFit.fitWidth,
        // image: AssetImage('assets/images/mybackground.png',),
        image: AssetImage('assets/images/background2.png',),
    ),
        gradient: LinearGradient(
              colors: [
              Styles.myBlueColor.withAlpha(-85),
              Styles.myBackgroundShade1,
              Styles.myBackgroundShade1,
              Styles.myBackgroundShade1,
              Styles.myBackgroundShade2,
              Styles.myBackgroundShade3,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [-2,0.18,0.45,0.6,0.70,2,],
        ),

    ),
      child: child,


    );
  }
}
