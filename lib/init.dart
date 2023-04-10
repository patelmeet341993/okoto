import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'backend/common/app_controller.dart';
import 'utils/my_http_overrides.dart';
import 'utils/my_print.dart';
import 'view/my_app.dart';

/// Runs the app in [runZonedGuarded] to handle all types of errors, including [FlutterError]s.
/// Any error that is caught will be send to Sentry backend
Future<void>? runErrorSafeApp({bool isDev = false}) {
  return runZonedGuarded<Future<void>>(
    () async {
      WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

      // Keep native splash screen up until app is finished bootstrapping
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      await initApp(isDev: isDev);

      runApp(
        const MyApp(),
      );

      // await Future.delayed(const Duration(seconds: 5));

      MyPrint.printOnConsole("Hiding Splash Screen");
      // Remove splash screen when bootstrap is complete
      FlutterNativeSplash.remove();
    },
    (e, s) {
      MyPrint.printOnConsole("Error in runZonedGuarded:$e");
      MyPrint.printOnConsole(s);
      // AnalyticsController().recordError(e, stackTrace);
    },
  );
}

/// It provides initial initialisation the app and its global services
Future<void> initApp({bool isDev = false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppController.isDev = isDev;

  List<Future> futures = [];

  if(!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    HttpOverrides.global = MyHttpOverrides();
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

    futures.addAll([
      Firebase.initializeApp(),
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]),
    ]);
  }

  await Future.wait(futures);

  if(!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    try {
      await Future.wait([
        FirebaseMessaging.instance.requestPermission(),
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        ),
        FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true),
      ]);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Requesting Notifications Permission:$e");
      MyPrint.printOnConsole(s);
    }
  }
  MyPrint.printOnConsole('Running ${isDev ? 'dev' : 'prod'} version...');
}
