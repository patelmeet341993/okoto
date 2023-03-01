import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:okoto/backend/notification/notification_provider.dart';
import 'package:okoto/view/common/components/common_text.dart';
import 'package:provider/provider.dart';

import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/data/data_controller.dart';
import '../../../backend/data/data_provider.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../backend/user/user_controller.dart';
import '../../../backend/user/user_provider.dart';
import '../../../configs/styles.dart';
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

    await Future.delayed(const Duration(milliseconds: 100));

    //region Get Property Data
    DataProvider dataProvider = Provider.of<DataProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    await DataController(dataProvider: dataProvider).getPropertyData();
    //endregion

    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    NotificationProvider notificationProvider = Provider.of<NotificationProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    UserController userController = UserController(userProvider: userProvider,);

    bool isUserLoggedIn = await AuthenticationController(userProvider: userProvider).isUserLoggedIn(initializeUserid: true);

    if(isUserLoggedIn) {
      String userId = userProvider.getUserId();

      bool isExist = await userController.checkUserWithIdExistOrNotAndIfNotExistThenCreate(userId: userId);
      MyPrint.printOnConsole("isExist for userId '$userId':$isExist");

      if (isExist && (userProvider.getUserModel()?.isHavingNecessaryInformation() ?? false)) {
        MyPrint.printOnConsole("User Exist");

        await userController.checkSubscriptionActivatedOrNot();

        userController.startUserListening(
          userId: userId,
          notificationProvider: notificationProvider,
        );

        if(context.mounted) {
          // NavigationController.navigateToHomeTempScreen(navigationOperationParameters: NavigationOperationParameters(
          //   context: context,
          //   navigationType: NavigationType.pushNamedAndRemoveUntil,
          // ));
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

        // NavigationController.navigateToSignUpScreen(navigationOperationParameters: NavigationOperationParameters(
        //   context: context,
        //   navigationType: NavigationType.pushNamed,
        // ));

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
        body:Stack(
          children: [
            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                //color: Styles.myBackgroundShade2,

                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  // image: AssetImage('assets/images/mybackground.png',),
                  image: AssetImage('assets/icons/Splash_screen.jpg',),
                ),
                gradient: LinearGradient(
                  colors: [
                    Styles.myBlueColor.withAlpha(-85),
                    Styles.myBackgroundShade1,
                    Styles.myBackgroundShade1,
                    Styles.myBackgroundShade1,
                    Styles.myBackgroundShade2,
                    Styles.myBackgroundShade3,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [-2,0.18,0.45,0.6,0.70,2,],
                ),

              ),
              child: Container(),


            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 45,
            child: SpinKitDualRing(
                        //  color:Styles.myLightPinkShade,
                        color:Colors.white,
                        duration: const Duration(milliseconds: 500),
                        size: 45,
                        lineWidth: 3,
                      ),
          ),
          ],
        )
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        //   child: Column(
        //     children: [
        //       /*Center(
        //         child: LoadingAnimationWidget.inkDrop(color: themeData.backgroundColor, size: 40),
        //       ),*/
        //       Expanded(
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             CommonText(
        //               text: 'OKOTO',
        //               //color: Styles.myLightPinkShade.withOpacity(.4),
        //               color: Styles.myVioletShade4.withOpacity(.8),
        //               fontWeight: FontWeight.bold,
        //               fontSize: 60,
        //             ),
        //           ],
        //         )
        //
        //         // Center(
        //         //   child: Image.asset("assets/images/${AppController.isDev ? "okoto-dev-logo.png" : "okoto-prod-logo.png"}"),
        //         // ),
        //       ),
        //       const Center(
        //         child: SpinKitDualRing(
        //           //  color:Styles.myLightPinkShade,
        //           color:Colors.white,
        //           duration: const Duration(milliseconds: 500),
        //           size: 50,
        //           lineWidth: 5,
        //         ),
        //       ),
        //       SizedBox(height: 15,)
        //     ],
        //   ),
        // ),
      ),
    );
  }

}
