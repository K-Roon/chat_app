import 'dart:math';

import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chat_rooms_screen.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/views/signin.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  AuthService authMethods = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream friends;
  String version;

  Widget friendsList() {
    return StreamBuilder(
      stream: friends,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return FriendsTile(
                    snapshot.data.docs[index].data()['friendName'].toString(),
                    snapshot.data.docs[index].data()['friendId'],
                  );
                })
            : Container();
      },
    );
  }

  getUserFriends() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myId = await HelperFunctions.getUserIdSharedPreference();
    DatabaseMethods().getFriends(Constants.myId).then((value) {
      setState(() {
        friends = value;
        print("다음과 같은 데이터를 얻음: + ${value.toString()}\n이름: ${Constants.myName}");
      });
    });
  }

  @override
  void initState() {
    getUserFriends();

    FirebaseFirestore.instance
        .collection("notifyUpdate")
        .doc("lastVersion")
        .get()
        .then((value) {
      DocumentSnapshot documentSnapshot = value;
      version = documentSnapshot.get("lastVersion");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${Constants.myName.toString()}의 친구 목록",
        ),
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.circular(15),
        ),
        child: friendsList(),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(CupertinoIcons.search),
        tooltip: "검색",
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Search()));
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 5.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              tooltip: '채팅 목록',
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              icon: Icon(
                CupertinoIcons.chat_bubble_text,
                color: Theme.of(context).backgroundColor,
              ),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ChatRoom()));
              },
            ),

            //로그아웃
            IconButton(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              icon: Icon(
                CupertinoIcons.escape,
                color: Theme.of(context).backgroundColor,
              ),
              tooltip: "로그아웃",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    return AlertDialog(
                      title: new Text("로그아웃"),
                      content: new Text("로그아웃 하시겠어요?\n로그아웃 이후 재로그인이 필요합니다."),
                      actions: <Widget>[
                        new TextButton(
                          child: new Text("취소"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        new TextButton(
                          child: new Text("여기를 길게 눌러 로그아웃"),
                          onPressed: () {},
                          onLongPress: () {
                            HelperFunctions.saveUserLoggedInSharedPreference(
                                false);
                            Navigator.pop(context);
                            authService.signOut();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Authenticate()));
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ),
            IconButton(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              icon: Icon(
                CupertinoIcons.info_circle,
                color: Theme.of(context).backgroundColor,
              ),
              tooltip: "앱 정보 및 업데이트 확인",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    return AlertDialog(
                      title: new Text("애플리케이션 정보"),
                      content: new Text(
                          "현재 버전: ${Constants.appVersion}\n새로운 버전: ${version != null ? version : null}\n${Constants.showDifference}"),
                      actions: <Widget>[
                        new TextButton(
                          child: new Text("확인"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FriendsTile extends StatelessWidget {
  final String friendName;
  final String friendId;

  FriendsTile(this.friendName, this.friendId);

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(45)),
            child: Text(
              "${friendName.substring(0, 1).toUpperCase()}",
              style: biggerTextStyle(),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Container(
            child: Text(
              friendName,
              style: TextStyle(
                  color: Theme.of(context).backgroundColor, fontSize: 20),
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.more_horiz),
            color: Theme.of(context).backgroundColor,
            tooltip: "$friendName 님의 상세 정보",
            onPressed: () {
              listPushed(context);
            },
          )
        ],
      ),
    );
  }

  void listPushed(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(40)),
                  child: Text(
                    "${friendName.substring(0, 1).toUpperCase()}",
                    style: mediumTextStyle(),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Container(
                  child: Text(
                    friendName,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  color: Colors.white,
                  tooltip: "$friendName 님의 상세 정보",
                  onPressed: () {
                    listPushed(context);
                  },
                ),
                new IconButton(
                  icon: Icon(Icons.clear_rounded),
                  tooltip: "돌아가기",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            content: new Text("이 사용자와 무엇을 하시겠어요?"),
            actions: <Widget>[
              new TextButton(
                child: Text("대화 나누기"),
                onPressed: () {
                  pushConv(friendId, context);
                },
              )
            ],
          );
        });
  }

  void pushConv(friendId, context) {
    ChatMethods().isAlreadyExistChatRoom(friendId).then((value) {
      print(value);
      if (value != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationScreen(value.toString())));
      } else {
        print("value is null!!");

        if (friendId != Constants.myId) {
          String chatRoomId = getRandomString(20);
          List<String> users = [friendId, Constants.myId.toString()];
          users.sort((a, b) => a.compareTo(b));
          Map<String, dynamic> chatRoomMap = {
            "users": users,
            "chatroomId": chatRoomId,
            "chatName": "${Constants.myName}, $friendName",
            "isOneVone": true
          };
          ChatMethods().createChatRoom(chatRoomId, chatRoomMap);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConversationScreen(chatRoomId)));
        } else {
          print("나 자신은 영원한 인생의 동반자입니다.");
        }
      }
    });
  }
}
