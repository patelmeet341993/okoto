import 'package:flutter/material.dart';
import 'package:my_popup_snakbar/my_popup_snakbar.dart';

class MyToast{
  static showCustomTopSnackBar({
    required BuildContext context,
    required Widget child,
    Duration displayDuration = const Duration(milliseconds: 3000),
    Duration showOutAnimationDuration = const Duration(milliseconds: 1200),
    Duration hideOutAnimationDuration = const Duration(milliseconds: 550),
  }) {
    MyPopupSnakbar().showTopSnackBar(
      context,
      child,
      dismissPreviousOverlay: true,
      displayDuration: displayDuration,
      reverseAnimationDuration: hideOutAnimationDuration,
      animationDuration: showOutAnimationDuration,
    );
    return;
  }

  static void showError({required BuildContext context, required String msg}) {
    showCustomTopSnackBar(
      context: context,
      child: CustomSnackBar.error(
        message: msg,
      ),
    );
  }

  static void showSuccess({required BuildContext context, required String msg}) {
    showCustomTopSnackBar(
      context: context,
      child: CustomSnackBar.success(
        message: msg,
      ),
    );
  }

  static void normalMsg({required BuildContext context, required String msg}) {
    showCustomTopSnackBar(
      context: context,
      child: CustomSnackBar.info(
        message: msg,
      ),
    );
  }
}