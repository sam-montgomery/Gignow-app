import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gignow/model/post.dart';

class ImagePost extends Post {
  String imageURL;

  ImagePost(String postID, String userUID, Timestamp postDate,
      String postDescription, this.imageURL)
      : super(
            postID: postID,
            userUID: userUID,
            postDate: postDate,
            postDescription: postDescription);
}
