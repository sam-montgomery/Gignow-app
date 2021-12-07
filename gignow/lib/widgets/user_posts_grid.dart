import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/loading.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// class UserPostGrid extends StatelessWidget {
// String userUid;
// UserPostGrid({this.userUid});
// @override
// Widget build(BuildContext context) {
//   return FutureBuilder(
//       future: FirebaseService().getUsersVideoPosts(userUid),
//       builder: (context, snapshot) {
//         if (snapshot.hasData &&
//             snapshot.connectionState == ConnectionState.done) {
//           List<VideoPost> posts = snapshot.data;
//           if (posts.isEmpty) {
//             return Padding(
//               padding: EdgeInsets.only(top: 150),
//               child: Text(
//                 "No Posts Yet",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.grey,
//                 ),
//               ),
//             );
//           } else {
//             return GridView.builder(
//                 itemCount: 20,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3),
//                 itemBuilder: (context, index) {
//                   VideoPost post = posts[index];
//                   return Text(post.postDescription);
//                 });
//           }
//           // itemBuilder: (context, index) {
//           //   return Padding(
//           //     padding: const EdgeInsets.all(2.0),
//           //     child: Container(color: Colors.deepPurple[100]),
//           //   );
//           // });
//         } else {
//           return Loading();
//         }
//       });
// }

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
                    return Image.network(post.thumbnailURL ??
                        "https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png");
                    // return FutureBuilder(
                    //     future: VideoThumbnail.thumbnailFile(
                    //         video: post.videoURL,
                    //         imageFormat: ImageFormat.JPEG),
                    //     builder: (context, snapshot) {
                    //       if (snapshot.hasData) {
                    //         var fileName = snapshot.data;
                    //         return Image.file(fileName);
                    //       } else {
                    //         return Text("No thumbnail");
                    //       }
                    //     });
                  });
            }
            // itemBuilder: (context, index) {
            //   return Padding(
            //     padding: const EdgeInsets.all(2.0),
            //     child: Container(color: Colors.deepPurple[100]),
            //   );
            // });
          } else {
            return Loading();
          }
        });
  }
}
