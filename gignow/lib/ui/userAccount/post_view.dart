import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:gignow/ui/userAccount/edit_socials_screen.dart';
import 'package:gignow/widgets/user_posts_grid.dart';
import 'package:gignow/widgets/video_post_list.dart';
import 'package:gignow/widgets/video_post_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:gignow/widgets/user_posts_grid.dart';

class PostViewScreen extends StatefulWidget {
  VideoPost post;
  PostViewScreen(this.post);
  @override
  PostViewScreenState createState() => PostViewScreenState();
}

class PostViewScreenState extends State<PostViewScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white),
      body: VideoPostWidget(this.widget.post),
    );
  }
}
