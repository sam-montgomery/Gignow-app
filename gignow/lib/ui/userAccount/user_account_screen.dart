import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:webview_flutter/webview_flutter.dart';

//Profile UI https://medium.com/@palmeiro.leonardo/simple-profile-screen-with-flutter-fe2f1f7cfaf5
class UserAccountScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  UserAccountScreen(this.profile);
  @override
  UserAccountScreenState createState() => UserAccountScreenState();
}

class UserAccountScreenState extends State<UserAccountScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    bool venue = (widget.profile['venueName'] != null ? true : false);
    bool hasUsername = (widget.profile['username'] != null ? true : false);
    String firstName = widget.profile['firstName'];
    String lastName = widget.profile['lastName'];
    String venueName = widget.profile['venueName'];
    return Scaffold(
      // // appBar: AppBar(
      // //   title: Text("Your Profile"),
      // //   actions: [
      // //     Padding(
      // //       padding: const EdgeInsets.only(right: 20.0),
      // //       child: GestureDetector(
      // //         onTap: () => auth.signOut(),
      // //         child: Icon(Icons.logout),
      // //       ),
      // //     )
      // //   ],
      // // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/chat');
      //   },
      //   child: Text("Chat"),
      // ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Center(
              child: Text(
            hasUsername ? widget.profile["username"] : "@NoUsername",
            style: TextStyle(fontSize: 20),
          )),
          Container(
            height: 250,
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [Colors.white, Colors.blue.shade300],
            //     begin: Alignment.centerLeft,
            //     end: Alignment.centerRight,
            //     stops: [0.5, 0.9],
            //   ),
            // ),
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
                            NetworkImage(widget.profile["profile_picture_url"]),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                venue
                    ? Text(
                        '$venueName',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        '$firstName $lastName',
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
                      icon: Icon(Icons.build, color: Colors.grey),
                      onPressed: () {}),
                  Text("Edit Profile")
                ],
              ),
            ],
          ),
          Center(
            child: Column(
              children: [
                IconButton(
                    icon: Icon(Icons.camera_alt_outlined,
                        size: 30, color: Colors.red[300]),
                    onPressed: () {}),
                Text("Add Media")
              ],
            ),
          ),

          // Container(
          //   child: Row(
          //     children: <Widget>[
          //       Expanded(
          //         child: Container(
          //           color: Colors.blue.shade300,
          //           child: ListTile(
          //             title: Text(
          //               '5000',
          //               textAlign: TextAlign.center,
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 30,
          //                 color: Colors.white,
          //               ),
          //             ),
          //             subtitle: Text(
          //               'Followers',
          //               textAlign: TextAlign.center,
          //               style: TextStyle(
          //                 fontSize: 20,
          //                 color: Colors.white70,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         child: Container(
          //           color: Colors.blue,
          //           child: ListTile(
          //             title: Text(
          //               '5000',
          //               textAlign: TextAlign.center,
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 30,
          //                 color: Colors.white,
          //               ),
          //             ),
          //             subtitle: Text(
          //               'Following',
          //               textAlign: TextAlign.center,
          //               style: TextStyle(
          //                 fontSize: 20,
          //                 color: Colors.white70,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Center(
          //   child: Container(
          //     height: 80,
          //     child:
          //         spotifySnippet(widget.profile["spotifyHighlightTrackCode"]),
          //   ),
          // ),
          // Container(
          //   child: Column(
          //     children: <Widget>[
          //       ListTile(
          //         title: Text(
          //           'Phone #',
          //           style: TextStyle(
          //             color: Colors.blue,
          //             fontSize: 20,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         subtitle: Text(
          //           widget.profile["phoneNumber"],
          //           style: TextStyle(
          //             fontSize: 18,
          //           ),
          //         ),
          //       ),
          //       Divider(),
          //       ListTile(
          //         title: Text(
          //           'Genres',
          //           style: TextStyle(
          //             color: Colors.blue,
          //             fontSize: 20,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         subtitle: Text(
          //           widget.profile['genres'],
          //           style: TextStyle(
          //             fontSize: 18,
          //           ),
          //         ),
          //       ),
          //       venue
          //           ? ListTile(
          //               title: Text(
          //                 'Genres',
          //                 style: TextStyle(
          //                   color: Colors.blue,
          //                   fontSize: 20,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //               subtitle: Text(
          //                 widget.profile['genres'],
          //                 style: TextStyle(
          //                   fontSize: 18,
          //                 ),
          //               ),
          //             )
          //           : ListTile(
          //               title: Text(
          //                 'Genres',
          //                 style: TextStyle(
          //                   color: Colors.blue,
          //                   fontSize: 20,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //               subtitle: Text(
          //                 widget.profile['genres'],
          //                 style: TextStyle(
          //                   fontSize: 18,
          //                 ),
          //               ),
          //             ),
          //       Divider(),
          //       //spotifySnippet(widget.profile["spotifyHighlightTrackCode"])
          //       // ListTile(
          //       //   title: Text(
          //       //     'Linkedin',
          //       //     style: TextStyle(
          //       //       color: Colors.blue,
          //       //       fontSize: 20,
          //       //       fontWeight: FontWeight.bold,
          //       //     ),
          //       //   ),
          //       //   subtitle: Text(
          //       //     'www.linkedin.com/in/leonardo-palmeiro-834a1755',
          //       //     style: TextStyle(
          //       //       fontSize: 18,
          //       //     ),
          //       //   ),
          //       // ),
          //     ],
          //   ),
          // )
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

  // Future<Widget> _getImage(BuildContext context, String image) async {
  //   Image m;
  //   await firebase_storage.Reference
  //   await FireStorageService.loadFromStorage(context, image)
  //       .then((downloadUrl) {
  //     m = Image.network(
  //       downloadUrl.toString(),
  //       fit: BoxFit.scaleDown,
  //     );
  //   });

  //   return m;
  // }
}
