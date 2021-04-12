class UserModel {
  String uid;
  String name;
  String genres;
  String phone;
  String handle;
  String profilePictureUrl;

  // User({this.uid, this.firstName, this.lastName, this.profilePictureUrl});
  UserModel(String uid, String name, String genres, String phone, String handle,
      String profilePicUrl) {
    this.uid = uid;
    this.name = name;
    this.genres = genres;
    this.phone = phone;
    this.handle = handle;
    this.profilePictureUrl = profilePicUrl;
  }
}

//name, phone, genres, profile_pic_url, handle
