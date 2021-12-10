import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/ui/userAccount/post_view.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UserPostGrid extends StatefulWidget {
  @override
  String userUid;
  UserPostGrid({this.userUid});
  _UserPostGridState createState() => _UserPostGridState(userUid: userUid);
}

class _UserPostGridState extends State<UserPostGrid> {
  String userUid;
  _UserPostGridState({this.userUid});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseService().getUsersVideoPosts(userUid),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            List<VideoPost> posts = snapshot.data;
            if (posts.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: 150),
                child: Text(
                  "No Posts Yet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              );
            } else {
              return GridView.builder(
                  itemCount: posts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (context, index) {
                    VideoPost post = posts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostViewScreen(post)));
                      },
                      child: Image.network(post.thumbnailURL ??
                          "https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png"),
                    );
                  });
            }
          } else {
            return Loading();
          }
        });
  }
}
