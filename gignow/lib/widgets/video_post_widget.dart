import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/net/globals.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/ui/userProfile/profile_screen.dart';
import 'package:gignow/widgets/video_player_widget.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
//import 'package:cached_video_player/cached_video_player.dart';

class VideoPostWidget extends StatefulWidget {
  VideoPost post;
  VideoPostWidget(this.post);
  @override
  _VideoPostWidgetState createState() => _VideoPostWidgetState(post);
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  VideoPost post;
  _VideoPostWidgetState(this.post);
  Global global = Global();

  VideoPlayerController _controller;
  FirebaseService firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.network(post.videoURL);
    // _controller.addListener(() {
    //   // setState(() {});
    // });
    // _controller.setLooping(true);
    // // _controller.initialize().then((_) => setState(() {}));
    // _controller.initialize();
    //_controller.play();
  }

  @override
  Widget build(BuildContext context) {
    //VideoPost post = widget.post;

    return Container(
        decoration: new BoxDecoration(
          boxShadow: [
            new BoxShadow(
                color: Colors.black,
                blurRadius: 5.0,
                offset: Offset(0.0, 0.75)),
          ],
        ),
        child: FutureBuilder<UserModel>(
            future: firebaseService.getUser(post.userUID),
            builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
              if (snapshot.hasData) {
                UserModel user = snapshot.data;
                return Card(
                    key: ValueKey("VideoPost"),
                    color: Colors.grey[200],
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(40)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // SizedBox(
                          //   height: 20,
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Row(
                          //       //Profile Picture
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.spaceAround,
                          //       children: <Widget>[
                          //         GestureDetector(
                          //           onTap: () {
                          //             Navigator.push(
                          //                 context,
                          //                 MaterialPageRoute(
                          //                     builder: (context) =>
                          //                         ProfileScreen(user)));
                          //           },
                          //           child: CircleAvatar(
                          //             backgroundColor: Colors.white70,
                          //             minRadius: 10.0,
                          //             child: CircleAvatar(
                          //               radius: 20.0,
                          //               backgroundImage: NetworkImage(
                          //                   user.profilePictureUrl),
                          //             ),
                          //           ),
                          //         ),
                          //         SizedBox(
                          //           width: 5,
                          //         ),
                          //         Text(user.name),
                          //       ],
                          //     ),
                          //     Text(DateFormat("yyyy-MM-dd").format(
                          //         DateTime.fromMicrosecondsSinceEpoch(
                          //             post.postDate.microsecondsSinceEpoch)))
                          //   ],
                          // ),
                          // Divider(
                          //   thickness: 2,
                          // ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          // Text(
                          //   post.postDescription,
                          //   textAlign: TextAlign.start,
                          // ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          VideoPlayerWidget(post, user)
                          // Container(
                          //   padding: const EdgeInsets.all(20),
                          //   child: AspectRatio(
                          //     aspectRatio: _controller.value.aspectRatio,
                          //     child: Stack(
                          //       alignment: Alignment.bottomCenter,
                          //       children: <Widget>[
                          //         VideoPlayer(_controller),
                          //         _ControlsOverlay(controller: _controller),
                          //         VideoProgressIndicator(_controller,
                          //             allowScrubbing: true),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // Center(
                          //   child: Image(
                          //       width: MediaQuery.of(context).size.width * 0.65,
                          //       image: NetworkImage(
                          //           "https://image.smythstoys.com/original/desktop/159327.jpg")),
                          // )
                        ],
                      ),
                    ));
              } else {
                return Loading();
              }
            })

        // Card(
        //   color: Colors.grey[200],
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        //   child: Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: <Widget>[
        //         SizedBox(
        //           height: 20,
        //         ),
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Row(
        //               //Profile Picture
        //               mainAxisAlignment: MainAxisAlignment.spaceAround,
        //               children: <Widget>[
        //                 CircleAvatar(
        //                   backgroundColor: Colors.white70,
        //                   minRadius: 10.0,
        //                   child: CircleAvatar(
        //                     radius: 20.0,
        //                     backgroundImage: NetworkImage(
        //                         "https://firebasestorage.googleapis.com/v0/b/gignow-402c6.appspot.com/o/profile_pictures%2Fprofile_picture_86S6iBxF7CQW1nuWo4Wq7bdy4uR2?alt=media&token=277c5528-95f3-4c26-a10c-cd75d1287ffc"),
        //                   ),
        //                 ),
        //                 SizedBox(
        //                   width: 5,
        //                 ),
        //                 Text(post.postUserFullName),
        //               ],
        //             ),
        //             Text(DateFormat("yyyy-MM-dd").format(post.postDate))
        //           ],
        //         ),
        //         Divider(
        //           thickness: 2,
        //         ),
        //         SizedBox(
        //           height: 10,
        //         ),
        //         Text(
        //           post.postDescription,
        //           textAlign: TextAlign.start,
        //         ),
        //         SizedBox(
        //           height: 10,
        //         ),
        //         Container(
        //           padding: const EdgeInsets.all(20),
        //           child: AspectRatio(
        //             aspectRatio: _controller.value.aspectRatio,
        //             child: Stack(
        //               alignment: Alignment.bottomCenter,
        //               children: <Widget>[
        //                 VideoPlayer(_controller),
        //                 _ControlsOverlay(controller: _controller),
        //                 VideoProgressIndicator(_controller, allowScrubbing: true),
        //               ],
        //             ),
        //           ),
        //         ),
        //         // Center(
        //         //   child: Image(
        //         //       width: MediaQuery.of(context).size.width * 0.65,
        //         //       image: NetworkImage(
        //         //           "https://image.smythstoys.com/original/desktop/159327.jpg")),
        //         // )
        //       ],
        //     ),
        //   ),
        // ),
        );
  }
}

// class VideoPostWidg1et extends StatelessWidget {
//   VideoPost post;
//   VideoPostWidget(this.post);
//   @override
//   Widget build(BuildContext context) {
//     //https://medium.com/@shakleenishfar/leaf-flutter-social-media-app-part-4-creating-news-feed-using-listview-1ed2097df871

//     return Card(
//       color: Colors.grey[200],
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             SizedBox(
//               height: 20,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   //Profile Picture
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: <Widget>[
//                     CircleAvatar(
//                       backgroundColor: Colors.white70,
//                       minRadius: 10.0,
//                       child: CircleAvatar(
//                         radius: 20.0,
//                         backgroundImage: NetworkImage(
//                             "https://firebasestorage.googleapis.com/v0/b/gignow-402c6.appspot.com/o/profile_pictures%2Fprofile_picture_86S6iBxF7CQW1nuWo4Wq7bdy4uR2?alt=media&token=277c5528-95f3-4c26-a10c-cd75d1287ffc"),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(post.postUserFullName),
//                   ],
//                 ),
//                 Text(DateFormat("yyyy-MM-dd").format(post.postDate))
//               ],
//             ),
//             Divider(
//               thickness: 2,
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               post.postDescription,
//               textAlign: TextAlign.start,
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Center(
//               child: Image(
//                   width: MediaQuery.of(context).size.width * 0.65,
//                   image: NetworkImage(
//                       "https://image.smythstoys.com/original/desktop/159327.jpg")),
//             )
//           ],
//         ),
//       ),
//     );
//     return Card(
//       child: Column(children: <Widget>[
//         Expanded(
//           flex: 3,
//           child: Row(
//             children: <Widget>[
//               Expanded(
//                   flex: 2,
//                   child: Image.network(
//                       "https://firebasestorage.googleapis.com/v0/b/gignow-402c6.appspot.com/o/profile_pictures%2Fprofile_picture_9nshq4G7ITZyNwge1O3Xc9xEE5K2")),
//               Expanded(
//                 flex: 3,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     Text(post.postDate.toString()),
//                     Text(post.postDescription),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//         Row(
//           children: <Widget>[
//             Expanded(
//               flex: 1,
//               child: CircleAvatar(
//                   backgroundImage: NetworkImage(
//                       "https://firebasestorage.googleapis.com/v0/b/gignow-402c6.appspot.com/o/profile_pictures%2Fprofile_picture_${post.userUID}?alt=media&token=2089c073-685e-4efc-af1f-fd945ffe8816")),
//             ),
//             Expanded(
//               flex: 7,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(post.postUserEmail),
//                 ],
//               ),
//             )
//           ],
//         )
//       ]),
//     );
//   }
// }

// Future getVideo() async {
//     final pickedFile = await picker.getVideo(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       var now = DateTime.now();
//       String fileName = "video-" + now.toString();
//       firebase_storage.Reference firebaseStorageRef = firebase_storage
//           .FirebaseStorage.instance
//           .ref()
//           .child('videos/$fileName');
//       firebase_storage.UploadTask uploadTask =
//           firebaseStorageRef.putFile(File(pickedFile.path));
//       firebase_storage.TaskSnapshot taskSnapshot =
//           await uploadTask.whenComplete(() => null);
//       taskSnapshot.ref.getDownloadURL().then((value) {
//         print("Done: $value");
//       });
//     } else {
//       print('No video selected.');
//     }
//   }

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
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
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
