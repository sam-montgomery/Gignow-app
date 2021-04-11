import 'package:flutter/material.dart';
import 'package:gignow/model/video_post.dart';

class VideoPostWidget extends StatelessWidget {
  VideoPost post;
  VideoPostWidget({this.post});
  @override
  Widget build(BuildContext context) {
    //https://medium.com/@shakleenishfar/leaf-flutter-social-media-app-part-4-creating-news-feed-using-listview-1ed2097df871
    return Card(
      child: Column(children: <Widget>[
        Expanded(
          flex: 3,
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Image.network(
                      "https://firebasestorage.googleapis.com/v0/b/gignow-402c6.appspot.com/o/profile_pictures%2Fprofile_picture_9nshq4G7ITZyNwge1O3Xc9xEE5K2?alt=media&token=2089c073-685e-4efc-af1f-fd945ffe8816")),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(post.postDate.toString()),
                    Text(post.postDescription),
                  ],
                ),
              )
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://firebasestorage.googleapis.com/v0/b/gignow-402c6.appspot.com/o/profile_pictures%2Fprofile_picture_${post.userUID}?alt=media&token=2089c073-685e-4efc-af1f-fd945ffe8816")),
            ),
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(post.postUserEmail),
                ],
              ),
            )
          ],
        )
      ]),
    );
  }
}

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
