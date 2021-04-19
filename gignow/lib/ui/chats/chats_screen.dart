import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/database.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/home_view.dart';

import 'conversation_screen.dart';

class ChatsScreen extends StatefulWidget {
  final UserModel profile;
  ChatsScreen(this.profile);
  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatsScreen> {
  bool isSearching = false;
  Stream usersStream;
  Stream chatRoomsStream;
  String myName, myProfilePic, myHandle;
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();

  TextEditingController searchUserNameEditingController =
      TextEditingController();

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  onScreenLoaded() async {
    await getInfoFromSharedPreferences();
    getChatRooms(myHandle);
  }

  onSearchButtonClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUserNameEditingController.text);
    setState(() {});
  }

  getChatRoomIDByHandle(String idA, String idB) {
    if (idA.substring(0, 1).codeUnitAt(0) >=
        idB.substring(0, 1).codeUnitAt(0)) {
      return "$idB\_$idA";
    } else {
      return "$idA\_$idB";
    }
  }

  getInfoFromSharedPreferences() {
    myName = widget.profile.name;
    myProfilePic = widget.profile.profilePictureUrl;
    myHandle = widget.profile.handle;
  }

  getChatRooms(String handle) async {
    chatRoomsStream = await DatabaseMethods().getChatRooms(handle);
    setState(() {});
  }

  Widget userTile(String uid, profileURL, name, handle) {
    return GestureDetector(
      onTap: () {
        var chatRoomID = getChatRoomIDByHandle(handle, myHandle);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myHandle, handle]
        };

        DatabaseMethods().createChatRoom(chatRoomID, chatRoomInfoMap);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConversationScreen(widget.profile, name, handle)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              profileURL,
              height: 50,
              width: 50,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(name), Text(handle)],
          )
        ],
      ),
    );
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return userTile(ds["userUid"], ds["profile_picture_url"],
                      ds["name"], ds["handle"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget chatRoomsList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return ChatRoomListTile(
                      ds["lastMessage"],
                      ds.id,
                      myHandle,
                      widget.profile,
                    );
                  },
                )
              : Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chats"),
          actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
        ),
        body: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    isSearching
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isSearching = false;
                                searchUserNameEditingController.text = "";
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.arrow_back),
                            ),
                          )
                        : Container(),
                    Expanded(
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: 16),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey,
                                  width: 1.4,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(24)),
                          child: Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                controller: searchUserNameEditingController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search for people"),
                              )),
                              GestureDetector(
                                  onTap: () {
                                    if (searchUserNameEditingController.text !=
                                        "") {
                                      onSearchButtonClick();
                                    }
                                  },
                                  child: Icon(Icons.search))
                            ],
                          )),
                    ),
                  ],
                ),
                isSearching ? searchUsersList() : chatRoomsList()
              ],
            )));
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomID, myHandle;
  final UserModel profile;
  ChatRoomListTile(
      this.lastMessage, this.chatRoomID, this.myHandle, this.profile);
  @override
  ChatRoomListTileState createState() => ChatRoomListTileState();
}

class ChatRoomListTileState extends State<ChatRoomListTile> {
  String recieverProfilePictureURL, recieverName, recieverHandle;
  QuerySnapshot recieverProfile;

  getThisUserInfo() async {
    recieverHandle = widget.chatRoomID
        .replaceAll(widget.profile.handle, "")
        .replaceAll("_", "");
    recieverProfile =
        await DatabaseMethods().getUserByUserHandle(recieverHandle);
    // QuerySnapshot querySnapshot =
    //     await DatabaseMethods().getUserInfoByHandle(widget.myHandle);
    //print("something ${querySnapshot.docs[0].id}");
    recieverName = recieverProfile.docs[0]["name"];
    //name = querySnapshot.docs[0]["name"];
    //profilePictureURL = querySnapshot.docs[0]["profile_picture_url"];
    recieverProfilePictureURL = recieverProfile.docs[0]["profile_picture_url"];
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return recieverProfilePictureURL != ""
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConversationScreen(
                          widget.profile, recieverName, recieverHandle)));
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    recieverProfilePictureURL,
                    height: 60,
                    width: 60,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recieverName,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(widget.lastMessage)
                  ],
                )
              ],
            ),
          )
        : Container();
  }
}
