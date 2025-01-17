import 'dart:async';

import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/storage_methods.dart';
import 'package:chat_app/views/friends_screen_check.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';
import 'package:vibration/vibration.dart';

///conversation : 대화(nown)
///상대방과 대화할 수 있는 스크린 입니다.
///일반 사용자들은 이 스크린을 흔히 "대화방" 혹은 "톡방"으로 부릅니다.
class ConversationScreen extends StatefulWidget {
  final String chatRoomId;

  ConversationScreen(this.chatRoomId);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  Stream chatMessageStream;

  TextEditingController chatNameTextEditingController =
      new TextEditingController();

  String chatRoomName;

  // ignore: non_constant_identifier_names
  Widget ChatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      snapshot.data.docs[index].data()["message"],
                      snapshot.data.docs[index].data()["sendBy"] ==
                          Constants.myName,
                      snapshot.data.docs[index].data()["time"],
                      snapshot.data.docs[index].data()["sendBy"],
                      snapshot.data.docs[index].data()["type"],
                      snapshot.data.docs[index].data()['Download_url'],
                      widget.chatRoomId);
                })
            : Container(
                decoration: BoxDecoration(
                color: Color(0x99FFFFFF),
                borderRadius: BorderRadius.circular(15),
              ));
      },
    );
  }

  sendMessage() {
    ChatMethods().addText(
        widget.chatRoomId, messageController.text.trimLeft().trimRight());
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
    messageController.clear();
  }

  @override
  void initState() {
    ChatMethods().getConvMsg(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    ChatMethods().getRoomName(widget.chatRoomId).then((value) {
      setState(() {
        chatRoomName = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int pushSecond = 0;
    Timer timer;
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(chatRoomName == null ? "로드중.." : chatRoomName),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              MaterialSymbols.edit,
              weight: 200,
            ),
            tooltip: "채팅방 이름 바꾸기",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("채팅방 이름 바꾸기"),
                    content: TextField(
                      controller: chatNameTextEditingController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "새로운 채팅방 이름..",
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text("취소"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text("적용"),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("채팅방 이름 바꾸기"),
                                content: Text(
                                  "채팅방 이름을 새롭게 변경하면 참가자 전체의 채팅방 이름이 바뀌게 됩니다.\n되도록 참가자 모두를 만족할 수 있는 이름으로 지정하세요.\n채팅방 이름을 변경함으로써 일어난 일에 대한 책임은 본인에게 있습니다.",
                                  style: TextStyle(color: Colors.black),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("취소"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: Text("여기를 길게 눌러 확인"),
                                    onPressed: () {},
                                    onLongPress: () {
                                      ChatMethods().changeRoomName(
                                          widget.chatRoomId,
                                          chatNameTextEditingController.text);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              MaterialSymbols.logout,
              weight: 200,
            ),
            tooltip: "채팅방 나가기",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("채팅방 나가기"),
                    content: Text(
                      "채팅방을 나가시겠어요?\n다른 멤버가 다시 초대할 때 까지 채팅에 참가할 수 없습니다.",
                      style: TextStyle(color: Colors.black),
                    ),
                    actions: [
                      TextButton(
                        child: Text("취소"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text("여기를 길게 눌러 나가기"),
                        onPressed: () {},
                        onLongPress: () {
                          ChatMethods().getOutChatRoom(widget.chatRoomId);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              MaterialSymbols.person_add,
              weight: 200,
            ),
            tooltip: "초대",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FriendsCheckScreen(widget.chatRoomId, chatRoomName)));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 65,
              margin: const EdgeInsets.only(bottom: 65),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ChatMessageList(),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0x99FFFFFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("파일/사진 공유"),
                              content: Text("파일, 사진 중 어떤 것을 공유할까요?"),
                              actions: [
                                TextButton(
                                  child: Row(
                                    children: [
                                      Icon(
                                        MaterialSymbols.close,
                                        weight: 200,
                                      ),
                                      Text(" 취소"),
                                    ],
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: Row(
                                    children: [
                                      Icon(
                                        MaterialSymbols.attach_file,
                                        weight: 200,
                                      ),
                                      Text(" 파일"),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    StorageMethods()
                                        .toUploadFile(widget.chatRoomId);
                                  },
                                ),
                                TextButton(
                                  child: Row(
                                    children: [
                                      Icon(
                                        MaterialSymbols.image,
                                        weight: 200,
                                      ),
                                      Text(" 사진"),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    StorageMethods()
                                        .toUploadImage(widget.chatRoomId);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onLongPress: () {
                        Vibration.vibrate(duration: 10);
                        StorageMethods().toUploadFile(widget.chatRoomId);
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        padding: EdgeInsets.all(1),
                        margin: EdgeInsets.only(right: 5),
                        child: Icon(
                          MaterialSymbols.add,
                          weight: 200,
                          color: Colors.black26,
                          size: 30,
                        ),
                      ),
                    ),
                    Expanded(
                        child: TextField(
                      controller: messageController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "텍스트 입력",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                      ),
                    )),
                    GestureDetector(
                      onTapDown: (tapDownDetails) {
                        Vibration.vibrate(pattern: [0, 5]);
                        timer = Timer.periodic(Duration(milliseconds: 900),
                            (timer) {
                          setState(() {
                            pushSecond++;
                            if (pushSecond >= 2) {
                              Vibration.vibrate(pattern: [0, 5]);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("파일/사진 공유"),
                                    content: Text("파일, 사진 중 어떤 것을 공유할까요?"),
                                    actions: [
                                      TextButton(
                                        child: Row(
                                          children: [
                                            Icon(
                                              MaterialSymbols.close,
                                              weight: 200,
                                            ),
                                            Text(" 취소"),
                                          ],
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: Row(
                                          children: [
                                            Icon(
                                              MaterialSymbols.attach_file,
                                              weight: 200,
                                            ),
                                            Text(" 파일"),
                                          ],
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          StorageMethods()
                                              .toUploadFile(widget.chatRoomId);
                                        },
                                      ),
                                      TextButton(
                                        child: Row(
                                          children: [
                                            Icon(
                                              MaterialSymbols.image,
                                              weight: 200,
                                            ),
                                            Text(" 사진"),
                                          ],
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          StorageMethods()
                                              .toUploadImage(widget.chatRoomId);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              timer?.cancel();
                              pushSecond = 0;
                            }
                          });
                        });
                      },
                      onTapUp: (tapUpDetails) {
                        timer?.cancel();
                        Vibration.vibrate(pattern: [0, 5]);

                        if (messageController.text.trimLeft().trimRight() !=
                                "" &&
                            pushSecond <= 1) {
                          sendMessage();
                        }
                        pushSecond = 0;
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          MaterialSymbols.arrow_upward,
                          color: Colors.white,
                          size: 25,
                          weight: 200,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// type 에 관련된 정보
/// info: 정보, text: 단문 텍스트, file: 파일, image: 이미지파일
class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  final String time;
  final String sendBy;
  final String type;
  final String download_Url;
  final String chatRoomId;

  MessageTile(this.message, this.isSendByMe, this.time, this.sendBy, this.type,
      this.download_Url, this.chatRoomId);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case "info":
        return Container(
          padding: EdgeInsets.only(top: 3, bottom: 3, left: 20, right: 20),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                padding:
                    EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0x80000000),
                ),
                child: Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w300)),
              ),
            ],
          ),
        );
        break;
      case "file":
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("다운로드 중..")));
            StorageMethods()
                .toDownloadFile(this.message, this.download_Url, chatRoomId)
                .then((value) {
              String retnSum = value;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(retnSum != null
                      ? retnSum
                      : "권한 허용이 되지 않아 다운로드 되지 않았습니다!")));
            });
          },
          child: Container(
            padding: EdgeInsets.only(
                top: 3,
                bottom: 3,
                left: isSendByMe ? 0 : 20,
                right: isSendByMe ? 20 : 0),
            alignment:
                isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isSendByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                isSendByMe
                    ? Row()
                    : Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(40)),
                            child: Text(
                              "${sendBy.substring(0, 1).toUpperCase()}",
                              style: mediumTextStyle(),
                            ),
                          ),
                          spaceW8(),
                          Container(
                            child: Text(
                              sendBy,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                isSendByMe ? Container() : spaceH3(),
                Container(
                  margin: isSendByMe
                      ? EdgeInsets.only(left: 20)
                      : EdgeInsets.only(right: 20),
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: isSendByMe ? Color(0xff007EF4) : Color(0x1AFFFFFF),
                  ),
                  child: Row(
                    mainAxisAlignment: isSendByMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.arrow_circle_down_outlined,
                          color: Colors.white,
                          size: 40,
                          weight: 200,
                        ),
                      ),
                      Flexible(
                        child: Text(message,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.w300)),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: isSendByMe
                      ? EdgeInsets.only(left: 20)
                      : EdgeInsets.only(right: 20),
                  child: Text(time,
                      textAlign: isSendByMe ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        color:
                            isSendByMe ? Color(0xff007EF4) : Color(0x1AFFFFFF),
                      )),
                )
              ],
            ),
          ),
        );
        break;
      case "image":
        return GestureDetector(
          onTap: () {
            StorageMethods()
                .toDownloadFile(this.message, this.download_Url, chatRoomId)
                .then((value) {
              String retnSum = value;
              ScaffoldMessenger.of(context)
                  .showSnackBar(new SnackBar(content: Text(retnSum)));
            });
          },
          child: Container(
            padding: EdgeInsets.only(
                top: 3,
                bottom: 3,
                left: isSendByMe ? 0 : 20,
                right: isSendByMe ? 20 : 0),
            alignment:
                isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isSendByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                isSendByMe
                    ? Row()
                    : Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(40)),
                            child: Text(
                              "${sendBy.substring(0, 1).toUpperCase()}",
                              style: mediumTextStyle(),
                            ),
                          ),
                          spaceW8(),
                          Container(
                            child: Text(
                              sendBy,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                isSendByMe ? Container() : spaceH3(),
                Container(
                  margin: isSendByMe
                      ? EdgeInsets.only(left: 20)
                      : EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Image(
                    height: 150,
                    width: 150,
                    filterQuality: FilterQuality.low,
                    fit: BoxFit.cover,
                    image: FirebaseImage(
                      'gs://chatappsample-a6614.appspot.com/$download_Url',
                      shouldCache: true,
                      scale: 0.1,
                      maxSizeBytes: 3000 * 3000,
                      cacheRefreshStrategy: CacheRefreshStrategy.NEVER,
                      // Switch off update checking
                    ),
                  ),
                ),
                Container(
                  margin: isSendByMe
                      ? EdgeInsets.only(left: 20)
                      : EdgeInsets.only(right: 20),
                  child: Text(time,
                      textAlign: isSendByMe ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        color:
                            isSendByMe ? Color(0xff007EF4) : Color(0x1AFFFFFF),
                      )),
                )
              ],
            ),
          ),
        );
        break;
      default:
        return Container(
          padding: EdgeInsets.only(
              top: 3,
              bottom: 3,
              left: isSendByMe ? 0 : 20,
              right: isSendByMe ? 20 : 0),
          alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                isSendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              isSendByMe
                  ? Row()
                  : Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(40)),
                          child: Text(
                            "${sendBy.substring(0, 1).toUpperCase()}",
                            style: mediumTextStyle(),
                          ),
                        ),
                        spaceW8(),
                        Container(
                          child: Text(
                            sendBy,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
              isSendByMe ? Container() : spaceH3(),
              Container(
                margin: isSendByMe
                    ? EdgeInsets.only(left: 20)
                    : EdgeInsets.only(right: 20),
                padding:
                    EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft:
                          isSendByMe ? Radius.circular(15) : Radius.circular(2),
                      bottomRight: isSendByMe
                          ? Radius.circular(2)
                          : Radius.circular(15)),
                  color: isSendByMe ? Color(0xff007EF4) : Color(0x80000000),
                ),
                child: Text(message,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300)),
              ),
              Container(
                margin: isSendByMe
                    ? EdgeInsets.only(left: 20)
                    : EdgeInsets.only(right: 20),
                child: Text(time,
                    textAlign: isSendByMe ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: isSendByMe ? Color(0xff007EF4) : Color(0x1AFFFFFF),
                    )),
              )
            ],
          ),
        );
        break;
    }
  }
}
