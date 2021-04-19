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
import 'package:gignow/widgets/video_post_list.dart';
import 'package:gignow/widgets/video_post_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileScreen extends StatefulWidget {
  UserModel profile;
  ProfileScreen(this.profile);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    String name = widget.profile.name;
    String handle = widget.profile.handle;
    return Scaffold(
      floatingActionButton: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Center(
              child: Text(
            handle,
            style: TextStyle(fontSize: 20),
          )),
          Container(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white70,
                      minRadius: 60.0,
                      child: CircleAvatar(
                        radius: 80.0,
                        backgroundImage:
                            NetworkImage(widget.profile.profilePictureUrl),
                      ),
                    ),
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
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     Column(
          //       children: [
          //         IconButton(
          //             icon: Icon(
          //               Icons.settings,
          //               color: Colors.grey,
          //             ),
          //             onPressed: () {
          //               Navigator.pushNamed(context, '/settings');
          //             }),
          //         Text("Settings")
          //       ],
          //     ),
          //     Column(
          //       children: [
          //         IconButton(
          //             icon: Icon(Icons.edit, color: Colors.grey),
          //             onPressed: () {}),
          //         Text("Edit Profile")
          //       ],
          //     ),
          //   ],
          // ),
          // Center(
          //   child: Column(
          //     children: [
          //       IconButton(
          //           icon: Icon(Icons.camera_alt_outlined,
          //               size: 30, color: Colors.red[300]),
          //           onPressed: () {
          //             Navigator.pushNamed(context, '/postvideo');
          //           }),
          //       Text("Add Media")
          //     ],
          //   ),
          // ),
          SizedBox(
            height: 20,
          ),
          SingleChildScrollView(child: UsersVideoPostList(widget.profile.uid))
        ],
      ),
    );
  }
}
