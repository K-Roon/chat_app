import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/views/chat_rooms_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  print("IT'S RUNNING...\n애플리케이션의 작동을 시작합니다.");
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn = false;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  ///로그인 여부를 구합니다. 로그인/아웃의 여부는 Auth.dart 에서 다룹니다.
  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatting Us',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primaryColor: Color(0xffEFEFEF),
        primaryColorBrightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFEFEFEF),
        bottomAppBarColor: Color(0xFFEFEFEF),
        primaryColorLight: Color(0xffFFFFFF),
        primaryColorDark: Color(0xffDFDFDF),
        backgroundColor: Color(0xff2F2F2F),
        fontFamily: "OverpassRegular",
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
            elevation: 0.0,
            backgroundColor: Color(0xffEFEFEF),
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 20)),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Color(0xff0076FF)),
        bottomAppBarTheme:
            BottomAppBarTheme(color: Color(0xFFEEEEEE), elevation: 2.0),
        textTheme: const TextTheme(
          headline6: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
          bodyText1: TextStyle(color: Colors.black54, fontSize: 15),
          bodyText2: TextStyle(color: Colors.black, fontSize: 12),
          overline: TextStyle(color: Colors.black54, fontSize: 9),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: Color(0xff2F2F2F),
        primaryColorLight: Color(0xff5F5F5F),
        primaryColorDark: Color(0xff1F1F1F),
        primaryColorBrightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xff2F2F2F),
        bottomAppBarColor: Color(0xff2F2F2F),
        backgroundColor: Color(0xffEFEFEF),
        fontFamily: "OverpassRegular",
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Color(0xff0076FF)),
        appBarTheme: AppBarTheme(
            backgroundColor: Color(0xff2F2F2F),
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0.0,
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20)),
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
      ),
      home: userIsLoggedIn != null
          ? userIsLoggedIn
              ? ChatRoom()
              : Authenticate()
          : Container(
              child: Center(
                child: Authenticate(),
              ),
            ),
    );
  }
}

///비어 있음
class IamBlink extends StatefulWidget {
  @override
  _IamBlinkState createState() => _IamBlinkState();
}

class _IamBlinkState extends State<IamBlink> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
