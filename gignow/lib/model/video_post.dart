import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gignow/model/post.dart';

class VideoPost extends Post {
  String videoURL;
  String thumbnailURL;

  VideoPost(String postID, String userUID, Timestamp postDate,
      String postDescription, this.videoURL, this.thumbnailURL)
      : super(
            postID: postID,
            userUID: userUID,
            postDate: postDate,
            postDescription: postDescription);
}
