import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:okoto/backend/navigation/navigation.dart';
import 'package:provider/provider.dart';

import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/user/user_provider.dart';
import '../../../model/user/user_model.dart';
import '../../common/components/modal_progress_hud.dart';

class ProfileScreen extends StatefulWidget {
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

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body:  Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getProfileDetails(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    singleOption1(
                      iconData: Icons.list,
                      option: "Orders",
                      ontap: () async {
                        NavigationController.navigateToOrderListScreen(navigationOperationParameters: NavigationOperationParameters(
                          context: context,
                          navigationType: NavigationType.pushNamed,
                        ));
                      },
                    ),
                    singleOption1(
                      iconData: Icons.logout,
                      option: "Logout",
                      ontap: () async {
                        AuthenticationController(userProvider: userProvider).logout(context: context, isShowConfirmDialog: true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getProfileDetails() {
    return Consumer<UserProvider>(
      builder: (BuildContext context, UserProvider userProvider, Widget? child) {
        UserModel? userModel = userProvider.getUserModel();

        if(userModel == null) {
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
                      ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.fill,)
                      : Image.asset("assets/images/male profile vector.png", fit: BoxFit.fill,),
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
      onTap: ()async {
        if(ontap != null) ontap();
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
                child: Text(option,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
              size: 22,
              color: themeData.colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}
