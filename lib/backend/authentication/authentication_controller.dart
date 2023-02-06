import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okoto/backend/user/user_provider.dart';

import '../../configs/constants.dart';
import '../../utils/my_print.dart';
import '../../utils/shared_pref_manager.dart';
import '../../view/common/components/common_popup.dart';
import '../navigation/navigation_controller.dart';
import '../navigation/navigation_operation_parameters.dart';
import '../navigation/navigation_type.dart';

class AuthenticationController {
  late UserProvider _userProvider;

  AuthenticationController({required UserProvider? userProvider}) {
    _userProvider = userProvider ?? UserProvider();
  }

  UserProvider get userProvider => _userProvider;

  //To Check if User is Login
  //This Method will Check if User is Login and if login and initializeUserid is True then it will Store User data in UserProvider
  //It will Return true or false
  Future<bool> isUserLoggedIn({bool initializeUserid = false, BuildContext? context}) async {
    User? user = await FirebaseAuth.instance.authStateChanges().first;
    bool isLoggedIn = user != null;
    if(isLoggedIn && initializeUserid) {
      UserProvider provider = userProvider;

      userProvider.setUserId(userId: user.uid, isNotify: false);
      // provider.setUserId(userId: "lzk6gLIY9CSd4BPtsCcCjEx4Vnv2", isNotify: false);
      MyPrint.printOnConsole("User Id in Authentication:${userProvider.getUserId()}");
      provider.setFirebaseUser(user: user, isNotify: false);
    }
    MyPrint.printOnConsole("Login:$isLoggedIn");
    return isLoggedIn;

    /*bool isLoggedIn = await getIsUserLoggedInFromSharedPreferences();

    return isLoggedIn;*/
  }

  Future<void> setIsUserLoggedInInSharedPreferences({bool isLoggedIn = false}) async {
    await SharedPrefManager().setBool(SharePreferenceKeys.isUserLoggedIn, isLoggedIn);
  }

  Future<bool> getIsUserLoggedInFromSharedPreferences() async {
    return (await SharedPrefManager().getBool(SharePreferenceKeys.isUserLoggedIn)) ?? false;
  }

  //Will logout from system and remove data from UserProvider and local memory
  Future<bool> logout({BuildContext? context, bool isShowConfirmDialog = true}) async {
    if(context != null && isShowConfirmDialog) {
      dynamic value = await showDialog(context: context, builder: (context){
        return CommonPopUp(
          text: 'Are you sure you want to Logout?',
          rightText: 'Logout',
          rightOnTap: () {
            Navigator.pop(context, true);
          },
        );
      });

      if(value != true) {
        return false;
      }
    }

    context ??= NavigationController.mainScreenNavigator.currentContext!;

    UserProvider provider = userProvider;

    provider.setFirebaseUser(user: null, isNotify: false);
    provider.setUserId(userId: "", isNotify: false);
    provider.setUserModel(userModel: null, isNotify: false);

    await FirebaseAuth.instance.signOut();

    if(context.mounted) {
      NavigationController.navigateToLoginScreen(
        navigationOperationParameters: NavigationOperationParameters(
          context: context,
          navigationType: NavigationType.pushNamedAndRemoveUntil,
        ),
      );
    }

    return true;
  }
}