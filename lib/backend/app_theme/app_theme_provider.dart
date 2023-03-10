import 'dart:io';

import 'package:flutter/material.dart';
import 'package:okoto/configs/app_theme.dart';

import '../../utils/shared_pref_manager.dart';

class AppThemeProvider extends ChangeNotifier {
  static bool kIsWeb = kIsWeb;
  static bool kIsWindow = Platform.isWindows;
  static bool kIsLinux = Platform.isLinux;
  static bool kIsMac = Platform.isMacOS;

  static const String _appThemeModeKey = "themeMode";

  static bool kIsFullScreen = kIsLinux || kIsWeb || kIsWindow || kIsMac;

  int _themeMode = AppTheme.themeDark;

  AppThemeProvider() {
    init();
  }

  init() async {
    int? data =  await SharedPrefManager().getInt(_appThemeModeKey);
    if(data==null) {
      _themeMode = AppTheme.themeDark;
    }
    else {
      _themeMode = data;
    }
    notifyListeners();
  }

  int get themeMode => _themeMode;

  Future<void> updateTheme(int themeMode) async {
    _themeMode = themeMode;
    notifyListeners();

    SharedPrefManager().setInt(_appThemeModeKey, themeMode);
  }
}