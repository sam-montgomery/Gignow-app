import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/database.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/home_view.dart';
import 'package:gignow/ui/loading.dart';

import 'components/chat_room_list_tile.dart';
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
  //Stream connectionsStream;
  String myName, myProfilePic, myHandle, myUID;
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
    getChatRooms(myUID);
  }

  onSearchButtonClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUserNameEditingController.text);
    setState(() {});
  }

  getInfoFromSharedPreferences() {
    myName = widget.profile.name;
    myProfilePic = widget.profile.profilePictureUrl;
    myHandle = widget.profile.handle;
    myUID = widget.profile.uid;
  }

  getChatRooms(String uid) async {
    // connectionsStream =
    //     await DatabaseMethods().getConnections(widget.profile.uid);
    chatRoomsStream = await DatabaseMethods().getChatRooms(uid);
    setState(() {});
  }

  Widget chatRoomsList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
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
            );
          } else {
            return Loading();
          }
        });
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
                  // String chatRoomID =
                  //     DatabaseMethods().getChatRoomsIDs(ds["userUid"]);
                  return ChatRoomListTile(null, ds["userUid"] + "_" + myUID,
                      widget.profile.handle, widget.profile);
                  // return userTile(ds["userUid"], ds["profile_picture_url"],
                  //     ds["name"], ds["handle"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              "Chats",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
          ),
          body: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Expanded(
                child: ListView(
                  shrinkWrap: true,
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
                                        if (searchUserNameEditingController
                                                .text !=
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
                ),
              )));
    } catch (e) {
      return Loading();
    }
  }
}
