/*
* File : Location Permission Dialog
* Version : 1.0.0
* */

import 'package:flutter/material.dart';

import '../../../configs/styles.dart';
import 'common_text.dart';

class CommonPopUp extends StatelessWidget {
  final String text;
  final String leftText ,rightText;
  final IconData? icon;
  final Color rightBackgroundColor;
  final Function()? rightOnTap;
  final Function()? leftOnTap;

  const CommonPopUp({
    super.key,
    required this.text,
    this.icon,
    this.leftText = "No",
    this.rightText = "Yes",
    this.leftOnTap,
    this.rightOnTap,
    this.rightBackgroundColor =  Styles.myBorderVioletColor,
  });

  @override
  Widget build(BuildContext context) {

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Container(
      //  height: MediaQuery.of(context).size.height*.15,
        //width: MediaQuery.of(context).size.width*.3,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Styles.darkBackgroundColor
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                icon!=null?Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Icon(
                    icon,
                    size: 28,
                    color:Colors.black,
                  ),
                ):const SizedBox.shrink(),
                const SizedBox(width: 8,),
                Expanded(
                  child: CommonText(
                    text: text,
                    fontWeight: FontWeight.normal,
                    fontSize: 15,

                  ),
                )
              ],
            ),
            Container(
                margin: const EdgeInsets.only(top: 20),
                alignment: AlignmentDirectional.centerEnd,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: InkWell(
                        onTap:() {
                          if(leftOnTap == null){
                            Navigator.pop(context);
                          }else{
                            leftOnTap!();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: CommonText(
                              text:leftText ,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            )
                        ),
                      ),
                    ),
                    Flexible(
                      child: InkWell(
                        onTap: rightOnTap,
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                            decoration: BoxDecoration(
                              color: rightBackgroundColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child:CommonText(
                              text:rightText ,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            )
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

