import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/ui/userProfile/profile_screen.dart';
import 'package:video_player/video_player.dart';

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

  VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(videoPost.videoURL);
    _controller.addListener(() {
      // setState(() {});
    });
    _controller.setLooping(true);
    // _controller.initialize().then((_) => setState(() {}));
    _controller.initialize();
    //_controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: MediaQuery.of(context).size.width /
          (MediaQuery.of(context).size.height * 0.90),
      //padding: const EdgeInsets.all(20),
      child: FutureBuilder(
        future: DefaultCacheManager().getSingleFile(videoPost.videoURL),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("Video Loaded from ${snapshot.data.toString()}");
            _controller = VideoPlayerController.file(snapshot.data);
            _controller.addListener(() {
              // setState(() {});
            });
            _controller.setLooping(true);
            _controller.initialize();
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                                            ProfileScreen(user)));
                              },
                              child: CircleAvatar(
                                  backgroundColor: Colors.white70,
                                  minRadius: 10.0,
                                  child: CircleAvatar(
                                    radius: 20.0,
                                    backgroundImage:
                                        NetworkImage(user.profilePictureUrl),
                                  )),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(user.handle,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text(videoPost.postDescription,
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          } else {
            return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[Loading()]));
          }
        },
      ),
    );
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
            child: SizedBox.shrink()
            // child: controller.value.isPlaying
            //     ? SizedBox.shrink()
            //     : Container(
            //         color: Colors.black26,
            //         child: Center(
            //           child: Icon(
            //             Icons.play_arrow,
            //             color: Colors.white,
            //             size: 100.0,
            //           ),
            //         ),
            //       ),
            ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: PopupMenuButton<double>(
        //     initialValue: controller.value.playbackSpeed,
        //     tooltip: 'Playback speed',
        //     onSelected: (speed) {
        //       controller.setPlaybackSpeed(speed);
        //     },
        //     itemBuilder: (context) {
        //       return [
        //         for (final speed in _examplePlaybackRates)
        //           PopupMenuItem(
        //             value: speed,
        //             child: Text('${speed}x'),
        //           )
        //       ];
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(
        //         // Using less vertical padding as the text is also longer
        //         // horizontally, so it feels like it would need more spacing
        //         // horizontally (matching the aspect ratio of the video).
        //         vertical: 12,
        //         horizontal: 16,
        //       ),
        //       child: Text('${controller.value.playbackSpeed}x'),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
