import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Text("Chatting Us"),
    elevation: 0.0,
    centerTitle: true,
  );
}

Widget appBarCustom(BuildContext context, String text, bool isCenterTitle) {
  return AppBar(
    title: Text(text),
    elevation: 0.0,
    centerTitle: isCenterTitle,
    backgroundColor: Theme.of(context).primaryColor,
  );
}

InputDecoration textFieldInputDecoration(
    BuildContext context, String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: Theme.of(context).textTheme.bodyText1,
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).backgroundColor)),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).backgroundColor)));
}

TextStyle simpleTextStyle(BuildContext context) {
  return TextStyle(color: Theme.of(context).backgroundColor, fontSize: 16);
}

TextStyle biggerTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 18);
}

TextStyle mediumTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 15);
}

TextStyle smallTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 10);
}

SizedBox spaceW(double width) {
  return SizedBox(width: width);
}

SizedBox spaceH(double height) {
  return SizedBox(height: height);
}

SizedBox spaceW8() {
  return SizedBox(width: 8.0);
}

SizedBox spaceH3() {
  return SizedBox(height: 3.0);
}

SizedBox spaceH16() {
  return SizedBox(height: 16.0);
}
