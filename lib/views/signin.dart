import 'dart:ui';

import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/widgets/theme.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chat_rooms_screen.dart';
import 'package:chat_app/views/forgot_password.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn(this.toggleView);

  @override
  _SignInState createState() => _SignInState();
}

TextEditingController emailTextEditingController = new TextEditingController();
TextEditingController passwordTextEditingController =
    new TextEditingController();
AuthService authService = new AuthService();

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  signIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService
          .signInWithEmailAndPassword(emailTextEditingController.text,
              passwordTextEditingController.text)
          .then((result) async {
        if (result == null) {
          QuerySnapshot userInfoSnapshot = await DatabaseMethods()
              .getUserByEmail(emailTextEditingController.text);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.docs[0].get("name"));
          HelperFunctions.saveUserEmailSharedPreference(
              userInfoSnapshot.docs[0].get("email"));
          HelperFunctions.saveUserIdSharedPreference(
              userInfoSnapshot.docs[0].get("userId"));
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));

          ///아이디, 비밀번호 오류 발생시
        } else if (result.contains("wrong-password")) {
          setState(() {
            isLoading = false;
          });

          loginErrorDialog(
              context: context,
              titleText: "아이디/비밀번호 오류",
              contentText: "이메일 혹은 비밀번호가 달라요.\n다시 확인해보세요.");

          /// 계정 사용 정지시.
        } else if (result.contains("user-disabled")) {
          print("계정 정지됨.");
          setState(() {
            isLoading = false;
          });
          loginErrorDialog(
              context: context,
              titleText: "계정 사용이 일시 정지되었음.",
              contentText:
                  "Chatting Us 운영원칙을 위반하여 계정 사용이 정지되었습니다.\n관리자에게 문의하세요.");

          ///사용자를 찾을 수 없음
        } else if (result.contains("user-not-found")) {
          print("사용자를 찾을 수 없음");
          setState(() {
            isLoading = false;
          });
          loginErrorDialog(
              context: context,
              titleText: "사용자를 찾을 수 없음(혹은 탈퇴한 계정)",
              contentText: "사용자를 찾을 수 없습니다.\n혹시 계정을 탈퇴하셨나요?");

          ///아이디/비밀번호를 자꾸 틀리며 로그인 요청을 많이 한 경우 (메크로를 돌려서 비밀번호 해킹을 시도한 경우)
        } else if (result.contains("too-many-requests")) {
          setState(() {
            isLoading = false;
          });
          loginErrorDialog(
              context: context,
              titleText: "계정 사용이 일시 정지되었음. (해킹보호정책)",
              contentText: "해당 계정으로 수상한 트래픽이 탐지되었습니다. 이는 해킹 시도일 수도 있습니다.\n" +
                  "저희 Chatting Us 팀은 해당 계정의 해킹 방지를 위해 보호중입니다.\n" +
                  "몇 분 뒤에 자동으로 정지가 풀립니다. 잠시 기다려주세요.");

          /// 다른 알 수 없는 오류
        } else {
          setState(() {
            isLoading = false;
          });
          loginErrorDialog(
              context: context,
              titleText: "알 수 없는 오류",
              contentText: "알 수 없는 오류로 로그인에 실패했습니다.\n다시 시도해보세요.");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarCustom(context, "로그인", true),
      //resizeToAvoidBottomInset: false,
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                /*
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0x002F2F2F), const Color(0xff2F2F2F)],
                  stops: [0.05, 0.5],
                ),*/
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "올바른 이메일을 입력해주세요.";
                          },
                          controller: emailTextEditingController,
                          style: simpleTextStyle(context),
                          decoration: textFieldInputDecoration(context, "이메일"),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          obscureText: true,
                          validator: (val) {
                            if (val.length < 6) {
                              return "6자 이상되는 비밀번호를 입력해주세요.";
                            } else {
                              return null;
                            }
                          },
                          style: simpleTextStyle(context),
                          controller: passwordTextEditingController,
                          textInputAction: TextInputAction.go,
                          decoration: textFieldInputDecoration(context, "비밀번호"),
                          onEditingComplete: (() {
                            signIn();
                          }),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword()));
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              "비밀번호를 잊으셨나요?",
                              style: simpleTextStyle(context),
                            )),
                      )
                    ],
                  ),
                  spaceH16(),
                  GestureDetector(
                    onTap: () {
                      signIn();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff007EF4),
                              const Color(0xff009955)
                            ],
                          )),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "로그인",
                        style: biggerTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  spaceH16(),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xff4285F4),
                            const Color(0xffEA4335),
                            const Color(0xffEA4335),
                            const Color(0xffFBBC05),
                            const Color(0xffFBBC05),
                            const Color(0xff34A853),
                          ],
                          stops: [0.25, 0.25, 0.50, 0.50, 0.75, 0.75],
                        )),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "Google 계정으로 로그인",
                      style:
                          TextStyle(fontSize: 17, color: CustomTheme.textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  spaceH16(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "계정이 없으신가요? ",
                        style: simpleTextStyle(context),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Text(
                          "가입하세요",
                          style: TextStyle(
                              color: Theme.of(context).backgroundColor,
                              fontSize: 16,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  spaceH16()
                ],
              ),
            ),
    );
  }
}
