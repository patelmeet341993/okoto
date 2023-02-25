

import 'package:flutter/material.dart';
import 'package:okoto/view/common/components/common_back_button.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({Key? key, this.text = "", this.height = kToolbarHeight}) : super(key: key);
  final String text;
  final double height;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(double.infinity, height),
      child: AppBar(
        // leadingWidth: 55,
        leading: Row(
        children:  [
            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 18.0),
                child: SizedBox(
                  width: 32,
                    height: 32,
                    child: CommonBackButton(padding: 0,)),
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(text, style: const TextStyle(
          fontSize: 20,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600
        ),),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}


