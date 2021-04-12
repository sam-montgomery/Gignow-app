import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String postID;
  String userUID;
  Timestamp postDate;
  String postDescription;

  Post({this.postID, this.userUID, this.postDate, this.postDescription});
}
