import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = "USERIDKEY";
  static String nameKey = "NAMEKEY";
  static String handleKey = "HANDLEKEY";
  static String profilePictureKey = "PROFILEPICTUREKEY";

  //save data
  Future<bool> saveName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(nameKey, name);
  }

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveHadle(String getHandle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(handleKey, getHandle);
  }

  Future<bool> saveProfilePictureUrl(String getUserProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(profilePictureKey, getUserProfile);
  }

  //get data
  Future<String> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(nameKey);
  }

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String> getHandle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(handleKey);
  }

  Future<String> getProfilePictureUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(profilePictureKey);
  }
}
