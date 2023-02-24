/*
* File : App Theme
* Version : 1.0.0
* */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/my_print.dart';
import 'styles.dart';

class AppTheme {
  static const int themeLight = 1;
  static const int themeDark = 2;

  AppTheme._();

  static CustomAppTheme getCustomAppTheme(int themeMode) {
    if (themeMode == themeLight) {
      return lightCustomAppTheme;
    } else if (themeMode == themeDark) {
      return darkCustomAppTheme;
    }
    return darkCustomAppTheme;
  }

  static TextStyle getTextStyle(TextStyle textStyle,
      {FontWeight fontWeight = FontWeight.w400,
        bool muted = false,
        bool xMuted =false,
        double letterSpacing = 0.15,
        Color? color,
        TextDecoration decoration = TextDecoration.none,
        double? height,
        double wordSpacing = 0,
        double? fontSize,
      }) {
    double finalFontSize = (fontSize ?? textStyle.fontSize) ?? 10;

    Color finalColor;
    if(color==null) {
      finalColor= (xMuted ? textStyle.color?.withAlpha(160) : (muted ? textStyle.color?.withAlpha(200) : textStyle.color)) ?? Styles.lightPrimaryColor;
    }
    else {
      finalColor = xMuted ? color.withAlpha(160) : ( muted ? color.withAlpha(200) : color);
    }
    
    return getTextStyleWithFontFamily(
      textStyle: TextStyle(
        fontSize: finalFontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: finalColor,
        decoration: decoration,
        height: height,
        wordSpacing: wordSpacing,
      ),
    );
  }

  static TextStyle getTextStyleWithFontFamily({TextStyle? textStyle}) {
    // return (textStyle ?? TextStyle()).copyWith(fontFamily: "Mono");
    return GoogleFonts.lato(textStyle: textStyle);
  }

  //App Bar Text
  static final TextTheme lightAppBarTextTheme = TextTheme(
    displayLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 102, color: Styles.lightTextColor)),
    displayMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 64, color: Styles.lightTextColor)),
    displaySmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 51, color: Styles.lightTextColor)),
    headlineLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 43, color: Styles.lightTextColor)),
    headlineMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 36, color: Styles.lightTextColor)),
    headlineSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 25, color: Styles.lightTextColor)),
    titleLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 18, color: Styles.lightTextColor)),
    titleMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 17, color: Styles.lightTextColor)),
    titleSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 15, color: Styles.lightTextColor)),
    bodyLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 16, color: Styles.lightTextColor)),
    bodyMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 14, color: Styles.lightTextColor)),
    bodySmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 12, color: Styles.lightTextColor)),
    labelLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 15, color: Styles.lightTextColor)),
    labelMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 13, color: Styles.lightTextColor)),
    labelSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 11, color: Styles.lightTextColor)),
  );

  static final TextTheme darkAppBarTextTheme = TextTheme(
    displayLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 102, color: Styles.darkTextColor)),
    displayMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 64, color: Styles.darkTextColor)),
    displaySmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 51, color: Styles.darkTextColor)),
    headlineLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 42, color: Styles.darkTextColor)),
    headlineMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 36, color: Styles.darkTextColor)),
    headlineSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 25, color: Styles.darkTextColor)),
    titleLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 20, color: Styles.darkTextColor)),
    titleMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 17, color: Styles.darkTextColor)),
    titleSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 15, color: Styles.darkTextColor)),
    bodyLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 16, color: Styles.darkTextColor)),
    bodyMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 14, color: Styles.darkTextColor)),
    bodySmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 13, color: Styles.darkTextColor)),
    labelLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 15, color: Styles.darkTextColor)),
    labelMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 13, color: Styles.darkTextColor)),
    labelSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 11, color: Styles.darkTextColor)),
  );

  //Text Themes
  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 102, color: Styles.lightTextColor)),
    displayMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 64, color: Styles.lightTextColor)),
    displaySmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 51, color: Styles.lightTextColor)),
    headlineMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 36, color: Styles.lightTextColor)),
    headlineSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 25, color: Styles.lightTextColor)),
    titleLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 18, color: Styles.lightTextColor)),
    titleMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 17, color: Styles.lightTextColor)),
    titleSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 15, color: Styles.lightTextColor)),
    bodyLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 16, color: Styles.lightTextColor)),
    bodyMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 14, color: Styles.lightTextColor)),
    bodySmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 13, color: Styles.lightTextColor)),
    labelLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 15, color: Styles.lightTextColor)),
    labelMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 13, color: Styles.lightTextColor)),
    labelSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 11, color: Styles.lightTextColor)),
  );

  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 102, color: Styles.darkTextColor)),
    displayMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 64, color: Styles.darkTextColor)),
    displaySmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 51, color: Styles.darkTextColor)),
    headlineMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 36, color: Styles.darkTextColor)),
    headlineSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 25, color: Styles.darkTextColor)),
    titleLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 18, color: Styles.darkTextColor)),
    titleMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 17, color: Styles.darkTextColor)),
    titleSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 15, color: Styles.darkTextColor)),
    bodyLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 16, color: Styles.darkTextColor)),
    bodyMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 14, color: Styles.darkTextColor)),
    bodySmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 13, color: Styles.darkTextColor)),
    labelLarge: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 15, color: Styles.darkTextColor)),
    labelMedium: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 13, color: Styles.darkTextColor)),
    labelSmall: getTextStyleWithFontFamily(
        textStyle: const TextStyle(fontSize: 11, color: Styles.darkTextColor)),
  );

  //Color Themes
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Styles.lightPrimaryColor,
    canvasColor: Colors.transparent,
    scaffoldBackgroundColor: Styles.lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      //textTheme: lightAppBarTextTheme,
      titleTextStyle: TextStyle(
        color: Styles.lightTextColor,
      ),
      toolbarTextStyle: TextStyle(
        color: Styles.lightTextColor,
      ),
      actionsIconTheme: IconThemeData(
        color: Styles.lightTextColor,
      ),
      color: Styles.lightAppBarColor,
      iconTheme: IconThemeData(color: Styles.lightTextColor, size: 24),
    ),
    navigationRailTheme: NavigationRailThemeData(
        selectedIconTheme: const IconThemeData(color: Styles.lightPrimaryColor, opacity: 1, size: 24),
        unselectedIconTheme: const IconThemeData(color: Styles.lightTextColor, opacity: 1, size: 24),
        backgroundColor: Styles.lightBackgroundColor,
        elevation: 3,
        selectedLabelTextStyle: const TextStyle(color: Styles.lightPrimaryColor),
        unselectedLabelTextStyle: const TextStyle(color: Styles.lightTextColor),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.4),
      elevation: 1,
      margin: const EdgeInsets.all(0),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(fontSize: 15, color: Color(0xaa495057)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(width: 1, color: Styles.lightPrimaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(width: 1, color: Colors.black54),
      ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Colors.black54)),
    ),
    splashColor: Colors.white.withAlpha(100),
    iconTheme: const IconThemeData(
      color: Colors.black,
      size: 30
    ),
    textTheme: lightTextTheme,
    indicatorColor: Colors.white,
    disabledColor: const Color(0xffdcc7ff),
    highlightColor: Colors.white,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Styles.lightPrimaryColor,
      splashColor: Colors.white.withAlpha(100),
      highlightElevation: 8,
      elevation: 4,
      focusColor: Styles.lightPrimaryColor,
      hoverColor: Styles.lightPrimaryColor,
      foregroundColor: Colors.white,
    ),
    dividerColor: const Color(0xffd1d1d1),
    cardColor: Colors.white,
    popupMenuTheme: PopupMenuThemeData(
      color: Styles.lightBackgroundColor,
      textStyle: lightTextTheme.bodyMedium?.merge(const TextStyle(color: Styles.lightTextColor)),
    ),
    bottomAppBarTheme: BottomAppBarTheme(color: Styles.lightBackgroundColor, elevation: 2),
    tabBarTheme: const TabBarTheme(
      unselectedLabelColor: Styles.lightTextColor,
      labelColor: Styles.lightPrimaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: Styles.lightPrimaryColor, width: 2.0),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Styles.lightPrimaryColor,
      inactiveTrackColor: Styles.lightPrimaryColor.withAlpha(140),
      trackShape: const RoundedRectSliderTrackShape(),
      trackHeight: 4.0,
      thumbColor: Styles.lightPrimaryColor,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
      tickMarkShape: const RoundSliderTickMarkShape(),
      inactiveTickMarkColor: Colors.red[100],
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      valueIndicatorTextStyle: const TextStyle(
        color: Colors.white,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Styles.lightPrimaryColor,
      onPrimary: Colors.white,
      primaryContainer: Styles.lightPrimaryVariant,
      secondary: Styles.lightSecondaryColor,
      secondaryContainer: Styles.lightSecondaryVariant,
      onSecondary: Colors.white,
      surface: Color(0xffe2e7f1),
      background: Color(0xfff3f4f7),
      onBackground: Styles.lightTextColor,
      error: Color(0xfff0323c),
    ),
  );

  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      canvasColor: Colors.transparent,
      primaryColor: Styles.darkPrimaryColor,
      scaffoldBackgroundColor: Styles.darkBackgroundColor,
      appBarTheme: AppBarTheme(
        // textTheme: darkAppBarTextTheme,
        titleTextStyle: darkAppBarTextTheme.bodyLarge,
        actionsIconTheme: const IconThemeData(
          color: Styles.darkTextColor,
        ),
        color: Styles.darkAppBarColor,
        iconTheme: const IconThemeData(color: Styles.darkTextColor, size: 24),
      ),
      cardTheme: const CardTheme(
        color: Color(0xff37404a),
        shadowColor: Color(0xff000000),
        elevation: 1,
        margin: EdgeInsets.all(0),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      textTheme: darkTextTheme,
      indicatorColor: Colors.white,
      disabledColor: const Color(0xffa3a3a3),
      highlightColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: darkTextTheme.labelMedium?.copyWith(
          // color: ,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Color(0xff10bbf0)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Colors.white70),
        ),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(width: 1, color: Colors.white70)),
      ),
      dividerColor: const Color(0xffd1d1d1),
      cardColor: const Color(0xff282a2b),
      splashColor: Colors.white.withAlpha(100),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Styles.darkPrimaryColor,
          splashColor: Colors.white.withAlpha(100),
          highlightElevation: 8,
          elevation: 4,
          focusColor: Styles.darkPrimaryColor,
          hoverColor: Styles.darkPrimaryColor,
          foregroundColor: Colors.white,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xff37404a),
        textStyle: lightTextTheme.bodyMedium?.merge(const TextStyle(color: Styles.darkTextColor)),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xff292929), elevation: 2),
      tabBarTheme: const TabBarTheme(
        unselectedLabelColor: Styles.lightTextColor,
        labelColor: Color(0xff10bbf0),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xff10bbf0), width: 2.0),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xff10bbf0),
        inactiveTrackColor: Styles.darkPrimaryColor.withAlpha(100),
        trackShape: const RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbColor: const Color(0xff10bbf0),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
        tickMarkShape: const RoundSliderTickMarkShape(),
        inactiveTickMarkColor: Colors.red[100],
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(),
      colorScheme: const ColorScheme.dark(
        primary: Styles.darkPrimaryColor,
        primaryContainer: Styles.darkPrimaryVariant,
        secondary: Styles.darkSecondaryColor,
        secondaryContainer: Styles.darkSecondaryVariant,
        background: Colors.black,
        onPrimary: Colors.white,
        onBackground: Colors.white,
        onSecondary: Colors.white,
        surface: Color(0xff585e63),
        error: Colors.orange,
      ),
  );

  static ThemeData getThemeFromThemeMode(int themeMode) {
    if (themeMode == themeLight) {
      return lightTheme;
    }
    else if (themeMode == themeDark) {
      return darkTheme;
    }
    return darkTheme;
  }

  static NavigationBarTheme getNavigationThemeFromMode(int themeMode) {
    MyPrint.printOnConsole(themeMode);
    NavigationBarTheme navigationBarTheme = NavigationBarTheme();
    if (themeMode == themeLight) {
      navigationBarTheme.backgroundColor = Colors.white;
      navigationBarTheme.selectedItemColor = const Color(0xff10bbf0);
      navigationBarTheme.unselectedItemColor = const Color(0xff495057);
      navigationBarTheme.selectedOverlayColor = const Color(0x383d63ff);
    }
    else if (themeMode == themeDark) {
      navigationBarTheme.backgroundColor = const Color(0xff37404a);
      navigationBarTheme.selectedItemColor = const Color(0xff37404a);
      navigationBarTheme.unselectedItemColor = const Color(0xffd1d1d1);
      navigationBarTheme.selectedOverlayColor = const Color(0xffffffff);
    }
    return navigationBarTheme;
  }

  static final CustomAppTheme lightCustomAppTheme = CustomAppTheme(
    bgLayer1: const Color(0xffffffff),
    bgLayer2: const Color(0xfff9f9f9),
    bgLayer3: const Color(0xffe8ecf4),
    bgLayer4: const Color(0xffdcdee3),
    disabledColor: const Color(0xff636363),
    onDisabled: const Color(0xffffffff),
    colorInfo: const Color(0xffff784b),
    colorWarning: const Color(0xffffc837),
    colorSuccess: const Color(0xff3cd278),
    shadowColor: const Color(0xffeaeaea),
    onInfo: const Color(0xffffffff),
    onSuccess: const Color(0xffffffff),
    onWarning: const Color(0xffffffff),
    colorError: const Color(0xfff0323c),
    onError: const Color(0xffffffff),);
  static final CustomAppTheme darkCustomAppTheme = CustomAppTheme(
    bgLayer1: const Color(0xff212429),
    bgLayer2: const Color(0xff282930),
    bgLayer3: const Color(0xff303138),
    bgLayer4: const Color(0xff383942),
    disabledColor: const Color(0xffbababa),
    onDisabled: const Color(0xff000000),
    colorInfo: const Color(0xffff784b),
    colorWarning: const Color(0xffffc837),
    colorSuccess: const Color(0xff3cd278),
    shadowColor: const Color(0xff1a1a1a),
    onInfo: const Color(0xffffffff),
    onSuccess: const Color(0xffffffff),
    onWarning: const Color(0xffffffff),
    colorError: const Color(0xfff0323c),
    onError: const Color(0xffffffff),
  );
}

class CustomAppTheme {
  final Color bgLayer1,
      bgLayer2,
      bgLayer3,
      bgLayer4,
      disabledColor,
      onDisabled,
      colorInfo,
      colorWarning,
      colorSuccess,
      colorError,
      shadowColor,
      onInfo,
      onWarning,
      onSuccess,
      onError;

  CustomAppTheme({
    this.bgLayer1 = const Color(0xffffffff),
    this.bgLayer2 = const Color(0xfff8faff),
    this.bgLayer3 = const Color(0xffeef2fa),
    this.bgLayer4 = const Color(0xffdcdee3),
    this.disabledColor = const Color(0xffdcc7ff),
    this.onDisabled = const Color(0xffffffff),
    this.colorWarning = const Color(0xffffc837),
    this.colorInfo = const Color(0xffff784b),
    this.colorSuccess = const Color(0xff3cd278),
    this.shadowColor = const Color(0xff1f1f1f),
    this.onInfo = const Color(0xffffffff),
    this.onWarning = const Color(0xffffffff),
    this.onSuccess = const Color(0xffffffff),
    this.colorError = const Color(0xfff0323c),
    this.onError = const Color(0xffffffff),
  });
}

class NavigationBarTheme {
  Color? backgroundColor,
      selectedItemIconColor,
      selectedItemTextColor,
      selectedItemColor,
      selectedOverlayColor,
      unselectedItemIconColor,
      unselectedItemTextColor,
      unselectedItemColor;
}
