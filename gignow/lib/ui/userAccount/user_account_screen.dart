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

class UserAccountScreen extends StatefulWidget {
  final UserModel profile;
  UserAccountScreen(this.profile);
  @override
  UserAccountScreenState createState() => UserAccountScreenState();
}

class UserAccountScreenState extends State<UserAccountScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    String name = widget.profile.name;
    String handle = widget.profile.handle;
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Center(
              child: Text(
            handle,
            style: TextStyle(fontSize: 15, color: Colors.grey),
          )),
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
                  '  $name',
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
                      icon: Icon(
                        Icons.settings,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      }),
                  Text("Settings")
                ],
              ),
              Column(
                children: [
                  IconButton(
                      icon: Icon(Icons.camera_alt_outlined,
                          size: 30, color: Colors.grey),
                      onPressed: () {
                        Navigator.pushNamed(context, '/postvideo');
                      }),
                  Text("Add Media")
                ],
              ),
              Column(
                children: [
                  IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditSocialsScreen(widget.profile)));
                      }),
                  Text("Edit Profile")
                ],
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            children: <Widget>[
              SizedBox(
                  height: 400,
                  child: UserPostGrid(
                    userUid: widget.profile.uid,
                  )),
            ],
          )
        ],
      ),
    );
  }

  WebView spotifySnippet(String trackCode) {
    String html = """<!DOCTYPE html>
          <html>
                                                
        <div class="embed-youtube">
         <iframe src="https://open.spotify.com/embed/track/$trackCode" width="300" height="380" frameborder="0" allowtransparency="true" allow="encrypted-media"></iframe></div>
          </body>                                    
        </html>
    """;
    final Completer<WebViewController> _controller =
        Completer<WebViewController>();
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(html));
    return WebView(
      initialUrl: 'data:text/html;base64,$contentBase64',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
      },
      gestureNavigationEnabled: true,
    );
  }
}
