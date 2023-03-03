import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:okoto/backend/notification/notification_provider.dart';
import 'package:okoto/view/common/components/common_text.dart';
import 'package:okoto/view/common/components/my_screen_background.dart';
import 'package:provider/provider.dart';
import 'package:show_up_animation/show_up_animation.dart';

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

  Future<void> waitScreen({required DateTime startTime}) async {
    DateTime endTimeTime = DateTime.now();
    int inMilliseconds = endTimeTime.difference(startTime).inMilliseconds;
    MyPrint.printOnConsole("inMilliseconds:$inMilliseconds");

    int remainingTime = 2300 - inMilliseconds;
    MyPrint.printOnConsole("remainingTime:$remainingTime");
    if(remainingTime > 0) {
      await Future.delayed(Duration(milliseconds: remainingTime));
    }
  }

  Future<void> checkLogin() async {
    NavigationController.isFirst = false;

    DateTime startTime = DateTime.now();

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

        await waitScreen(startTime: startTime);

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

        await waitScreen(startTime: startTime);

        if(context.mounted) {
          NavigationController.navigateToSignUpScreen(navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ));
        }

      }
    }
    else {
      await waitScreen(startTime: startTime);
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

    return  Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitWidth,
            image: AssetImage('assets/splash_screen/splash_screen_background.png',),
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
        child: Container(
          padding: EdgeInsets.all(25),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(width: 80,),
                        Expanded(
                          flex: 1,
                          child: myContainer('assets/splash_screen/logo_K.png',number: 1),
                        ),
                        Expanded(
                          flex: 1,
                          child: myContainer('assets/splash_screen/logo_o.png',number: 2),
                        ),
                        Expanded(
                          flex: 1,
                          child: myContainer('assets/splash_screen/logo_T.png',number: 3),
                        ),
                        Expanded(
                          flex: 1,
                          child: myContainer('assets/splash_screen/logo_o.png',number: 4),
                        ),

                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: myContainer('assets/splash_screen/logo_image.png',size: 80,),
                  ),
                ],
              ),
              ShowUpAnimation(
                direction: Direction.vertical,
                delayStart: Duration(milliseconds: 5*300 + 100),
                child: Container(
                  margin: EdgeInsets.only(top:5 ),
                  child: Image.asset(
                    'assets/splash_screen/logo_real_time.png',
                    fit: BoxFit.fill,
                  ),
                ),
              )



            ],
          ),
        ),
      ),
    );
  }


  Widget myContainer(String imageUrl,{double size =  45,double? width,int number = 0}){
    return ShowUpAnimation(
      delayStart: Duration(milliseconds: number*300 + 100),
      direction: Direction.horizontal,
      child: Container(
        margin: EdgeInsets.only(right:4 ),
        child: Image.asset(
          imageUrl,
          height: size,
          width: width,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

}
