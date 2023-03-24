import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:okoto/backend/navigation/navigation.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:provider/provider.dart';

import '../../utils/my_print.dart';
import '../user/user_controller.dart';

class AnalyticsController {
  static AnalyticsController? _instance;

  factory AnalyticsController() {
    if(_instance == null) {
      _instance = AnalyticsController._();
    }
    return _instance!;
  }

  AnalyticsController._();

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;


  Future<void> setUserid() async {
    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainScreenNavigator.currentContext!,listen: false);
    String uid = userProvider.getUserId();
    await analytics.setUserId(id: uid);
  }
  
  Future<void> fireEvent({required String analyticEvent, Map<String, dynamic>? parameters}) async {
    await analytics.logEvent(name:  analyticEvent, parameters: parameters != null && parameters.isNotEmpty ? parameters : null).then((value) {
      MyPrint.printOnConsole('$analyticEvent fired with parameters:${parameters}');
    })
    .catchError((e) {
      MyPrint.printOnConsole('Error in Firing $analyticEvent:${e}');
    });
  }
  
  Future<void> recordError(Object exception, StackTrace stackTrace, {String? reason}) async {
    await FirebaseCrashlytics.instance.recordError(exception, stackTrace, reason: reason, printDetails: true,);
  }
}