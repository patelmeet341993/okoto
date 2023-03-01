import 'package:flutter/material.dart';
import 'package:okoto/backend/authentication/authentication_controller.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/configs/constants.dart';
import 'package:provider/provider.dart';

import '../../../configs/styles.dart';
import '../../../model/user/user_model.dart';

class MyProfileAvatar extends StatelessWidget {
  final double size;
  const MyProfileAvatar({super.key, this.size = 27});

  @override
  Widget build(BuildContext context) {
    bool isMale = true;
    return Consumer<UserProvider>(
        builder: (BuildContext context, UserProvider userProvider, Widget? child) {
          UserModel? userModel = userProvider.getUserModel();
          if(userModel !=  null){
            if(userModel.gender == UserGender.male){
              isMale = true;
            }else{
              isMale = false;
            }
          }
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Styles.myDarkVioletColor,width: 1.5)
            ),
            child: Image.asset(isMale?'assets/images/male.png':'assets/images/female.png',
              height: size,width: size,),
          );
        }
    );
  }
}
