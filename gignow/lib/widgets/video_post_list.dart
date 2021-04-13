import 'package:flutter/material.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/widgets/video_post_widget.dart';

class VideoPostList extends StatefulWidget {
  @override
  _VideoPostListState createState() => _VideoPostListState();
}

class _VideoPostListState extends State<VideoPostList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseService().getVideoPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<VideoPost> posts = snapshot.data;
          return ListView.builder(
              shrinkWrap: true,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                VideoPost post = posts[index];
                return VideoPostWidget(post);
              });
        } else {
          return Loading();
        }
      },
    );
  }
}

class UsersVideoPostList extends StatefulWidget {
  String userUid;
  UsersVideoPostList(this.userUid);
  @override
  _UsersVideoPostListState createState() => _UsersVideoPostListState();
}

class _UsersVideoPostListState extends State<UsersVideoPostList> {
  @override
  Widget build(BuildContext context) {
    String uid = widget.userUid;
    return FutureBuilder(
      future: FirebaseService().getUsersVideoPosts(uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<VideoPost> posts = snapshot.data;
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                VideoPost post = posts[index];
                return VideoPostWidget(post);
              });
        } else {
          return Loading();
        }
      },
    );
  }
}
