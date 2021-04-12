import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gignow/model/post.dart';

class VideoPost extends Post {
  String videoURL;

  VideoPost(String postID, String userUID, Timestamp postDate,
      String postDescription, this.videoURL)
      : super(
            postID: postID,
            userUID: userUID,
            postDate: postDate,
            postDescription: postDescription);
}
