import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/ui/userProfile/profile_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoPlayerWidget extends StatefulWidget {
  VideoPost videoPost;
  UserModel user;
  VideoPlayerWidget(this.videoPost, this.user);
  @override
  _VideoPlayerWidgetState createState() =>
      _VideoPlayerWidgetState(videoPost, user);
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPost videoPost;
  UserModel user;
  _VideoPlayerWidgetState(this.videoPost, this.user);
  bool isLiked = false;

  VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
  }

  void toggleLiked() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    double playerWidth = MediaQuery.of(context).size.width;
    double playerHeight = (MediaQuery.of(context).size.height * 0.90);
    return FutureBuilder(
        future: FirebaseService().getIsLikedAndNumLikes(videoPost),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            bool isLiked = snapshot.data['isLiked'];
            var numLikes = snapshot.data['numLikes'];
            return AspectRatio(
              aspectRatio: playerWidth / playerHeight,
              //padding: const EdgeInsets.all(20),
              child: FutureBuilder(
                future: DefaultCacheManager().getSingleFile(videoPost.videoURL),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //print("Video Loaded from ${snapshot.data.toString()}");
                    _controller = VideoPlayerController.file(snapshot.data);
                    _controller.addListener(() {
                      // setState(() {});
                    });
                    _controller.setLooping(true);
                    // _controller.initialize().then((_) => setState(() {}));
                    _controller.initialize();
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          VideoPlayer(_controller),
                          _ControlsOverlay(controller: _controller),
                          VideoProgressIndicator(_controller,
                              allowScrubbing: true),
                          _VideoOverlay(
                            videoPost: videoPost,
                            user: user,
                          ),
                          //   Container(
                          //     alignment: Alignment.bottomLeft,
                          //     child: Column(
                          //       mainAxisAlignment: MainAxisAlignment.end,
                          //       children: [
                          //         Row(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceBetween,
                          //           children: [
                          //             Row(
                          //               children: [
                          //                 SizedBox(
                          //                   width: 10,
                          //                 ),
                          //                 GestureDetector(
                          //                   onTap: () {
                          //                     Navigator.push(
                          //                         context,
                          //                         MaterialPageRoute(
                          //                             builder: (context) =>
                          //                                 ProfileScreen(user)));
                          //                   },
                          //                   child: CircleAvatar(
                          //                       backgroundColor: Colors.white70,
                          //                       minRadius: 24.0,
                          //                       child: CircleAvatar(
                          //                         radius: 20.0,
                          //                         backgroundImage:
                          //                             CachedNetworkImageProvider(
                          //                           user.profilePictureUrl,
                          //                         ),
                          //                       )),
                          //                 ),
                          //                 SizedBox(
                          //                   width: 10,
                          //                 ),
                          //                 Text(user.handle,
                          //                     style: TextStyle(
                          //                         color: Colors.white,
                          //                         fontWeight: FontWeight.bold,
                          //                         fontSize: 20)),
                          //               ],
                          //             ),
                          //             Column(
                          //               //mainAxisAlignment: MainAxisAlignment.end,
                          //               children: [
                          //                 MaterialButton(
                          //                   shape: CircleBorder(),
                          //                   onPressed: () async {
                          //                     // setState(() {
                          //                     //   isLiked = !isLiked;
                          //                     // });
                          //                     FirebaseService()
                          //                         .likeUnlikeVideo(videoPost);
                          //                     //toggleLiked();
                          //                   },
                          //                   child: Icon(Icons.favorite,
                          //                       color: isLiked
                          //                           ? Colors.red
                          //                           : Colors.white,
                          //                       size: playerWidth * 0.08),
                          //                 ),
                          //                 Text("${numLikes.toString()}",
                          //                     style: TextStyle(
                          //                       color: Colors.white,
                          //                     )),
                          //                 MaterialButton(
                          //                   shape: CircleBorder(),
                          //                   onPressed: () {
                          //                     print('1');
                          //                   },
                          //                   //height: playerHeight * 0.03,
                          //                   child: Icon(Icons.share,
                          //                       color: Colors.white,
                          //                       size: playerWidth * 0.08),
                          //                 ),
                          //                 //SizedBox(width: playerWidth * 0.05)
                          //               ],
                          //             )
                          //           ],
                          //         ),
                          //         SizedBox(height: 5),
                          //         Row(
                          //           mainAxisAlignment: MainAxisAlignment.start,
                          //           children: [
                          //             SizedBox(
                          //               width: 10,
                          //             ),
                          //             Text(videoPost.postDescription,
                          //                 textAlign: TextAlign.left,
                          //                 style: TextStyle(color: Colors.white)),
                          //           ],
                          //         ),
                          //         SizedBox(
                          //           height: 10,
                          //         )
                          //       ],
                          //     ),
                          //   )
                        ],
                      ),
                    );
                  } else {
                    return AspectRatio(
                        aspectRatio: MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height * 0.90),
                        child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[Loading()]));
                  }
                },
              ),
            );
          } else {
            return AspectRatio(
                aspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height * 0.90),
                child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[Loading()]));
          }
        });
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
            duration: Duration(milliseconds: 50),
            reverseDuration: Duration(milliseconds: 200),
            child: SizedBox.shrink()),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

class _VideoOverlay extends StatefulWidget {
  const _VideoOverlay({Key key, this.videoPost, this.user}) : super(key: key);

  final VideoPost videoPost;
  final UserModel user;
  @override
  __VideoOverlayState createState() => __VideoOverlayState();
}

class __VideoOverlayState extends State<_VideoOverlay> {
  Color likeColor;
  @override
  Widget build(BuildContext context) {
    double playerWidth = MediaQuery.of(context).size.width;
    double playerHeight = (MediaQuery.of(context).size.height * 0.90);

    return FutureBuilder(
        future: FirebaseService().getIsLikedAndNumLikes(widget.videoPost),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            bool isLiked = snapshot.data['isLiked'];
            print(isLiked);
            if (isLiked) {
              likeColor = Colors.red;
            } else {
              likeColor = Colors.white;
            }
            var numLikes = snapshot.data['numLikes'];
            return Container(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileScreen(widget.user)));
                            },
                            child: CircleAvatar(
                                backgroundColor: Colors.white70,
                                minRadius: 24.0,
                                child: CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: CachedNetworkImageProvider(
                                    widget.user.profilePictureUrl,
                                  ),
                                )),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(widget.user.handle,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                        ],
                      ),
                      Column(
                        //mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            shape: CircleBorder(),
                            onPressed: () async {
                              // setState(() {
                              //   isLiked = !isLiked;
                              // });
                              await FirebaseService()
                                  .likeUnlikeVideo(widget.videoPost);
                              setState(() {});
                              if (isLiked) {
                                print('Liked Video');
                              } else {
                                print('Unliked Video');
                              }
                            },
                            child: Icon(Icons.favorite,
                                color: likeColor, size: playerWidth * 0.08),
                          ),
                          Text("${numLikes.toString()}",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          MaterialButton(
                            shape: CircleBorder(),
                            onPressed: () {
                              print('1');
                            },
                            //height: playerHeight * 0.03,
                            child: Icon(Icons.share,
                                color: Colors.white, size: playerWidth * 0.08),
                          ),
                          //SizedBox(width: playerWidth * 0.05)
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(widget.videoPost.postDescription,
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
