import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:okoto/view/authentication/screens/sign_up_screen.dart';
import 'package:okoto/view/notification_screen/notification_screen.dart';
import 'package:okoto/view/device/screens/devices_screen.dart';
import 'package:okoto/view/order/screens/order_detail_screen.dart';
import 'package:okoto/view/subscription/screens/subscription_detail_screen.dart';

import '../../utils/my_print.dart';
import '../../view/authentication/screens/login_screen.dart';
import '../../view/authentication/screens/otp_screen.dart';
import '../../view/common/screens/about_app_screen.dart';
import '../../view/common/screens/splashscreen.dart';
import '../../view/common/screens/terms_and_conditions_screen.dart';
import '../../view/home/screens/home_screen.dart';
import '../../view/home/screens/home_temp_screen.dart';
import '../../view/order/screens/order_list_screen.dart';
import '../../view/profile_screen/screens/profile_screen.dart';
import '../../view/subscription/screens/subscription_checkout_screen.dart';
import '../../view/subscription/screens/subscription_list_screen.dart';
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
      case NotificationScreen.routeName: {
        page = parseNotificationScreen(settings: settings);
        break;
      }
      case HomeTempScreen.routeName: {
        page = parseHomeTempScreen(settings: settings);
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
      case DevicesScreen.routeName: {
        page = parseDevicesScreen(settings: settings);
        break;
      }
      case SubscriptionListScreen.routeName: {
        page = parseSubscriptionListScreen(settings: settings);
        break;
      }
      case AboutAppScreen.routeName: {
        page = parseAboutAppScreen(settings: settings);
        break;
      }
      case OrderListScreen.routeName: {
        page = parseOrderListScreen(settings: settings);
        break;
      }
      case SubscriptionCheckoutScreen.routeName: {
        page = parseSubscriptionCheckoutScreen(settings: settings);
        break;
      }
      case SubscriptionDetail.routeName: {
        page = parseSubscriptionDetailScreen(settings: settings);
        break;
      }

      case OrderDetailScreen.routeName: {
        page = parsePaymentDetailScreen(settings: settings);
        break;
      }

      case ProfileScreen.routeName: {
        page = ProfileScreen();
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

  static Widget? parseNotificationScreen({required RouteSettings settings}) {
    return const NotificationScreen();
  }

  static Widget? parseHomeTempScreen({required RouteSettings settings}) {
    return const HomeTempScreen();
  }

  static Widget? parseHomeScreen({required RouteSettings settings}) {
    return const HomeScreen();
  }

  static Widget? parseDevicesScreen({required RouteSettings settings}) {
    return const DevicesScreen();
  }

  static Widget? parseSubscriptionListScreen({required RouteSettings settings}) {
    return const SubscriptionListScreen();
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

  static Widget? parseOrderListScreen({required RouteSettings settings}) {
    return const OrderListScreen();
  }

  static Widget? parseSubscriptionCheckoutScreen({required RouteSettings settings}) {
    if(settings.arguments is SubscriptionCheckoutScreenNavigationArguments) {
      SubscriptionCheckoutScreenNavigationArguments arguments = settings.arguments as SubscriptionCheckoutScreenNavigationArguments;

      return SubscriptionCheckoutScreen(
        arguments: arguments,
      );
    }
    else {
      return null;
    }
  }
  static Widget? parseSubscriptionDetailScreen({required RouteSettings settings}) {
    if(settings.arguments is SubscriptionDetailScreenNavigationArguments) {
      SubscriptionDetailScreenNavigationArguments arguments = settings.arguments as SubscriptionDetailScreenNavigationArguments;

      return SubscriptionDetail(
        arguments: arguments,
      );
    }
    else {
      return null;
    }
  }

  static Widget? parsePaymentDetailScreen({required RouteSettings settings}) {
    if(settings.arguments is PaymentDetailScreenNavigationArguments) {
      PaymentDetailScreenNavigationArguments arguments = settings.arguments as PaymentDetailScreenNavigationArguments;

      return OrderDetailScreen(
        arguments: arguments,
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

  static Future<dynamic> navigateToOtpScreen({
    required NavigationOperationParameters navigationOperationParameters, 
    required OtpScreenNavigationArguments arguments,
  }) {
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

  static Future<dynamic> navigateToNotificationScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: NotificationScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToHomeTempScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: HomeTempScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToHomeScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: HomeScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToDevicesScreen({required NavigationOperationParameters navigationOperationParameters}) {
      return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: DevicesScreen.routeName,
      ));
    }

  static Future<dynamic> navigateToTermsAndConditionsScreen({
    required NavigationOperationParameters navigationOperationParameters, 
    required TermsAndConditionsScreenNavigationArguments arguments,
  }) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: TermsAndConditionsScreen.routeName,
      arguments: arguments,
    ));
  }

  static Future<dynamic> navigateToAboutAppScreen({
    required NavigationOperationParameters navigationOperationParameters, 
    required AboutAppScreenNavigationArguments arguments,
  }) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: AboutAppScreen.routeName,
      arguments: arguments,
    ));
  }

  static Future<dynamic> navigateToOrderListScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: OrderListScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToSubscriptionListScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: SubscriptionListScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToSubscriptionCheckoutScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required SubscriptionCheckoutScreenNavigationArguments arguments,
  }) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: SubscriptionCheckoutScreen.routeName,
      arguments: arguments,
    ));
  }

  static Future<dynamic> navigateToSubscriptionDetailScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required SubscriptionDetailScreenNavigationArguments arguments,
  }) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: SubscriptionDetail.routeName,
      arguments: arguments,
    ));
  }

  static Future<dynamic> navigateToPaymentDetailScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required PaymentDetailScreenNavigationArguments arguments,
  }) {
    return NavigationOperation.navigate(navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: OrderDetailScreen.routeName,
      arguments: arguments,
    ));
  }
  //endregion
}
