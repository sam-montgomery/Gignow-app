import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final firestoreInstance = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void createArtistProfile(
      String firstName, String lastName, String phone, String genres) {
    final user = auth.currentUser;
    firestoreInstance.collection("Artists").add({
      "userUid": user.uid,
      "firstName": firstName,
      "lastName": lastName,
      "genres": genres
    });
  }

  Future getProfile(String uid)  {
        firestoreInstance.collection("users").doc(auth.currentUser.uid).get().then((value){
          print(value.data());
    });
      
    }
  }

  FirebaseService();
}
