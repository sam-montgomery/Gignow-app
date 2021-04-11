import 'package:gignow/model/post.dart';

class VideoPost extends Post {
  String videoURL;

  VideoPost(String postID, String userUID, String postUserEmail,
      DateTime postDate, String postDescription, this.videoURL)
      : super(
            postID: postID,
            userUID: userUID,
            postUserEmail: postUserEmail,
            postDate: postDate,
            postDescription: postDescription);
}
