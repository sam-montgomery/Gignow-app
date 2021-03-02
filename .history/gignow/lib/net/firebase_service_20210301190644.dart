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
    firestoreInstance.collection("Artists").doc(auth.currentUser.uid).set({
      "userUid": user.uid,
      "firstName": firstName,
      "lastName": lastName,
      "genres": genres
    });
  }

  Future getProfile(String uid) async {
    await firestoreInstance.collection("Artists").doc(uid).get().then((value) {
      return (value.data());
    });
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = firestoreInstance.collection('collectionName');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }

  FirebaseService();
}
