import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class UserModel {
  String uid;
  String name;
  String genres;
  String phone;
  String handle;
  String profilePictureUrl;
  Map<String, String> socials;
  bool venue;
  GeoPoint position;

  // User({this.uid, this.firstName, this.lastName, this.profilePictureUrl});
  UserModel(
      String uid,
      String name,
      String genres,
      String phone,
      String handle,
      String profilePicUrl,
      Map<String, String> socials,
      bool venue,
      GeoPoint position) {
    this.uid = uid;
    this.name = name;
    this.genres = genres;
    this.phone = phone;
    this.handle = handle;
    this.profilePictureUrl = profilePicUrl;
    this.socials = socials;
    this.venue = venue;
    this.position = position;
  }

  Map<String, dynamic> toJson() => {
        'userUid': uid,
        'name': name,
        'genres': genres,
        'phoneNumber': phone,
        'handle': handle,
        'profile_picture_url': profilePictureUrl,
        'socials': socials,
        'venue': venue,
        'position': position
      };

  UserModel.empty();
}

//name, phone, genres, profile_pic_url, handle
