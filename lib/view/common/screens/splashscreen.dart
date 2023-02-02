import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:okoto/backend/common/app_controller.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/SplashScreen";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late ThemeData themeData;

  Future<void> checkLogin() async {
    /*AdminUserProvider adminUserProvider = Provider.of<AdminUserProvider>(context, listen: false);
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);

    MyDataController(provider: dataProvider).getPropertyData();

    await Future.delayed(const Duration(milliseconds: 600));

    AdminUserModel? user = await AuthenticationController(adminUserProvider: adminUserProvider).isAdminUserLoggedIn();
    MyPrint.printOnConsole("User From isUserLoggedIn:$user");*/

    await Future.delayed(const Duration(seconds: 3));

    // bool isUserLoggedIn = user != null;
    bool isUserLoggedIn = Random().nextBool();

    NavigationController.isFirst = false;
    if(mounted) {
      if(isUserLoggedIn) {
        /*AdminUserProvider adminUserProvider = Provider.of<AdminUserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
        VisitProvider visitProvider = Provider.of<VisitProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
        MyAdminUserController(provider: adminUserProvider).startAdminUserSubscription(visitProvider: visitProvider);*/

        NavigationController.navigateToHomeScreen(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ),
        );
      }
      else {
        NavigationController.navigateToLoginScreen(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Container(
      color: themeData.colorScheme.background,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            children: [
              /*Center(
                child: LoadingAnimationWidget.inkDrop(color: themeData.backgroundColor, size: 40),
              ),*/
              Expanded(
                child: Center(
                  child: Image.asset("assets/images/${AppController.isDev ? "okoto-dev-logo.png" : "okoto-prod-logo.png"}"),
                ),
              ),
              Center(
                child: LoadingAnimationWidget.inkDrop(color: themeData.primaryColor, size: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
