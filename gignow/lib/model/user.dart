class UserModel {
  String uid;
  String name;
  String genres;
  String phone;
  String handle;
  String profilePictureUrl;
  Map<String, String> socials;
  bool venue;

  // User({this.uid, this.firstName, this.lastName, this.profilePictureUrl});
  UserModel(String uid, String name, String genres, String phone, String handle,
      String profilePicUrl, Map<String, String> socials, bool venue) {
    this.uid = uid;
    this.name = name;
    this.genres = genres;
    this.phone = phone;
    this.handle = handle;
    this.profilePictureUrl = profilePicUrl;
    this.socials = socials;
    this.venue = venue;
  }

  UserModel.empty();
}

//name, phone, genres, profile_pic_url, handle
