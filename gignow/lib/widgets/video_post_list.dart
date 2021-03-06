import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/net/globals.dart';
import 'package:gignow/net/video_ranking_service.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/widgets/video_post_widget.dart';

class VideoPostList extends StatefulWidget {
  @override
  _VideoPostListState createState() => _VideoPostListState();
}

class _VideoPostListState extends State<VideoPostList> {
  int vidIndex = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool showFollowing = false;
  FirebaseService firebaseService = FirebaseService();
  List<Future> futures = [];
  int futureIndex = 1;
  Global global = Global();
  int curVid = Global().vidIdx;
  final _controller = PageController(initialPage: Global().vidIdx);
  // @override
  // Widget build2(BuildContext context) {
  //   futures.add(firebaseService.getFollowingVideoPosts());
  //   futures.add(firebaseService.getVideoPosts());
  //   return FutureBuilder(
  //     future: showFollowing
  //         ? (firebaseService.getFollowingVideoPosts())
  //         : VideoRankingService().getRankedVideos(auth.currentUser.uid),
  //     // : firebaseService.getVideoPosts(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData &&
  //           snapshot.connectionState == ConnectionState.done) {
  //         List<VideoPost> posts = snapshot.data;
  //         if (posts.length > 0) {
  //           VideoPostWidget curVid = VideoPostWidget(
  //               posts[showFollowing ? global.followingVidIdx : global.vidIdx]);
  //           //previous vid, next vid
  //           return Stack(
  //             children: [
  //               curVid,
  //               //VideoPostWidget(posts[vidIndex]),
  //               Column(children: [
  //                 SizedBox(
  //                   height: 30,
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     MaterialButton(
  //                       color: Colors.white,
  //                       child: Text("Previous"),
  //                       onPressed: () {
  //                         if (showFollowing) {
  //                           if (global.followingVidIdx > 0) {
  //                             setState(() {
  //                               global.followingVidIdx--;
  //                             });
  //                           }
  //                         } else {
  //                           if (global.vidIdx > 0) {
  //                             setState(() {
  //                               global.vidIdx--;
  //                             });
  //                           }
  //                         }
  //                         //widget.createState();
  //                       },
  //                     ),
  //                     MaterialButton(
  //                       color: Colors.white,
  //                       child:
  //                           Text(showFollowing ? "Show All" : "Show Following"),
  //                       onPressed: () {
  //                         setState(() {
  //                           showFollowing = !showFollowing;
  //                           // global.vidIdx = 0;
  //                           if (futureIndex == 0) {
  //                             futureIndex = 1;
  //                           } else {
  //                             futureIndex = 0;
  //                           }
  //                         });
  //                       },
  //                     ),
  //                     MaterialButton(
  //                       color: Colors.white,
  //                       child: Text("Next"),
  //                       onPressed: () {
  //                         if (showFollowing) {
  //                           if (global.followingVidIdx < posts.length - 1) {
  //                             setState(() {
  //                               global.followingVidIdx++;
  //                             });
  //                           }
  //                         } else {
  //                           if (global.vidIdx < posts.length - 1) {
  //                             setState(() {
  //                               global.vidIdx++;
  //                             });
  //                           }
  //                         }
  //                         //widget.createState();
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ])
  //             ],
  //           );
  //           // return ListView.builder(
  //           //     shrinkWrap: true,
  //           //     itemCount: posts.length,
  //           //     itemBuilder: (context, index) {
  //           //       VideoPost post = posts[index];
  //           //       return VideoPostWidget(post);
  //           //     });
  //         } else {
  //           return Container();
  //         }
  //       } else {
  //         return Loading();
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    futures.add(firebaseService.getFollowingVideoPosts());
    futures.add(firebaseService.getVideoPosts());
    return FutureBuilder(
      future: showFollowing
          ? (firebaseService.getFollowingVideoPosts())
          : VideoRankingService().getRankedVideos(auth.currentUser.uid),
      // : firebaseService.getVideoPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          List<VideoPost> posts = snapshot.data;
          if (posts.length > 0) {
            VideoPostWidget curVid = VideoPostWidget(
                posts[showFollowing ? global.followingVidIdx : global.vidIdx]);
            //previous vid, next vid

            return PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _controller,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  VideoPost post = posts[index];
                  return Stack(children: [
                    VideoPostWidget(post),
                    Column(children: [
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FlatButton(
                            color: Colors.transparent,
                            child: Text(
                              showFollowing ? "Show All" : "Show Following",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                showFollowing = !showFollowing;
                                // global.vidIdx = 0;
                                if (futureIndex == 0) {
                                  futureIndex = 1;
                                } else {
                                  futureIndex = 0;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ])
                  ]);
                });
          } else {
            return Container();
          }
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
          if (posts.isEmpty) {
            //return no posts yet
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
          }
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
