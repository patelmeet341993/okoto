import 'package:flutter/material.dart';
import 'package:okoto/backend/common/app_controller.dart';
import 'package:okoto/view/common/components/common_loader.dart';
import 'package:provider/provider.dart';

import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/data/data_controller.dart';
import '../../../backend/data/data_provider.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../backend/user/user_controller.dart';
import '../../../backend/user/user_provider.dart';
import '../../../utils/my_print.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/SplashScreen";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late ThemeData themeData;

  Future<void> checkLogin() async {
    NavigationController.isFirst = false;

    await Future.delayed(const Duration(seconds: 3));

    //region Get Property Data
    DataProvider dataProvider = Provider.of<DataProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    await DataController(dataProvider: dataProvider).getPropertyData();
    //endregion

    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);

    bool isUserLoggedIn = await AuthenticationController(userProvider: userProvider).isUserLoggedIn(initializeUserid: true);

    if(isUserLoggedIn) {
      bool isExist = await UserController(userProvider: userProvider,).checkUserWithIdExistOrNotAndIfNotExistThenCreate(userId: userProvider.getUserId());
      MyPrint.printOnConsole("isExist:$isExist");

      if (isExist && (userProvider.getUserModel()?.isHavingNecessaryInformation() ?? false)) {
        MyPrint.printOnConsole("User Exist");

        if(context.mounted) {
          NavigationController.navigateToHomeScreen(navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ));
        }
      }
      else {
        MyPrint.printOnConsole("User Not Exist");
        MyPrint.logOnConsole("Created:${userProvider.getUserModel()}");

        if(context.mounted) {
          NavigationController.navigateToSignUpScreen(navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ));
        }
      }
    }
    else {
      if(context.mounted) {
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
              const Center(
                child: CommonLoader(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
