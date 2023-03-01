import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoto/backend/navigation/navigation.dart';
import 'package:okoto/utils/date_presentation.dart';
import 'package:okoto/view/common/components/common_appbar.dart';
import 'package:okoto/view/common/components/common_text.dart';
import 'package:okoto/view/common/components/my_profile_avatar.dart';
import 'package:okoto/view/common/components/my_screen_background.dart';
import 'package:provider/provider.dart';

import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/user/user_provider.dart';
import '../../../configs/styles.dart';
import '../../../model/user/user_model.dart';
import '../../common/components/modal_progress_hud.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = "/profileScreen";

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ThemeData themeData;

  bool isLoading = false;

  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return MyScreenBackground(
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CommonAppBar(text: "Profile"),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 33,
                ),
                getMainWidget(),
                // Center(
                //   child: Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       singleOption1(
                //         iconData: Icons.list,
                //         option: "Orders",
                //         ontap: () async {
                //           NavigationController.navigateToOrderListScreen(
                //               navigationOperationParameters: NavigationOperationParameters(
                //             context: context,
                //             navigationType: NavigationType.pushNamed,
                //           ));
                //         },
                //       ),
                //       singleOption1(
                //         iconData: Icons.logout,
                //         option: "Logout",
                //         ontap: () async {
                //           AuthenticationController(userProvider: userProvider).logout(context: context, isShowConfirmDialog: true);
                //         },
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getMainWidget() {
    return Consumer<UserProvider>(
      builder: (BuildContext context, UserProvider userProvider, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getProfileUserNameWidget(
              userProvider.getUserModel() ?? UserModel(),
            ),
            SizedBox(height: 33,),
            getLastGamePlayedWidget(
              userProvider.getUserModel() ?? UserModel(),
            )
          ],
        );
      },
    );
  }

  //region ProfileUserNameWidegt
  Widget getProfileUserNameWidget(UserModel userModel) {
    return Column(
      children: [
        MyProfileAvatar(
          size: 100,
        ),
        CommonText(
          text: userModel.name,
          fontSize: 20,
          letterSpacing: .5,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(
          height: 8,
        ),
        CommonText(
          text: "@${userModel.userName}",
          fontSize: 16,
          letterSpacing: .5,
          fontStyle: FontStyle.italic,
          color: Styles.textWhiteColor,
          fontWeight: FontWeight.w600,
        )
      ],
    );
  }

  //endregion

  //region lastGamePlayedWidget
  Widget getLastGamePlayedWidget(UserModel userModel) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: getHeaderWithValue(headerText: "Last game played", value: "Call of Duty: Warzone", iconPath: "assets/icons/gamePad.png"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: VerticalDivider(
              thickness: 2,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: getHeaderWithValue(
                headerText: "Total Time",
                iconPath: "assets/icons/stopWatch.png",
                value: "${DatePresentation.getSingleFormat("mm", Timestamp.now())}m : ${DatePresentation.getSingleFormat("ss", Timestamp.now())}s"),
          ),
        ],
      ),
    );
  }

  Widget getHeaderWithValue({required String headerText, required String value, String iconPath = ""}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CommonText(
          text: headerText,
          color: Styles.textWhiteColor,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: iconPath.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
              Flexible(
                  child: CommonText(
                text: value,
                fontStyle: FontStyle.normal,
                fontSize: 16,
              )),
            ],
          ),
        ),
      ],
    );
  }

  //endregion

  Widget getProfileDetails() {
    return Consumer<UserProvider>(
      builder: (BuildContext context, UserProvider userProvider, Widget? child) {
        UserModel? userModel = userProvider.getUserModel();

        if (userModel == null) {
          return const Text("Profile Details Not Available");
        }

        String imageUrl = '';

        return Container(
          margin: const EdgeInsets.only(bottom: 250),
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(300),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.fill,
                        )
                      : Image.asset(
                          "assets/images/male profile vector.png",
                          fit: BoxFit.fill,
                        ),
                ),
              ),
              Text(userModel.name),
              Text(userModel.userName),
              Visibility(
                visible: (userModel.mobileNumber).isNotEmpty,
                child: Text(userModel.mobileNumber),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget singleOption1({required IconData iconData, required String option, Function? ontap}) {
    return InkWell(
      onTap: () async {
        if (ontap != null) ontap();
      },
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: themeData.bottomAppBarTheme.color,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Icon(
                iconData,
                size: 22,
                color: themeData.colorScheme.onBackground,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                child: Text(
                  option,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 22,
              color: themeData.colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}
