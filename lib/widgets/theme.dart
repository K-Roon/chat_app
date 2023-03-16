import 'package:flutter/material.dart';

class CustomTheme {
  static Color colorAccent = Color(0xff007EF4);
  static Color textColor = Color(0xff071930);
}

final themeData = ThemeData(
  primaryColor: Color(0xffEFEFEF),
  primaryColorBrightness: Brightness.light,
  scaffoldBackgroundColor: Color(0xFFEFEFEF),
  primaryColorLight: Color(0xffFFFFFF),
  primaryColorDark: Color(0xffDFDFDF),
  backgroundColor: Color(0xff2F2F2F),
  fontFamily: "OverpassRegular",
  visualDensity: VisualDensity.adaptivePlatformDensity,
  appBarTheme: AppBarTheme(
      elevation: 0.0,
      backgroundColor: Color(0xffEFEFEF),
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20)),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xff0076FF)),
  bottomAppBarTheme:
      BottomAppBarTheme(color: Color(0xFFEEEEEE), elevation: 2.0),
  textTheme: const TextTheme(
    headline6: TextStyle(
        color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
    bodyText1: TextStyle(color: Colors.black54, fontSize: 15),
    bodyText2: TextStyle(color: Colors.black, fontSize: 12),
    overline: TextStyle(color: Colors.black54, fontSize: 9),
  ),
);

final darkThemeData = ThemeData(
  primaryColor: Color(0xff2F2F2F),
  primaryColorLight: Color(0xff5F5F5F),
  primaryColorDark: Color(0xff1F1F1F),
  primaryColorBrightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xff2F2F2F),
  backgroundColor: Color(0xffEFEFEF),
  fontFamily: "OverpassRegular",
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xff0076FF)),
  appBarTheme: AppBarTheme(
      backgroundColor: Color(0xff2F2F2F),
      iconTheme: IconThemeData(color: Colors.white),
      elevation: 0.0,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
  bottomAppBarTheme:
      BottomAppBarTheme(color: Color(0xFF3F3F3F), elevation: 2.0),
  dialogTheme: DialogTheme(
    backgroundColor: Color(0xff2F2F2F),
    contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
    titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
  ),
  textTheme: const TextTheme(
    headline6: TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
    bodyText1: TextStyle(color: Colors.white54, fontSize: 15),
    bodyText2: TextStyle(color: Colors.white, fontSize: 12),
    overline: TextStyle(color: Colors.white54, fontSize: 9),
  ),
  //appBarTheme: AppBarTheme(brightness: Brightness.dark),
);
