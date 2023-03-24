import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:my_popup_snakbar/my_popup_snakbar.dart';
import 'package:okoto/backend/device/device_provider.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:provider/provider.dart';

import '../backend/app_theme/app_theme_provider.dart';
import '../backend/common/app_controller.dart';
import '../backend/connection/connection_provider.dart';
import '../backend/data/data_provider.dart';
import '../backend/game/game_provider.dart';
import '../backend/navigation/navigation_controller.dart';
import '../backend/notification/notification_provider.dart';
import '../backend/order/order_provider.dart';
import '../backend/subscription/subscription_provider.dart';
import '../configs/app_theme.dart';
import '../configs/constants.dart';
import '../utils/my_print.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MyPrint.printOnConsole("MyApp Build Called");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppThemeProvider>(create: (_) => AppThemeProvider(), lazy: false),
        ChangeNotifierProvider<ConnectionProvider>(create: (_) => ConnectionProvider(), lazy: false),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider(), lazy: false),
        ChangeNotifierProvider<DataProvider>(create: (_) => DataProvider(), lazy: false),
        ChangeNotifierProvider<DeviceProvider>(create: (_) => DeviceProvider(), lazy: false),
        ChangeNotifierProvider<SubscriptionProvider>(create: (_) => SubscriptionProvider(), lazy: false),
        ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider(), lazy: false),
        ChangeNotifierProvider<GameProvider>(create: (_) => GameProvider(), lazy: false),
        ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider(), lazy: false),
      ],
      child: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
    MyPrint.printOnConsole("MainApp Build Called");

    return Consumer<AppThemeProvider>(
      builder: (BuildContext context, AppThemeProvider appThemeProvider, Widget? child) {
        //MyPrint.printOnConsole("ThemeMode:${appThemeProvider.themeMode}");

        return OverlaySupport.global(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationController.mainScreenNavigator,
            title: AppConstants.getAppNameFromAppType(isDev: AppController.isDev),
            theme: AppTheme.getThemeFromThemeMode(appThemeProvider.themeMode),
            onGenerateRoute: NavigationController.onMainAppGeneratedRoutes,
            navigatorObservers:  [
              FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
            ],
          ),
        );
      },
    );
  }
}