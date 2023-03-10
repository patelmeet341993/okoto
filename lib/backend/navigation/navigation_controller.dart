import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:okoto/view/authentication/screens/sign_up_screen.dart';

import '../../utils/my_print.dart';
import '../../view/authentication/screens/login_screen.dart';
import '../../view/authentication/screens/otp_screen.dart';
import '../../view/common/screens/about_app_screen.dart';
import '../../view/common/screens/splashscreen.dart';
import '../../view/common/screens/terms_and_conditions_screen.dart';
import '../../view/home/screens/home_screen.dart';
import 'navigation_arguments.dart';
import 'navigation_operation.dart';
import 'navigation_operation_parameters.dart';

class NavigationController {
  static NavigationController? _instance;
  static String chatRoomId = "";
  static bool isNoInternetScreenShown = false;
  static bool isFirst = true;

  factory NavigationController() {
    _instance ??= NavigationController._();
    return _instance!;
  }

  NavigationController._();

  static final GlobalKey<NavigatorState> mainScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> pharmaDashboardScreenNavigator = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> historyScreenNavigator = GlobalKey<NavigatorState>();

  static bool isUserProfileTabInitialized = false;

  static bool checkDataAndNavigateToSplashScreen() {
    MyPrint.printOnConsole("checkDataAndNavigateToSplashScreen called, isFirst:$isFirst");

    if(isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        isFirst = false;
        Navigator.pushNamedAndRemoveUntil(mainScreenNavigator.currentContext!, SplashScreen.routeName, (route) => false);
      });
    }

    return isFirst;
  }

  static Route? onMainAppGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("onAdminMainGeneratedRoutes called for ${settings.name} with arguments:${settings.arguments}");

    // if(navigationCount == 2 && Uri.base.hasFragment && Uri.base.fragment != "/") {
    //   return null;
    // }

    if(kIsWeb) {
      if(!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }
    /*if(!["/", SplashScreen.routeName].contains(settings.name)) {
      if(NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }
    else {
      if(!kIsWeb) {
        if(isFirst) {
          isFirst = false;
        }
      }
    }*/

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/": {
        page = const SplashScreen();
        break;
      }
      case SplashScreen.routeName: {
        page = const SplashScreen();
        break;
      }
      case LoginScreen.routeName: {
        page = parseLoginScreen(settings: settings);
        break;
      }
      case OtpScreen.routeName: {
        page = parseOtpScreen(settings: settings);
        break;
      }
      case SignUpScreen.routeName: {
        page = parseSignUpScreen(settings: settings);
        break;
      }
      case HomeScreen.routeName: {
        page = parseHomeScreen(settings: settings);
        break;
      }
      case TermsAndConditionsScreen.routeName: {
        page = parseTermsAndConditionsScreen(settings: settings);
        break;
      }
      case AboutAppScreen.routeName: {
        page = parseAboutAppScreen(settings: settings);
        break;
      }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  //region Parse Page From RouteSettings
  static Widget? parseLoginScreen({required RouteSettings settings}) {
    return const LoginScreen();
  }

  static Widget? parseOtpScreen({required RouteSettings settings}) {
    if(settings.arguments is OtpScreenNavigationArguments) {
      OtpScreenNavigationArguments arguments = settings.arguments as OtpScreenNavigationArguments;

      return OtpScreen(mobile: arguments.mobileNumber,);
    }
    else {
      return null;
    }
  }

  static Widget? parseSignUpScreen({required RouteSettings settings}) {
    return const SignUpScreen();
  }

  static Widget? parseHomeScreen({required RouteSettings settings}) {
    return const HomeScreen();
  }

  static Widget? parseTermsAndConditionsScreen({required RouteSettings settings}) {
    if(settings.arguments is TermsAndConditionsScreenNavigationArguments) {
      TermsAndConditionsScreenNavigationArguments arguments = settings.arguments as TermsAndConditionsScreenNavigationArguments;

      return TermsAndConditionsScreen(termsAndConditionsUrl: arguments.termsAndConditionsUrl,);
    }
    else {
      return null;
    }
  }

  static Widget? parseAboutAppScreen({required RouteSettings settings}) {
    if(settings.arguments is AboutAppScreenNavigationArguments) {
      AboutAppScreenNavigationArguments arguments = settings.arguments as AboutAppScreenNavigationArguments;

      return AboutAppScreen(
        aboutDescription: arguments.aboutDescription,
        contact: arguments.contact,
        whatsapp: arguments.whatsapp,
      );
    }
    else {
      return null;
    }
  }
  //endregion

  //region Navigation Methods
  static Future<dynamic> navigateToLoginScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: LoginScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToOtpScreen({required NavigationOperationParameters navigationOperationParameters, required OtpScreenNavigationArguments arguments}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: OtpScreen.routeName,
      arguments: arguments,
    ));
  }

  static Future<dynamic> navigateToSignUpScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: SignUpScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToHomeScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: HomeScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToTermsAndConditionsScreen({required NavigationOperationParameters navigationOperationParameters, required TermsAndConditionsScreenNavigationArguments arguments}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: TermsAndConditionsScreen.routeName,
      arguments: arguments,
    ));
  }

  static Future<dynamic> navigateToAboutAppScreen({required NavigationOperationParameters navigationOperationParameters, required AboutAppScreenNavigationArguments arguments}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: AboutAppScreen.routeName,
      arguments: arguments,
    ));
  }
  //endregion
}
