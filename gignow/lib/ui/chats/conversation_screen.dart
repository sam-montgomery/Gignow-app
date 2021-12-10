import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/helper_functions/shared_preferences_helper.dart';
import 'package:gignow/model/event.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/database.dart';
import 'package:gignow/net/globals.dart';
import 'package:gignow/ui/chats/chats_screen.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/events/events_screen_consts.dart';
import 'package:gignow/ui/navBar/artist_nav_bar.dart';
import 'package:gignow/ui/navBar/venue_nav_bar.dart';
import 'package:intl/intl.dart';
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

  Widget eventMessageTile(
      Event event, bool sentByMe, UserModel venue, UserModel artist) {
    UserModel um = Global().currentUserModel;
    bool venue = um.venue;
    bool applied = false;
    bool accepted = false;

    if (event.applicants.contains(um.uid) || event.acceptedUid.isNotEmpty) {
      applied = true;
    }
    if (event.acceptedUid == um.uid) {
      accepted = true;
    }
    String startingTime = event.eventStartTime.hour.toString() +
        ':' +
        (event.eventStartTime.minute == 0
            ? "00"
            : event.eventStartTime.minute.toString());
    DateTime eventFinishTime = event.eventStartTime.add(event.eventDuration);
    String finishingTime = eventFinishTime.hour.toString() +
        ':' +
        (eventFinishTime.minute == 0
            ? "00"
            : eventFinishTime.minute.toString());
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              venue
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: ListView(
                          children: [
                            Text(
                              moty[event.eventStartTime.month - 1],
                              textAlign: TextAlign.center,
                              style: monthStyle,
                            ),
                            Text(
                              event.eventStartTime.day.toString(),
                              textAlign: TextAlign.center,
                              style: dateStyle,
                            ),
                          ],
                        ),
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                      ))
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return generateEventDialog(event, um);
                              },
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white70,
                            minRadius: 30.0,
                            child: CircleAvatar(
                              radius: 30.0,
                              backgroundImage: NetworkImage(
                                  event.venue['profile_picture_url']),
                            ),
                          ),
                        ),
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                      )),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      venue
                          ? Text(
                              DateFormat('EEEE').format(event.eventStartTime),
                              textAlign: TextAlign.center,
                              style: dayStyle,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(event.venue['name'],
                                      textAlign: TextAlign.left,
                                      style: eventTitle),
                                  Text(
                                    DateFormat('EEEE')
                                            .format(event.eventStartTime) +
                                        " - " +
                                        moty[event.eventStartTime.month - 1] +
                                        " " +
                                        event.eventStartTime.day.toString(),
                                    textAlign: TextAlign.left,
                                    style: inActiveScreen,
                                  )
                                ]),
                      Text(
                        "$startingTime - $finishingTime",
                        textAlign: TextAlign.left,
                        style: timeStyle,
                      )
                    ],
                  ),
                ),
              ),
              venue
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                    )
                  : SizedBox(width: 0),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    venue
                        ? applied
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                      child: Text(
                                        'Applicant \nSelected',
                                        textAlign: TextAlign.center,
                                      ),
                                      color: Colors.lightBlue,
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                      child: Text('Applicants'),
                                      color: Colors.lightBlue,
                                      onPressed: () async {
                                        await showApplicantsDialog(
                                            context, event);
                                      },
                                    ),
                                  ],
                                ),
                              )
                        : accepted
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                      child: Text('Confirm'),
                                      color: Colors.lightBlue,
                                      onPressed: () {
                                        FirebaseService().confirmEvent(event);
                                        Navigator.of(context).push(
                                            new MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return new ArtistNavbar(1);
                                        }));
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                      child:
                                          Text(applied ? 'Applied' : 'Apply'),
                                      color: Colors.lightBlue,
                                      onPressed: () {
                                        if (!applied) {
                                          applyForEvent(event, um.uid);
                                          applied = true;
                                          Navigator.of(context).push(
                                              new MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return new ArtistNavbar(1);
                                          }));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                    venue
                        ? PopupMenuButton(
                            onSelected: (value) {
                              deleteEvent(event);
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return new VenueNavbar(2);
                              }));
                            },
                            child: Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.delete),
                                      Text('Delete')
                                    ],
                                  )),
                            ],
                          )
                        : SizedBox(width: 10),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
            ],
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
                    //if message contains eventstring ...
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
