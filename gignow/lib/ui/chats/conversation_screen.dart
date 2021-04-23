import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/helper_functions/shared_preferences_helper.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/database.dart';
import 'package:gignow/ui/chats/chats_screen.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:random_string/random_string.dart';

class ConversationScreen extends StatefulWidget {
  final String chatWithName, chatWithUID;
  final UserModel senderProfile;
  ConversationScreen(this.senderProfile, this.chatWithName, this.chatWithUID);
  @override
  ConversationScreenState createState() => ConversationScreenState();
}

class ConversationScreenState extends State<ConversationScreen> {
  String chatRoomID, messageID = "";
  String myName, myProfilePic, myHandle, myUID;
  Stream messageStream;
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();
  TextEditingController messageTextEditingController = TextEditingController();

  getInfoFromSharedPreferences() {
    myName = widget.senderProfile.name;
    myProfilePic = widget.senderProfile.profilePictureUrl;
    myHandle = widget.senderProfile.handle;
    myUID = widget.senderProfile.uid;
    //String chatName = widget.chatWithName;
    //print("Testing $chatName");

    chatRoomID =
        DatabaseMethods().getChatRoomIDByHandle(myUID, widget.chatWithUID);
  }

  addMessage() {
    if (messageTextEditingController != "") {
      String message = messageTextEditingController.text;
      var lastMessageTimeStamp = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sentBy": myUID,
        "timeStamp": lastMessageTimeStamp,
        "imgUrl": myProfilePic
      };

      //messageID
      if (messageID == "") {
        messageID = randomAlphaNumeric(12);
      }

      DatabaseMethods().addMessage(chatRoomID, messageInfoMap).then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSentTimeStamp": lastMessageTimeStamp,
          "lastMessageSentBy": myUID
        };
        messageTextEditingController.text = "";
      });
    }
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomID);
    setState(() {});
  }

  onLaunch() async {
    getInfoFromSharedPreferences();
    getAndSetMessages();
  }

  @override
  void initState() {
    onLaunch();
    super.initState();
  }

  Widget messageTile(String message, bool sentByMe) {
    return Row(
      mainAxisAlignment:
          sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight:
                      sentByMe ? Radius.circular(0) : Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft:
                      sentByMe ? Radius.circular(24) : Radius.circular(0)),
              color: sentByMe ? Colors.lightBlueAccent : Colors.grey[400]),
          padding: EdgeInsets.all(16),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget messages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 70, top: 16),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  if (ds['message'] != null) {
                    return messageTile(ds["message"], myUID == ds["sentBy"]);
                  }
                })
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatWithName,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            messages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageTextEditingController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message",
                          hintStyle: TextStyle(fontWeight: FontWeight.w400)),
                    )),
                    GestureDetector(
                        onTap: () {
                          addMessage();
                          messageTextEditingController.text = "";
                        },
                        child: Icon(Icons.send))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
