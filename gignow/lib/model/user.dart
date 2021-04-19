class UserModel {
  String uid;
  String name;
  String genres;
  String phone;
  String handle;
  String profilePictureUrl;
  bool venue;

  // User({this.uid, this.firstName, this.lastName, this.profilePictureUrl});
  UserModel(String uid, String name, String genres, String phone, String handle,
      String profilePicUrl, bool venue) {
    this.uid = uid;
    this.name = name;
    this.genres = genres;
    this.phone = phone;
    this.handle = handle;
    this.profilePictureUrl = profilePicUrl;
    this.venue = venue;
  }
}

//name, phone, genres, profile_pic_url, handle
