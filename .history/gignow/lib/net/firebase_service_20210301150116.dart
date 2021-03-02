import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final firebaseUser;
  final firestoreInstance = FirebaseFirestore.instance;

  void createArtistProfile(
      String firstName, String lastName, String phone, String genres) {
    firestoreInstance.collection("Artists").add({
      "userUid" : ,
      "firstName" : firstName,
      "lastName" : lastName,
      "genres" : genres
    });
  }

  FirebaseService({this.firebaseUser});
}

