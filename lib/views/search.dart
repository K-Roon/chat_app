import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchTextEditingController =
      new TextEditingController();
  QuerySnapshot searchResultSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

  ///사람을 검색할 때 사용합니다. 이 경우 검색창이 비어있지 않아야 합니다.
  initiateSearch() async {
    if (searchTextEditingController.text.isNotEmpty) {
      await databaseMethods
          .getUserByUsername(searchTextEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          haveUserSearched = true;
        });
      });
    }
  }

  @override
  void initState() {
    initiateSearch();
    super.initState();
  }

  ///유저가 검색이 된 경우 Firebase 에서 값을 구해옵니다. 만약 "k"를 검색한 경우 "k"와 관련되어 있는 이름이 모두 뜨게 됩니다.
  Widget searchList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.docs.length,
            itemBuilder: (context, index) {
              return SearchTile(
                searchResultSnapshot.docs[index].get("name"),
                searchResultSnapshot.docs[index].get("email"),
                searchResultSnapshot.docs[index].get("userId"),
              );
            })
        : Container();
  }

  addFriend(
      {String userName,
      String userId,
      bool hasConvRoom,
      String oneChatRoomId}) {
    Map<String, dynamic> friendMap = {
      "friendId": userId,
      "friendName": userName,
      "hasConvRoom": hasConvRoom,
      "oneChatRoomId": null
    };
    databaseMethods.addFriends(userId, friendMap, hasConvRoom, oneChatRoomId);
  }

  // ignore: non_constant_identifier_names
  Widget SearchTile(String userName, String userEmail, String userId) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                userEmail,
                style: TextStyle(color: Colors.white54, fontSize: 15),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              if (userId != Constants.myId) {
                addFriend(
                    userName: userName, userId: userId, hasConvRoom: false);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("친구가 추가되었습니다. 채팅을 즐겨보세요.")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("나 자신은 인생의 영원한 친구입니다.")));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color:
                      userId == Constants.myId ? Colors.black54 : Colors.blue,
                  borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Icon(
                userId == Constants.myId
                    ? MaterialSymbols.person_add_disabled
                    : MaterialSymbols.person_add,
                color: Colors.white,
                weight: 200,
              ), //하얀색 메시지 아이콘
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0x99FFFFFF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Expanded(
                      child: TextField(
                        controller: searchTextEditingController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.search,
                        onEditingComplete: (() {
                          initiateSearch();
                        }),
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "사용자 이름 검색",
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 17,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            onPressed: () =>
                                searchTextEditingController.clear(),
                            icon: Icon(
                              MaterialSymbols.cancel_filled,
                              color: Colors.black54,
                              weight: 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff1F1F1F),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: searchList(),
                  )
                ],
              ),
            ),
    );
  }
}
