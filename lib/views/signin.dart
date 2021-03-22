import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/helper/theme.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chat_rooms_screen.dart';
import 'package:chat_app/views/forgot_password.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
              userInfoSnapshot.docs[0].data()["name"]);
          HelperFunctions.saveUserEmailSharedPreference(
              userInfoSnapshot.docs[0].data()["email"]);
          HelperFunctions.saveUserIdSharedPreference(
              userInfoSnapshot.docs[0].data()["userId"]);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        } else if (result.contains("wrong-password")) {
          setState(() {
            isLoading = false;
          });
          print("비밀번호에 오류가 발생했어요!");
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("비밀번호가 일치하지 않아요. 비밀번호를 잃어버린 경우 비밀번호 찾기를 클릭해주세요.")));
        } else if (result.contains("user-disabled")) {
          print("계정 정지됨.");
          setState(() {
            isLoading = false;
          });
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(
                  "이용약관을 위반하여 관리자에 의해 사용자 계정 이용이 정지되었어요. 😢 이용 정지가 풀릴 때 까지 기다리시면 됩니다. 만일 오류라고 판단될 경우 지원팀에 문의해주세요.")));
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarCustom(context, "로그인", true),
      //resizeToAvoidBottomPadding: false,
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0x002F2F2F), const Color(0xff2F2F2F)],
                    stops: [0.05, 0.5],
                  ),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  Spacer(),
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
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration("이메일"),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          obscureText: true,
                          validator: (val) {
                            return val.length >= 6
                                ? null
                                : "6자 이상되는 비밀번호를 입력해 주세요.";
                          },
                          style: simpleTextStyle(),
                          controller: passwordTextEditingController,
                          textInputAction: TextInputAction.go,
                          decoration: textFieldInputDecoration("비밀번호"),
                          onEditingComplete: (() {
                            signIn();
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
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
                              style: simpleTextStyle(),
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
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
                  SizedBox(
                    height: 16,
                  ),
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
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "계정이 없으신가요? ",
                        style: simpleTextStyle(),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Text(
                          "가입하세요",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
    );
  }
}
