import 'package:flutter/material.dart';

import '../../../configs/styles.dart';


class CommonBackButton extends StatelessWidget {
  const CommonBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: Styles.myButtonBlack,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Styles.myVioletShade4)
        ),
        child: Icon(
          Icons.arrow_back_outlined,
          color: Styles.myVioletShade4,
          size: 20,
        ),
      ),
    );
  }
}
