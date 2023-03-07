import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:okoto/backend/authentication/authentication_controller.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/configs/constants.dart';
import 'package:okoto/utils/my_utils.dart';
import 'package:okoto/view/common/components/common_cachednetwork_image.dart';
import 'package:provider/provider.dart';

import '../../../configs/styles.dart';
import '../../../model/user/user_model.dart';
import 'image_view_page.dart';

class MyProfileAvatar extends StatelessWidget {
  final double size;
   bool isImageView = false;
    MyProfileAvatar({this.size = 27,this.isImageView = false});

  @override
  Widget build(BuildContext context) {
    bool isMale = true;
    return Consumer<UserProvider>(builder: (BuildContext context, UserProvider userProvider, Widget? child) {
      UserModel? userModel = userProvider.getUserModel();
      if (userModel != null) {
        if (userModel.gender == UserGender.male) {
          isMale = true;
        } else {
          isMale = false;
        }
      }
      return Container(
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Styles.myDarkVioletColor, width: 1.5)),
        child: userModel == null || userModel.profileImageUrl.isEmpty
            ? Image.asset(
                isMale ? 'assets/images/male.png' : 'assets/images/female.png',
                height: size,
                width: size,
              )
            : InkWell(
              onTap: isImageView ?  (){
                showDialog(context: context, builder: (context){
                  return ImageViewPage(
                    isDialog: true,
                    images: [userModel.profileImageUrl],
                    initialIndex: 0,
                  );
                });
              }:null,
              child: CommonCachedNetworkImage(
                  borderRadius: 100,
                  imageUrl: MyUtils().getSecureUrl(userModel.profileImageUrl),
                  height: size,
                  width: size,
                ),
            ),
      );
    });
  }
}
