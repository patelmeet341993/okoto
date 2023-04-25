import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:okoto/backend/notification/notification_controller.dart';
import 'package:okoto/backend/notification/notification_provider.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/model/notification/notification_model.dart';
import 'package:okoto/utils/my_print.dart';
import 'package:okoto/view/common/components/common_cachednetwork_image.dart';
import 'package:okoto/view/common/components/common_text.dart';
import 'package:provider/provider.dart';

import '../../backend/analytics/analytics_controller.dart';
import '../../backend/analytics/analytics_event.dart';
import '../../configs/styles.dart';
import '../../utils/date_presentation.dart';
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
  late UserProvider userProvider;
  late NotificationProvider notificationProvider;
  late NotificationController notificationController;

  bool isLoading = false;
  /*NotificationModel notificationModel = NotificationModel(
    title: 'New Game Arrived',
    image: "https://res.cloudinary.com/dxegfkhzd/image/upload/v1677566819/pexels-sound-on-3761118_v4fec1.jpg",
    description: 'we are happy to inform you about our newly launched game which is blab ba blabal ',
  );*/
  Future? getFuture;

  Future<void> getData() async {
    try {
      await notificationController.getNotificationList(userId: userProvider.getUserId());
    } catch (e, s) {
      MyPrint.printOnConsole("Error in getData: $e");
      MyPrint.printOnConsole(s);
    }
  }

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    notificationProvider = context.read<NotificationProvider>();
    notificationController = NotificationController(notificationProvider: notificationProvider);
    AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.user_any_screen_view,parameters: {AnalyticsParameters.event_value:AnalyticsParameterValue.notification_screen});
    getFuture = getData();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CommonLoader(),
      child: MyScreenBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CommonAppBar(text: "Notifications"),
          body: FutureBuilder(
            future: getFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return getMainWidget();
              } else {
                return const Center(child: CommonLoader());
              }
            },
          ),
        ),
      ),
    );
  }

  Widget getMainWidget() {
    return Consumer(
      builder: (BuildContext context, NotificationProvider notificationProvider, _) {
        List<NotificationModel> notificationModelList = notificationProvider.getNotificationModelList;

        MyPrint.printOnConsole("notificationProvider.notificationsMapWithMonthYear:${notificationProvider.notificationsMapWithMonthYear}");

        return RefreshIndicator(
          onRefresh: () async {
            getFuture = getData();
            setState(() {});
          },
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: notificationModelList.length,
            itemBuilder: (BuildContext context, int index) {
              NotificationModel model = NotificationModel.fromMap(notificationModelList[index].toMap());
              String key = "";
              String month = "";
              if (model.createdTime != null) {
                key = "${model.createdTime!.toDate().month}${model.createdTime!.toDate().year}";

                DateTime now = DateTime.now();
                month = model.createdTime!.toDate().year == now.year && model.createdTime!.toDate().month == now.month
                    ? "This month"
                    : DatePresentation.MMyyyy(model.createdTime!);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  notificationProvider.notificationsMapWithMonthYear[key] == model.id
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                    child: CommonText(
                      text: month,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      letterSpacing: .2,
                    ),
                  )
                      : const SizedBox(),
                  getNotificationCard(model, model.isOpened, notificationProvider, key, month, index),
                  const Divider(
                    color: Colors.white,
                    height: 1,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget getNotificationCard(NotificationModel notificationModel, bool isSelected, NotificationProvider notificationProvider, String key, String month, index) {
    String titleFirstLetter = notificationModel.title.isNotEmpty ? notificationModel.title.toUpperCase() : "N";

    return InkWell(
      highlightColor: Colors.transparent,
      onTap: () {
        // notificationModel.isOpened = !notificationModel.isOpened;
        // if(isSelected){
        //   is
        // }
        if (isSelected) {
          notificationProvider.getNotificationModelList[index].isOpened = false;
          notificationController.updateNotificationIsNotificationOpen(model: notificationModel, loggedInUserId: userProvider.getUserId(), value: false);
          // AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.notificationscreen_notification_click,parameters: {AnalyticsParameters.event_value: 'need to give'});
          setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Styles.notificationCardColor : Colors.transparent,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Styles.notificationImage,
              borderRadius: BorderRadius.circular(4),
            ),
            child: notificationModel.image.isNotEmpty
                ? CommonCachedNetworkImage(imageUrl: notificationModel.image, borderRadius: 4)
                : Center(
              child: Text(
                titleFirstLetter.characters.first,
                style: TextStyle(
                  //color: Colors.black.withOpacity(.6),
                    color: Styles.readMoreTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 23),
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 1.0),
            child: Row(
              children: [
                Expanded(
                  child: CommonText(
                    text: notificationModel.title,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                CommonText(
                  text:  notificationModel.createdTime == null ? '' : DateFormat("dd/MM/yy").format(notificationModel.createdTime!.toDate()),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          subtitle: notificationModel.description.isNotEmpty ? Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: CommonText(
              text: notificationModel.description,
              fontSize: 14.0,
              maxLines: 2,
              height: 1.1,
              textOverFlow: TextOverflow.ellipsis,
            ),
          ):const SizedBox.shrink(),
        ),
      ),
    );
  }
}
