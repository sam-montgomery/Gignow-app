import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/database.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/home_view.dart';
import 'package:gignow/ui/loading.dart';

import '../conversation_screen.dart';

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomID, senderHandle;
  final UserModel senderProfile;
  ChatRoomListTile(
      this.lastMessage, this.chatRoomID, this.senderHandle, this.senderProfile);
  @override
  ChatRoomListTileState createState() => ChatRoomListTileState();
}

class ChatRoomListTileState extends State<ChatRoomListTile> {
  String recieverProfilePictureURL, recieverName, recieverUID;
  QuerySnapshot recieverProfile;

  getThisUserInfo() async {
    recieverUID = widget.chatRoomID
        .replaceAll(widget.senderProfile.uid, "")
        .replaceAll("_", "");
    recieverProfile = await DatabaseMethods().getUserByUserUID(recieverUID);
    recieverName = recieverProfile.docs[0]["name"];
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
                          widget.senderProfile, recieverName, recieverUID)));
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
                    widget.lastMessage != null
                        ? Text(widget.lastMessage)
                        : Text("Say hello to your new connection!")
                  ],
                )
              ],
            ),
          )
        : Container();
  }
}
