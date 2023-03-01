import 'package:flutter/material.dart';
import 'package:okoto/view/common/components/common_text.dart';

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
                       SizedBox(height: 300,),

                       CommonText(
                         text: 'No Notifications',
                         fontWeight: FontWeight.bold,
                         fontSize: 19,
                         textAlign: TextAlign.center,
                       )

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
}
