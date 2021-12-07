import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:gignow/model/user.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:gignow/net/globals.dart';
import 'package:gignow/ui/chats/conversation_screen.dart';
import 'package:gignow/ui/userProfile/socials_screen.dart';
import 'package:gignow/widgets/video_post_list.dart';
import 'package:gignow/widgets/video_post_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileScreen extends StatefulWidget {
  UserModel profile;
  bool isFollowing;
  ProfileScreen(this.profile, this.isFollowing);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseService firebaseService = FirebaseService();
  FirebaseAuth auth = FirebaseAuth.instance;
  Global global = Global();

  @override
  Widget build(BuildContext context) {
    UserModel currentUser = global.currentUserModel;
    String name = widget.profile.name;
    String handle = widget.profile.handle;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          handle,
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      ),
      // floatingActionButton: IconButton(
      //   icon: Icon(Icons.close),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.all(16),
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white70,
                      minRadius: 60.0,
                      child: CircleAvatar(
                        radius: 60.0,
                        backgroundImage: CachedNetworkImageProvider(
                            widget.profile.profilePictureUrl),
                      ),
                    ),
                    SizedBox(width: 50),
                    Column(
                      children: [
                        Text("${widget.profile.followers}",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Followers"),
                      ],
                    ),
                    SizedBox(width: 50),
                    Column(
                      children: [
                        Text("${widget.profile.followers}",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Following"),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '$name',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  IconButton(
                      icon: Icon(Icons.message_rounded,
                          size: 30, color: Colors.red[300]),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConversationScreen(
                                    currentUser,
                                    widget.profile.name,
                                    widget.profile.uid)));
                      }),
                  Text("Message")
                ],
              ),
              Column(
                children: [
                  IconButton(
                      icon: Icon(Icons.insert_link_rounded,
                          color: Colors.red[300]),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SocialsScreen(widget.profile)));
                      }),
                  Text("Socials")
                ],
              ),
              Column(
                children: [
                  IconButton(
                      icon: Icon(
                          widget.isFollowing
                              ? Icons.person_remove_alt_1_rounded
                              : Icons.person_add_alt_1_rounded,
                          color: Colors.red[300]),
                      onPressed: () {
                        setState(() {
                          if (widget.isFollowing) {
                            widget.profile.followers--;
                          } else {
                            widget.profile.followers++;
                          }
                          widget.isFollowing = !widget.isFollowing;
                        });
                        firebaseService.followUnfollowUser(widget.profile.uid);
                      }),
                  Text(widget.isFollowing ? "Unfollow" : "Follow")
                ],
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          SingleChildScrollView(child: UsersVideoPostList(widget.profile.uid))
        ],
      ),
    );
  }
}
