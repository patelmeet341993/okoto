import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:okoto/model/notification/notification_model.dart';
import 'package:okoto/view/common/components/common_cachednetwork_image.dart';
import 'package:okoto/view/common/components/common_text.dart';

import '../../configs/styles.dart';
import '../common/components/common_appbar.dart';
import '../common/components/common_loader.dart';
import '../common/components/modal_progress_hud.dart';
import '../common/components/my_screen_background.dart';

class NotificationScreen extends StatefulWidget {
  static const String routeName = "/NotificationScreen";

  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isLoading = false;
  NotificationModel notificationModel = NotificationModel(
    title: 'New Game Arrived',
    image:"https://res.cloudinary.com/dxegfkhzd/image/upload/v1677566819/pexels-sound-on-3761118_v4fec1.jpg",
    description: 'we are happy to inform you about our newly launched game which is blab ba blabal '
  );

  @override
  Widget build(BuildContext context) {
    return  ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CommonLoader(),
      child: Scaffold(
        body: MyScreenBackground(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CommonAppBar(text: 'Notification'),
                       SizedBox(height: 30,),
                       getNotificationCard(notificationModel,true),
                       getNotificationCard(notificationModel,false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getNotificationCard(NotificationModel notificationModel,bool isSelected){
    String titleFirstLetter = notificationModel.title.isNotEmpty?notificationModel.title.toUpperCase() : "N";

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            //color: Colors.transparent,
            color: isSelected?Styles.notificationCardColor:Colors.transparent,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color:Styles.notificationImage,
                borderRadius: BorderRadius.circular(4),
              ),
              child: notificationModel.image.isNotEmpty
                  ? CommonCachedNetworkImage(
                  imageUrl: notificationModel.image,
                  borderRadius: 4,
              )
                  : Center(child: Text(
                titleFirstLetter.characters.first,
                style: TextStyle(
                  //color: Colors.black.withOpacity(.6),
                    color:Styles.readMoreTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 23
                ),
              ))
            ),
            title: Padding(
              padding:  EdgeInsets.only(bottom: 1.0),
              child: Row(
                children: [
                  Expanded(
                    child: CommonText(
                     text:  notificationModel.title,
                     fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),

                  ),
                  SizedBox(width: 1,),
                  CommonText(
                    text: '12/12/23',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: CommonText(
                text: notificationModel.description,
                  fontSize: 14.0,
                  maxLines: 2,
                  height: 1.1,
                  textOverFlow: TextOverflow.ellipsis,

              ),
            ),
          ),
        ),
        Divider(
          color: Colors.white,
          height: 1,
        )
      ],
    );
  }


}
