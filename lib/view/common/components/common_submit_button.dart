import 'package:flutter/material.dart';
import 'package:okoto/view/common/components/common_text.dart';

import '../../../configs/styles.dart';

class CommonSubmitButton extends StatelessWidget {
  Function onTap;
  String text;
  double verticalPadding;
  double horizontalPadding;
  double fontSize;
  double borderRadius;
  Widget? icon;
  Widget? suffixIcon;
  bool isSelected = true;
  CommonSubmitButton({
    required this.onTap,
    required this.text,
    this.verticalPadding=13,
    this.fontSize=20,
    this.icon,
    this.suffixIcon,
    this.borderRadius=10,
    this.horizontalPadding=40,
    this.isSelected=true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      //splashColor: Colors.white,
      splashColor: Styles.myVioletShade3,
      highlightColor:Styles.myVioletShade3 ,
      padding: EdgeInsets.symmetric(horizontal: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18)
      ),
      onPressed: () {
        onTap();
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: verticalPadding,horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: Styles.myBorderVioletColor,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            gradient: LinearGradient(
              colors: [
                Styles.myDarkVioletShade2,
                Styles.myVioletShade3,
                Styles.myVioletShade3,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon != null ? Padding(
                padding:  EdgeInsets.only(right: 4.0),
                child: icon!,
              ) : Container(),
              CommonText(
                text: text,
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.normal,

              ),
              suffixIcon != null ? Padding(
                padding:  EdgeInsets.only(left: 4.0),
                child: suffixIcon!,
              ) : Container(),
            ],
          )),
    );
  }
}
